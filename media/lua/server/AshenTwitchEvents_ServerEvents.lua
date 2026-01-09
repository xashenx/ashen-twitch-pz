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

-- create local table temporaryZombies
local temporaryZombies = {}
local temporaryZombiesEnd = 0

function serverZombieDespawn()
	local calendar = PZCalendar.getInstance()
	if calendar:getTimeInMillis() > temporaryZombiesEnd then
		if temporaryZombies then
			for k, v in pairs(temporaryZombies) do
				-- v:Kill(v)
				v:removeFromWorld()
			end
		end
		temporaryZombies = {}
		temporaryZombiesEnd = 0
		Events.EveryOneMinute.Remove(serverZombieDespawn)
	end
end

function serverSpawnSpecificZombie(event)
    local radius =  event.radius or 10
    -- local player = getPlayer()
    if not event.player then
        print("ERROR: Player not found.")
        return
    end

	for i=1, event.zedquant do
		local zombie = createZombie(event.X, event.Y, event.Z, nil, 0, IsoDirections.W)
		if zombie then
			if event.runner then
				zombie:setWalkType("sprint1")
			end
			if event.toothless then
				zombie:setNoTeeth(event.toothless)
			end
			zombie:setTarget(event.player)
			zombie:pathToCharacter(event.player)
			-- zombieList:add(zombie)
			if event.timedZombies then
				table.insert(temporaryZombies, zombie)
			end
		end
	end
	if event.timedZombies then
		local calendar = PZCalendar.getInstance()
		temporaryZombiesEnd = calendar:getTimeInMillis() + 19000
		Events.EveryOneMinute.Add(serverZombieDespawn)
	end
end

Commands.AshenTwitch.RingofFire = function(source, args)
	local event = args
	local radius = event.radius or 10
    local points = event.points or 15
	local player = source
    local playerX = math.floor(player:getX())
    local playerY = math.floor(player:getY())
    local playerZ = math.floor(player:getZ())

    local angleStep = 360 / points
    local seenTiles = {}

    for i = 0, points - 1 do
        local angle = i * angleStep
        local radian = math.rad(angle)
        local tileX = math.floor(playerX + radius * math.cos(radian))
        local tileY = math.floor(playerY + radius * math.sin(radian))
        local key = tileX .. "," .. tileY

        
        if not seenTiles[key] then
            seenTiles[key] = true
            local square = getCell():getGridSquare(tileX, tileY, playerZ)
            if square then
                
                pcall(function()
                    square:explode()
                end)
            end
        end
    end
end

Commands.AshenTwitch.ReviveZombies = function(source, args)
	local event = args
    local range = event.range or 10
    local player = source
    local px, py, pz = player:getX(), player:getY(), player:getZ()
    local cell = player:getCell()

    for dx = -range, range do
        for dy = -range, range do
            local square = cell:getGridSquare(px + dx, py + dy, pz)
            if square then
                local corpses = square:getDeadBodys()
                for i = 0, corpses:size() - 1 do
                    local corpse = corpses:get(i)
                    if not corpse:isSkeleton() then
                        corpse:setReanimateTime(getGameTime():getWorldAgeHours() + (3 / 3600)) -- Reanimate in 3 seconds
                        print("Reviving corpse at (" .. square:getX() .. ", " .. square:getY() .. ", " .. square:getZ() .. ")")
                    end
                end
            end
        end
    end
end


Commands.AshenTwitch.ringOfFire = function(source, args)
	local event = args
	local radius = event.radius or 10
    local points = event.points or 15
	local player = event.player
    if not player then return end
    local playerX = math.floor(player:getX())
    local playerY = math.floor(player:getY())
    local playerZ = math.floor(player:getZ())

    local angleStep = 360 / points
    local seenTiles = {}

    for i = 0, points - 1 do
        local angle = i * angleStep
        local radian = math.rad(angle)
        local tileX = math.floor(playerX + radius * math.cos(radian))
        local tileY = math.floor(playerY + radius * math.sin(radian))
        local key = tileX .. "," .. tileY

        
        if not seenTiles[key] then
            seenTiles[key] = true
            local square = getCell():getGridSquare(tileX, tileY, playerZ)
            if square then
                
                pcall(function()
                    square:explode()
                end)
            end
        end
    end
end

Commands.AshenTwitch.Zedspawn = function(source, args)
    local sourceId = source:getOnlineID();
    local ZedQ = tonumber(args.ZedQ);
	-- print("Zedspawn [".. sourceId .."] quant: ", ZedQ)
	-- print("Zedspawn [".. sourceId .."] XY: ", args.ZedX,args.ZedY)
	-- print("Zedspawn [".. sourceId .."] PlayerXY: ", source:getX(),source:getY())
	-- createHordeFromTo(args.ZedX, args.ZedY, source:getX(), source:getY(), args.ZedQ)
	event = {}
	event.zedquant = ZedQ
	event.X = args.ZedX
	event.Y = args.ZedY
	event.Z = 0
	event.player = source
	event.runner = args.runner
	event.toothless = args.toothless
	event.timedZombies = args.timedZombies

	serverSpawnSpecificZombie(event)
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
			-- if sandbox forwardEvents is true, then forward messages to all clients, otherwine, only to the initiator
			-- sendServerCommand("AshenTwitch", "Handshake", args)
			if AshenTwitchEvents.sandboxSettings.forwardEvents then
				sendServerCommand("AshenTwitch", "Handshake", args)
			else
				sendServerCommand(source, "AshenTwitch", "Handshake", args)
			end
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

	AshenTwitchEvents.sandboxSettings.forwardEvents = SandboxVars.AshenTwitchEvents.forwardEvents
end

-- local function initServer()
AshenTwitchEvents.server.initServer = function()
    AshenTwitchEvents.server.fetchSandboxVars()
end

-- local onClientCommand = function(module, command, source, args) -- Events Constructor.
AshenTwitchEvents.server.onClientCommand = function(module, command, source, args) -- Events Constructor.
    if Commands[module] and Commands[module][command] then
	    Commands[module][command](source, args)
    end
end

Events.OnServerStarted.Add(AshenTwitchEvents.server.initServer)
Events.OnClientCommand.Add(AshenTwitchEvents.server.onClientCommand); -- Listening Events from Client side.

--/////////////////////////////////////////////////////////////////////////
--//////////////////////// Snippet Code by Dislaik ////////////////////////
--/////////////////////////////////////////////////////////////////////////
