local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

return drawTriangle
