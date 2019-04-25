-- Services
CS = game:GetService("CollectionService")
RP = game:GetService("ReplicatedStorage")
TS = game:GetService("TweenService")
SS = game:GetService("ServerScriptService")
SD = game:GetService("ServerStorage")
-- Paths
Resources = SD.Resources
DisableSkills = RP.Events.General.DisableSkills
-- Objects
SnareReachObject = Resources.SnareReach
SnareGrabObject = Resources.SnareGrab
-- Requirements
Misc = require(RP.General.Misc)

function Snare(Character, TargetPlayer)
    local PlayerPrimaryPart = TargetPlayer.Character.PrimaryPart
    local PlayerStats = SS.Updates.GetPlayerData:Invoke(TargetPlayer)

    local SnareReach = SnareReachObject:Clone()
    SnareReach.CFrame = Character.PrimaryPart.CFrame
    SnareReach.Size = Vector3.new(0.5, 0.616, 0)
    SnareReach.Parent = workspace.Projectiles

    CS:AddTag(SnareReach, "ProjectileIgnore")

    local TargetPosition = PlayerPrimaryPart.Position
    local TargetCFrame = CFrame.new(Character.PrimaryPart.Position, TargetPosition)
    TargetPosition = TargetPosition+TargetCFrame.lookVector*3
    local Distance = (Character.PrimaryPart.Position-TargetPosition).magnitude
    local Tween = TS:Create(SnareReach, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {CFrame = TargetCFrame+TargetCFrame.lookVector*Distance/2, Size = Vector3.new(0.5, 0.616, Distance)})
    Character.PrimaryPart.Anchored = true
    Tween:Play()
    Tween.Completed:wait()

    -- local Percentage = 100-math.floor(PlayerStats.StrengthLevel/10)
    -- if math.random(0, 100) > Percentage then return end
    -- Detect if the thing hit the player
    local Characters = Misc.FindCharactersInVicinity(TargetPosition, 3, true)
    -- If so disable skills and do damage
    TS:Create(SnareReach, TweenInfo.new(0.1), {Transparency = 1}):Play()

    for _,Character in pairs(Characters) do
        print(Character[1])
        if Character[1] == TargetPlayer.Character then
            TargetPlayer.Character.PrimaryPart.Anchored = true
            -- Wrap the player
            local SnareGrab = SnareGrabObject:Clone()
            SnareGrab.CFrame = TargetPlayer.Character.PrimaryPart.CFrame*CFrame.new(0, -1.25, -2.9)
            SnareGrab.Parent = workspace.Projectiles

            DisableSkills:FireClient(TargetPlayer, 5)
            wait(5)
            SnareGrab:Destroy()
            TargetPlayer.Character.PrimaryPart.Anchored = false
            -- Updates.HealthChange:Invoke(game.Players:GetPlayerFromCharacter(Character[1]), -3000)
            break
        end
    end
    Character.PrimaryPart.Anchored = false
    wait(0.1)
    SnareReach:Destroy()
end

return Snare