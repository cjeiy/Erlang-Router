-module(test2).
-export([run/1]).

run(ShortName) ->
    %% Routers:
    routy:start(malmo),
    
    routy:start(stockholm),
    
    routy:start(goteborg),

    
%% Interfaces:
    malmo ! {add, stockholm, {stockholm, ShortName}},

    stockholm ! {add, goteborg, {goteborg, ShortName}},

    goteborg ! {add, malmo, {malmo, ShortName}},


    
%% Broadcast link-state message to all neighbours -> new map.
    malmo ! broadcast,
    
    stockholm ! broadcast,
    
    goteborg ! broadcast,
    
    timer:sleep(300),

%% dijkstra -> udpate routing tables
    stockholm ! update,
    
    malmo ! update,
    
    goteborg ! update,
    
    timer:sleep(200),

    erlang:send_after(500, malmo, broadcast),

    malmo ! broadcast,

    timer:sleep(1000),
    
%% State:
    malmo ! {status,self()},
    
    stockholm ! {status,self()},
    
    goteborg ! {status,self()},

    
%% Send and route:
    malmo ! {send, goteborg, "hello"},

    timer:sleep(200),

    timer:sleep(1000),
    
    malmo ! stop,
    stockholm ! stop,
    goteborg ! stop.
    
