--!strict

local drawChunk =				require(script.DrawChunk)
local Types = 					require(script.Types)


local BLOCK_PHYSICAL_SIZE = 3
local CHUNK_SIZE = 20

local WORLD_START_POSITION = Vector3.new(0, 60, 0)

local SEED = 123123123
local SCALE = 150


local chunksFolder = Instance.new("Folder", workspace)
chunksFolder.Name = "Voxel_Chunks"


local function heightCallback(x: number, z: number, scale: number, seed: number): number
	local h = math.noise(x / scale, seed, z / scale) * 250 + math.noise(x / scale, seed * 2, z / scale) * 50

	if h > 3 then
		return h + WORLD_START_POSITION.Y
	else
		return 0
	end
end

for chunkZ = -8, 8 do
	for chunkY = -1, 3 do
		for chunkX = -8, 8 do
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

