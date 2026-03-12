local function DrawLabel(parent: Instance, position: Vector3, text: string, textSize: number?, color: Color3?)
	textSize = textSize or 14
	color = color or Color3.new(1, 1, 1)

	local width = #text * (textSize :: number) * 0.6
	local height = textSize :: number

	local attachment = Instance.new("Attachment")
	attachment.Position = position
	attachment.Parent = parent

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Adornee = attachment
	billboardGui.Size = UDim2.new(0, width, 0, height)
	billboardGui.StudsOffset = Vector3.new(0, 0, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = attachment

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Text = text
	textLabel.TextSize = textSize :: number
	textLabel.TextColor3 = color :: Color3
	textLabel.Font = Enum.Font.RobotoMono
	textLabel.Parent = billboardGui

	return attachment, billboardGui, textLabel
end

-- Return the function to be used as a module
return DrawLabel
