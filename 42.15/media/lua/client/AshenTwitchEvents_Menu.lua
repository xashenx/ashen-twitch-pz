if isServer() then return end;
AshenTwitchEvents = AshenTwitchEvents or {}
-- AshenTwitchEvents.LOCAL_SWITCH_STATE = true
AshenTwitchEvents.SERVER_SWITCH_STATE = nil
-- AshenTwitchEvents.Options = AshenTwitchEvents.Options or {}
-- AshenTwitchEvents.Options.SoundsEnabled = true
-- AshenTwitchEvents.Options.AcceptEvents = false
-- AshenTwitchEvents.whitelisted = nil

local function sendAction(scope, action)
    -- print("AshenTwitchEvents Menu Action: " .. scope .. " -> " .. action)
    -- if scope == "local" then
    --     if action == "on" then
    --         AshenTwitchEvents.LOCAL_SWITCH_STATE = true
    --     elseif action == "off" then
    --         AshenTwitchEvents.LOCAL_SWITCH_STATE = false
    --     end
    -- elseif scope == "sounds" then
    --     if action == "on" then
    --         AshenTwitchEvents.Options.SoundsEnabled = true
    --     elseif action == "off" then
    --         AshenTwitchEvents.Options.SoundsEnabled = false
    --     end
    -- elseif scope == "acceptevents" then
    --     if action == "on" then
    --         AshenTwitchEvents.Options.AcceptEvents = true
    --     elseif action == "off" then
    --         AshenTwitchEvents.Options.AcceptEvents = false
    --     end
    -- elseif scope == "server" then
    if scope == "server" then
        sendClientCommand("AshenTwitch", "ToggleServerSwitch", { action = action })
    end
end

local function doMenu(playerIndex, context, worldobjects, test)
    local player = getSpecificPlayer(playerIndex)
    local isadmin = player:getAccessLevel() == "admin"
    -- first we check the whitelisted status
    -- if AshenTwitchEvents.whitelisted == nil then
    --     sendClientCommand("AshenTwitch", "RequestWhitelistState", {})
    -- end

    local mainMenu = ISContextMenu:getNew(context)
    if not mainMenu then return true end
    
    -- if not isadmin and not AshenTwitchEvents.whitelisted then return true end
    local atwitch_menu = context:addOption("Ashen Twitch", worldobjects, nil)
    context:addSubMenu(atwitch_menu, mainMenu)
    -- if AshenTwitchEvents.whitelisted then
    --     if AshenTwitchEvents.Options.SoundsEnabled then
    --         mainMenu:addOption("SOUNDS: ON", nil, function() sendAction("sounds", "off") end)
    --     else
    --         mainMenu:addOption("SOUNDS: OFF", nil, function() sendAction("sounds", "on") end)
    --     end

    --     if AshenTwitchEvents.Options.AcceptEvents then
    --         mainMenu:addOption("FORWARDED EVENTS: ON", nil, function() sendAction("acceptevents", "off") end)
    --     else
    --         mainMenu:addOption("FORWARDED EVENTS: OFF", nil, function() sendAction("acceptevents", "on") end)
    --     end
    -- end
    if isadmin then
        if not AshenTwitchEvents.SERVER_SWITCH_STATE then
            mainMenu:addOption("SERVER SWITCH: DISABLED (Click to Enable)", nil, function() sendAction("server", "on") end)
        else
            mainMenu:addOption("SERVER SWITCH: ENABLED (Click to Disable)", nil, function() sendAction("server", "off") end)
        end
    end

    -- if AshenTwitchEvents.whitelisted then
    --     if not AshenTwitchEvents.LOCAL_SWITCH_STATE then
    --         mainMenu:addOption("LOCAL SWITCH: DISABLED (Click to Enable)", nil, function() sendAction("local", "on") end)
    --     else
    --         mainMenu:addOption("LOCAL SWITCH: ENABLED (Click to Disable)", nil, function() sendAction("local", "off") end)
    --     end
    -- end
    return true
end

local onServerResponse = function(module, command, reponseData)
    -- handles the response from the server
     -- drop messages not intended for AshenTwitch
    if module ~= "AshenTwitch" then
        return
    end
    -- print("AshenTwitchEvents Menu received server switch state -> " .. tostring(reponseData["serverSwitchState"]))
    if command == "serverSwitchState" then
        AshenTwitchEvents.SERVER_SWITCH_STATE = reponseData["serverSwitchState"]
    -- elseif command == "whitelistState" then
    --     AshenTwitchEvents.whitelisted = reponseData.whitelisted
    end
end

local function RequestServerUpdate()
    local player = getSpecificPlayer(0)
    local isadmin = player:getAccessLevel() == "admin"
    if AshenTwitchEvents.SERVER_SWITCH_STATE ~= nil or not isadmin then
        Events.OnPlayerUpdate.Remove(RequestServerUpdate)
    else        
        -- print("AshenTwitchEvents Menu requesting server switch state")
        sendClientCommand("AshenTwitch", "RequestServerSwitchState", {})
    end
end

Events.OnPlayerUpdate.Add(RequestServerUpdate)
Events.OnServerCommand.Add(onServerResponse)
Events.OnFillWorldObjectContextMenu.Add(doMenu)