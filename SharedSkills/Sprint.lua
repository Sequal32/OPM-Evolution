local Sprint = {}

function Sprint.Disable()
	Sprint.Humanoid.WalkSpeed = Sprint.WalkSpeed
end

function Sprint.Enable(WalkSpeed)
	Sprint.WalkSpeed = WalkSpeed
	Sprint.Humanoid.WalkSpeed = WalkSpeed*2
end

function Sprint.New(Plr)
	Sprint.Humanoid = Plr.Character.Humanoid
end

return Sprint