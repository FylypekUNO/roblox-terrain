local drawTriangle3D = require(script.Parent.DrawTriangle3D)

local function drawChunk(wedgesContainer: Instance, chunkX: number, chunkZ: number, chunkWidth: number, blocksCount: number, heightCallback: (x: number, z: number) -> (number)): ()
	local startPos = Vector3.new(chunkX, 0, chunkZ) * chunkWidth
	local blockWidth = chunkWidth / blocksCount

	for x = 0, blocksCount - 1 do
		local xPos = startPos.X + x * blockWidth
		
		local pos1 = Vector3.new(xPos, heightCallback(xPos, startPos.Z), startPos.Z)
		local pos2 = Vector3.new(xPos + blockWidth, heightCallback(xPos + 1, startPos.Z), startPos.Z)

		for z = 1, blocksCount do
			local zPos = startPos.Z + z * blockWidth
			
			local pos3 = Vector3.new(pos1.X, heightCallback(xPos, zPos), pos1.Z + blockWidth)

		    local w1, w2 = drawTriangle3D(wedgesContainer, pos1, pos2, pos3)

		    pos1 = pos3
		    pos3 = Vector3.new(pos1.X + blockWidth, heightCallback(xPos + blockWidth, zPos), pos1.Z)

		    local w3, w4 = drawTriangle3D(wedgesContainer, pos1, pos2, pos3)

		    pos2 = pos3
		end
	end
	
	
end
  
return drawChunk