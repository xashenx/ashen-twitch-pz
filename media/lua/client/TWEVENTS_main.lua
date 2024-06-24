Events.OnGameBoot.Add(print("------------=Twitch Events: alpha v0.56.1=------------"))
local json = require("json")
local myevents = require("TWEEVENTS_Events")
local MyEventsTable = {}

function getreward()
    local ReadReward = getFileReader("arewards.txt",true)
    json_string = ReadReward:readLine()
    ReadReward:close()
    if json_string ~= nil then
      MyEventsTable = json:decode(json_string)	
      local EmptyRewardFile = getFileWriter("arewards.txt", false, false)
      EmptyRewardFile:write("")
      EmptyRewardFile:close()
      performHandshake(MyEventsTable)
    end
end

Events.EveryOneMinute.Add(getreward)
