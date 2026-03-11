local Point = {}
Point.__index = Point

type self = {
	Part: Part,
	Position: Vector3,
	Density: number,
	Direction: Vector3,
}

export type Point = typeof(setmetatable({} :: self, Point))

function Point.new(part: Part, position: Vector3, density: number, direction: Vector3): Point
	local self = setmetatable({} :: self, Point)

	self.Part = part
	self.Position = position
	self.Density = density
	self.Direction = direction

	return self
end

function Point.__lt(a: Point, b: Point): boolean
	return a.Density < b.Density
end

function Point.__eq(a: Point, b: Point): boolean
	return a.Position == b.Position and a.Density == b.Density and a.Direction == b.Direction
end

function Point.__tostring(self: Point): string
	return `Point(Position: {self.Position}, Density: {self.Density}, Direction: {self.Direction})`
end

return Point
