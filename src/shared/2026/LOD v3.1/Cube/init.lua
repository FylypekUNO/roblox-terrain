--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local drawTriangle = require(ReplicatedStorage["2026"].DrawTriangle)
local drawPoint = require(ReplicatedStorage["2026"].DrawPoint)
local drawLine = require(ReplicatedStorage["2026"].DrawLine)
local drawLabel = require(ReplicatedStorage["2026"].DrawLabel)
local Vector3Util = require(ReplicatedStorage["2026"].Vector3)
local Array = require(ReplicatedStorage["2026"].Array)
local Point = require(script.Point)
local Types = require(script.Types)

export type Point = Point.Point

local function drawCube(parent: Instance, positions: { Vector3 }, densities: { number }, color: Color3?): ()
  local centerPosition = Vector3.new(0, 0, 0)

  for _, position in ipairs(positions) do
    centerPosition += position / #positions
  end

  local points: { Point } = Array.Map(positions, function(position, index)
    return Point.new(position, densities[index], (position - centerPosition).Unit)
  end)

  local centerOfMass = centerPosition

  for _, point in ipairs(points) do
    centerOfMass += (point.Position - centerPosition) * point.Density
  end

  local centerDirection = (centerOfMass - centerPosition).Unit

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

    table.insert(potentialCorners, midPoint)
  end

  local isClicked = false

  local function addClicker(part: Instance)
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 100

    clickDetector.MouseClick:Connect(function(_player: Player)
      if isClicked then
        return
      end

      isClicked = true

      for _, pair in ipairs(pairs) do
        local p1, p2 = pair[1], pair[2]

        drawLine(
          parent,
          p1.Position,
          p2.Position,
          Color3.new(1, 1, 1),
          (points[1].Position - points[8].Position).Magnitude / 100
        )
      end

      for _, potentialCorner in ipairs(potentialCorners) do
        drawPoint(
          parent,
          potentialCorner,
          Color3.new(1, 0, 0),
          (points[1].Position - points[8].Position).Magnitude / 100
        )
      end

      for _, point in ipairs(points) do
        drawLabel(parent, point.Position, string.format("%.2f", point.Density), 14, Color3.new(1, 1, 0))
      end
    end)

    clickDetector.Parent = part
  end

  if #potentialCorners > 2 then
    Vector3Util.SortClockwise(potentialCorners, centerOfMass, centerDirection)

    if #potentialCorners == 3 then
      local w1, w2 = drawTriangle(parent, potentialCorners[1], potentialCorners[2], potentialCorners[3], color)

      addClicker(w1)
      addClicker(w2)
    elseif #potentialCorners == 4 then
      local points1 = { potentialCorners[1], potentialCorners[2], potentialCorners[4] }
      Vector3Util.SortClockwise(points1, centerOfMass, centerDirection)

      local points2 = { potentialCorners[2], potentialCorners[3], potentialCorners[4] }
      Vector3Util.SortClockwise(points2, centerOfMass, centerDirection)

      local w1, w2 = drawTriangle(parent, points1[1], points1[2], points1[3], color)
      local w3, w4 = drawTriangle(parent, points2[1], points2[2], points2[3], color)

      addClicker(w1)
      addClicker(w2)
      addClicker(w3)
      addClicker(w4)
    elseif #potentialCorners == 5 then
      local points1 = { potentialCorners[1], potentialCorners[2], potentialCorners[5] }
      Vector3Util.SortClockwise(points1, centerOfMass, centerDirection)

      local points2 = { potentialCorners[2], potentialCorners[3], potentialCorners[5] }
      Vector3Util.SortClockwise(points2, centerOfMass, centerDirection)

      local points3 = { potentialCorners[3], potentialCorners[4], potentialCorners[5] }
      Vector3Util.SortClockwise(points3, centerOfMass, centerDirection)

      local w1, w2 = drawTriangle(parent, points1[1], points1[2], points1[3], color)
      local w3, w4 = drawTriangle(parent, points2[1], points2[2], points2[3], color)
      local w5, w6 = drawTriangle(parent, points3[1], points3[2], points3[3], color)

      addClicker(w1)
      addClicker(w2)
      addClicker(w3)
      addClicker(w4)
      addClicker(w5)
      addClicker(w6)
    elseif #potentialCorners == 6 then
      local points1 = { potentialCorners[1], potentialCorners[2], potentialCorners[6] }
      Vector3Util.SortClockwise(points1, centerOfMass, centerDirection)

      local points2 = { potentialCorners[2], potentialCorners[3], potentialCorners[6] }
      Vector3Util.SortClockwise(points2, centerOfMass, centerDirection)

      local points3 = { potentialCorners[3], potentialCorners[4], potentialCorners[6] }
      Vector3Util.SortClockwise(points3, centerOfMass, centerDirection)

      local points4 = { potentialCorners[4], potentialCorners[5], potentialCorners[6] }
      Vector3Util.SortClockwise(points4, centerOfMass, centerDirection)

      local w1, w2 = drawTriangle(parent, points1[1], points1[2], points1[3], color)
      local w3, w4 = drawTriangle(parent, points2[1], points2[2], points2[3], color)
      local w5, w6 = drawTriangle(parent, points3[1], points3[2], points3[3], color)
      local w7, w8 = drawTriangle(parent, points4[1], points4[2], points4[3], color)

      addClicker(w1)
      addClicker(w2)
      addClicker(w3)
      addClicker(w4)
      addClicker(w5)
      addClicker(w6)
      addClicker(w7)
      addClicker(w8)
    end
  end
end

return {
  drawCube = drawCube,
  Point = Point,
}
