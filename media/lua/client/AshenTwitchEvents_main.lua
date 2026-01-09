Events.OnGameBoot.Add(print("------------=Twitch Events: alpha v0.56.1=------------"))
local json = require("AshenTwitchEvents_json")
local myevents = require("AshenTwitchEvents_Events")
local MyEventsTable = {}
AshenTwitchEvents = AshenTwitchEvents or {}
AshenTwitchEvents.client = AshenTwitchEvents.client or {}

-- function getreward()
AshenTwitchEvents.client.getreward = function()
    local player = getPlayer()
    local ReadReward = getFileReader("arewards.txt",true)
    json_string = ReadReward:readLine()
    ReadReward:close()
    if json_string ~= nil then
      MyEventsTable = json:decode(json_string)
      local EmptyRewardFile = getFileWriter("arewards.txt", false, false)
      EmptyRewardFile:write("")
      EmptyRewardFile:close()
      AshenTwitchEvents.client.performHandshake(MyEventsTable)
    end
end

Events.EveryOneMinute.Add(AshenTwitchEvents.client.getreward)
