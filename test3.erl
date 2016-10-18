-module(test3).
-export([run/1]).

run(ShortName) ->
    %% Routers:
    routy:start(malmo),
    
    routy:start(stockholm),
    
    routy:start(goteborg),

    routy:start(lulea),
    
    routy:start(sundsvall),
    
    routy:start(arjeplog),
    
    routy:start(kiruna),
    


    
%% Interfaces:
    malmo ! {add, goteborg, {goteborg, ShortName}},

    stockholm ! {add, goteborg, {goteborg, ShortName}},

    stockholm ! {add, malmo, {malmo, ShortName}},

    goteborg ! {add, lulea, {lulea, ShortName}},

    lulea ! {add, sundsvall, {sundsvall, ShortName}},

    sundsvall ! {add, arjeplog, {arjeplog, ShortName}},

    arjeplog ! {add, kiruna, {kiruna, ShortName}},

    arjeplog ! {add, stockholm, {stockholm, ShortName}},

    kiruna ! {add, stockholm, {stockholm, ShortName}},
    
%% Broadcast link-state message to all neighbours -> new map.
    malmo ! broadcast,
    
    stockholm ! broadcast,
    
    goteborg ! broadcast,

    lulea ! broadcast,

    sundsvall ! broadcast,

    arjeplog ! broadcast,

    kiruna ! broadcast,

    
    timer:sleep(300),

%% dijkstra -> udpate routing tables
    stockholm ! update,
    
    malmo ! update,
    
    goteborg ! update,

    lulea ! update,

    sundsvall ! update,

    arjeplog ! update,

    kiruna ! update,

    
    timer:sleep(200),
    
%% State:
    malmo ! {status,self()},
    
    stockholm ! {status,self()},
    
    goteborg ! {status,self()},

    
%% Send and route:
    malmo ! {send, stockholm, "hello"},

    timer:sleep(200),

    timer:sleep(1000),
    
    malmo ! stop,
    stockholm ! stop,
    goteborg ! stop,
    lulea ! stop,
    sundsvall ! stop,
    arjeplog ! stop,
    kiruna ! stop.
    
