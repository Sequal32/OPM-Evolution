RP = game:GetService("ReplicatedStorage")
SD = game:GetService("ServerStorage")

Settings = require(SD.GameAnalytics.Settings)
Events = RP.Events.General

function Events.GetServerVersion.OnServerInvoke(Player)
    return Settings.Build
end