--!strict

local RunService = game:GetService("RunService")

local drawPoint = require(script.DrawPoint)
local drawLine = require(script.DrawLine)
local drawTriangle = require(script.DrawTriangle)
local drawLabel = require(script.DrawLabel)
local Table = require(script.Utils.Table)
local Point = require(script.Point)
local createUI = require(script.UI)
local Types = require(script.Types)

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

local points: { Point.Point } = Table.MapArray(parts, function(part, index)
	return Point.new(part, part.Position, 0, directions[index])
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

	local pairs = {
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

	local connections: { Types.Connection } = {}

	for _, pair in ipairs(pairs) do
		local p1, p2 = pair[1], pair[2]

		if p1.Density > 0.01 and p2.Density < 0.01 then
			table.insert(connections, {
				SolidPoint = p1,
				AirPoint = p2,
			})
		elseif p2.Density > 0.01 and p1.Density < 0.01 then
			table.insert(connections, {
				SolidPoint = p2,
				AirPoint = p1,
			})
		end
	end

	local potentialCorners: { Vector3 } = {}

	for _, connection in ipairs(connections) do
		local solid, air = connection.SolidPoint, connection.AirPoint

		local alpha = solid.Density
		local midPoint = solid.Position:Lerp(air.Position, alpha)

		drawPoint(FrameFolder, midPoint, Color3.new(1, 1, 0), 0.1)
		drawLine(FrameFolder, solid.Position, air.Position, Color3.new(1, 0, 0), 0.05)

		table.insert(potentialCorners, midPoint)
	end

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

	local function sortClockwise3D(positions: { Vector3 }, center: Vector3, normal: Vector3)
		if #positions == 0 then
			return
		end

		-- Orthonormal basis for the plane
		local function getBasis(n)
			local up = n
			local tangent
			if math.abs(up.X) > math.abs(up.Z) then
				tangent = Vector3.new(-up.Y, up.X, 0)
			else
				tangent = Vector3.new(0, -up.Z, up.Y)
			end
			tangent = tangent.Unit
			local bitangent = up:Cross(tangent)
			return tangent, bitangent
		end

		local tangent, bitangent = getBasis(normal.Unit)
		local refVec = (positions[1] - center)
		refVec = Vector3.new(refVec:Dot(tangent), refVec:Dot(bitangent), 0)

		local function getAngle(pt: Vector3)
			local v = pt - center
			v = Vector3.new(v:Dot(tangent), v:Dot(bitangent), 0)
			return math.atan2(v.Y, v.X) -- 2D angle in the plane
		end

		table.sort(positions, function(a, b)
			return getAngle(a) > getAngle(b) -- descending for clockwise
		end)

		return positions
	end

	if #potentialCorners > 2 then
		potentialCorners = sortClockwise3D(potentialCorners, centerPosition, -centerDirection)

		for i, pos in ipairs(potentialCorners) do
			drawLabel(FrameFolder, pos, `{i}`, 20, Color3.new(1, 1, 0))
		end

		if #potentialCorners == 3 then
			drawTriangle(FrameFolder, potentialCorners[1], potentialCorners[2], potentialCorners[3])
		elseif #potentialCorners == 4 then
			drawTriangle(FrameFolder, potentialCorners[1], potentialCorners[2], potentialCorners[3])
			drawTriangle(FrameFolder, potentialCorners[1], potentialCorners[3], potentialCorners[4])
		elseif #potentialCorners == 5 then
			drawTriangle(FrameFolder, potentialCorners[1], potentialCorners[2], potentialCorners[5])
			drawTriangle(FrameFolder, potentialCorners[2], potentialCorners[3], potentialCorners[5])
			drawTriangle(FrameFolder, potentialCorners[3], potentialCorners[4], potentialCorners[5])
		elseif #potentialCorners == 6 then
			drawTriangle(FrameFolder, potentialCorners[1], potentialCorners[2], potentialCorners[6])
			drawTriangle(FrameFolder, potentialCorners[2], potentialCorners[3], potentialCorners[6])
			drawTriangle(FrameFolder, potentialCorners[3], potentialCorners[4], potentialCorners[6])
			drawTriangle(FrameFolder, potentialCorners[4], potentialCorners[5], potentialCorners[6])
		else
			local cube = Instance.new("Part")
			cube.Anchored = true
			cube.CanCollide = false
			cube.Size = baseSize
			cube.Position = basePosition
			cube.Parent = FrameFolder
		end
	end

	RunService.Heartbeat:Wait()
end
