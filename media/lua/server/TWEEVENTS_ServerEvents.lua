--/////////////////////////////////////////////////////////////////////////
--//////////////////////// Snippet Code by Dislaik ////////////////////////
--/////////////////////////////////////////////////////////////////////////

require "ExpandedHelicopter02a_Presets"
require "ExpandedHelicopter09_EasyConfigOptions"

local Commands = {};
Commands.TWEEvents = {};
Commands.TWEEvents.Dfrag = function(source, args)
print("Triggered Dfrag command on server")
end


Commands.TWEEvents.Zedspawn = function(source, args)
    local sourceId = source:getOnlineID();
    local ZedQ = tonumber(args.ZedQ);
	print("Zedspawn [".. sourceId .."] quant: ", ZedQ)
	print("Zedspawn [".. sourceId .."] XY: ", args.ZedX,args.ZedY)
	print("Zedspawn [".. sourceId .."] PlayerXY: ", source:getX(),source:getY())
	createHordeFromTo(args.ZedX, args.ZedY, source:getX(), source:getY(), args.ZedQ)
end


Commands.TWEEvents.AirEvent = function(source, args)
    local sourceId = source:getOnlineID();
--	onAirCommand("twitch-events","scheduleEvent",sourceID,args.Event)
	print("--TWEEVENT- AirEvent Triggered--" .. args.Event)
	local heli = getFreeHelicopter(args.Event)
	heli:launch(source,true)
end

local onClientCommand = function(module, command, source, args) -- Events Constructor.
    if Commands[module] and Commands[module][command] then
	    Commands[module][command](source, args);
    end
end


Events.OnClientCommand.Add(onClientCommand); -- Listening Events from Client side.

--/////////////////////////////////////////////////////////////////////////
--//////////////////////// Snippet Code by Dislaik ////////////////////////
--/////////////////////////////////////////////////////////////////////////


