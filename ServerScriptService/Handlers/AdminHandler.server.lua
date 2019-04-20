SS = game:GetService("ServerScriptService")
RP = game:GetService("ReplicatedStorage")
Players = game:GetService("Players")

Updates = SS.Updates
CheckAdmin = require(RP.General.CheckAdmin)

BannedPlayers = Updates.GetData:Invoke("BannedPlayers") or {}

RP.Events.Admin.Teleport.OnServerEvent:Connect(function(Player, TargetPlayer, TargetTPPlayer)
    if not CheckAdmin(Player) then return end
    TargetPlayer.Character:SetPrimaryPartCFrame(TargetTPPlayer.Character.PrimaryPart.CFrame)
end)

RP.Events.Admin.Kick.OnServerEvent:Connect(function(Player, KickingPlayer)
    if not CheckAdmin(Player) then return end
    KickingPlayer:Kick("An admin has kicked you from the server.")
end)

RP.Events.Admin.Ban.OnServerEvent:Connect(function(Player, BanningPlayer)
    if not CheckAdmin(Player) then return end
    Updates.UpdateData:Invoke(nil, "BannedPlayers", function(OldData)
        if not OldData then OldData = {} end
        table.insert(OldData, Player.UserId)
        return OldData
    end)
    BanningPlayer:Kick("An admin has banned you from the server.")
end)

game.Players.PlayerAdded:Connect(function(Player)
    local Banned
    for _,BannedPlayer in pairs(BannedPlayers) do
        if BannedPlayer.UserId == Player.UserId then
            Player:Kick("You are banned.")
        end
    end
end)