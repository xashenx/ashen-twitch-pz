require "ExpandedHelicopter02a_Presets"
require "ExpandedHelicopter09_EasyConfigOptions"

AshenTwitchEvents = AshenTwitchEvents or {}
AshenTwitchEvents.HelpTheStreamer = {}
AshenTwitchEvents.TrollTheStreamer = {}
AshenTwitchEvents.TWE_Airevents = {}
AshenTwitchEvents.TWETraitsTable = {}

local timervalue = 10 --timer value in minutes for the temporary traits
local TWE_Events = {}
local TraitEndTime = 0
local ViewerName = ""
----positive items table
local HelpTheStreamer ={ "Base.BaseballBat", "Base.HuntingKnife", "Base.Axe", "Base.WristWatch_Right_DigitalRed", "Base.Crowbar", "Base.HandAxe", "Base.Burger", "Base.Crisps", "Base.Sandwich", "Base.BeerBottle", "Base.Pop","Base.Belt2","Base.TinnedBeans" }
----negative items table
local TrollTheStreamer = { "Base.Generator", "Base.LogStacks4", "Base.Dirtbag", "Base.Sandbag" }
-----Air Events Presets
local TWE_Airevents = {"military","police","news_chopper_hover","raiders","FEMA_drop","jet","survivor_heli","military_attackhelicopter_zombies","samaritan_drop"}
-----Temporary traits table
local TWETraitsTable = {[1]="Deaf",[2]="Thinskinned",[3]="AllThumbs",[4]="Cowardly",[5]="Hemophobic",[6]="SundayDriver",[7]="Graceful",[8]="KeenHearing",[9]="ThickSkinned",[10]="SpeedDemon",[11]="Jogger",[12]="Inconspicuous"}
local TWETempTraitsTable = {}
local TWEAnnouceEvents = true
local playerChar = getPlayer()
local LocalEventsTable = {}

local ClientCommands = {};
ClientCommands.AshenTwitch = {};


--processes the EventsTable generated by getreward
function performHandshake(EventsTable)
    local playerChar = getPlayer()
	-- LocalEventsTable = EventsTable
	-- print(playerChar:getUsername())
	ServerEvent = {["Etype"] = "Handshake", ["ZedX"] = Zedx, ["ZedY"] = Zedy, ["ZedQ"] = zedquant, ["target"] = playerchar, ["EventsTable"] = EventsTable}
	ServerEvent.state = "Request"
	ServerEvent.initiator = playerChar:getUsername()
	--playerChar:Say("x:" .. tostring(ServerEvent.ZedX) .. "y: " .. tostring(ServerEvent.ZedY))
	sendClientCommand("TWEEvents", "Handshake", ServerEvent); -- Trigger Event from Client to Server
end

