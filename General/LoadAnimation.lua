
function LoadAnimation(Humanoid, AnimationId)
	local Anim = Instance.new("Animation")
	Anim.AnimationId = "rbxassetid://"..AnimationId
	return Humanoid:LoadAnimation(Anim) -- Returns animation track
end

return LoadAnimation