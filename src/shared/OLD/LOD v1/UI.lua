-- !strict

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

local function createUI(LODContainer: { LOD: number }): ()
	-- Create ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PointControlUI"
	screenGui.Parent = playerGui
	screenGui.ResetOnSpawn = false

	-- Create container for sliders
	local sliderContainer = Instance.new("Frame")
	sliderContainer.Name = "SliderContainer"
	sliderContainer.Size = UDim2.new(0, 300, 0, 200)
	sliderContainer.Position = UDim2.new(1, -320, 1, -220) -- bottom right
	sliderContainer.BackgroundTransparency = 0.5
	sliderContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	sliderContainer.BorderSizePixel = 0
	sliderContainer.Parent = screenGui

	-- Create sliders layout container
	local sliderLayoutFrame = Instance.new("Frame")
	sliderLayoutFrame.Name = "SlidersLayout"
	sliderLayoutFrame.Size = UDim2.new(1, -20, 1, -40)
	sliderLayoutFrame.Position = UDim2.new(0, 10, 0, 35)
	sliderLayoutFrame.BackgroundTransparency = 1
	sliderLayoutFrame.Parent = sliderContainer

	-- Add UIListLayout for horizontal arrangement
	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.Padding = UDim.new(0, 10)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = sliderLayoutFrame

	-- Create a vertical slider for each point
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Name = "Slider"
	sliderFrame.Size = UDim2.new(0, 25, 1, 0)
	sliderFrame.BackgroundTransparency = 1
	sliderFrame.LayoutOrder = 1
	sliderFrame.Parent = sliderLayoutFrame

	-- Slider track (background)
	local sliderTrack = Instance.new("Frame")
	sliderTrack.Name = "Track"
	sliderTrack.Size = UDim2.new(0, 8, 0.8, 0)
	sliderTrack.Position = UDim2.new(0.5, -4, 0, 0)
	sliderTrack.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	sliderTrack.BorderSizePixel = 0
	sliderTrack.Parent = sliderFrame

	-- Slider handle/knob
	local handle = Instance.new("Frame")
	handle.Name = "Handle"
	handle.Size = UDim2.new(0, 20, 0, 10)
	handle.Position = UDim2.new(0.5, -10, 0.8, -5) -- Start at bottom (0 value)
	handle.BackgroundColor3 = Color3.fromRGB(255, 115, 0) -- Orange to match points
	handle.BorderSizePixel = 0
	handle.ZIndex = 2
	handle.Parent = sliderFrame

	-- Value label
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "Value"
	valueLabel.Size = UDim2.new(1, 0, 0, 20)
	valueLabel.Position = UDim2.new(0, 0, 1, -20)
	valueLabel.BackgroundTransparency = 1
	valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueLabel.Text = "1"
	valueLabel.TextSize = 14
	valueLabel.Font = Enum.Font.SourceSans
	valueLabel.Parent = sliderFrame

	-- Point number label
	local pointLabel = Instance.new("TextLabel")
	pointLabel.Name = "PointNum"
	pointLabel.Size = UDim2.new(1, 0, 0, 20)
	pointLabel.Position = UDim2.new(0, 0, 0, -25)
	pointLabel.BackgroundTransparency = 1
	pointLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	pointLabel.Text = "LOD"
	pointLabel.TextSize = 14
	pointLabel.Font = Enum.Font.SourceSansBold
	pointLabel.Parent = sliderFrame

	-- Slider logic and direct connection to point density
	local dragging = false

	local function updateSlider(inputY)
		local trackAbsPos = sliderTrack.AbsolutePosition.Y
		local trackAbsSize = sliderTrack.AbsoluteSize.Y

		-- Calculate relative position (bottom = 0, top = 1)
		local relativeY = trackAbsPos + trackAbsSize - inputY
		local normalizedY = math.clamp(relativeY / trackAbsSize, 0, 1)

		-- Update handle position
		handle.Position = UDim2.new(0.5, -10, 0.8 - (normalizedY * 0.8), -5)

		-- Update value display
		local displayValue = math.floor(normalizedY * 16 / 4) + 1
		valueLabel.Text = `{displayValue}`

		print("LOD set to:", LODContainer.LOD)

		-- Direct connection: Update the point's density value
		LODContainer.LOD = displayValue
	end

	handle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if
			(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
			and dragging
		then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			updateSlider(input.Position.Y)
		end
	end)
end

return createUI
