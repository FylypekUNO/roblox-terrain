-- Source: https://create.roblox.com/store/asset/5656315743
-- Edited by @ffiilliippfff for better readability

local WEDGE_THICKNESS = 0

local function drawTriangle3D(parent: Instance, a: Vector3, b: Vector3, c: Vector3): (WedgePart, WedgePart)
	local ab, ac, bc = b - a, c - a, c - b
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)

	if abd > acd and abd > bcd then
		c, a = a, c
	elseif acd > bcd and acd > abd then
		a, b = b, a
	end

	ab, ac, bc = b - a, c - a, c - b

	local right = ac:Cross(ab).unit
	local up = bc:Cross(right).unit
	local back = bc.unit

	local height = math.abs(ab:Dot(up))

	local w1 = Instance.new("WedgePart")
	local w2 = Instance.new("WedgePart")

	w1.Anchored = true
	w2.Anchored = true

	w1.TopSurface = Enum.SurfaceType.Smooth
	w2.TopSurface = Enum.SurfaceType.Smooth

	w1.BottomSurface = Enum.SurfaceType.Smooth
	w2.BottomSurface = Enum.SurfaceType.Smooth

	w1.CastShadow = true
	w2.CastShadow = true

	w1.Size = Vector3.new(WEDGE_THICKNESS, height, math.abs(ab:Dot(back)))
	w2.Size = Vector3.new(WEDGE_THICKNESS, height, math.abs(ac:Dot(back)))

	w1.CFrame = CFrame.fromMatrix((a + b) / 2, right, up, back)
	w2.CFrame = CFrame.fromMatrix((a + c) / 2, -right, up, -back)

	if (a.Y + b.Y + c.Y) <= 60 * 3 then
		w1.Color = Color3.new(0.0235294, 0.529412, 1)
		w2.Color = Color3.new(0.0235294, 0.529412, 1)
	elseif (a.Y + b.Y + c.Y) <= 180 * 3 then
		w1.Color = Color3.new(0.0313725, 0.596078, 0.0980392)
		w2.Color = Color3.new(0.0313725, 0.596078, 0.0980392)
	else
		w1.Color = Color3.new(1, 1, 1)
		w2.Color = Color3.new(1, 1, 1)
	end

	w1.Parent = parent
	w2.Parent = parent

	return w1, w2
end

return drawTriangle3D
