-module(kick_clients_emqx_plugin).

%% for #message{} record
%% no need for this include if we call emqx_message:to_map/1 to convert it to a map
-include_lib("emqx/include/emqx.hrl").
-include_lib("emqx/include/emqx_hooks.hrl").

%% for logging
-include_lib("emqx/include/logger.hrl").

-export([
    load/1,
    unload/0
]).

%% Client Lifecycle Hooks
-export([on_client_disconnected/4]).

%% Session Lifecycle Hooks
-export([on_session_terminated/4]).

%% Message Pubsub Hooks
-export([on_message_publish/2]).

%% Called when the plugin application start
load(Env) ->
    hook('client.disconnected', {?MODULE, on_client_disconnected, [Env]}),
    hook('session.terminated', {?MODULE, on_session_terminated, [Env]}),
    hook('message.publish', {?MODULE, on_message_publish, [Env]}).

%%--------------------------------------------------------------------
%% Client Lifecycle Hooks
%%--------------------------------------------------------------------

on_client_disconnected(ClientInfo = #{clientid := ClientId}, ReasonCode, ConnInfo, _Env) ->
    io:format(
        "Client(~s) disconnected due to ~p, ClientInfo:~n~p~n, ConnInfo:~n~p~n",
        [ClientId, ReasonCode, ClientInfo, ConnInfo]
    ).

on_session_terminated(_ClientInfo = #{clientid := ClientId}, Reason, SessInfo, _Env) ->
    io:format(
        "Session(~s) is terminated due to ~p~nSession Info: ~p~n",
        [ClientId, Reason, SessInfo]
    ).

on_message_publish(Message = #message{topic = <<"$SYS/", _/binary>>}, _Env) ->
    {ok, Message};
on_message_publish(Message = #message{topic = <<"kick/", ClientId/binary>>}, _Env) ->
    io:format("Kick client ~s~n", [ClientId]),
    emqx_cm:kick_session(ClientId),
    {ok, Message};
on_message_publish(Message, _Env) ->
    io:format("Publish ~p~n", [emqx_message:to_map(Message)]),
    {ok, Message}.

%% Called when the plugin application stop
unload() ->
    unhook('client.disconnected', {?MODULE, on_client_disconnected}),
    unhook('session.terminated', {?MODULE, on_session_terminated}),
    unhook('message.publish', {?MODULE, on_message_publish}).

hook(HookPoint, MFA) ->
    %% use highest hook priority so this module's callbacks
    %% are evaluated before the default hooks in EMQX
    emqx_hooks:add(HookPoint, MFA, _Property = ?HP_HIGHEST).

unhook(HookPoint, MFA) ->
    emqx_hooks:del(HookPoint, MFA).
