-module(ws_conv).
-export([msg/2]).
-compile(export_all).
-include_lib("cmon/include/logger.hrl").
-include_lib("web/include/db.hrl").

% list users in conversation
conv_users(Uid, ConvId) when is_number(Uid) ->
   List = db_conv:users(ConvId),
   UserDetailList = db_user:detail_short(List),
   [ ok, UserDetailList ];
conv_users(_,_) -> [fail, args].

% message history
conv_history(SelfId, ConvId) when is_number(SelfId), is_number(ConvId) ->
   History = [ [db_user:detail_short(Uid), [cvt:now_to_time_binary(Stamp), Text]]
      || #message{stamp=Stamp,text=Text,user_id=Uid} <- db_conv:history(ConvId) ],
   [ok, History];
conv_history(_,_) -> [fail, agrs].

% new conversation
conv_new(Uid) when is_number(Uid) ->
   ConvId = db_conv:generic(Uid),
   [ok, ConvId];
conv_new(_) -> [fail, args].

% join conversation
conv_join(Uid, ConvId) when is_number(Uid) -> db_conv:join(Uid, ConvId), [ok, ConvId];
conv_join(_,_) -> [fail, args].

% leave conversation
conv_leave(Uid, ConvId) when is_number(Uid) -> db_conv:leave(Uid, ConvId), [ok];
conv_leave(_,_) -> [fail, args].

%
% MESSAGES
%

%msg group list
msg(M = <<"conv/users">>, [Uid, ConvId]) when is_number(Uid), is_number(ConvId) ->
   R = [M] ++ conv_users(Uid, ConvId),
   ?INFO("R: ~p", [R]),
   R;

%msg message history
msg(M = <<"conv/history">>, [Uid, ConvId]) when is_number(Uid), is_number(ConvId)  ->
   [M] ++ conv_history(Uid, ConvId);

%msg create group
msg(M = <<"conv/new">>, [Uid]) when is_number(Uid) ->
   [M] ++ conv_new(Uid);

%msg join group
msg(M = <<"conv/join">>, [Uid, ConvId]) when is_number(Uid), is_number(ConvId) ->
   [M] ++ conv_join(Uid, ConvId);

%msg leave group
msg(M = <<"conv/leave">>, [Uid, ConvId]) when is_number(Uid), is_number(ConvId)  ->
   [M] ++ conv_leave(Uid, ConvId);

msg(_,_) -> skip.
