local Player = game.Players.LocalPlayer
local Character = Player.Character

local Mouse = Player:GetMouse()
local Modules = script.Parent.Parent.Modules

local TS = game:GetService("TweenService")
local UpperTorsoC1 = Character.UpperTorso.Waist.C1
local HeadC1 = Character.Head.Neck.C1

local cacheOffset = 0

Utils = require(Modules.MouseUtils)

Mouse.Move:connect(function()
	if not Character.UpperTorso:FindFirstChild("Waist") then return end

	local offset = Mouse.Origin.lookVector-Character.PrimaryPart.CFrame.lookVector
	local angleOffset = math.atan(offset.Z/offset.X)
	local tInfo = TweenInfo.new(0.1)
	
	TS:Create(Character.UpperTorso.Waist, tInfo, {["C1"] = UpperTorsoC1*CFrame.Angles(0, angleOffset/6, 0)}):Play()
	if math.abs(angleOffset) > 0.3 then
		TS:Create(Character.Head.Neck, tInfo, {["C1"] = HeadC1*CFrame.Angles(0, angleOffset, 0)}):Play()
	end
	
	cacheOffset = angleOffset
end)