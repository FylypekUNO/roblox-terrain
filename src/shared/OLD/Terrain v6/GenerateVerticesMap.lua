type verticesMap = {{Vector3}}

local function generateVerticesMap(startPos: Vector3, chunkWidth: number, blocksCount: number, scale: number, seed: number): verticesMap
	local blockWidth = chunkWidth / blocksCount
	
	local verticesMapZX = {}
	
	for x = 0, blocksCount + 1 do
		local verticesMapZ = {}
		
		local posX = startPos.X + x * blockWidth
		
		for z = 0, blocksCount + 1 do
			local posZ = startPos.Z + z * blockWidth
			
			local height = math.noise(posX / scale, seed, posZ / scale) * math.sqrt(math.abs(posX) * math.abs(posZ))
			
			verticesMapZ[z] = Vector3.new(posX, startPos.Y + height, posZ)
		end
		
		verticesMapZX[x] = verticesMapZ
	end
	
	return verticesMapZX
end

return generateVerticesMap