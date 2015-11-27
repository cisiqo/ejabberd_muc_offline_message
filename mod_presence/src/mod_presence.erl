%%%----------------------------------------------------------------------

%%% File    : mod_offline_post.erl
%%% Author  : Adam Duke <adam.v.duke@gmail.com>
%%% Purpose : Forward offline messages to an arbitrary url
%%% Created : 12 Feb 2012 by Adam Duke <adam.v.duke@gmail.com>
%%%
%%%
%%% Copyright (C) 2012   Adam Duke
%%%
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License as
%%% published by the Free Software Foundation; either version 2 of the
%%% License, or (at your option) any later version.
%%%
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%%% General Public License for more details.
%%%
%%% You should have received a copy of the GNU General Public License
%%% along with this program; if not, write to the Free Software
%%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
%%% 02111-1307 USA
%%%
%%%----------------------------------------------------------------------

-module(mod_presence).
-author('csq1124@gmail.com').

-behavior(gen_mod).

-export([start/2,
	 stop/1,
	 set_presence/4,
     unset_presence/4,
     post_data/4]).

-define(PROCNAME, ?MODULE).

-include("ejabberd.hrl").
-include("logger.hrl").
-include("jlib.hrl").
-include("ejabberd_http.hrl").
-include("ejabberd_ctl.hrl").

start(Host, _Opts) ->
    inets:start(),
    ssl:start(),
    ejabberd_hooks:add(set_presence_hook, Host, ?MODULE, set_presence, 50),
    ejabberd_hooks:add(unset_presence_hook, Host, ?MODULE, unset_presence, 50),
    flush_data(Host),
    ok.

stop(Host) ->
    % ?DEBUG("Stopping mod_presence", [] ),
    ejabberd_hooks:delete(set_presence_hook, Host,
			  ?MODULE, set_presence, 50),
    ejabberd_hooks:delete(unset_presence_hook, Host,
              ?MODULE, unset_presence, 50),
    ok.

set_presence(User, Server, Resource, Packet) ->
    {xmlel, <<"presence">>, _, Pbody} = Packet,
    case Pbody of 
      [{xmlel, _, _, Xmlcdata}] ->
        [{xmlel, _, _, Xmlcdata}] = Pbody,
        case Xmlcdata of
          [{xmlcdata,Data}] ->
              [{xmlcdata,Data}] = Xmlcdata,
              Status = binary_to_list(Data);
          [] ->
            Status = binary_to_list(<<"chat">>)
        end;
      [] ->
        Status = binary_to_list(<<"chat">>)
    end,
    post_data(User,Status,Resource,Server).

unset_presence(User, Server, Resource, _) ->
    St = binary_to_list(<<"offline">>),
    post_data(User,St,Resource,Server).

post_data(Jid, Status,Resource, Server) ->
    Token = gen_mod:get_module_opt(Server, ?MODULE, auth_token, fun(S) -> iolist_to_binary(S) end, list_to_binary("")),
    PostUrl = gen_mod:get_module_opt(Server, ?MODULE, post_url, fun(S) -> iolist_to_binary(S) end, list_to_binary("")),
	Sep = "&",
    Post = [
      "jid=", Jid, Sep,
      "status=", Status, Sep,
      "resource=", Resource, Sep,
      "access_token=", Token],
    httpc:request(post, {binary_to_list(PostUrl), [], "application/x-www-form-urlencoded", list_to_binary(Post)},[],[]),
    ok.

flush_data(Host) ->
    PostUrl = gen_mod:get_module_opt(Host, ?MODULE, post_url, fun(S) -> iolist_to_binary(S) end, list_to_binary("")),
    Token = "JW_flush_presence_data",
    Post = [
      "access_token=", Token],
    httpc:request(post, {binary_to_list(PostUrl), [], "application/x-www-form-urlencoded", list_to_binary(Post)},[],[]),
    ok.