function performEvent(EventsTable, initiator)
	local playerChar = getPlayer()
	if EventsTable then
		ViewerName = EventsTable["Viewer"]
		if EventsTable["zombies"] == true and EventsTable["zedquant"] > 0 then
			print("------------=Twitch Events: zombies=------------")
			if TWEAnnouceEvents == true then
				if EventsTable["zedpacks"] > 1 then
					local message = EventsTable["Viewer"] .. getText("UI_ZombieSpawn") .. EventsTable["zedpacks"] .. getText("UI_ZombiePacks")
					message = message .. EventsTable["zedquant"] .. " zombies (" .. EventsTable["zedquant"] * EventsTable["zedpacks"] .. ")" 
					playerChar:Say(message)
				else
					playerChar:Say(EventsTable["Viewer"] .. getText("UI_ZombieSpawn") .. EventsTable["zedquant"] .. " zombies")
				end
			end

			if initiator == playerChar:getUsername() then
				--local Zedx, Zedy, wz = LSpawnLoc();
				local zedquant = tonumber(EventsTable["zedquant"])
				if isClient() then
					for i=1, EventsTable["zedpacks"] do
						local Zedx, Zedy, Zedz = SpawnLoc(50)
						ServerEvent = {["Etype"] = "Zedspawn", ["ZedX"] = Zedx, ["ZedY"] = Zedy, ["ZedQ"] = zedquant, ["PlayerChar"] = playerchar }
						--playerChar:Say("x:" .. tostring(ServerEvent.ZedX) .. "y: " .. tostring(ServerEvent.ZedY))
						print("spawning pack of " .. zedquant .. " zeds at " .. Zedx .. " " .. Zedy .. " " .. Zedz .. " zedpack #" .. i)
						sendClientCommand("TWEEvents", "Zedspawn", ServerEvent); -- Trigger Event from Client to Server
					end

					-- local Zedx, Zedy, Zedz = SpawnLoc(50)
					-- ServerEvent = {["Etype"] = "Zedspawn", ["ZedX"] = Zedx, ["ZedY"] = Zedy, ["ZedQ"] = zedquant, ["PlayerChar"] = playerchar }
					-- --playerChar:Say("x:" .. tostring(ServerEvent.ZedX) .. "y: " .. tostring(ServerEvent.ZedY))
					-- sendClientCommand("TWEEvents", "Zedspawn", ServerEvent); -- Trigger Event from Client to Server
				else
					local Zedx, Zedy, Zedz = SpawnLoc(85)
					createHordeFromTo(Zedx, Zedy, playerChar:getX(), playerChar:getY(), zedquant)
				end
			end
		end

		if tonumber(EventsTable["gifts"]) > 0 then
			print("------------=Twitch Events: gift =------------")
			TWE_Events.GiftItems(tonumber(EventsTable["gifts"]), initiator)
		end

		if tonumber(EventsTable["helicopter"]) > 0 then

			if tonumber(EventsTable["helicopter"]) == 1 then
				print("------------=Twitch Events: Air Event=------------")
				if TWEAnnouceEvents == true then
					playerChar:Say(EventsTable["Viewer"] .. getText("UI_AirEventMilitary"))
				end

				if initiator == playerChar:getUsername() then
					if isClient() then
						ServerEvent = {["Etype"] = "AirEvent", ["target"] = playerchar, ["Event"] = "military" }
						sendClientCommand("TWEEvents", "AirEvent", ServerEvent); -- Trigger Event from Client to Server
					else
						local heli = getFreeHelicopter("military")
						heli:launch(playerChar, false)
					end
				end
			end

			if tonumber(EventsTable["helicopter"]) == 2 then
				print("------------=Twitch Events: Air Event=------------")
				if TWEAnnouceEvents == true then
					playerChar:Say(EventsTable["Viewer"] .. getText("UI_AirEventNews"))
				end

				if initiator == playerChar:getUsername() then
					if isClient() then
						ServerEvent = {["Etype"] = "AirEvent", ["target"] = playerchar, ["Event"] = "news_chopper_hover" }
						sendClientCommand("TWEEvents", "AirEvent", ServerEvent); -- Trigger Event from Client to Server
					else
						local heli = getFreeHelicopter("news_chopper_hover")
						heli:launch(playerChar, false)
					end
				end
			end

			if tonumber(EventsTable["helicopter"]) == 3 then
				print("------------=Twitch Events: Air Event=------------")
				if TWEAnnouceEvents == true then
					playerChar:Say(EventsTable["Viewer"] .. getText("UI_AirEventPolice"))
				end

				if initiator == playerChar:getUsername() then
					if isClient() then
						ServerEvent = {["Etype"] = "AirEvent", ["target"] = playerchar, ["Event"] = "police" }
						sendClientCommand("TWEEvents", "AirEvent", ServerEvent); -- Trigger Event from Client to Server
					else
						local heli = getFreeHelicopter("police")
						heli:launch(playerChar, false)
					end
				end
			end

			if tonumber(EventsTable["helicopter"]) == 4 then
				print("------------=Twitch Events: Air Event=------------")
				if TWEAnnouceEvents == true then
					playerChar:Say(EventsTable["Viewer"] .. getText("UI_AirEventRaiders"))
				end
				
				if initiator == playerChar:getUsername() then
					if isClient() then
						ServerEvent = {["Etype"] = "AirEvent", ["target"] = playerchar, ["Event"] = "raiders" }
						sendClientCommand("TWEEvents", "AirEvent", ServerEvent); -- Trigger Event from Client to Server
					else
						local heli = getFreeHelicopter("raiders")
						heli:launch(playerChar, false)
					end
				end
			end

			if tonumber(EventsTable["helicopter"]) == 5 then
				print("------------=Twitch Events: Air Event=------------")
				if TWEAnnouceEvents == true then
					playerChar:Say(EventsTable["Viewer"] .. getText("UI_AirEventFema"))
				end

				if initiator == playerChar:getUsername() then
					if isClient() then
						ServerEvent = {["Etype"] = "AirEvent", ["target"] = playerchar, ["Event"] = "FEMA_drop" }
						sendClientCommand("TWEEvents", "AirEvent", ServerEvent); -- Trigger Event from Client to Server
					else
						local heli = getFreeHelicopter("FEMA_drop")
						heli:launch(playerChar, false)
					end
				end
			end

			if tonumber(EventsTable["helicopter"]) == 6 then
				print("------------=Twitch Events: Air Event=------------")
				if TWEAnnouceEvents == true then
					playerChar:Say(EventsTable["Viewer"] .. getText("UI_AirEventJet"))
				end

				if initiator == playerChar:getUsername() then
					if isClient() then
						ServerEvent = {["Etype"] = "AirEvent", ["target"] = playerchar, ["Event"] = "jet" }
						sendClientCommand("TWEEvents", "AirEvent", ServerEvent); -- Trigger Event from Client to Server
					else
						local heli = getFreeHelicopter("jet")
						heli:launch(playerChar, false)
					end
				end
			end

			if tonumber(EventsTable["helicopter"]) == 7 then
				print("------------=Twitch Events: Air Event=------------")
				if TWEAnnouceEvents == true then
					playerChar:Say(EventsTable["Viewer"] .. getText("UI_AirEventMilitaryFriendly"))
				end

				if initiator == playerChar:getUsername() then
					if isClient() then
						ServerEvent = {["Etype"] = "AirEvent", ["target"] = playerchar, ["Event"] = "military_attackhelicopter_zombies" }
						sendClientCommand("TWEEvents", "AirEvent", ServerEvent); -- Trigger Event from Client to Server
					else
						local heli = getFreeHelicopter("military_attackhelicopter_zombies")
						heli:launch(playerChar, false)
					end
				end
			end

			if tonumber(EventsTable["helicopter"]) == 8 then
				print("------------=Twitch Events: Air Event=------------")
				if TWEAnnouceEvents == true then
					playerChar:Say(EventsTable["Viewer"] .. getText("UI_AirEventSurvivor"))
				end

				if initiator == playerChar:getUsername() then
					if isClient() then
						ServerEvent = {["Etype"] = "AirEvent", ["target"] = playerchar, ["Event"] = "survivor_heli" }
						sendClientCommand("TWEEvents", "AirEvent", ServerEvent); -- Trigger Event from Client to Server
					else
						local heli = getFreeHelicopter("survivor_heli")
						heli:launch(playerChar, false)
					end
				end
			end

			if tonumber(EventsTable["helicopter"]) == 9 then
				print("------------=Twitch Events: Air Event=------------")
				if TWEAnnouceEvents == true then
					playerChar:Say(EventsTable["Viewer"] .. getText("UI_AirEventSamaritan"))
				end

				if initiator == playerChar:getUsername() then
					if isClient() then
						ServerEvent = {["Etype"] = "AirEvent", ["target"] = playerchar, ["Event"] = "samaritan_drop" }
						sendClientCommand("TWEEvents", "AirEvent", ServerEvent); -- Trigger Event from Client to Server
					else
						local heli = getFreeHelicopter("samaritan_drop")
						heli:launch(playerChar, false)
					end
				end
			end

			if tonumber(EventsTable["helicopter"]) == 100 then
				print("------------=Twitch Events: Air Event=------------")
				if TWEAnnouceEvents == true then
					playerChar:Say(EventsTable["Viewer"] .. getText("UI_AirEventRandom"))
				end

				if initiator == playerChar:getUsername() then
					if isClient() then
						ServerEvent = {["Etype"] = "AirEvent", ["target"] = playerchar, ["Event"] = "RANDOM" }
						sendClientCommand("TWEEvents", "AirEvent", ServerEvent); -- Trigger Event from Client to Server
					else
						local heli = getFreeHelicopter("RANDOM")
						heli:launch(playerChar, false)
					end
				end
			end

			if tonumber(EventsTable["helicopter"]) == 69 then
				print("------------=Twitch Events: Custom Air Event=------------")
				if TWEAnnouceEvents == true then
					playerChar:Say(EventsTable["Viewer"] .. " called a ".. EventsTable["title"])
				end

				if initiator == playerChar:getUsername() then
					if isClient() then
						ServerEvent = {["Etype"] = "AirEvent", ["target"] = playerchar, ["Event"] = EventsTable["title"] }
						sendClientCommand("TWEEvents", "AirEvent", ServerEvent); -- Trigger Event from Client to Server
					else
						local heli = getFreeHelicopter(EventsTable["title"])
						heli:launch(playerChar, false)
					end
				end
			end
			
		end

		local part_modifier = tonumber(EventsTable["part_modifier"])
		if EventsTable["gas"] then --car events begin
			TWE_Events.TWECars(EventsTable["Viewer"], "GasTank", part_modifier)
		end
		if EventsTable["tire"] then
			TWE_Events.TWECars(EventsTable["Viewer"], "FlatTire", part_modifier)
		end
		if EventsTable["muffler"] then
			TWE_Events.TWECars(EventsTable["Viewer"], "Muffler", part_modifier)
		end
		if EventsTable["battery"] then
			TWE_Events.TWECars(EventsTable["Viewer"], "Battery", part_modifier)
		end
		if EventsTable["engine"] then -- car events end
			TWE_Events.TWECars(EventsTable["Viewer"], "Engine", part_modifier)
		end

		if tonumber(EventsTable["trait"]) == 99 then -- random trait
			print("------------=Twitch Events: random trait Event=------------")
			-- get the size of AshenTwitchEvents.TWETraitsTable
			-- get a random number between 1 and the size of AshenTwitchEvents.TWETraitsTable
			local length
			for k, v in pairs(AshenTwitchEvents.TWETraitsTable) do
				length = length + 1
			end
			TWETableTraitsTrigger(ZombRand(1,length), initiator)
		elseif tonumber(EventsTable["trait"]) > 0 then -- specifi trait
			print("------------=Twitch Events: specific trait Event=------------")
			TWETableTraitsTrigger(tonumber(EventsTable["trait"]), initiator)
		end
	end
