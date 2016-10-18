-module(map).
-export([new/0,update/3,reachable/2,all_nodes/1]).

new() ->
    [].

update(Node, Links, Map) ->
    MapRemOld = lists:keydelete(Node, 1, Map),
    [{Node, Links} | MapRemOld ].

reachable(Node, Map)->
    case lists:keyfind(Node, 1, Map) of
	false -> [];
	{_, ReachableList} -> ReachableList
    end.

all_nodes(Map) ->
     lists:usort(lists:flatmap(fun({Node, Links}) -> [Node | Links] end, Map)).
    
