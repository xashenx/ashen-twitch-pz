
local calendar = PZCalendar.getInstance()
local hour = calendar:get(Calendar.HOUR_OF_DAY)
local minute = calendar:get(Calendar.MINUTE)
local second = calendar:get(Calendar.SECOND)
local ZKillTimer = nil
local ZKilltimeout = 10
local lastKillReward = {}
local PlayerSpawnTime = nil
local PlayerSpawnDelta = 200000

AshenTwitchEvents = AshenTwitchEvents or {}
AshenTwitchEvents.client = AshenTwitchEvents.client or {}

if hour == 0 then --check if its 0, if true replaces 0 with 24
    ZKillTimer = (24 * 60 + minute + ZKilltimeout) * 60 + second
else 
    ZKillTimer = (hour * 60 + minute + ZKilltimeout) * 60 + second
end
local lastCheck = (hour * 60 + minute) * 60 + second

AshenTwitchEvents.client.checkForEvent = function()
    local playerChar = getSpecificPlayer(0)
    local calendar = PZCalendar.getInstance()
    local hour = calendar:get(Calendar.HOUR_OF_DAY)
    local minute = calendar:get(Calendar.MINUTE)
    local second = calendar:get(Calendar.SECOND)
    local currentTime = nil
    if hour == 0 then --check if its 0, if true replaces 0 with 24
        currentTime = (24 * 60 + minute) * 60 + second
    else 
        currentTime = (hour * 60 + minute) * 60 + second
    end

    if ZKillTimer <= currentTime or lastCheck > currentTime then
        -- print("------------- AAI: zombie spawn event -------------")
        local roll = ZombRand(1,7)
        if roll > 1 then -- 30%
            -- print('skip zombie spawn event: ', roll)
            return
        elseif roll > 2 then -- 30%
            -- reset ZKillTimer
            AshenTwitchEvents.client.updateZombieTimer()
        end

        event = {}
        event.type = "zombie_spawn"
        local horde_roll = ZombRand(1,21)
        if horde_roll == 20 then -- 5%
            event.runner = false
            event.toothless = false
            event.horde = true
            local horde_roll = ZombRand(1,31)
            if horde_roll == 30 then -- 3.3%
                playerChar:Say("EVENTO GRANDE ORDA")
                event.zedquant = AshenTwitchEvents.hordeZedQnt
                event.zedpacks = 5
            elseif horde_roll > 19  then -- 33.3%
                playerChar:Say("EVENTO ORDA MEDIA")
                event.zedquant = AshenTwitchEvents.hordeZedQnt
                event.zedpacks = 3
            else  -- 63.3%
                playerChar:Say("EVENTO PICCOLA ORDA")
                event.zedquant = AshenTwitchEvents.hordeZedQnt
                event.zedpacks = 1
            end
        else
            event.zedquant = ZombRand(1,3)
            if event.zedquant == 1 then
                event.zedpacks = ZombRand(1,3)
            else
                event.zedpacks = 1
            end
            
            if ZombRand(1,5) == 1 then -- 25%
                event.runner = true
            else
                event.runner = false
            end
            
            if ZombRand(1,6) == 1 then -- 20%
                event.toothless = true
            else
                event.toothless = false
            end
            event.horde = false
        end
        AshenTwitchEvents.client.performAAIevent(event)
        AshenTwitchEvents.client.updateZombieTimer()
    end
    lastCheck = currentTime
end

AshenTwitchEvents.client.killRewards = function(player)
    local kills = player:getLastZombieKills() + 1
    if not lastKillReward[player:getUsername()] then
        lastKillReward[player:getUsername()] = 0
    end

    if lastKillReward[player:getUsername()] < kills then
        local inv = player:getInventory()
        if kills == 100 then
            player:Say("Complimenti per i tuoi primi 100 kills")
            player:Say("ZombieMaster Ashen ti premia con " .. getItemNameFromFullType("Base.NailsBox"))
            player:playSound("Thank")
            inv:AddItem("Base.NailsBox")
        elseif kills == 250 then
            player:Say("Complimenti per i tuoi 250 kills")
            player:Say("ZombieMaster Ashen ti premia con " .. getItemNameFromFullType("Base.HammerStone"))
            player:playSound("Thank")
            inv:AddItem("Base.HammerStone")
        elseif kills == 500 then
            player:Say("Complimenti per i tuoi 500 kills")
            player:Say("ZombieMaster Ashen ti premia con " .. getItemNameFromFullType("Base.Nightstick"))
            player:playSound("Thank")
            inv:AddItem("Base.Nightstick")
        elseif kills == 1000 then
            player:Say("Complimenti per i tuoi 1000 kills")
            player:Say("ZombieMaster Ashen ti premia con " .. getItemNameFromFullType("Base.Axe"))
            player:playSound("Thank")
            inv:AddItem("Base.Axe")
        -- elseif kills == 1500 then
        --     player:Say("Complimenti per i tuoi 1500 kills")
        --     player:Say("ZombieMaster Ashen ti premia con " .. getItemNameFromFullType("Base.Axe"))
        --     player:playSound("Thank")
        --     inv:AddItem("Base.Axe")
        end
        lastKillReward[player:getUsername()] = kills
    end
