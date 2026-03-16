local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tool = script.Parent
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Fetching the module based on your provided path (adjusted for typos)
local drawTriangleModule =
  require(ReplicatedStorage:WaitForChild("2026"):WaitForChild("DrawTriangle"))

local points = {}

local function spawnDot(position)
  local dot = Instance.new("Part")
  dot.Shape = Enum.PartType.Ball
  dot.Size = Vector3.new(0.1, 0.1, 0.1)
  dot.Position = position
  dot.Anchored = true
  dot.CanCollide = false
  dot.BrickColor = BrickColor.new("Really red")
  dot.Material = Enum.Material.Neon
  dot.Parent = workspace
end

tool.Activated:Connect(function()
  local hitPos = mouse.Hit.Position

  spawnDot(hitPos)
  table.insert(points, hitPos)

  local count = #points
  if count >= 3 then
    local p1 = points[count - 2]
    local p2 = points[count - 1]
    local p3 = points[count]

    drawTriangleModule(workspace, p1, p2, p3)
  end
end)

tool.Unequipped:Connect(function()
  -- Optional: Clear points when tool is unequipped if you want to start a new shape next time
  points = {}
end)
