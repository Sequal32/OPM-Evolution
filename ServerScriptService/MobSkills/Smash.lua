-- Paths
Debris = game:GetService("Debris")
Misc = require(game:GetService("ReplicatedStorage").General.Misc)
ShockwaveObject = game:GetService("ServerStorage").Resources.Shockwave
TS = game:GetService("TweenService")
Updates = game:GetService("ServerScriptService").Updates
-- Variables
NumGen = Random.new()

Offsets = {3, -3}

function Smash(Character, TargetPlayer)
    Character:SetPrimaryPartCFrame(TargetPlayer.Character.PrimaryPart.CFrame+Vector3.new(Offsets[NumGen:NextInteger(1, 2)], 2, Offsets[NumGen:NextInteger(1, 2)]))

    local Shockwave = ShockwaveObject:Clone()
    Shockwave:SetPrimaryPartCFrame(CFrame.new(Character.PrimaryPart.Position-Vector3.new(0, 0.5, 0), TargetPlayer.Character.PrimaryPart.Position))
    Shockwave.Parent = workspace.Projectiles

    TS:Create(Shockwave.Part1, TweenInfo.new(0.5), {Transparency = 1}):Play()
    TS:Create(Shockwave.Part2, TweenInfo.new(0.5), {Transparency = 1}):Play()

    local Characters = Misc.FindCharactersInVicinity(Character.PrimaryPart.Position, 20, true)
    for _,Character in pairs(Characters) do
        Updates.HealthChange:Invoke(game.Players:GetPlayerFromCharacter(Character[1]), -3000)
    end

    Debris:AddItem(Shockwave, 1)
end

return Smash