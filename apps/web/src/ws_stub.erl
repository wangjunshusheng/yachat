-module(ws_stub).
-export([msg/2]).
-include_lib("cmon/include/logger.hrl").
-include_lib("web/include/db.hrl").

msg(M = <<"ping">>, []) -> M;

% catch-all
msg(Stub, Args) ->
	?INFO("stub msg:~s args:~p", [Stub, Args]),
	[stub, ok, Stub].