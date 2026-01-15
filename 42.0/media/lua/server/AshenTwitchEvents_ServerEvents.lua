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

SERVER_SWITCH_STATE = true

-- Server Command Handle for Zed Spawn Event from Client
-- The server will spawn the requested number of zombies at the specified location
Commands.AshenTwitch.Zedspawn = function(source, args)
	-- TODO verificare inconsistenza di spawn e chiamata canSpawnAt(args.ZedX, args.ZedY, source:getZ())
    local sourceId = source:getOnlineID();
    local ZedQ = tonumber(args.ZedQ);
	-- print("Zedspawn [".. sourceId .."] quant: ", ZedQ)
	-- print("Zedspawn [".. sourceId .."] XYZ: ", args.ZedX,args.ZedY,args.ZedZ)
	-- print("Zedspawn [".. sourceId .."] PlayerXYZ: ", source:getX(),source:getY(),source:getZ())
	createHordeFromTo(args.ZedX, args.ZedY, source:getX(), source:getY(), args.ZedQ)

	-- BEGIN - TEST CODE TMP REMOVED
	-- create the zombies and move them to the player location
	-- spawnHorde(args.ZedX, args.ZedY, args.ZedX, args.ZedY, source:getZ(), args.ZedQ)
	-- local spawnable = canSpawnAt(args.ZedX, args.ZedY, source:getZ())
	-- print("Zedspawn [".. sourceId .."] canSpawnAt: ", tostring(spawnable))
	-- if spawnable then
	-- 	spawnHorde(args.ZedX, args.ZedY, args.ZedX, args.ZedY, source:getZ(), args.ZedQ)
	-- end
	-- END - TEST CODE TMP REMOVED
end

-- Server Command Handle for Animal Spawn Event from Client
-- The server will spawn the requested animal at the specified location
Commands.AshenTwitch.AnimalSpawn = function(source, args)
    local sourceId = source:getOnlineID();
	print("Animalspawn [".. sourceId .."] XY: ", args.AnimalX,args.AnimalY, args.AnimalZ)
	print("Animalspawn [".. sourceId .."] PlayerXY: ", source:getX(),source:getY())

-- Ottieni il quadrato (square) di destinazione
	local square = getCell():getGridSquare(args.AnimalX, args.AnimalY, args.AnimalZ)
    if square then
        -- Crea l'animale tramite l'AnimalSystem (B42)
        -- animalType può essere: "Cow", "Sheep", "Chicken", "Rabbit", "Pig"
		print(args.AnimalX, args.AnimalY, args.animalType)
		local animal = IsoAnimal.new(getCell(), args.AnimalX, args.AnimalY,  args.AnimalZ, args.animalType, args.animalBreed);
        
        -- Impostiamo il sesso su Maschio (true = maschio, false = femmina)
        -- In B42 il metodo specifico è setFemale(false)
        -- animal:setFemale(false)
        
        -- Assicuriamoci che sia adulto (i vitelli non sono tori)
        -- bull:setBaby(false)
        -- local animal = IsoAnimal.new(getCell(), args.AnimalX, args.AnimalY, 0, animalType)
		-- animal:getStats():setFear(1.0)
		animal:setWild(true)
        -- animal:getBehaviourHub():setAttackTarget(source)
		animal:getBehavior():goAttack(source)
        -- Aggiunge l'animale al mondo
        -- square:getObjects():add(bull)
        animal:addToWorld()
        
        print("Twitch Spawn: " .. args.animalType .. " spawnato a " .. args.AnimalX .. "," .. args.AnimalY)
    end
end

-- Server Command Handle for Air Event from Client
-- The server will spawn the requested air event at the specified location
Commands.AshenTwitch.AirEvent = function(source, args)
    local sourceId = source:getOnlineID();
--	onAirCommand("twitch-events","scheduleEvent",sourceID,args.Event)
	print("--TWEEVENT- AirEvent Triggered--" .. args.Event)
	local heli = getFreeHelicopter(args.Event)
	heli:launch(source,true)
end

-- Server Command Handle for Handshake Event from Client
-- The server will validate the user and respond with sandbox settings
Commands.AshenTwitch.Handshake = function(source, args)
    local sourceId = source:getOnlineID();

	if args.state == "Request" then
		-- check if user is allowed to use commands
		local allowed = false
		args.sandbox = AshenTwitchEvents.sandboxSettings
		if not SERVER_SWITCH_STATE then
			-- server switch is off, no one is allowed
			args.state = "ServerDisabled"
			sendServerCommand(source, "AshenTwitch", "Handshake", args)
			return
		else
			for i=1,#AshenTwitchEvents.sandboxSettings.allowedUsers do
				if AshenTwitchEvents.sandboxSettings.allowedUsers[i] == args.initiator then
					allowed = true
				end
			end
		end
		-- print("--TWEEVENT- Handshake REQUEST -- " .. tostring(allowed) .. " for " .. args.initiator)
		
		if allowed then
			args.initiatorID = sourceId
			-- insert args.EventsTable in EventList
			-- AshenTwitchEvents.server.EventList[args.initiator] = args.EventsTable
			-- send back a handshake
			args.state = "Accepted"
			sendServerCommand(source, "AshenTwitch", "Handshake", args)
		else
			-- send back a handshake denial
			args.state = "Denied"
			sendServerCommand(source, "AshenTwitch", "Handshake", args)
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

