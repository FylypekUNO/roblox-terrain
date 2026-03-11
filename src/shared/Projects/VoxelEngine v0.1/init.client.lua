--!strict

local drawChunk =				require(script.DrawChunk)
local Types = 					require(script.Types)


local BLOCK_PHYSICAL_SIZE = 24
local CHUNK_SIZE = 6

local SEED = 123123123
local SCALE = 250


local chunksFolder = Instance.new("Folder", workspace)
chunksFolder.Name = "Voxel_Chunks"


local function heightCallback(x: number, z: number, scale: number, seed: number): number
	local h = math.noise(x / scale, seed, z / scale) * 250 + math.noise(x / scale, seed * 2, z / scale) * 50

	if h > 3 then
		return h
	else
		return 0
	end
end


for chunkZ = -6, 6 do
	for chunkY = -1, 2 do
		for chunkX = -6, 6 do
			local chunkFolder = Instance.new("Folder")
			chunkFolder.Name = `{chunkX}x{chunkY}x{chunkZ}`
			
			local chunkStartPos = Vector3.new(chunkX, chunkY, chunkZ) * (CHUNK_SIZE - 1) * BLOCK_PHYSICAL_SIZE - Vector3.one * BLOCK_PHYSICAL_SIZE / 2
			
			local blocks: Types.BlocksMap = {}
			
			for blockZ = 1, CHUNK_SIZE do
				local blocksXY = {}
				local posZ = chunkStartPos.Z + (blockZ * BLOCK_PHYSICAL_SIZE)
				
				for blockY = 1, CHUNK_SIZE do
					local blocksX = {}
					local posY = chunkStartPos.Y + (blockY * BLOCK_PHYSICAL_SIZE)
					
					for blockX = 1, CHUNK_SIZE do
						local posX = chunkStartPos.X + (blockX * BLOCK_PHYSICAL_SIZE)
						
						local height = heightCallback(posX, posZ, SCALE, SEED)
						
						local block: Types.BlockData
						
						if posY > height then
							block = {
								Material = "air",
								Position = Vector3.new(posX, posY, posZ)
							}
						else
							block = {
								Material = "dirt",
								Position = Vector3.new(posX, posY, posZ)
							}
						end
						
						blocksX[blockX] = block
					end
					
					blocksXY[blockY] = blocksX
				end
				
				blocks[blockZ] = blocksXY
			end
			
			drawChunk(chunkFolder, blocks, chunkStartPos, CHUNK_SIZE)
			task.wait()
			
			chunkFolder.Parent = chunksFolder
		end
	end
end

