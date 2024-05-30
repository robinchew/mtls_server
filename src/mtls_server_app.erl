-module(mtls_server_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
  Dispatch = cowboy_router:compile([
    {'_', [{"/", req_handler, []}]}
  ]),
  {ok, _} = cowboy:start_tls(https_server,
    [
     {port, 8080},
     {verify,verify_peer},
     {cacertfile,"/home/digby/git/mtls_server/certs/root.crt"},
     {certfile,"/home/digby/git/mtls_server/certs/server.crt"},
     {keyfile,"/home/digby/git/mtls_server/certs/server.key"},
     %{fail_if_no_peer_cert, false}, % uncomment to allow client to view without a valid cert
     %{password,"test"}, % use an environment variable for this when a password is on the key file
     {depth,2}
    ],
    #{env => #{dispatch => Dispatch}}
  ),
	mtls_server_sup:start_link().

stop(_State) ->
	ok.
