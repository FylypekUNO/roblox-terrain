-- !strict

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

local function createUI(LODContainer: { LOD: number, Smoothness: number }): ()
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

	-- Create LOD slider
	local lodSliderFrame = Instance.new("Frame")
	lodSliderFrame.Name = "LODSlider"
	lodSliderFrame.Size = UDim2.new(0, 25, 1, 0)
	lodSliderFrame.BackgroundTransparency = 1
	lodSliderFrame.LayoutOrder = 1
	lodSliderFrame.Parent = sliderLayoutFrame

	-- LOD Slider track (background)
	local lodSliderTrack = Instance.new("Frame")
	lodSliderTrack.Name = "Track"
	lodSliderTrack.Size = UDim2.new(0, 8, 0.8, 0)
	lodSliderTrack.Position = UDim2.new(0.5, -4, 0, 0)
	lodSliderTrack.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	lodSliderTrack.BorderSizePixel = 0
	lodSliderTrack.Parent = lodSliderFrame

	-- LOD Slider handle/knob
	local lodHandle = Instance.new("Frame")
	lodHandle.Name = "Handle"
	lodHandle.Size = UDim2.new(0, 20, 0, 10)
	lodHandle.Position = UDim2.new(0.5, -10, 0.8, -5) -- Start at bottom (0 value)
	lodHandle.BackgroundColor3 = Color3.fromRGB(255, 115, 0) -- Orange to match points
	lodHandle.BorderSizePixel = 0
	lodHandle.ZIndex = 2
	lodHandle.Parent = lodSliderFrame

	-- LOD Value label
	local lodValueLabel = Instance.new("TextLabel")
	lodValueLabel.Name = "Value"
	lodValueLabel.Size = UDim2.new(1, 0, 0, 20)
	lodValueLabel.Position = UDim2.new(0, 0, 1, -20)
	lodValueLabel.BackgroundTransparency = 1
	lodValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	lodValueLabel.Text = "1"
	lodValueLabel.TextSize = 14
	lodValueLabel.Font = Enum.Font.SourceSans
	lodValueLabel.Parent = lodSliderFrame

	-- LOD Point number label
	local lodPointLabel = Instance.new("TextLabel")
	lodPointLabel.Name = "PointNum"
	lodPointLabel.Size = UDim2.new(1, 0, 0, 20)
	lodPointLabel.Position = UDim2.new(0, 0, 0, -25)
	lodPointLabel.BackgroundTransparency = 1
	lodPointLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	lodPointLabel.Text = "LOD"
	lodPointLabel.TextSize = 14
	lodPointLabel.Font = Enum.Font.SourceSansBold
	lodPointLabel.Parent = lodSliderFrame

	-- Create Smoothness slider
	local smoothnessSliderFrame = Instance.new("Frame")
	smoothnessSliderFrame.Name = "SmoothnessSlider"
	smoothnessSliderFrame.Size = UDim2.new(0, 25, 1, 0)
	smoothnessSliderFrame.BackgroundTransparency = 1
	smoothnessSliderFrame.LayoutOrder = 2
	smoothnessSliderFrame.Parent = sliderLayoutFrame

	-- Smoothness Slider track (background)
	local smoothnessSliderTrack = Instance.new("Frame")
	smoothnessSliderTrack.Name = "Track"
	smoothnessSliderTrack.Size = UDim2.new(0, 8, 0.8, 0)
	smoothnessSliderTrack.Position = UDim2.new(0.5, -4, 0, 0)
	smoothnessSliderTrack.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	smoothnessSliderTrack.BorderSizePixel = 0
	smoothnessSliderTrack.Parent = smoothnessSliderFrame

	-- Smoothness Slider handle/knob
	local smoothnessHandle = Instance.new("Frame")
	smoothnessHandle.Name = "Handle"
	smoothnessHandle.Size = UDim2.new(0, 20, 0, 10)
	smoothnessHandle.Position = UDim2.new(0.5, -10, 0.8, -5) -- Start at bottom (0 value)
	smoothnessHandle.BackgroundColor3 = Color3.fromRGB(0, 170, 255) -- Blue to distinguish from LOD
	smoothnessHandle.BorderSizePixel = 0
	smoothnessHandle.ZIndex = 2
	smoothnessHandle.Parent = smoothnessSliderFrame

	-- Smoothness Value label
	local smoothnessValueLabel = Instance.new("TextLabel")
	smoothnessValueLabel.Name = "Value"
	smoothnessValueLabel.Size = UDim2.new(1, 0, 0, 20)
	smoothnessValueLabel.Position = UDim2.new(0, 0, 1, -20)
	smoothnessValueLabel.BackgroundTransparency = 1
	smoothnessValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	smoothnessValueLabel.Text = "1"
	smoothnessValueLabel.TextSize = 14
	smoothnessValueLabel.Font = Enum.Font.SourceSans
	smoothnessValueLabel.Parent = smoothnessSliderFrame

	-- Smoothness label
	local smoothnessPointLabel = Instance.new("TextLabel")
	smoothnessPointLabel.Name = "PointNum"
	smoothnessPointLabel.Size = UDim2.new(1, 0, 0, 20)
	smoothnessPointLabel.Position = UDim2.new(0, 0, 0, -25)
	smoothnessPointLabel.BackgroundTransparency = 1
	smoothnessPointLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	smoothnessPointLabel.Text = "Smooth"
	smoothnessPointLabel.TextSize = 14
	smoothnessPointLabel.Font = Enum.Font.SourceSansBold
	smoothnessPointLabel.Parent = smoothnessSliderFrame

	-- LOD Slider logic
	local lodDragging = false

	local function updateLODSlider(inputY)
		local trackAbsPos = lodSliderTrack.AbsolutePosition.Y
		local trackAbsSize = lodSliderTrack.AbsoluteSize.Y

		-- Calculate relative position (bottom = 0, top = 1)
		local relativeY = trackAbsPos + trackAbsSize - inputY
		local normalizedY = math.clamp(relativeY / trackAbsSize, 0, 1)

		-- Update handle position
		lodHandle.Position = UDim2.new(0.5, -10, 0.8 - (normalizedY * 0.8), -5)

		-- Update value display
		local displayValue = math.floor(normalizedY * 256 / 4) + 1
		lodValueLabel.Text = `{displayValue}`

		-- Direct connection: Update the LOD value
		LODContainer.LOD = displayValue
	end

	-- Smoothness Slider logic
	local smoothnessDragging = false

	local function updateSmoothnessSlider(inputY)
		local trackAbsPos = smoothnessSliderTrack.AbsolutePosition.Y
		local trackAbsSize = smoothnessSliderTrack.AbsoluteSize.Y

		-- Calculate relative position (bottom = 0, top = 1)
		local relativeY = trackAbsPos + trackAbsSize - inputY
		local normalizedY = math.clamp(relativeY / trackAbsSize, 0, 1)

		-- Update handle position
		smoothnessHandle.Position = UDim2.new(0.5, -10, 0.8 - (normalizedY * 0.8), -5)

		-- Update value display with value between 1 and 5
		local displayValue = math.floor(normalizedY * 100) + 1
		smoothnessValueLabel.Text = `{displayValue}`

		-- Direct connection: Update the Smoothness value
		LODContainer.Smoothness = displayValue
	end

	lodHandle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			lodDragging = true
		end
	end)

	smoothnessHandle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			smoothnessDragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			lodDragging = false
			smoothnessDragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if lodDragging then
				updateLODSlider(input.Position.Y)
			elseif smoothnessDragging then
				updateSmoothnessSlider(input.Position.Y)
			end
		end
	end)
end

return createUI
