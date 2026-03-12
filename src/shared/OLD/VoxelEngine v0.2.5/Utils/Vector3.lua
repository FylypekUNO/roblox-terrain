local Vector3Utils = {}


function Vector3Utils.Floor(vec: Vector3): Vector3
  return Vector3.new(math.floor(vec.X), math.floor(vec.Y), math.floor(vec.Z))
end


return Vector3Utils