end

--temporary traits trigger---
function TWETableTraitsTrigger(MyTrait, initiator)
	local playerChar = getPlayer()
	local calendar = PZCalendar.getInstance()
	local hour = calendar:get(Calendar.HOUR_OF_DAY)
	local minute = calendar:get(Calendar.MINUTE)
	local second = calendar:get(Calendar.SECOND)
	if hour == 0 then --check if its 0, if true replaces 0 with 24
		TraitEndTime = (24 * 60 + minute + timervalue ) * 60 + second
	else 
		TraitEndTime = (hour * 60 + minute + timervalue) * 60 + second
	end	
	
	selectedTrait = AshenTwitchEvents.TWETraitsTable[MyTrait]
	-- if not playerChar:HasTrait(TWETraitsTable[MyTrait]) then
		-- playerChar:getTraits():add(TWETraitsTable[MyTrait]);
		-- table.insert(TWETempTraitsTable, {trait = TWETraitsTable[MyTrait], endtime = TraitEndTime})
		-- HaloTextHelper.addTextWithArrow(playerChar, getText("UI_trait_"..TWETraitsTable[MyTrait]), true, HaloTextHelper.getColorGreen())
	if not playerChar:HasTrait(selectedTrait) then
		playerChar:getTraits():add(selectedTrait);
		table.insert(TWETempTraitsTable, {trait = selectedTrait, endtime = TraitEndTime})
		HaloTextHelper.addTextWithArrow(playerChar, getText("UI_trait_" .. selectedTrait), true, HaloTextHelper.getColorGreen())
		Events.EveryOneMinute.Remove(TWE_TraitCheck);
		Events.EveryOneMinute.Add(TWE_TraitCheck);
	end
