--!strict

local drawTriangle3D = 	require(script.Parent.DrawTriangle3D)
local drawLine3D =			require(script.Parent.DrawLine3D)
local Types = 					require(script.Parent.Types)

local function drawChunk(parent: Instance, blocks: Types.BlocksMap, startPos: Vector3, chunkSize: number): ()
	local linesFolder = Instance.new("Folder")
	linesFolder.Name = "Lines"
	
	for z = 2, chunkSize do
		for y = 2, chunkSize do
			for x = 2, chunkSize do
				
				-- Bottom   Top
				--  3--4    7--8
				--  |  |    |  |
				--  1--2    5--6
				
				local block1 = blocks[z - 1][y - 1][x - 1]
				local block2 = blocks[z - 1][y - 1][x]
				local block3 = blocks[z - 1][y][x - 1]
				local block4 = blocks[z - 1][y][x]
				local block5 = blocks[z][y - 1][x - 1]
				local block6 = blocks[z][y - 1][x]
				local block7 = blocks[z][y][x - 1]
				local block8 = blocks[z][y][x]
				
				local selectedBlocks = {
					block1,
					block2,
					block3,
					block4,
					block5,
					block6,
					block7,
					block8
				}
				
				for i = 1, 8 do
					local b1 = selectedBlocks[i]
					
					if b1.Material == "air" then continue end
					
					for j = i + 1, 8 do
						local b2 = selectedBlocks[j]
						
						if b2.Material == "air" then continue end
						
						local part = drawLine3D(linesFolder, b1.Position, b2.Position, Color3.new(1/x, 1/y, 1/z), 0.3)
						part.Name = `{x}x{y}x{z}-{i}x{j}`
					end 
				end
			end
		end
	end

	linesFolder.Parent = parent
end

return drawChunk