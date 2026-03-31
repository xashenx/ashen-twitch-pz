local MODULE_ID = "AshenTwitch"

AshenTwitchEvents = AshenTwitchEvents or {}
AshenTwitchEvents.MODULE_ID = MODULE_ID


AshenTwitchEvents.Options = {
    -- ReqElecLvl   = 0,
    EnableRedeem  = true,
    SoundsEnabled = true,
    AcceptEvents  = false,
}

local PZOptions

local config = {
    -- ReqElecLvl   = nil,
    EnableRedeem  = nil,
    SoundsEnabled = nil,
    AcceptEvents  = nil,
}

local function applyOptions()
    local options = PZAPI.ModOptions:getOptions(MODULE_ID)

    if options then
        -- AshenTwitchEvents.Options.ReqElecLvl  = options:getOption("ReqElecLvl"):getValue()
        AshenTwitchEvents.Options.EnableRedeem = options:getOption("EnableRedeem"):getValue()
        AshenTwitchEvents.Options.SoundsEnabled = options:getOption("SoundsEnabled"):getValue()
        AshenTwitchEvents.Options.AcceptEvents = options:getOption("AcceptEvents"):getValue()

    else
        print("AshenTwitchEvents: Could not load saved settings.  Using defaults.")
    end
end

local function initConfig()
    PZOptions = PZAPI.ModOptions:create(MODULE_ID, getText("UI_AshenTwitchEvents_Options_Title"))

    -- config.ReqElecLvl = PZOptions:addSlider(
    --     "ReqElecLvl",
    --     getText("UI_AshenTwitchEvents_Options_ReqLevel"),
    --     0,
    --     10,
    --     1,
    --     AshenTwitchEvents.Options.ReqElecLvl,
    --     getText("UI_AshenTwitchEvents_Options_ReqLevel_Tooltip")
    -- )

    config.EnableRedeem = PZOptions:addTickBox(
        "EnableRedeem",
        getText("UI_AshenTwitchEvents_Options_EnableRedeem"),
        AshenTwitchEvents.Options.EnableRedeem,
        getText("UI_AshenTwitchEvents_Options_EnableRedeem_Tooltip")
    )

    config.SoundsEnabled = PZOptions:addTickBox(
        "SoundsEnabled",
        getText("UI_AshenTwitchEvents_Options_SoundsEnabled"),
        AshenTwitchEvents.Options.SoundsEnabled,
        getText("UI_AshenTwitchEvents_Options_SoundsEnabled_Tooltip")
    )

    config.AcceptEvents = PZOptions:addTickBox(
        "AcceptEvents",
        getText("UI_AshenTwitchEvents_Options_AcceptEvents"),
        AshenTwitchEvents.Options.AcceptEvents,
        getText("UI_AshenTwitchEvents_Options_AcceptEvents_Tooltip")
    )

    PZOptions.apply = function ()
        applyOptions()
    end
end

initConfig()

Events.OnMainMenuEnter.Add(function()
    applyOptions()
end)

return AshenTwitchEvents.Options