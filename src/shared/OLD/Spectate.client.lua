local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local flying = false
local flyingSpeed = 50
local velocity = Vector3.new(0,0,0)
local direction = Vector3.new(0,0,0)
local cameraCFrame = camera.CFrame

-- Tworzenie GUI i przycisku
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpectateGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local spectateButton = Instance.new("TextButton")
spectateButton.Name = "SpectateButton"
spectateButton.Size = UDim2.new(0, 150, 0, 40)
spectateButton.Position = UDim2.new(0, 20, 0, 20)
spectateButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
spectateButton.BackgroundTransparency = 0.5
spectateButton.TextColor3 = Color3.fromRGB(255,255,255)
spectateButton.Font = Enum.Font.SourceSansBold
spectateButton.TextSize = 22
spectateButton.Text = "Spectate"
spectateButton.Parent = screenGui

-- Funkcja do aktualizacji kierunku latania zgodnie z naciśniętymi klawiszami
local function updateDirection()
	direction = Vector3.new(0,0,0)
	if userInputService:IsKeyDown(Enum.KeyCode.W) then
		direction = direction + cameraCFrame.LookVector
	end
	if userInputService:IsKeyDown(Enum.KeyCode.S) then
		direction = direction - cameraCFrame.LookVector
	end
	if userInputService:IsKeyDown(Enum.KeyCode.A) then
		direction = direction - cameraCFrame.RightVector
	end
	if userInputService:IsKeyDown(Enum.KeyCode.D) then
		direction = direction + cameraCFrame.RightVector
	end
	if userInputService:IsKeyDown(Enum.KeyCode.Space) then
		direction = direction + Vector3.new(0,1,0)
	end
	if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		direction = direction - Vector3.new(0,1,0)
	end
	if direction.Magnitude > 0 then
		direction = direction.Unit
	end
end

-- Sterowanie kamerą w trybie latania
local heartbeatConn

local function startFlying()
	flying = true
	camera.CameraType = Enum.CameraType.Scriptable
	cameraCFrame = camera.CFrame

	heartbeatConn = runService.Heartbeat:Connect(function(dt)
		updateDirection()
		velocity = direction * flyingSpeed
		cameraCFrame = cameraCFrame + velocity * dt
		camera.CFrame = cameraCFrame
	end)
end

local function stopFlying()
	flying = false
	if heartbeatConn then
		heartbeatConn:Disconnect()
		heartbeatConn = nil
	end
	camera.CameraType = Enum.CameraType.Custom
end

spectateButton.MouseButton1Click:Connect(function()
	if flying then
		stopFlying()
		spectateButton.Text = "Spectate"
	else
		startFlying()
		spectateButton.Text = "Stop Spectate"
	end
end)
