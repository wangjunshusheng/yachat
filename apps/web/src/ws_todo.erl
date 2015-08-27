-module(ws_todo).
-export([msg/2,to_props/2,to_props_with_items/2]).
-include_lib("cmon/include/logger.hrl").
-include_lib("web/include/db.hrl").
-compile({no_auto_import,[get/1,put/2]}).
-import(db_todo, [put/2, get/1, get/2, get_item/1, add/2, click/2, del/1]).

to_props_with_items([Tag], [H = #todo{id=Tid} | T]) ->
	Items = db_todo:get_items(Tid),
	Props = db_todo:add_tags_prop(db_todo:to_proplist(H)),
	[{Props
		++ [{default, db_util:to_bool(db_todo:check_default(Tid, Tag))}]
		++ [{items, db_util:jiffy_wrapper(db_todo:to_proplist(Items))}]
	}] ++ to_props_with_items([Tag], T);

to_props_with_items([], T) -> to_props_with_items([<<"">>], T);

to_props_with_items(_Tag, []) -> [].

to_props([Tag], [H = #todo{id=Tid} | T]) ->
	Props = db_todo:add_tags_prop(db_todo:to_proplist(H))
		++ [{default, db_util:to_bool(db_todo:check_default(Tid, Tag))}]
		++ [{current_tag, Tag}],
	[{Props}] ++ to_props([Tag], T);

to_props([], T) -> to_props([<<"">>], T);

to_props(_Tag, []) -> [].

%msg create or update todo list
msg(M = <<"todo/update">>, [Uid, Form]) ->
	Plist = db_func:form_to_plist(Form),
	Todo = db_todo:from_proplist(Plist),
	Tags = proplists:get_value(tags, Plist),
	Tid = put(Uid, Todo),
	db_todo:update_tags(Tid, Tags),
	[M, Tid];

%msg get all todo lists with items for user
msg(M = <<"todo/get">>, [Uid, Sid]) ->
	Tag = db_session:get(Sid, tag),
	[M] ++ [to_props_with_items(Tag, db_todo:get_by_tag(Uid, Tag))];

% get all todo lists without items for user
msg(M = <<"todo/list">>, [Uid, Sid]) ->
	Tag = db_session:get(Sid, tag),
	[M] ++ [to_props(Tag, db_todo:get_by_tag(Uid, Tag))]
		++ [to_props(Tag, db_todo:get_default(Uid, Tag))];

%msg get todo list by id
msg(M = <<"todo/load">>, [Uid, Sid, Tid]) ->
	Tag = db_session:get(Sid, tag),
	[M] ++ [to_props(Tag, get(Uid, Tid))];

%msg add item to default todo list
msg(M = <<"todo/add">>, [Uid, Sid, Text]) ->
	Tag = db_session:get(Sid, tag),
	[M] ++ [add(db_todo:get_default(Uid, Tag), Text)];


%msg get default todo list (check we can write)
msg(M = <<"todo/default">>, [Uid, Sid]) ->
	Tag = db_session:get(Sid, tag),
	[M] ++ [to_props(Tag, db_todo:get_default(Uid, Tag))];

msg(M = <<"todo/default">>, [Uid, Sid, Tid, State]) ->
	Tag = db_session:get(Sid, tag),
	db_todo:clear_default(Uid, Tag),
	db_todo:set_tag(Tid, Tag, State),
	[M, ok];

msg(M = <<"todo/move_to">>, [Uid, Tid, MoveTo]) ->
	[T] = get(Uid, Tid),
	[M] ++ [db_todo:put(Uid, T#todo{move_to=MoveTo})];

%msg del todo list
msg(M = <<"todo/del">>, [Uid, Tid]) ->
	[M] ++ [del(get(Uid, Tid))];

%msg del or move item from todo list
msg(M = <<"todo/click">>, [Uid, Tid, ItemId]) ->
	[M] ++ [click(get(Uid, Tid), get_item(ItemId))];

msg(_,_) -> skip.