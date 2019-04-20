CAS = game:GetService("ContextActionService")
RP = game:GetService("ReplicatedStorage")
TS = game:GetService("TweenService")

Player = game.Players.LocalPlayer
PlayerGui = Player.PlayerGui
AdminPanel = PlayerGui:WaitForChild("AdminPanel"):WaitForChild("Panel")

PlayerListFrame = AdminPanel.PlayerListFrame
PlayerList = PlayerListFrame.PlayerList

CheckAdmin = require(RP.General.CheckAdmin)

Validated = {
    Level = false,
    Strength = false,
    Stamina = false,
    Agility = false
}

TargetPlayer = nil
TargetTPPlayer = nil
PlayerListOpen = false

PlayerListPositions = {
    Top = UDim2.new(0.501, 0, 0.277, 0),
    Bottom = UDim2.new(0.501, 0, 0.693, 0)
}

-- Cooldowns
SaveCooldown = 0

function ValidateSkillNumber(TextInstance)
    local Number = tonumber(TextInstance.Text)
    if not Number or Number > 250 or Number <= 0 then 
        TextInstance.Text = "Who you fooling with these numbers ya nimwit?"
    end
end

function CheckPlayer(TextInstance, Text)
    if not TargetPlayer then
        AdminPanel.SelectTPPlayer.Text = "Select Victim"
        TextInstance.Text = "Who you fooling?"
        wait(1)
        TextInstance.Text = Text
        return false
    end
    return true
end

function CheckTPPlayer(TextInstance)
    if not TargetTPPlayer then
        AdminPanel.SelectTPPlayer.Text = "Select Perp"
        TextInstance.Text = "Who you fooling?"
        wait(1)
        TextInstance.Text = Text
        return false
    end
    return true
end

-- SAVE FUNCTIONALITY

AdminPanel.Level.FocusLost:Connect(function()
    ValidateSkillNumber(AdminPanel.Level)
end)

AdminPanel.Strength.FocusLost:Connect(function()
    ValidateSkillNumber(AdminPanel.Strength)
end)

AdminPanel.Agility.FocusLost:Connect(function()
    ValidateSkillNumber(AdminPanel.Agility)
end)

AdminPanel.Stamina.FocusLost:Connect(function()
    ValidateSkillNumber(AdminPanel.Stamina)
end)

AdminPanel.Save.Activated:Connect(function()
    if not CheckPlayer(AdminPanel.Save, "Save Eternally") then return end
    if os.time()-SaveCooldown < 0 then AdminPanel.Save.Text = "too speedy for this meat" wait(2) AdminPanel.Save.Text = "Save Eternally" end

    RP.Events.Admin.AppendData:FireServer(
        tonumber(AdminPanel.Level.Text),
        tonumber(AdminPanel.Strength.Text),
        tonumber(AdminPanel.Agility.Text),
        tonumber(AdminPanel.Stamina.Text)
    )
    SaveCooldown = os.time()+10
end)

-- PLAYER SELECTION
function OpenPlayerList(Position)
    PlayerListOpen = true
    Players = game.Players:GetChildren()
    PlayerListFrame.Position = PlayerListPositions[Position]

    -- Tween frame
    TS:Create(PlayerList, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0, 0)}):Play()

    for _,Element in pairs(PlayerList:GetChildren()) do
        if Element:IsA("GuiBase2d") then
            Element:Destroy()
        end
    end

    for _,Player in pairs(Players) do
        local PlayerFrame = Instance.new("TextButton")
        PlayerFrame.Size = UDim2.new(1, 0, 0, 20)
        PlayerFrame.Text = Player.Name
        PlayerFrame.Parent = PlayerList

        PlayerFrame.Activated:Connect(function()
            if Position == "Top" then
                TargetPlayer = Player
                AdminPanel.SelectPlayer.Text = Player.Name
            else
                TargetTPPlayer = Player
                AdminPanel.SelectTPPlayer.Text = Player.Name
            end
            
            ClosePlayerList()
        end)
    end
end

function ClosePlayerList()
    PlayerListOpen = false
    TS:Create(PlayerList, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, -1, 0)}):Play()
end

AdminPanel.SelectPlayer.Activated:Connect(function()
    if PlayerListOpen then
        ClosePlayerList()
    else
        OpenPlayerList("Top")
    end
end)

AdminPanel.SelectTPPlayer.Activated:Connect(function()
    if PlayerListOpen then
        ClosePlayerList()
    else
        OpenPlayerList("Bottom")
    end
end)

-- KICK/BAN
AdminPanel.Ban.Activated:Connect(function()
    if not CheckPlayer(AdminPanel.Ban, "TO DEATH") then return end
    RP.Events.Admin.Ban:FireServer(TargetPlayer)
end)

AdminPanel.Kick.Activated:Connect(function()
    if not CheckPlayer(AdminPanel.Kick, "PAIN") then return end
    RP.Events.Admin.Kick:FireServer(TargetPlayer)
end)

-- Teleport
AdminPanel.Teleport.Activated:Connect(function()
    if not CheckPlayer(AdminPanel.Teleport, "Magic") and not CheckTPPlayer(AdminPanel.Teleport) then return end
    RP.Events.Admin.Teleport:FireServer(TargetPlayer, TargetTPPlayer)
end)

-- Connect if the user is an admin
function UIVisibility(ActionName, InputState)
    if InputState ~= Enum.UserInputState.Begin then return end
    if AdminPanel.Visible then
        AdminPanel.Visible = false
    else
        AdminPanel.Visible = true
    end
end

if CheckAdmin(Player) then
    CAS:BindAction("OpenAdminPanel", UIVisibility, false, Enum.KeyCode.F8)
else
    AdminPanel.Parent:Destroy()
    script:Destroy()
end
-- while true do
--     wait()
-- end