--!strict

local RunService = game:GetService("RunService")

local drawPoint = require(script.DrawPoint)
local drawLine = require(script.DrawLine)
local drawTriangle = require(script.DrawTriangle)
local Table = require(script.Utils.Table)
local Short = require(script.Utils.Short)
local Point = require(script.Point)
local createUI = require(script.UI)

local cubeBase: Part = workspace:WaitForChild("TheCube")

local baseSize: Vector3 = cubeBase.Size
local basePosition: Vector3 = cubeBase.Position

local directions: { Vector3 } = {
	Vector3.new(-1, -1, -1),
	Vector3.new(1, -1, -1),
	Vector3.new(-1, -1, 1),
	Vector3.new(1, -1, 1),

	Vector3.new(-1, 1, -1),
	Vector3.new(1, 1, -1),
	Vector3.new(-1, 1, 1),
	Vector3.new(1, 1, 1),
}

local positions = Table.MapArray(directions, function(dir: Vector3)
	return dir * (baseSize / 2) + basePosition
end)

local parts: { Part } = {}

local staticFolder = Instance.new("Folder")
staticFolder.Name = "Static"
staticFolder.Parent = workspace

-- Draw Points
for _, point in ipairs(positions) do
	local part = drawPoint(staticFolder, point, Color3.new(1, 0.450980, 0), 0.5)

	table.insert(parts, part)
end

-- Draw Lines
-- for i = 1, #positions do
-- 	for j = i + 1, #positions do
-- 		drawLine(staticFolder, positions[i], positions[j], Color3.new(1, 1, 1), 0.01)
-- 	end
-- end

local points: { Point.Point } = Table.MapArray(parts, function(part)
	return Point.new(part, part.Position, 0, (part.Position - basePosition) / baseSize)
end)

createUI(points)

local FrameFolder = Instance.new("Folder")
FrameFolder.Name = "Frame"
FrameFolder.Parent = workspace

while true do
	for _, point in ipairs(points) do
		point.Part.Color = Color3.new(1, 1, 1):Lerp(Color3.new(0, 0, 0), point.Density)
	end

	-- Linear visuals of Collistion
	FrameFolder:ClearAllChildren()

	local centerDirection = Vector3.zero

	for _, point in ipairs(points) do
		centerDirection += point.Direction * point.Density
	end

	local centerPosition = basePosition

	for _, point in ipairs(points) do
		centerPosition += (point.Position - basePosition) * point.Density / #points
	end

	local centerDensity = 0

	for _, point in ipairs(points) do
		centerDensity += point.Density / #points
	end

	local foundationPoints: { Point.Point } = {}

	if true then
		local startPos = basePosition + centerDirection.Unit * (baseSize / 2)

		local ball = Instance.new("Part")
		ball.Anchored = true
		ball.CanCollide = false
		ball.Size = baseSize
		ball.Position = basePosition
		ball.Transparency = 0.85
		ball.Shape = Enum.PartType.Ball
		ball.Parent = FrameFolder

		drawPoint(FrameFolder, startPos, Color3.new(0, 1, 0), 0.2)
		drawPoint(FrameFolder, centerPosition, Color3.new(0, 0, 1), 0.2)
		drawLine(FrameFolder, startPos, centerPosition, Color3.new(1, 0, 1), 0.2)
	end

	local potentialCorners: { Vector3 } = {}

	-- Linear visuals of line parts
	local pairs: { { Point.Point } } = {
		{ points[1], points[2] },
		{ points[1], points[3] },
		{ points[1], points[5] },
		{ points[2], points[4] },
		{ points[2], points[6] },
		{ points[3], points[4] },
		{ points[3], points[7] },
		{ points[4], points[8] },
		{ points[5], points[6] },
		{ points[5], points[7] },
		{ points[6], points[8] },
		{ points[7], points[8] },
	}

	for _, pair in ipairs(pairs) do
		local p1 = pair[1]
		local p2 = pair[2]

		if p1.Density < 0.01 and p2.Density < 0.01 then
			continue
		end

		if p1.Density > 0.99 and p2.Density > 0.99 then
			drawLine(FrameFolder, p1.Position, p2.Position, Color3.new(0, 0, 0), 0.1)
			continue
		end

		local low, high = Short.Sort(p1, p2)

		local alpha = (high.Density + low.Density) / 2

		local aPos = high.Position:Lerp(low.Position, alpha)

		table.insert(potentialCorners, aPos)

		drawLine(FrameFolder, high.Position, aPos, Color3.new(0, 0, 0), 0.1)
		drawLine(FrameFolder, low.Position, aPos, Color3.new(1, 1, 1), 0.1)
	end

	if #potentialCorners < 3 then
		if centerDensity > 0.01 then
			local cube = Instance.new("Part")
			cube.Anchored = true
			cube.CanCollide = false
			cube.Size = baseSize
			cube.Position = basePosition
			cube.Parent = FrameFolder
		end
	elseif #potentialCorners == 3 then
		drawTriangle(FrameFolder, potentialCorners[1], potentialCorners[2], potentialCorners[3])
	elseif #potentialCorners == 4 then
		drawTriangle(FrameFolder, potentialCorners[1], potentialCorners[2], potentialCorners[3])
		drawTriangle(FrameFolder, potentialCorners[2], potentialCorners[3], potentialCorners[4])
	end

	RunService.Heartbeat:Wait()
end