-- Server Command Handle for Revive Zombies Event from Client
-- The server will revive corpses in a specified range around the player
Commands.AshenTwitch.ReviveZombies = function(source, args)
	local event = args
	-- set default range if not provided
    local range = event.range or 10
    local player = source
	-- get player position
    local px, py, pz = player:getX(), player:getY(), player:getZ()
    local cell = player:getCell()
	local args = {}
	args.revivedCount = 0
	args.message = ''
	args.player = player:getUsername()
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
						args.revivedCount = args.revivedCount + 1
                    end
                end
            end
        end
    end

	-- prepare the message for the client
	if args.revivedCount == 0 then
		args.message = 'Mi spiace ' .. event.Viewer .. ' non ci sono corpi a terra! [' .. event.range .. ' tiles]'
	else
		args.message = event.Viewer .. ' ne resuscita ' .. args.revivedCount .. '! [' .. event.range .. ' tiles]'
	end
	sendServerCommand(source, "AshenTwitch", "ReviveResult", args)
end

-- Server Command Handle for Ring of Fire Event from Client
-- The server will create a ring of fire around the player
Commands.AshenTwitch.RingofFire = function(source, args)
	local event = args
	-- set default radius and points if not provided
	local radius = event.radius or 10
	-- set default points if not provided
    local points = event.points or 15
	local player = source
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
                    -- square:explode()
					IsoFireManager.StartFire(getCell(), square, true, 100, 500)
					-- IsoFireManager.explode(getCell(), square, 100)
                end)
            end
        end
    end
end

-- Server Command Handle for Create Gift Item Event from Client
-- The server will create the requested item in the player's inventory
Commands.AshenTwitch.CreateGiftItem = function(source, args)
	local player = source
	local inv = player:getInventory()
    if not player then return end

	-- generate item
	local item = inv:AddItem(args.item)
	-- validate item added
	sendAddItemToContainer(inv, item)
	-- sends feedback to client
	args.player = player:getUsername()
	sendServerCommand(source, "AshenTwitch", "GiftResult", args)
end

-- Server Command Handle for Set Stat Event from Client
-- The server will set the specified stat to the desired level for the player
Commands.AshenTwitch.SetStat = function(source, args)
	local event = args
	local player = source
	-- get player stats
	local stats = player:getStats()
	-- get stat enum
	local statEnum = CharacterStat[args.stat]
    if not player then return end
	-- print("Setting stat " .. args.stat .. " to level " .. args.level .. " for player " .. player:getUsername())
	-- set the stat level
	stats:set(statEnum, args.level)
end

-- Server Command Handle for Add/Remove Trait Event from Client
-- The server will add or remove the specified trait for the player
Commands.AshenTwitch.AddTrait = function(source, args)
	local player = source
	-- print("Adding trait " .. args.trait .. " to player " .. player:getUsername())
	player:getCharacterTraits():add( CharacterTrait[args.trait])
end

-- Server Command Handle for Remove Trait Event from Client
-- The server will remove the specified trait from the player
Commands.AshenTwitch.RemoveTrait = function(source, args)
	local player = source
	player:getCharacterTraits():remove(CharacterTrait[args.trait])
end

-- Server Command Handle for Forward Message Event from Client
-- The server will forward a message to all clients
Commands.AshenTwitch.ForwardMessage = function(source, args)
	sendServerCommand("AshenTwitch", "ForwardMessage", args)
end

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

-- set server switch state from client request
Commands.AshenTwitch.ToggleServerSwitch = function(source, args)
	if args.action == "on" then
		SERVER_SWITCH_STATE = true
	elseif args.action == "off" then
		SERVER_SWITCH_STATE = false
	end
	-- print("AshenTwitchEvents Server Switch State changed to -> " .. tostring(SERVER_SWITCH_STATE) .. " by " .. source:getUsername())
	-- broadcast new state to all clients
	sendServerCommand("AshenTwitch", "serverSwitchState", { serverSwitchState = SERVER_SWITCH_STATE })
end

-- return SERVER_SWITCH_STATE to the requesting client
Commands.AshenTwitch.RequestServerSwitchState = function(source, args)
	-- print("AshenTwitchEvents Server sending switch state -> " .. tostring(SERVER_SWITCH_STATE) .. " to " .. source:getUsername())
	sendServerCommand(source, "AshenTwitch", "serverSwitchState", { serverSwitchState = SERVER_SWITCH_STATE })
end

local function initServer()
    AshenTwitchEvents.server.fetchSandboxVars()
end

-- Client Messages Dispatcher
-- Receives messages from Client and dispatch to the correct Command Handler
local onClientCommand = function(module, command, source, args) -- Events Constructor.
    if Commands[module] and Commands[module][command] then
	    Commands[module][command](source, args)
    end
end

Events.OnServerStarted.Add(initServer)
Events.OnClientCommand.Add(onClientCommand); -- Listening Events from Client side.
