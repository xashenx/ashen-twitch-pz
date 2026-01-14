if isServer() then return end;

LOCAL_SWITCH_STATE = false
SERVER_SWITCH_STATE = false

local function sendAction(scope, action)
    print("AshenTwitchEvents Menu Action: " .. scope .. " -> " .. action)
    if scope == "local" then
        if action == "on" then
            LOCAL_SWITCH_STATE = false
        elseif action == "off" then
            LOCAL_SWITCH_STATE = true
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
        if SERVER_SWITCH_STATE then
            menu:addOption("SERVER: DISABLED (Click to Enable)", nil, function() sendAction("server", "on") end)
        else
            menu:addOption("SERVER: ENABLED (Click to Disable)", nil, function() sendAction("server", "off") end)
        end
    end

    if LOCAL_SWITCH_STATE then
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
    print("AshenTwitchEvents Menu received server switch state -> " .. tostring(reponseData["serverSwitchState"]))
    SERVER_SWITCH_STATE = reponseData["serverSwitchState"]
end

Events.OnServerCommand.Add(onServerResponse)
Events.OnFillWorldObjectContextMenu.Add(doMenu)