end

--temporary traits timer check---
function TWE_TraitCheck()
	local playerChar = getPlayer()
	local calendar = PZCalendar.getInstance()
	local hour = calendar:get(Calendar.HOUR_OF_DAY)
	local minute = calendar:get(Calendar.MINUTE)
	local second = calendar:get(Calendar.SECOND)
	if hour == 0 then --check if its 0, if true replaces 0 with 24
		currentTime = (24 * 60 + minute) * 60 + second
	else 
		currentTime = (hour * 60 + minute) * 60 + second
	end

	for i, v in ipairs(TWETempTraitsTable) do
		local trait = v.trait
		local endtime = v.endtime
		if endtime <= currentTime then
			print("Removing trait: " .. trait)
			print("Endtime: " .. endtime)
			playerChar:getTraits():remove(trait);
			HaloTextHelper.addTextWithArrow(playerChar, getText("UI_trait_"..trait), false, HaloTextHelper.getColorRed())     
			table.remove(TWETempTraitsTable, i)
			if TWETempTraitsTable == 0 then
				Events.EveryOneMinute.Remove(TWE_TraitCheck)
				break
			end
		end
	end
end

--car event actions
function TWE_Events.TWECars(Viewer, Mypart, modifier)
    local playerChar = getPlayer()
	local mycar = playerChar:getVehicle()
    local TireSet = { "TireRearRight", "TireRearLeft"," TireFrontRight", "TireFrontLeft"}
    local WhichTire = ZombRand(1,5)
    if mycar ~= nil then
        for i = mycar:getPartCount()-1,0,-1 do
            local part = mycar:getPartByIndex(i)
            local cat = part:getCategory()
            local item = part:getId()
            if item ~=  nil then
                if Mypart == "Engine" and item == Mypart then
					local condition = part:getCondition()
					if modifier > 0 then
                    	playerChar:Say(Viewer .. getText("UI_engineBonus") .. " " .. modifier)
					else
                    	playerChar:Say(Viewer .. getText("UI_engineMalus") .. " " .. modifier)
					end
					part:setCondition(condition + modifier)
                end
                if Mypart == "FlatTire" then
                    if TireSet[WhichTire] == item then
                        VehicleUtils.RemoveTire(part, true)
                    end
				end
				if Mypart == "GasTank" and item == Mypart then
					local content = part:getContainerContentAmount()
					if modifier > 0 then
                    	playerChar:Say(Viewer .. getText("UI_gasBonus") .. " " .. modifier)
					else
                    	playerChar:Say(Viewer .. getText("UI_gasMalus") .. " " .. modifier)
					end
					part:setContainerContentAmount(content + modifier)
				end
				if Mypart == "Muffler" and item == Mypart then
					local condition = part:getCondition()
					if modifier > 0 then
                    	playerChar:Say(Viewer .. getText("UI_mufflerBonus") .. " " .. modifier)
					else
                    	playerChar:Say(Viewer .. getText("UI_mufflerMalus") .. " " .. modifier)
					end
					part:setCondition(condition + modifier)
				end
				if Mypart == "Battery" and item == Mypart then
					local condition = part:getCondition()
					if modifier > 0 then
                    	playerChar:Say(Viewer .. getText("UI_batteryBonus") .. " " .. modifier)
					else
                    	playerChar:Say(Viewer .. getText("UI_batteryMalus") .. " " .. modifier)
					end
					part:setCondition(condition + modifier)
				end
			end
		end
	end
