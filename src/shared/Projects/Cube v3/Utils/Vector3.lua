local Vector3Utils = {}

function Vector3Utils.SortClockwise(vecs: { Vector3 }, center: Vector3, normal: Vector3): ()
	if #vecs == 0 then
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
	local refVec = (vecs[1] - center)
	refVec = Vector3.new(refVec:Dot(tangent), refVec:Dot(bitangent), 0)

	local function getAngle(pt: Vector3)
		local v = pt - center
		v = Vector3.new(v:Dot(tangent), v:Dot(bitangent), 0)
		return math.atan2(v.Y, v.X) -- 2D angle in the plane
	end

	table.sort(vecs, function(a, b)
		return getAngle(a) > getAngle(b) -- descending for clockwise
	end)
end

return Vector3Utils
