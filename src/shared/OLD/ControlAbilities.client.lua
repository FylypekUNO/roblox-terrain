--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MovementStats = {
	Speed = 16,
	Jump = 50
}

local function applyStats(character: Model?)
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = MovementStats.Speed
		humanoid.UseJumpPower = true
		humanoid.JumpPower = MovementStats.Jump
	end
end

local function createUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MovementControlUI"
	screenGui.Parent = playerGui
	screenGui.ResetOnSpawn = false

	local sliderContainer = Instance.new("Frame")
	sliderContainer.Name = "SliderContainer"
	sliderContainer.Size = UDim2.new(0, 150, 0, 140)
	sliderContainer.Position = UDim2.new(0, 20, 1, -160) -- Przeniesione na lewo i zmniejszone
	sliderContainer.BackgroundTransparency = 0.5
	sliderContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	sliderContainer.BorderSizePixel = 0
	sliderContainer.Parent = screenGui

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.Padding = UDim.new(0, 20)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Parent = sliderContainer

	local function createSlider(name: string, color: Color3, minVal: number, maxVal: number, defaultVal: number)
		local frame = Instance.new("Frame")
		frame.Name = name .. "Slider"
		frame.Size = UDim2.new(0, 35, 0, 90) -- Zmniejszona wysokość slidera
		frame.BackgroundTransparency = 1
		frame.Parent = sliderContainer

		local track = Instance.new("Frame")
		track.Name = "Track"
		track.Size = UDim2.new(0, 6, 1, 0)
		track.Position = UDim2.new(0.5, -3, 0, 0)
		track.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		track.BorderSizePixel = 0
		track.Parent = frame

		local handle = Instance.new("Frame")
		handle.Name = "Handle"
		handle.Size = UDim2.new(0, 20, 0, 10)
		local startPos = 1 - ((defaultVal - minVal) / (maxVal - minVal))
		handle.Position = UDim2.new(0.5, -10, math.clamp(startPos, 0, 1), -5)
		handle.BackgroundColor3 = color
		handle.BorderSizePixel = 0
		handle.ZIndex = 2
		handle.Parent = frame

		local label = Instance.new("TextLabel")
		label.Text = name
		label.Size = UDim2.new(0, 40, 0, 15)
		label.Position = UDim2.new(0.5, -20, 0, -20)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.Font = Enum.Font.SourceSansBold
		label.TextSize = 12
		label.Parent = frame

		local valLabel = Instance.new("TextLabel")
		valLabel.Text = tostring(defaultVal)
		valLabel.Size = UDim2.new(0, 40, 0, 15)
		valLabel.Position = UDim2.new(0.5, -20, 1, 5)
		valLabel.BackgroundTransparency = 1
		valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		valLabel.Font = Enum.Font.SourceSans
		valLabel.TextSize = 12
		valLabel.Parent = frame

		local dragging = false

		local function update(inputY)
			local trackAbsPos = track.AbsolutePosition.Y
			local trackAbsSize = track.AbsoluteSize.Y
			local relativeY = math.clamp(inputY - trackAbsPos, 0, trackAbsSize)
			local percentage = 1 - (relativeY / trackAbsSize)

			handle.Position = UDim2.new(0.5, -10, 1 - percentage, -5)
			local finalValue = math.floor(minVal + (percentage * (maxVal - minVal)))
			valLabel.Text = tostring(finalValue)

			MovementStats[name] = finalValue
			applyStats(player.Character)
		end

		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				update(input.Position.Y)
			end
		end)
	end

	-- Speed ustawione na max 500
	createSlider("Speed", Color3.fromRGB(255, 115, 0), 0, 500, 16)
	createSlider("Jump", Color3.fromRGB(0, 170, 255), 0, 250, 50)
end

player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	applyStats(character)
end)

createUI()
if player.Character then
	applyStats(player.Character)
end