end

AshenTwitchEvents.client.updateZombieTimer = function()
    local calendar = PZCalendar.getInstance()
    local hour = calendar:get(Calendar.HOUR_OF_DAY)
    local minute = calendar:get(Calendar.MINUTE)
    local second = calendar:get(Calendar.SECOND)
    if hour == 0 then --check if its 0, if true replaces 0 with 24
        ZKillTimer = (24 * 60 + minute + ZKilltimeout) * 60 + second
    else 
        ZKillTimer = (hour * 60 + minute + ZKilltimeout) * 60 + second
    end

    local playerZero = getSpecificPlayer(0)
    if not playerZero then 
        return
    else
        AshenTwitchEvents.client.killRewards(playerZero)
    end

    local playerRemote = getSpecificPlayer(1)
    if not playerRemote then 
        return
    else
        AshenTwitchEvents.client.killRewards(playerRemote)
    end
end

AshenTwitchEvents.client.onPerkLevel = function(character, perk, level, levelUp)
    -- print("------------- AAI: onPerkLevel -------------")
    if not levelUp then return end
    
    -- return if perk:getName() is equal to Fitness or Strength
    -- tmp fix for spawn events
    local calendar = PZCalendar.getInstance()
    local currentTime = calendar:getTimeInMillis()
    if currentTime < (PlayerSpawnTime + PlayerSpawnDelta) then
        return
    end

    roll = ZombRand(1,11)
    if roll >= (10 - level) or true then
        event = {}
        event.type = "gift"
        event.perk = perk
        event.level = level
        event.player = character
        event.initiator = character:getUsername()
        event.whatkind = 1
        event.message = "Complimenti per " .. perk:getName() .. " lv." .. level
        -- character:Say("Complimenti per " .. perk:getName() .. " lv." .. level)
        AshenTwitchEvents.client.performAAIevent(event)
    end
end

AshenTwitchEvents.client.playerDeath = function(player)
    local playerZero = getSpecificPlayer(0)
    local calendar = PZCalendar.getInstance()
    local currentTime = calendar:getTimeInMillis()
    PlayerSpawnTime = currentTime
    PlayerSpawnDelta = 200000
    if playerZero == player and AshenTwitchEvents.enableAI then
        Events.EveryTenMinutes.Remove(AshenTwitchEvents.client.checkForEvent)
        Events.LevelPerk.Remove(AshenTwitchEvents.client.onPerkLevel)
        Events.OnZombieDead.Remove(AshenTwitchEvents.client.updateZombieTimer)
        Events.OnPlayerDeath.Remove(AshenTwitchEvents.client.playerDeath)
    end
end

AshenTwitchEvents.client.newCharacter = function(playerIndex, player)
    local calendar = PZCalendar.getInstance()
    local currentTime = calendar:getTimeInMillis()
    PlayerSpawnTime = currentTime
    PlayerSpawnDelta = 5000
    if #AshenTwitchEvents.TWETraitsTable == 0 then
        getSandbox()
    end
    
    if playerIndex == 0 and AshenTwitchEvents.enableAI then
        Events.EveryTenMinutes.Add(AshenTwitchEvents.client.checkForEvent)
        Events.LevelPerk.Add(AshenTwitchEvents.client.onPerkLevel)
        Events.OnZombieDead.Add(AshenTwitchEvents.client.updateZombieTimer)
        Events.OnPlayerDeath.Add(AshenTwitchEvents.client.playerDeath)
    -- elseif playerIndex == 1 then -- remote player
    end
end

-- player
-- setBlockMovement
-- setForceSprint
Events.OnCreatePlayer.Add(newCharacter)