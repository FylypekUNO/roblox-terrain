local Short = require(script.Parent.Short)

local function rayBoxCollision(position: Vector3, direction: Vector3, boxSize: Vector3): Vector3?
	direction = direction.Unit

	if direction.Magnitude < 1e-8 then
		return nil
	end

	local halfSize = boxSize / 2

	local tX1, tX2 = Short.Sort(-halfSize.X / direction.X, halfSize.X / direction.X)
	local tY1, tY2 = Short.Sort(-halfSize.Y / direction.Y, halfSize.Y / direction.Y)
	local tZ1, tZ2 = Short.Sort(-halfSize.Z / direction.Z, halfSize.Z / direction.Z)

	local tMin = math.max(tX1, tY1, tZ1)
	local tMax = math.min(tX2, tY2, tZ2)

	local collisionDistance: number = (tMin >= 0) and tMin or tMax
	if collisionDistance < 0 then
		return nil
	end

	local collisionPoint: Vector3 = position + direction * collisionDistance
	return collisionPoint
end

return rayBoxCollision
