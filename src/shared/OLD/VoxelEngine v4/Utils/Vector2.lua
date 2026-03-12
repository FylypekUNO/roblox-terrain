local Vector2Utils = {}

function Vector2Utils.Floor(vec: Vector2): Vector2
	return Vector2.new(math.floor(vec.X), math.floor(vec.Y))
end

return Vector2Utils
