-- Source: https://create.roblox.com/store/asset/5656315743
-- Edited by @ffiilliippfff for better readability and to remove deprecated properties

local MESH_ID = "rbxassetid://115250631411867"
local MESH_THICKNESS = 0

local function drawTriangle(
  parent: Instance,
  a: Vector3,
  b: Vector3,
  c: Vector3,
  color: Color3?
): (MeshPart, MeshPart)
  color = color or Color3.fromRGB(163, 162, 165)

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

  local w1 = Instance.new("MeshPart")
  local w2 = Instance.new("MeshPart")

  w1.MeshId = MESH_ID
  w2.MeshId = MESH_ID

  w1.Anchored = true
  w2.Anchored = true

  w1.TopSurface = Enum.SurfaceType.Smooth
  w2.TopSurface = Enum.SurfaceType.Smooth

  w1.BottomSurface = Enum.SurfaceType.Smooth
  w2.BottomSurface = Enum.SurfaceType.Smooth

  w1.CastShadow = false
  w2.CastShadow = false

  w1.Size = Vector3.new(MESH_THICKNESS, height, math.abs(ab:Dot(back)))
  w2.Size = Vector3.new(MESH_THICKNESS, height, math.abs(ac:Dot(back)))

  w1.CFrame = CFrame.fromMatrix((a + b) / 2, right, up, back)
  w2.CFrame = CFrame.fromMatrix((a + c) / 2, -right, up, -back)

  w1.Color = color
  w2.Color = color

  w1.CanCollide = false
  w2.CanCollide = false

  w1.CanQuery = false
  w2.CanQuery = false

  w1.CanTouch = false
  w2.CanTouch = false

  w1.Parent = parent
  w2.Parent = parent

  return w1, w2
end

return drawTriangle
