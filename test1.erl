-module(test1).
-export([run/1]).

run(ShortName) ->
    %% Routers:
    routy:start(malmo),
    
    routy:start(stockholm),
    
    routy:start(goteborg),

    routy:start(lulea),
    
%% Interfaces:
    malmo ! {add, stockholm, {stockholm, ShortName}},
    
    stockholm ! {add, malmo, {malmo, ShortName}},
    
    stockholm ! {add, goteborg, {goteborg,  ShortName}},
    
    goteborg ! {add, stockholm, {stockholm,  ShortName}},

    malmo ! {add, lulea, {lulea, ShortName}},

    lulea ! {add, stockholm, {stockholm, ShortName}},

    
%% Broadcast link-state message to all neighbours -> new map.
    malmo ! broadcast,
    
    stockholm ! broadcast,
    
    goteborg ! broadcast,

    lulea ! broadcast,
    
    timer:sleep(200),

%% dijkstra -> udpate routing tables
    stockholm ! update,
    
    malmo ! update,
    
    goteborg ! update,

    lulea ! update,
    
%% State:
    malmo ! {status,self()},
    
    stockholm ! {status,self()},
    
    goteborg ! {status,self()},

    lulea ! {status,self()},
    
%% Send and route:
    malmo ! {send, goteborg, "hello"},

    timer:sleep(200),
    
    goteborg ! {send, malmo, "hello"},
    
    timer:sleep(200),

    stockholm ! {send, lulea, "hello"},

    timer:sleep(1000),
    
    malmo ! stop,
    stockholm ! stop,
    lulea ! stop,
    goteborg ! stop.
    
