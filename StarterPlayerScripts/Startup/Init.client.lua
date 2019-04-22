-- Services
RP = game:GetService("ReplicatedStorage")

local Player = game.Players.LocalPlayer
local General = RP.General
local GeneralEvents = RP.Events.General

-- Some location constants
local PlayerScripts = Player.PlayerScripts
local AfterLoadedScripts = PlayerScripts.AfterCharacter
local Startup = PlayerScripts.Startup
local CharacterScripts = PlayerScripts.Characters
local CurrentClass = "SuperHuman"
-- Enable scripts
function Reset()
	repeat wait() until Player.Character
	
	workspace.CurrentCamera.CameraSubject = Player.Character
	Player.Character.Animate.Disabled = false

	require(General.Player).New(Player)

	for _,s in pairs(AfterLoadedScripts:GetChildren()) do
		s.Disabled = true
		s.Disabled = false
	end
end

Player.CharacterAdded:Connect(function()
	Reset()
end)

-- Character selection
GeneralEvents.CharacterChange.Event:Connect(function(CharacterName)
	AfterLoadedScripts:FindFirstChild(CurrentClass.."Client").Parent = CharacterScripts
	CharacterScripts:FindFirstChild(CharacterName.."Client").Parent = AfterLoadedScripts
	Reset()
end)

-- Quest Setup
local DoneAccepting = true
QuestGivers = {workspace.Genos}

Startup.DoneAccepting.Event:Connect(function()
    DoneAccepting = true
end)

for _,Giver in pairs(QuestGivers) do
    Giver.Head.Dialog.DialogChoiceSelected:Connect(function(Player, DialogChoice)
        if DialogChoice.Name == "Quest" and DoneAccepting then
            DoneAccepting = false
            GeneralEvents.QuestProgression:FireServer("Start")
        end
    end)   
end