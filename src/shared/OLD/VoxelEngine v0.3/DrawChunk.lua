--!strict

local drawTriangle3D = 	require(script.Parent.DrawTriangle3D)
local drawLine3D =			require(script.Parent.DrawLine3D)
local drawCube =        require(script.Parent.DrawCube)
local Types = 					require(script.Parent.Types)


local function drawChunk(parent: Instance, blocks: Types.BlocksMap, startPos: Vector3, chunkSize: number): ()
	for z = 2, chunkSize do
		for y = 2, chunkSize do
			for x = 2, chunkSize do
				
				local block1 = blocks[z - 1][y - 1][x - 1]
				local block2 = blocks[z - 1][y - 1][x]
				local block3 = blocks[z][y - 1][x - 1]
				local block4 = blocks[z][y - 1][x]
				local block5 = blocks[z - 1][y][x - 1]
				local block6 = blocks[z - 1][y][x]
				local block7 = blocks[z][y][x - 1]
				local block8 = blocks[z][y][x]
			
				drawCube(parent, {
					block1,
					block2,
					block3,
					block4,
					block5,
					block6,
					block7,
					block8
				})
			end
		end
	end
end

return drawChunk