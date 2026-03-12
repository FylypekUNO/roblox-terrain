local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MESH_THICKNESS = 0

local template: MeshPart = ReplicatedStorage.MeshParts.OneSidedTriangle:Clone()
template.Anchored = true
template.CanCollide = false
template.CanQuery = false
template.CanTouch = false
template.CastShadow = false

local DEFAULT_COLOR = Color3.fromRGB(163, 162, 165)

local function drawTriangle(
  parent: Instance,
  a: Vector3,
  b: Vector3,
  c: Vector3,
  color: Color3?
): (MeshPart, MeshPart)
  color = color or DEFAULT_COLOR

  local ab, ac, bc = b - a, c - a, c - b
  local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)

  if abd > acd and abd > bcd then
    c, a = a, c
  elseif acd > bcd and acd > abd then
    a, b = b, a
  end

  ab, ac, bc = b - a, c - a, c - b

  local right = ac:Cross(ab).Unit
  local up = bc:Cross(right).Unit
  local back = bc.Unit

  local height = math.abs(ab:Dot(up))

  local w1 = template:Clone()
  local w2 = template:Clone()

  w1.Size = Vector3.new(height, math.abs(ab:Dot(back)), MESH_THICKNESS)
  w2.Size = Vector3.new(height, math.abs(ac:Dot(back)), MESH_THICKNESS)

  w1.CFrame = CFrame.fromMatrix((a + b) / 2, right, up, back)
    * CFrame.Angles(math.pi * 1.5, math.pi / 2, 0)
  w2.CFrame = CFrame.fromMatrix((a + c) / 2, -right, up, -back)
    * CFrame.Angles(math.pi * 1.5, math.pi / 2, 0)

  w1.Color = color
  w2.Color = color

  w1.Parent = parent
  w2.Parent = parent

  return w1, w2
end

-- Spawn 3 small marker balls forming a triangle around the base position
local BASE = Vector3.new(-3, 85, -3)
local BALL_SIZE = Vector3.new(0.4, 0.4, 0.4)

local function makeBall(position: Vector3, color: Color3): Part
  local ball = Instance.new("Part")
  ball.Shape = Enum.PartType.Ball
  ball.Size = BALL_SIZE
  ball.Position = position
  ball.Anchored = true
  ball.CanCollide = false
  ball.CanQuery = false
  ball.CanTouch = false
  ball.CastShadow = false
  ball.Color = color
  ball.Material = Enum.Material.Neon
  ball.Parent = workspace
  return ball
end

local ballA = makeBall(BASE + Vector3.new(0, 0, -3), Color3.fromRGB(80, 255, 80)) -- green
local ballB = makeBall(BASE + Vector3.new(3, 0, 2), Color3.fromRGB(80, 80, 255)) -- blue
local ballC = makeBall(BASE + Vector3.new(-3, 0, 2), Color3.fromRGB(255, 80, 80)) -- red

-- Folder to hold current triangle meshes so they can be cleared on redraw
local triangleFolder = Instance.new("Folder")
triangleFolder.Name = "TestTriangle"
triangleFolder.Parent = workspace

local function redrawTriangle()
  -- Clear previous meshes
  for _, child in triangleFolder:GetChildren() do
    child:Destroy()
  end

  drawTriangle(triangleFolder, ballA.Position, ballB.Position, ballC.Position)
end

-- Initial draw
redrawTriangle()

-- Track position changes each frame
local lastA = ballA.Position
local lastB = ballB.Position
local lastC = ballC.Position

RunService.Heartbeat:Connect(function()
  local curA = ballA.Position
  local curB = ballB.Position
  local curC = ballC.Position

  if curA ~= lastA or curB ~= lastB or curC ~= lastC then
    lastA = curA
    lastB = curB
    lastC = curC
    redrawTriangle()
  end
end)
