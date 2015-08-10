-module(ws_todo).
-export([msg/2,to_props/1]).
-include_lib("cmon/include/logger.hrl").
-include_lib("web/include/db.hrl").
-compile({no_auto_import,[get/1,put/2]}).
-import(db_todo, [put/2, get/1, get/2, get_item/1, add/2, del/2, del/1]).

jiffy_wrapper(List) -> [ {Item} || Item <- List ].

to_props_with_items([H = #todo{id=Tid} | T]) ->
	Items = db_todo:get_items(Tid),
	Props = db_todo:to_proplist(H),
	[{Props ++ [{items, jiffy_wrapper(db_todo:to_proplist(Items))}]}] ++ to_props_with_items(T);
to_props_with_items([]) -> [].

to_props([H = #todo{id=Tid} | T]) ->
	Props = db_todo:to_proplist(H),
	[{Props}] ++ to_props(T);
to_props([]) -> [].

%msg create or update todo list
msg(M = <<"todo/update">>, [Uid, Form]) ->
	Plist = db_func:form_to_plist(Form),
	Todo = db_todo:from_proplist(Plist),
	[M] ++ [put(Uid, Todo)];

%msg get all todo lists for user
msg(M = <<"todo/get">>, [Uid]) ->
	[M] ++ [to_props_with_items(get(Uid))];

msg(M = <<"todo/list">>, [Uid]) ->
	[M] ++ [to_props(get(Uid))];

%msg get todo list by id
msg(M = <<"todo/get">>, [Uid, Tid]) ->
	[M] ++ [to_props(get(Uid, Tid))];

%msg add item to todo list
msg(M = <<"todo/add">>, [Uid, Tid, Text]) ->
	[M] ++ [add(get(Uid, Tid), Text)];

%msg add item to todo list
msg(M = <<"todo/add">>, [Uid, Text]) ->
	[M] ++ [add(db_todo:get_default(Uid), Text)];

%msg del or move item from todo list
msg(M = <<"todo/del">>, [Uid, Tid]) ->
	[M] ++ [del(get(Uid, Tid))];

%msg del or move item from todo list
msg(M = <<"todo/del">>, [Uid, Tid, ItemId]) ->
	[M] ++ [del(get(Uid, Tid), get_item(ItemId))];

msg(_,_) -> skip.