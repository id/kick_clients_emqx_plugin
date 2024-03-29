-module(kick_clients_emqx_plugin_app).

-behaviour(application).

-emqx_plugin(?MODULE).

-export([
    start/2,
    stop/1
]).

start(_StartType, _StartArgs) ->
    {ok, Sup} = kick_clients_emqx_plugin_sup:start_link(),
    kick_clients_emqx_plugin:load(application:get_all_env()),

    emqx_ctl:register_command(kick_clients_emqx_plugin, {kick_clients_emqx_plugin_cli, cmd}),
    {ok, Sup}.

stop(_State) ->
    emqx_ctl:unregister_command(kick_clients_emqx_plugin),
    kick_clients_emqx_plugin:unload().
