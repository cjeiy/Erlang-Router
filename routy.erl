-module(routy).
-export([start/1,stop/1, start_master_node/0]).

start_master_node() ->
    register(master, spawn(fun()-> init_master(master) end)).

start(Name) ->
    register(Name, spawn(fun()->
				init(Name) end)).
stop(Node) ->
    Node ! stop,
    unregister(Node).

init(Name) ->
    Intf = interf:new(),
    Map = map:new(),
    Table = dijkstra:table(Intf, Map),
    Hist = hist:new(Name),
    case whereis(master) of
	undefined -> router(Name, 0, Hist, Intf, Table, Map);
	true ->  master ! {create_node, self(), Name},
		 router(Name, 0, Hist, Intf, Table, Map)end.


init_master(Name) ->
    Map = map:new(),
    Nodes = [],
    router_master(Name, Map, Nodes).

router_master(Name, Map, Nodes) ->
    receive

	broad_and_update ->
	    lists:foreach(fun({Pidd,_}) -> interf:broadcast(broadcast,update,Pidd,Nodes,master) end,Nodes),
	    
	    lists:foreach(fun({Pidd,_}) -> interf:broadcast(broadcast,update,Pidd,Nodes,master) end,lists:reverse(Nodes)),
	    
	    lists:foreach(fun({Pidd,_}) -> interf:broadcast(broadcast,update,Pidd,Nodes,master) end,Nodes),
	    
	    router_master(Name, Map, Nodes);
	{create_node, NodeRef, NodeName} ->
	    NewNodes = Nodes ++ [{NodeName,NodeRef}],
	    NodeRef ! self(),
	    router_master(Name, Map, NewNodes);
	    
	{update_map, NewMap} ->
	    OnlyMap = lists:filter(fun ({X,_}) -> 
					   not lists:member(X, lists:map(fun ({V, _}) -> V end, NewMap)) end, Map),
	    
	    Re = lists:map(fun({Namee,Links})-> 
				   case lists:keyfind(Namee,1,Map) of
				       {Namee,L} -> 
					   {Namee,lists:usort(L++Links)};
				       false -> 
					   {Namee, lists:usort(Links)}
				   end
			   end,NewMap),
	    
	    Map1 = lists:append(Re,OnlyMap),
	    lists:foreach(fun({_,Pid}) -> Pid ! {updated_map, Map1} end,Nodes),		    
	    router_master(Name,Map1,Nodes)
end.
						 
	    




router(Name, N, Hist, Intf, Table, Map) ->
    receive
	{add, Node, Pid} ->
	    Ref = erlang:monitor(process, Pid),
	    Intf1 = interf:add(Node,Ref, Pid, Intf),
	    %Map1 = case lists:keyfind(Name,1,Map) of
%		       {Name, Links} -> map:update(Name,lists:append(Links,[Node]),Map);
%		       false -> map:update(Name,[Node], Map) end,
%	    Table1 = dijkstra:table(Intf1,Map1),
	   
%	    self() ! broadcast,
%	    Pid ! update,
	    router(Name,N,Hist,Intf1,Table,Map);
	{remove, Node} ->
	    {ok, Ref} = interf:ref(Node, Intf),
	    erlang:demonitor(Ref),
	    Intf1 = interf:remove(Node, Intf),
	    router(Name,N,Hist,Intf1,Table,Map);
	{'DOWN', Ref, process,_,_} ->
	    {ok, Down} = interf:name(Ref, Intf),
	    io:format("~w: exit recieved from ~w~n",[Name, Down]),
	    Intf1 = interf:remove(Down, Intf),
	    router(Name, N, Hist, Intf1, Table, Map);
	{status, From} ->
	    From ! {status, {Name, N, Hist, Intf, Table, Map}},
	    io:format("Name: ~w~n Hist: ~w~n Intf: ~w~n Table: ~w~n Map: ~w~n",[Name, Hist, Intf, Table, Map]),
	    router(Name, N, Hist, Intf, Table, Map);
	{links, Node, R, Links} ->
	    case hist:update(Node, R, Hist) of
		{new, Hist1} ->
		    interf:broadcast({links, Node, R, Links}, Intf),
		    Map1 = map:update(Node, Links, Map),
		    router(Name, N, Hist1, Intf, Table, Map1);
		old ->
		    io:format("OLD From ~w to ~w ~n",[Node, Name]),
		    router(Name, N, Hist, Intf, Table, Map)
	    end;
	{route, Name, From, Message} ->
	    io:format("~w: received message (~s) from ~w ~n~n", [Name, Message, From]),
	    router(Name, N, Hist, Intf, Table, Map);
	{route, To, From, Message} ->
	    io:format("~w: routing message (~s) to ~w~n" , [Name, Message, To]),
	    case dijkstra:route(To, Table) of
		{ok, Gw} ->
		    case interf:lookup(Gw, Intf) of
			{ok, Pid} ->
			    %io:format("~w Passing along to: ~w~n", [Name,Gw]),
			    Pid ! {route, To, From, Message};
			notfound ->
			    io:format("not found!!", [])
		    end;
		notfound ->
		    ok
	    end,
	    router(Name, N, Hist, Intf, Table, Map);
	{send, To, Message} ->
	    self() ! {route, To, Name, Message},
	    router(Name, N, Hist, Intf, Table, Map);	    
	update ->
	   % case whereis(master) of
	%	undefined -> 	    
		    Table1 = dijkstra:table(interf:list(Intf), Map),
		    %io:format("Current interface: ~n~w", [Intf]),
		    router(Name, N, Hist, Intf, Table1, Map);
	%	true ->
	%	    interf:broadcast(update_map,Map),
	%	    Table1 = dijkstra:table(interf:list(Intf), Map),
	%	    io:format("Current interface: ~n~w", [Intf]),
	%	    router(Name, N, Hist, Intf, Table1, Map)
	 %   end;



 
       {updated_map, Map1} ->
		    OnlyMap = lists:filter(fun ({X,_}) -> 
						   not lists:member(X, lists:map(fun ({V, _}) -> V end, Map)) end, Map1),

		    Re = lists:map(fun({Namee,Links})-> 
					   case lists:keyfind(Namee,1,Map1) of
					       {Namee,L} -> 
						   {Namee,lists:usort(L++Links)};
					       false -> 
						   {Namee, lists:usort(Links)}
					   end
				   end,Map),

		    Map2 = lists:append(Re,OnlyMap),
	    Table1 = dijkstra:table(interf:list(Intf), Map),
	    router(Name, N, Hist, Intf, Table1, Map2);



		
	broadcast ->
	    Message = {links, Name, N, interf:list(Intf)},
	    interf:broadcast(Message, Intf),
%	    interf:broadcast(mapupdate, self(), name, Map, Intf),	    
	   % interf:broadcast(update, Intf),

	    router(Name, N+1, Hist, Intf, Table, Map);
%	{mapupdate, From, Map, Node, Intf} ->
%	    
%	    router(Name, N, Hist, Intf1, Table, Map);


	    
	stop ->
	    ok
end.
