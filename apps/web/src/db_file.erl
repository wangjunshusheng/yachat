-module(db_file).
-compile({no_auto_import,[put/1,get/1]}).
-compile(export_all).
-include_lib("db/include/metainfo.hrl").
-include_lib("web/include/db.hrl").
-include_lib("stdlib/include/qlc.hrl").
-include_lib("cmon/include/logger.hrl").

% id of convs user is in
by_type(Uid, Type) ->
	Q = qlc:q([ {Type, C#user_file.id} || C <- mnesia:table(user_file),
      C#user_file.user_id == Uid,
      C#user_file.type == Type
   ]),
	dbd:do(Q).

get(Id) -> dbd:get(user_file, Id).
