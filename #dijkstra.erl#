-module(dijkstra).
-export([table/2,route/2,update/4, iterate/3]).

entry(Node, SortedList) ->
    case lists:keyfind(Node, 1, SortedList) of
	false -> 0;
	{_, Length,_} ->
	    Length
end.

replace(Node, N, Gate, SortedList) ->
    case lists:keyfind(Node, 1, SortedList) of
	false -> "no such element";
	{_,_,_} ->
	    SortedListRem = lists:keydelete(Node, 1, SortedList),
	    NewEntry = {Node, N, Gate},
	    lists:keysort(2,[NewEntry|SortedListRem])
end.

update(Node, N, Gate, SortedList)->
    L = entry(Node, SortedList),
    if
	L>N ->
	    replace(Node, N, Gate, SortedList);
	true -> SortedList
end.

iterate(SortedList, Map,Table) ->
    case SortedList of
	[] ->
	    Table;
	 [{_, inf, _} | _ ] -> 
	    Table;
	[Head | Tail] -> 
	    {TownNode, Length, Gate} = Head,
	    case lists:keyfind(TownNode,1,Map) of
	       %For every town in reachables, try creating a new path from TownNode->Reachable, increment the length +1 compared to Gate -> TownNode, Accum starts as tail
	       {_, Reachables} -> 
		   UpdatedSorted = lists:foldl(fun(Reachable,Accum) ->
		       update(Reachable,Length+1,Gate,Accum) end, Tail, Reachables),
		    iterate(UpdatedSorted, Map, [{TownNode, Gate} | Table]);

		false  -> iterate(Tail,Map,[{TownNode, Gate} | Table])
		    
	    end
end.
		   

table(Gateways, Map) ->
    AllNodes = map:all_nodes(Map),
    List = lists:map(fun(Node) ->
			     case lists:member(Node, Gateways) of
				 true ->
				     {Node, 0, Node};
				 false ->
				     {Node, inf, unknown}
			     end
		     end, AllNodes),
    SortedList = lists:keysort(2,List),
    iterate(SortedList,Map,[]).
    


route(Node, Table) ->
     case lists:keyfind(Node,1,Table) of
	 {Node, Gateway} -> {ok, Gateway};
	 false  -> notfound
end.   