end

--gifts event actions
function TWE_Events.GiftItems(whatkind, initiator)
	local player = getSpecificPlayer(0)
	local username = player:getUsername()
	local inv = player:getInventory()
	local Helpmeitem = 0
	local Trollmeitem = 0
	if whatkind == 1 then
		-- Helpmeitem = ZombRand(1,14)
		-- get the size of AshenTwitchEvents.HelpTheStreamer
		-- get a random number between 1 and the size of AshenTwitchEvents.HelpTheStreamer
		local length
		for k, v in pairs(AshenTwitchEvents.HelpTheStreamer) do
			length = length + 1
		end
		Helpmeitem = ZombRand(1,length)

		-- inv:AddItem(HelpTheStreamer[Helpmeitem])
		inv:AddItem(AshenTwitchEvents.HelpTheStreamer[Helpmeitem])
		player:Say(ViewerName .. " ".. getText("UI_HelpMEEvent") .. getItemNameFromFullType(AshenTwitchEvents.HelpTheStreamer[Helpmeitem]))
		args = {}
		args.message = username .. " ha ricevuto " .. getItemNameFromFullType(AshenTwitchEvents.HelpTheStreamer[Helpmeitem])
		args.initiator = initiator
		sendClientCommand("AshenTwitch", "Say", args)
	elseif whatkind == 2 then
		-- Trollmeitem = ZombRand(1,5)
		-- get the size of AshenTwitchEvents.TrollTheStreamer
		-- get a random number between 1 and the size of AshenTwitchEvents.TrollTheStreamer
		local length
		for k, v in pairs(AshenTwitchEvents.TrollTheStreamer) do
			length = length + 1
		end
		Trollmeitem = ZombRand(1,length)

		-- inv:AddItem(TrollTheStreamer[Trollmeitem])
		inv:AddItem(AshenTwitchEvents.TrollTheStreamer[Trollmeitem])
		player:Say(ViewerName .. " " .. getText("UI_HelpMEEvent") .. getItemNameFromFullType(AshenTwitchEvents.TrollTheStreamer[Trollmeitem]) .. getText("UI_HelpMEETroll"))
		args = {}
		args.message = username .. " ha ricevuto " .. getItemNameFromFullType(AshenTwitchEvents.TrollTheStreamer[Trollmeitem])
		args.initiator = initiator
		sendClientCommand("AshenTwitch", "Say", args)
	elseif whatkind == 3 then
		-- Trollmeitem = ZombRand(1,5)
		-- get the size of AshenTwitchEvents.TrollTheStreamer
		-- get a random number between 1 and the size of AshenTwitchEvents.TrollTheStreamer
		local length
		for k, v in pairs(AshenTwitchEvents.TrollTheStreamer) do
			length = length + 1
		end
		Trollmeitem = ZombRand(1,length)
		
		-- Helpmeitem = ZombRand(1,14)
		-- get the size of AshenTwitchEvents.HelpTheStreamer
		-- get a random number between 1 and the size of AshenTwitchEvents.HelpTheStreamer
		local length
		for k, v in pairs(AshenTwitchEvents.HelpTheStreamer) do
			length = length + 1
		end
		Helpmeitem = ZombRand(1,length)

		-- inv:AddItem(TrollTheStreamer[Trollmeitem])
		-- inv:AddItem(HelpTheStreamer[Helpmeitem])
		-- Ggift = HelpTheStreamer[Helpmeitem]
		-- Bgift = TrollTheStreamer[Trollmeitem]
		Ggift = AshenTwitchEvents.HelpTheStreamer[Helpmeitem]
		Bgift = AshenTwitchEvents.TrollTheStreamer[Trollmeitem]
		inv:AddItem(Ggift)
		inv:AddItem(Bgift)
		player:Say("So a " .. getItemNameFromFullType(Ggift) .. " with a " .. getItemNameFromFullType(Bgift) .. "! You have strange tastes " .. ViewerName .."!")
		args.message = username .. " ha ricevuto " .. getItemNameFromFullType(Ggift) .. " e " .. getItemNameFromFullType(Bgift)
		args.initiator = initiator
		sendClientCommand("AshenTwitch", "Say", args)
	elseif whatkind == 4 then
		inv:AddItem(LocalEventsTable["title"])
		end
