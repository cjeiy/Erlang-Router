-module(hist).
-export([new/1, update/3]).

new(Name) ->
    [{Name,inf}].
update(Node, N, History) ->
    case lists:keysearch(Node,1,History) of
	{value,{_,MessageId}}->
	   % io:format("New: ~w , Old: ~w~n", [N,MessageId]),
	    if
		N > MessageId -> {new, [{Node,N} | lists:keydelete(Node, 1, History)]};
		true  -> old
	    end;
	false ->
	    {new, [{Node,N} | lists:keydelete(Node, 1, History)]}
end.
		    
