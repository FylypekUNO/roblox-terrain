-- Source: https://create.roblox.com/store/asset/5656315743
-- Edited by @ffiilliippfff for better readability

local WEDGE = Instance.new("WedgePart")
WEDGE.Anchored = true
WEDGE.TopSurface = Enum.SurfaceType.Smooth
WEDGE.BottomSurface = Enum.SurfaceType.Smooth
WEDGE.CastShadow = true

local WEDGE_THICKNESS = 0


local function drawTriangle3D(parent: Instance, a: Vector3, b: Vector3, c: Vector3): (WedgePart, WedgePart)
  local ab, ac, bc = b - a, c - a, c - b
  local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)

  if (abd > acd and abd > bcd) then
    c, a = a, c
  elseif (acd > bcd and acd > abd) then
    a, b = b, a
  end

  ab, ac, bc = b - a, c - a, c - b

  local right = ac:Cross(ab).unit
  local up = bc:Cross(right).unit
  local back = bc.unit

  local height = math.abs(ab:Dot(up))


  local w1, w2 = WEDGE:Clone(), WEDGE:Clone()
  
  w1.Size = Vector3.new(WEDGE_THICKNESS, height, math.abs(ab:Dot(back)))
  w2.Size = Vector3.new(WEDGE_THICKNESS, height, math.abs(ac:Dot(back)))
  
  w1.CFrame = CFrame.fromMatrix((a + b) / 2,  right, up,  back)
  w2.CFrame = CFrame.fromMatrix((a + c) / 2, -right, up, -back)

  w1.Parent = parent
  w2.Parent = parent

  return w1, w2
end


return drawTriangle3D