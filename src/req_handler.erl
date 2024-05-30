-module(req_handler).
-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
    % erlang:display(Req0),
    % #{cert := Cert} = Req0,
    Req = cowboy_req:reply(200,
        #{<<"content-type">> => <<"text/plain">>},
        <<"SSL Connection Succeeded!">>,
        Req0),
    {ok, Req, State}.
