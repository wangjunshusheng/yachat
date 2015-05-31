-module(ws_main).
-include_lib("kvs/include/user.hrl").
-include_lib("web/include/logger.hrl").
-include_lib("web/include/db.hrl").

-export([init/4, stream/3, info/3, terminate/2]).
-export([clear_online_table/1]).

-record(state, {}).

init(_Transport, Req, Opts, _Active) ->
   ?INFO("init() pid:~p opts:~p active:~p ", [self(), Opts, _Active]),
   {ok, Req, #state{}}.

stream({text, <<"ping">>}, Req, State) ->
   {reply, jiffy:encode([<<"pong">>]), Req, State};

stream({text, JSON}, Req, State) ->
   [ Msg | Args ] = jiffy:decode(JSON),
   ?INFO("JSON MSG: ~p ARGS: ~p", [Msg, Args]),
   Raw = json_msg(Msg, Args),
   Reply = jiffy:encode(Raw),
   ?INFO("JSON REPLY: ~p", [Reply]),
   {reply, Reply, Req, State};

stream(Data, Req, State) ->
   ?INFO("message received ~p", [Data]),
   {ok, Req, State}.

info({msg, _Sender, Data}, Req, State) ->
   ?INFO("MSG: ~p", [Data]),
   {reply, Data, Req, State};

info({new_msg, ConvId, SenderId, Text}, Req, State) ->
   ?INFO("TEXT MSG: ~p ~p ~p", [ConvId, SenderId, Text]),
   Reply = jiffy:encode([new_msg, ConvId, SenderId, Text]),
   {reply, Reply, Req, State}.

terminate(_Req, State) ->
   ?INFO("terminate: pid:~p state: ~p", [self(), State]),
   user_offline(self()),
   ok.

% REAL PROTO HANDLER

get_user(Id) -> kvs:get(user, Id).
get_user_by_fb(Id) -> kvs:index(user, facebook_id, Id).
get_user_by_email(Id) -> kvs:index(user, email, Id).

make_uid() -> erlang:phash2( [now(), make_ref()], 4294967296 ).

clear_online_table([]) -> ok;
clear_online_table([#user_online{id=Id} | T]) -> kvs:delete(user_online, Id), clear_online_table(T).

user_online(#user{id=Uid}, Pid) ->
   case kvs:index(user_online, pid, Pid) of
      [] ->
         ?INFO("user_online: user_id=~p pid=~p", [Uid, Pid]),
         kvs:put(#user_online{id=kvs:next_id(user_online,1), stamp=now(), pid=Pid, user_id=Uid});
      [_ | _] ->
         ?INFO("user_online: already online, skip: user_id=~p pid=~p", [Uid, Pid])
   end.

drop_online_status([]) -> ok;

drop_online_status([#user_online{id=Id, pid=Pid} | R]) ->
   ?INFO("drop_online_status: id=~p pid=~p", [Id, Pid]),
   kvs:delete(user_online, Id),
   drop_online_status(R).

user_offline(Pid) ->
   R = kvs:index(user_online, pid, Pid),
   drop_online_status(R).

send_msg(Cid, UserId, Message) ->
   MsgId = db_conv:msg(Cid, UserId, Message),
   db_conv:conv_notify(Cid, UserId, Message),
   MsgId.

% check user existance by id
json_msg(M = <<"user">>, [Uid]) ->
   ?INFO("~s uid:~s", [M, Uid]),
   case get_user(Uid) of
      {ok, User} ->
         user_online(User, self()),
         [M, ok, User#user.id];
      _ ->
         [M, fail]
   end;

% check user existance by facebook id
json_msg(M = <<"user/fb">>, [FbId]) ->
   ?INFO("~s uid:~s", [M, FbId]),
   case get_user_by_fb(FbId) of
      {ok, User} ->
         [M, ok, User#user.id];
      _ ->
         [M, fail]
   end;

% check user email existance
json_msg(M = <<"user/email">>, [Email]) ->
   ?INFO("~s email:~s", [M, Email]),
   case get_user_by_email(Email) of
      {ok, #user{id=Uid}}              -> [M, ok, Uid];
      {error, not_found}               -> [M, fail];
      _                                -> [M, fail, protocol]
   end;

json_msg(M = <<"user/info">>, [Uid]) ->
   [M, ok, db_conv:user_detail(Uid)];

json_msg(M = <<"user/info">>, L) ->
   [M, ok, db_conv:users_detail(L)];

% create new user
json_msg(M = <<"user/new">>, []) ->
   ?INFO("~s new", [M]),
   NewUID = make_uid(),
   case kvs:put(U = #user{id=NewUID}) of
      ok    ->
         user_online(U, self()),
         [M, new, NewUID];
      _     -> [M, fail, protocol]
   end;

% login by email and password
json_msg(M = <<"login">>, [Email, Password]) ->
   ?INFO("~s email:~s password:~s", [M, Email, Password]),
   case kvs:index(user, email, Email) of
      {ok, #user{id=Uid, password=Password}}    -> [M, ok, Uid];
      {ok, _}                                   -> [M, fail, match];
      {error, not_found}                        -> [M, fail, match];
      _                                         -> [M, fail, protocol]
   end;

% update personal information
json_msg(M = <<"register">>, [Uid, Email, Password, Name, Gender]) ->
   ?INFO("~s uid:~s email:~s name:~s", [M, Uid, Email, Name]),
   case get_user(Uid) of
      {ok, User}  ->
         kvs:put(User#user{email=Email, password=Password, username=Name, sex=Gender}),
         [M, ok];
      _ ->
         [M, fail, uid]
   end;

% this comes from facebook auth
%  r.id, r.email, r.first_name, r.last_name, r.name, r.gender
json_msg(M = <<"facebook">>, [Uid, Id, Email, _, _, UserName, Gender]) ->
   ?INFO("~s uid:~s fb_id:~s email:~s name:~s", [M, Uid, Id, Email, UserName]),
   case get_user(Uid) of
      {ok, User}  ->
         kvs:put(User#user{email=Email, username=UserName, sex=Gender, facebook_id=Id}),
         [M, ok];
      _ ->
         [M, fail, uid]
   end;

% p2p message, create conv if not exists
json_msg(M = <<"msg/p2p">>, [UserId, PeerId, Message]) ->
   case db_conv:find_conv(UserId, PeerId, "p2p") of
      {ok, #conv{id=Cid}} ->
         MsgId = send_msg(Cid, UserId, Message),
         [M, ok, Cid, MsgId];
      _       ->
         Cid = db_conv:make_conv(UserId, PeerId, "p2p"),
         MsgId = send_msg(Cid, UserId, Message),
         [M, ok, Cid, MsgId]
   end;

% group message
json_msg(M = <<"msg/conv">>, [UserId, Cid, Message]) ->
   MsgId = send_msg(Cid, UserId, Message),
   [M, ok, Cid, MsgId];

% group list
json_msg(M = <<"conv/list">>, [UserId, ConvId]) ->
   List = db_conv:list(UserId, ConvId),
   Full = db_conv:users_detail(List),
   [M, ok, Full];

% stub in case of missing handlers
json_msg(Stub, Args) ->
	?INFO("stub msg:~s args:~p", [Stub, Args]),
	[stub, ok].
