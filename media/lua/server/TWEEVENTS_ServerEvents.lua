--/////////////////////////////////////////////////////////////////////////
--//////////////////////// Snippet Code by Dislaik ////////////////////////
--/////////////////////////////////////////////////////////////////////////
if not isServer() then return end
AshenTwitchEvents = AshenTwitchEvents or {}
AshenTwitchEvents.sandboxSettings = {}
AshenTwitchEvents.server = {}
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


Commands.TWEEvents.Handshake = function(source, args)
    local sourceId = source:getOnlineID();
	-- get name of source
--	onAirCommand("twitch-events","scheduleEvent",sourceID,args.Event)
	print("--TWEEVENT- Handshake username-- " .. args.username)
	print("--TWEEVENT- Handshake ID-- " .. sourceId)

	-- check if user is allowed to use commands
	local allowed = false
	for i=1,#AshenTwitchEvents.sandboxSettings.allowedUsers do
		if AshenTwitchEvents.sandboxSettings.allowedUsers[i] == args.username then
			allowed = true
		end
	end
	print("--TWEEVENT- Handshake allowed-- " .. tostring(allowed))
	
	if allowed then
		-- send back a handshake
		local result = {}
		result["username"] = args.username
		result["EventsTable"] = args.EventsTable
		sendServerCommand("AshenTwitchEvents", "HandshakeResult", result)
	end
end

-- function fetchSandboxVars()
AshenTwitchEvents.server.fetchSandboxVars = function()
	local helpString = SandboxVars.AshenTwitchEvents.HelpTheStreamer
	-- this is a string containing item names, separated by ;
	-- we neet to split it into a table
	AshenTwitchEvents.sandboxSettings.HelpTheStreamer = {}
	for item in helpString:gmatch("([^;]+)") do
		table.insert(AshenTwitchEvents.sandboxSettings.HelpTheStreamer, item)
	end

	-- repeat for other settings
	local trollString = SandboxVars.AshenTwitchEvents.TrollTheStreamer
	AshenTwitchEvents.sandboxSettings.TrollTheStreamer = {}
	for item in trollString:gmatch("([^;]+)") do
		table.insert(AshenTwitchEvents.sandboxSettings.TrollTheStreamer, item)
	end
	
	local aireventsString = SandboxVars.AshenTwitchEvents.TWE_Airevents
	AshenTwitchEvents.sandboxSettings.TWE_Airevents = {}
	for item in aireventsString:gmatch("([^;]+)") do
		table.insert(AshenTwitchEvents.sandboxSettings.TWE_Airevents, item)
	end

	local traitsString = SandboxVars.AshenTwitchEvents.TWETraitsTable
	AshenTwitchEvents.sandboxSettings.TWETraitsTable = {}
	for item in traitsString:gmatch("([^;]+)") do
		table.insert(AshenTwitchEvents.sandboxSettings.TWETraitsTable, item)
	end

	local allowedString = SandboxVars.AshenTwitchEvents.allowedUsers
	AshenTwitchEvents.sandboxSettings.allowedUsers = {}
	for item in allowedString:gmatch("([^;]+)") do
		table.insert(AshenTwitchEvents.sandboxSettings.allowedUsers, item)
	end
end

local function initServer()
    AshenTwitchEvents.server.fetchSandboxVars()
end

local onClientCommand = function(module, command, source, args) -- Events Constructor.
    if Commands[module] and Commands[module][command] then
	    Commands[module][command](source, args);
    end
end

Events.OnServerStarted.Add(initServer)
Events.OnClientCommand.Add(onClientCommand); -- Listening Events from Client side.

--/////////////////////////////////////////////////////////////////////////
--//////////////////////// Snippet Code by Dislaik ////////////////////////
--/////////////////////////////////////////////////////////////////////////


