-module(interf).
-export([new/0,add/4,remove/2,lookup/2,ref/2,name/2,list/1,broadcast/2]).

new() ->
    [].
add(Name, Ref, Pid, Intf) ->
    case lists:member({Name,Ref,Pid}, Intf) of
	true ->
	    Intf;
	false ->
	    [{Name,Ref,Pid}|Intf]
end.
remove(Name, Intf) ->
    lists:keydelete(Name,1,Intf).
lookup(Name,Intf) ->
    case lists:keyfind(Name,1,Intf) of
	{_,_,Pid} -> {ok, Pid};
	false -> notfound
end.
ref(Name, Intf) ->
    case lists:keyfind(Name,1,Intf) of
	false -> notfound;
	{Name,Ref,_} -> {ok, Ref}
end.
name(Ref, Intf) ->
    case lists:keyfind(Ref,2,Intf) of
	false -> notfound;
	{Name,Ref,_} -> {ok, Name}
end.
list(Intf) ->
    lists:map(fun({Name,_,_}) -> Name end, Intf).
broadcast(Message, Intf)->
    lists:map(fun({_,_,P}) -> P ! Message end, Intf).
%broadcast(Message, Nodes) ->
%    lists:foreach(fun({_,_,Pid}) -> Pid ! Message end,Nodes).
%% broadcast(Message, Nodes,master) ->
%%     lists:foreach(fun({Pid,_}) -> Pid ! Message end,Nodes).
%% broadcast(Message1, Message2, Pid, Nodes,master) ->
%%     Pid ! Message1,
%%     lists:foreach(fun({Pidd,_}) -> Pidd ! Message2 end,Nodes).
    
    
    

%broadcast(Message, From, Node ,Map ,Intf) ->
 %       lists:foreach(fun({_,_,Pid}) -> Pid ! {Message, From, Map, Node} end,Intf).
