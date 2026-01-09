AshenTwitchEvents = AshenTwitchEvents or {}
AshenTwitchEvents.Options = AshenTwitchEvents.Options or {}
AshenTwitchEvents.Options.acceptEvents = false

if ModOptions and ModOptions.getInstance then
    local function onModOptionsApply(optionValues)
        AshenTwitchEvents.Options.acceptEvents = optionValues.settings.options.acceptEvents
    end

    local function onModOptionApplyInGame(optionValues)
        AshenTwitchEvents.Options.acceptEvents = optionValues.settings.options.acceptEvents
    end

    local SETTINGS = {
        options_data = {
            acceptEvents = {
                name = "UI_Options_acceptEvents",
                tooltip = "UI_Options_acceptEvents_tooltip",
                default = false,
                OnApplyMainMenu = onModOptionsApply,
                OnApplyInGame = onModOptionApplyInGame,
            },
        },

        mod_id = 'AshenTwitch',
        mod_shortname = 'AshenTwitch',
        mod_fullname = 'AshenTwitch',
    }
    
    local optionsInstance = ModOptions:getInstance(SETTINGS)
    ModOptions:loadFile()

    Events.OnPreMapLoad.Add(function() onModOptionsApply({ settings = SETTINGS }) end)
end