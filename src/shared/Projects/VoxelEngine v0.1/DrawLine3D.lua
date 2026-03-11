--!strict

local DEFAULT_COLOR = Color3.new(1, 0, 0.0156863)
local DEFAULT_THICKNESS = 0.05


local function drawLine3D(parent: Instance, a: Vector3, b: Vector3, color: Color3?, thickness: number?): (Part)
	thickness = thickness or DEFAULT_THICKNESS
	color = color or DEFAULT_COLOR

	local distance = (b - a).Magnitude
	local direction = (b - a).Unit
	local origin = (a + b) / 2

	local rayPart = Instance.new("Part")
	rayPart.Anchored = true
	rayPart.CanCollide = false
	rayPart.CanQuery = false
	rayPart.CanTouch = false
	rayPart.Size = Vector3.new(thickness, thickness, distance)
	rayPart.Material = Enum.Material.Neon
	rayPart.Color = color
	rayPart.CFrame = CFrame.lookAt(origin, b) * CFrame.new(0, 0, -1 + thickness * 3)

	rayPart.Parent = parent

	return rayPart
end


return drawLine3D