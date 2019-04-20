Animation = {}

function Animation:Play()
	Animation.AnimTrack:Play()
	Animation.AnimTrack:AdjustWeight(Animation.Weight)
end

function Animation:Stop()
	Animation.AnimTrack:Stop()
end

function Animation.New(Humanoid, AnimationId, Weight)
	local Anim = Instance.new("Animation")
	Anim.AnimationId = "rbxassetid://"..AnimationId
	Animation.AnimTrack = Humanoid:LoadAnimation(Anim) -- Returns animation track
	Animation.Weight = Weight or 1
end

return Animation