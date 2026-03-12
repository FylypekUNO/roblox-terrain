--!strict

local DEFAULT_COLOR = Color3.new(1, 0, 0.0156863)
local DEFAULT_RADIUS = 0.2

local function drawPoint(parent: Instance, position: Vector3, color: Color3?, radius: number?): Part
	radius = radius or DEFAULT_RADIUS
	color = color or DEFAULT_COLOR

	local ball = Instance.new("Part")
	ball.Anchored = true
	ball.CanCollide = false
	ball.CanQuery = false
	ball.CanTouch = false
	ball.CastShadow = false
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.one * (radius :: number) * 2
	ball.Material = Enum.Material.Neon
	ball.Color = color :: Color3
	ball.Position = position

	ball.Parent = parent

	return ball
end

return drawPoint
