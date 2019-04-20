Player = game.Players.LocalPlayer
Camera = workspace.CurrentCamera

Camera.CameraType = Enum.CameraType.Scriptable
Camera.CameraSubject = nil

Camera.CFrame = CFrame.new(-775.307861, 120.499931, 978.388794)

Stop = false

script.Stop.Event:Connect(function()
	Camera.CameraType = Enum.CameraType.Custom
	Stop = true
	repeat wait() until Player.Character
	Camera.CameraSubject = Player.Character
end)

while not Stop do
	Camera.CFrame = Camera.CFrame * CFrame.Angles(0, math.rad(0.1), 0)
	wait()
end