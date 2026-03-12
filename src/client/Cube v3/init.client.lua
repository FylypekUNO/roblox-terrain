--!strict

local RunService = game:GetService("RunService")

local drawPoint = require(script.DrawPoint)
local drawLine = require(script.DrawLine)
local drawTriangle = require(script.DrawTriangle)
local drawLabel = require(script.DrawLabel)
local Table = require(script.Utils.Table)
local Vector3Util = require(script.Utils.Vector3)
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

local points: { Point.Point } = Table.MapArray(positions, function(position, index)
	return Point.new(position, 0, directions[index])
end)

createUI(points)

local FrameFolder = Instance.new("Folder")
FrameFolder.Name = "Frame"
FrameFolder.Parent = workspace

while true do
	FrameFolder:ClearAllChildren()

	for _, point in ipairs(points) do
		drawPoint(FrameFolder, point.Position, Color3.new(1, 1, 1):Lerp(Color3.new(0, 0, 0), point.Density), 0.25)
	end

	local centerDirection = Vector3.zero

	for _, point in ipairs(points) do
		centerDirection += point.Direction * point.Density
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

		if p1.Density > 0.5 and p2.Density < 0.5 then
			table.insert(connections, {
				SolidPoint = p1,
				AirPoint = p2,
			})
		elseif p2.Density > 0.5 and p1.Density < 0.5 then
			table.insert(connections, {
				SolidPoint = p2,
				AirPoint = p1,
			})
		end
	end

	local potentialCorners: { Vector3 } = {}

	for _, connection in ipairs(connections) do
		local solid, air = connection.SolidPoint, connection.AirPoint

		local alpha = (solid.Density - 0.5) + air.Density
		if alpha < 0 then
			continue
		end

		local midPoint = solid.Position:Lerp(air.Position, alpha)

		drawPoint(FrameFolder, midPoint, Color3.new(1, 1, 0), 0.1)
		drawLine(FrameFolder, solid.Position, air.Position, Color3.new(1, 0, 0), 0.05)

		table.insert(potentialCorners, midPoint)
	end

	if #potentialCorners > 2 then
		Vector3Util.SortClockwise(potentialCorners, basePosition, -centerDirection)

		for i, pos in ipairs(potentialCorners) do
			drawLabel(FrameFolder, pos, `{i}`, 14, Color3.new(1, 1, 0))
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
