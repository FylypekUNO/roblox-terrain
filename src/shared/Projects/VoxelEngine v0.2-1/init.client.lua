--!strict

local drawChunk =				require(script.DrawChunk)
local Types = 					require(script.Types)


local BLOCK_PHYSICAL_SIZE = 2
local CHUNK_SIZE = 4

local WORLD_START_POSITION = Vector3.new(0, 80, 0)

local SEED = 123123123
local SCALE = 10


local chunksFolder = Instance.new("Folder", workspace)
chunksFolder.Name = "Voxel_Chunks"

for chunkZ = -4, 4 do
	for chunkY = -1, 3 do
		for chunkX = -4, 4 do
			local chunkFolder = Instance.new("Folder")
			chunkFolder.Name = `{chunkX}x{chunkY}x{chunkZ}`

			local chunkStartPos = WORLD_START_POSITION + Vector3.new(chunkX, chunkY, chunkZ) * (CHUNK_SIZE - 1) * BLOCK_PHYSICAL_SIZE - Vector3.one * BLOCK_PHYSICAL_SIZE / 2

			local blocks: Types.BlocksMap = {}

			for blockZ = 1, CHUNK_SIZE do
				local blocksXY = {}
				local posZ = chunkStartPos.Z + (blockZ * BLOCK_PHYSICAL_SIZE)

				for blockY = 1, CHUNK_SIZE do
					local blocksX = {}
					local posY = chunkStartPos.Y + (blockY * BLOCK_PHYSICAL_SIZE)

					for blockX = 1, CHUNK_SIZE do
						local posX = chunkStartPos.X + (blockX * BLOCK_PHYSICAL_SIZE)

						local density = math.clamp(math.noise(posX / SCALE, posY / SCALE, posZ / SCALE) + 1 / 2, 0, 1)

						local block: Types.BlockData

						if density > 0.8 then
							block = {
								Material = "dirt",
								Position = Vector3.new(posX, posY, posZ)
							}
						else
							block = {
								Material = "air",
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

