if isServer() then return end;
AshenTwitchEvents = AshenTwitchEvents or {}
AshenTwitchEvents.LOCAL_SWITCH_STATE = true
AshenTwitchEvents.SERVER_SWITCH_STATE = nil

local function sendAction(scope, action)
    -- print("AshenTwitchEvents Menu Action: " .. scope .. " -> " .. action)
    if scope == "local" then
        if action == "on" then
            AshenTwitchEvents.LOCAL_SWITCH_STATE = true
        elseif action == "off" then
            AshenTwitchEvents.LOCAL_SWITCH_STATE = false
        end
    elseif scope == "server" then
        sendClientCommand("AshenTwitch", "ToggleServerSwitch", { action = action })
    end
end

local function doMenu(playerIndex, context, worldobjects, test)
    local player = getSpecificPlayer(playerIndex)
    local isadmin = player:getAccessLevel() == "admin"

    local menu = ISContextMenu:getNew(context)
    if not menu then return true end
    
    if not isadmin then return true end
    local opt = context:addOption("Ashen Twitch", worldobjects, nil)
    context:addSubMenu(opt, menu)

    if isadmin then
        if not AshenTwitchEvents.SERVER_SWITCH_STATE then
            menu:addOption("SERVER: DISABLED (Click to Enable)", nil, function() sendAction("server", "on") end)
        else
            menu:addOption("SERVER: ENABLED (Click to Disable)", nil, function() sendAction("server", "off") end)
        end
    end

    if not AshenTwitchEvents.LOCAL_SWITCH_STATE then
        menu:addOption("LOCAL: DISABLED (Click to Enable)", nil, function() sendAction("local", "on") end)
    else
        menu:addOption("LOCAL: ENABLED (Click to Disable)", nil, function() sendAction("local", "off") end)
    end

    return true
end

local onServerResponse = function(module, command, reponseData)
    -- handles the response from the server
    if module ~= "AshenTwitch" or command ~= "serverSwitchState" then
        return
    end
    -- print("AshenTwitchEvents Menu received server switch state -> " .. tostring(reponseData["serverSwitchState"]))
    AshenTwitchEvents.SERVER_SWITCH_STATE = reponseData["serverSwitchState"]
end

local function RequestServerUpdate()
    local player = getSpecificPlayer(0)
    local isadmin = player:getAccessLevel() == "admin"
    if AshenTwitchEvents.SERVER_SWITCH_STATE ~= nil or  not isadmin then
        Events.OnPlayerUpdate.Remove(RequestServerUpdate)
    else        
        -- print("AshenTwitchEvents Menu requesting server switch state")
        sendClientCommand("AshenTwitch", "RequestServerSwitchState", {})
    end
end

Events.OnPlayerUpdate.Add(RequestServerUpdate)
Events.OnServerCommand.Add(onServerResponse)
Events.OnFillWorldObjectContextMenu.Add(doMenu)