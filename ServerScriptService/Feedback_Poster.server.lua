HS = game:GetService("HttpService")
RP = game:GetService("ReplicatedStorage")
SD = game:GetService("ServerStorage")

Events = RP.Events.General
Settings = require(SD.GameAnalytics.Settings)

URL = "https://triggers.losant.com/webhooks/7dviUjnMy9HOG1cTW1sJ_PTu1QBCaXKETDVAIk6DaA1$"


Events.PostBug.OnServerEvent:Connect(function(Player, Body)
	HS:PostAsync(URL, HS:JSONEncode({
		["type"] = "bug",
		["body"] = Body,
		["playerName"] = Player.Name,
		["playerUserId"] = Player.UserId,
		["build"] = Settings.Build
	}))
end)

Events.PostFeedback.OnServerEvent:Connect(function(Player, Body)
	HS:PostAsync(URL, HS:JSONEncode({
		["type"] = "feedback",
		["body"] = Body,
		["playerName"] = Player.Name,
		["playerUserId"] = Player.UserId,
		["build"] = Settings.Build
	}))
end)