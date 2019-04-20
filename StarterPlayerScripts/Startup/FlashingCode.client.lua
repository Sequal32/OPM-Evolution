while true do
	wait(0.5)
	for i = 1,10 do
		script.Parent.ImageTransparency = script.Parent.ImageTransparency + 0.1
		wait()
	end
	wait(0.5)
		for i = 1,10 do
		script.Parent.ImageTransparency = script.Parent.ImageTransparency - 0.1
		wait()
	end
end