end

--spawn x,y,z randomizer needs improvement
function SpawnLoc(maxValue)
    local mx = getPlayer():getX();
    local my = getPlayer():getY();
    local mz = getPlayer():getZ();
    --local DistOffset = ZombRand(40,85);
    local DistOffset = ZombRand(25,maxValue);
	local Operation = ZombRand(1,5);
    local logic ={
        function() mx = mx + DistOffset end,
        function() mx = mx - DistOffset end,
        function() my = my + DistOffset end,
        function() my = my - DistOffset end
    }
    logic[Operation]()
    return mx,my,mz
end

function handshake(module, command, args)
    if module ~= "AshenTwitchEvents" or command ~= "Handshake" then
        return
    end

	playerChar = getPlayer()
	-- print('------------=Twitch Events: Handshake=------------', args.initiator, args.state)
	if args.state == "Accepted" then
		-- print("--TWEEVENT- Handshake ACCEPTED -- " .. args.initiator)
		-- perform the event
		if AshenTwitchEvents.Options.acceptEvents or playerChar:getUsername() == args.initiator then
			-- print("accepting events", AshenTwitchEvents.Options.acceptEvents)
			-- print("player is initiator", playerChar:getUsername() == args.initiator)
			performEvent(args.EventsTable, args.initiator)
		end

		-- if playerChar:getUsername() == args.initiator then
		-- 	print("mio eventooo")
		-- end
		-- args.state = "Join"
		-- sendClientCommand("TWEEvents", "Handshake", args); -- Trigger Event from Client to Server
	-- elseif result.state == "Execute" then
	-- 	print("--TWEEVENT- Handshake ACCEPTED -- " .. args.initiator)
	end
end


Commands.AshenTwitch.Say = function(source, args)
	playerChar = getPlayer()
	if args.initiator == playerChar:getUsername() then
		playerChar:Say(args.message)
	end
end


local onClientCommand = function(module, command, source, args) -- Events Constructor.
    if ClientCommands[module] and ClientCommands[module][command] then
	    ClientCommands[module][command](source, args)
    end
end

Events.OnServerCommand.Add(handshake)
Events.OnClientCommand.Add(onClientCommand)

return TWE_Events