--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local drawPoint = require(script.DrawPoint)
local drawLine = require(script.DrawLine)
local drawTriangle = require(ReplicatedStorage["2026"].DrawTriangle)
local drawLabel = require(script.DrawLabel)
local Array = require(ReplicatedStorage["2026"].Array)
local Vector3Util = require(ReplicatedStorage["2026"].Vector3)
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

local positions = Array.Map(directions, function(dir: Vector3)
  return dir * (baseSize / 2) + basePosition
end)

local points: { Point.Point } = Array.Map(positions, function(position, index)
  return Point.new(position, 0, directions[index])
end)

createUI(points)

local FrameFolder = Instance.new("Folder")
FrameFolder.Name = "Frame"
FrameFolder.Parent = workspace

while RunService.Heartbeat:Wait() do
  FrameFolder:ClearAllChildren()

  for _, point in ipairs(points) do
    drawPoint(
      FrameFolder,
      point.Position,
      Color3.new(1, 1, 1):Lerp(Color3.new(0, 0, 0), point.Density),
      0.25
    )
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
      local points1 = { potentialCorners[1], potentialCorners[2], potentialCorners[4] }
      Vector3Util.SortClockwise(points1, basePosition, -centerDirection)

      local points2 = { potentialCorners[2], potentialCorners[3], potentialCorners[4] }
      Vector3Util.SortClockwise(points2, basePosition, -centerDirection)

      drawTriangle(FrameFolder, points1[1], points1[2], points1[3])
      drawTriangle(FrameFolder, points2[1], points2[2], points2[3])
    elseif #potentialCorners == 5 then
      local points1 = { potentialCorners[1], potentialCorners[2], potentialCorners[5] }
      Vector3Util.SortClockwise(points1, basePosition, -centerDirection)

      local points2 = { potentialCorners[2], potentialCorners[3], potentialCorners[5] }
      Vector3Util.SortClockwise(points2, basePosition, -centerDirection)

      local points3 = { potentialCorners[3], potentialCorners[4], potentialCorners[5] }
      Vector3Util.SortClockwise(points3, basePosition, -centerDirection)

      drawTriangle(FrameFolder, points1[1], points1[2], points1[3])
      drawTriangle(FrameFolder, points2[1], points2[2], points2[3])
      drawTriangle(FrameFolder, points3[1], points3[2], points3[3])
    elseif #potentialCorners == 6 then
      local points1 = { potentialCorners[1], potentialCorners[2], potentialCorners[6] }
      Vector3Util.SortClockwise(points1, basePosition, -centerDirection)

      local points2 = { potentialCorners[2], potentialCorners[3], potentialCorners[6] }
      Vector3Util.SortClockwise(points2, basePosition, -centerDirection)

      local points3 = { potentialCorners[3], potentialCorners[4], potentialCorners[6] }
      Vector3Util.SortClockwise(points3, basePosition, -centerDirection)

      local points4 = { potentialCorners[4], potentialCorners[5], potentialCorners[6] }
      Vector3Util.SortClockwise(points4, basePosition, -centerDirection)

      drawTriangle(FrameFolder, points1[1], points1[2], points1[3])
      drawTriangle(FrameFolder, points2[1], points2[2], points2[3])
      drawTriangle(FrameFolder, points3[1], points3[2], points3[3])
      drawTriangle(FrameFolder, points4[1], points4[2], points4[3])
    else
      local cube = Instance.new("Part")
      cube.Anchored = true
      cube.CanCollide = false
      cube.Size = baseSize
      cube.Position = basePosition
      cube.Parent = FrameFolder
    end
  end
end
