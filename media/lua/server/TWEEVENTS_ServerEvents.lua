--/////////////////////////////////////////////////////////////////////////
--//////////////////////// Snippet Code by Dislaik ////////////////////////
--/////////////////////////////////////////////////////////////////////////
if not isServer() then return end
AshenTwitchEvents = AshenTwitchEvents or {}
AshenTwitchEvents.sandboxSettings = {}
AshenTwitchEvents.server = {}
AshenTwitchEvents.server.EventList = {}
AshenTwitchEvents.server.JoinList = {}
require "ExpandedHelicopter02a_Presets"
require "ExpandedHelicopter09_EasyConfigOptions"

local Commands = {};
Commands.AshenTwitch = {}
Commands.AshenTwitch.Dfrag = function(source, args)
print("Triggered Dfrag command on server")
end

Commands.AshenTwitch.Zedspawn = function(source, args)
    local sourceId = source:getOnlineID();
    local ZedQ = tonumber(args.ZedQ);
	print("Zedspawn [".. sourceId .."] quant: ", ZedQ)
	print("Zedspawn [".. sourceId .."] XY: ", args.ZedX,args.ZedY)
	print("Zedspawn [".. sourceId .."] PlayerXY: ", source:getX(),source:getY())
	createHordeFromTo(args.ZedX, args.ZedY, source:getX(), source:getY(), args.ZedQ)
end


Commands.AshenTwitch.AirEvent = function(source, args)
    local sourceId = source:getOnlineID();
--	onAirCommand("twitch-events","scheduleEvent",sourceID,args.Event)
	print("--TWEEVENT- AirEvent Triggered--" .. args.Event)
	local heli = getFreeHelicopter(args.Event)
	heli:launch(source,true)
end


Commands.AshenTwitch.Handshake = function(source, args)
    local sourceId = source:getOnlineID();

	if args.state == "Request" then
		-- check if user is allowed to use commands
		local allowed = false
		for i=1,#AshenTwitchEvents.sandboxSettings.allowedUsers do
			if AshenTwitchEvents.sandboxSettings.allowedUsers[i] == args.initiator then
				allowed = true
			end
		end
		-- print("--TWEEVENT- Handshake REQUEST -- " .. tostring(allowed) .. " for " .. args.initiator)
		
		if allowed then
			args.initiatorID = sourceId
			-- insert args.EventsTable in EventList
			-- AshenTwitchEvents.server.EventList[args.initiator] = args.EventsTable
			-- send back a handshake
			args.state = "Accepted"
			args.sandbox = AshenTwitchEvents.sandboxSettings
			sendServerCommand("AshenTwitch", "Handshake", args)
		end
	-- elseif args.state == "Join" then
	-- 	print("--TWEEVENT- Handshake JOIN -- " .. source:getUsername())
	-- 	AshenTwitchEvents.server.JoinList[source:getUsername()] = 1
	-- 	if AshenTwitchEvents.server.EventList[source:getUsername()] then
	-- 		-- send back a handshake
	-- 		args.state = "Accepted"
	-- 		sendServerCommand("AshenTwitchEvents", "Handshake", args)
	-- 	end
	end
end


Commands.AshenTwitch.ForwardMessage = function(source, args)
	sendServerCommand("AshenTwitch", "ForwardMessage", args)
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
	    Commands[module][command](source, args)
    end
end

Events.OnServerStarted.Add(initServer)
Events.OnClientCommand.Add(onClientCommand); -- Listening Events from Client side.

--/////////////////////////////////////////////////////////////////////////
--//////////////////////// Snippet Code by Dislaik ////////////////////////
--/////////////////////////////////////////////////////////////////////////


