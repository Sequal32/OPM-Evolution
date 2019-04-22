NumGen = Random.new()
Debris = game:GetService("Debris")
Misc = require(game:GetService("ReplicatedStorage").General.Misc)
Updates = game:GetService("ServerScriptService").Updates
ShockwaveObject = game:GetService("ServerStorage").Resources.Shockwave

Offsets = {3, -3}

function Smash(Character, TargetPlayer)
    Character:SetPrimaryPartCFrame(TargetPlayer.Character.PrimaryPart.CFrame+Vector3.new(Offsets[NumGen:NextInteger(1, 2)], 0, Offsets[NumGen:NextInteger(1, 2)]))

    local Shockwave = ShockwaveObject:Clone()
    Shockwave.CFrame = Character.PrimaryPart.CFrame-Vector3.new(0, -0.5, 0)
    Shockwave.Parent = workspace.Projectiles

    Tween = TS:Create(Shockwave, TweenInfo.new(0.5), {Transparency = 1})
    Tween:Play()

    local Characters = Misc.FindCharactersInVicinity(Character.Position, 20, true)
    for _,Character in pairs(Characters) do
        Updates.ChangeHealth:Fire(game.Players:GetPlayerFromCharacter(Character), -3000)
    end

    Debris:AddItem(Shockwave, 1)
end

return Smash