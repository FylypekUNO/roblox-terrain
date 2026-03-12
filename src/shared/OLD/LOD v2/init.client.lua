--!strict

local Runservice = game:GetService("RunService")

local Cube = require(script.Cube)
local Table = require(script.Utils.Table)
local CreateUI = require(script.UI)

local CUBE_PHYSICAL_SIZE = 16

local SCALE = 15

local WORLD_START_POSITION = Vector3.new(0, 90, 0)

local FrameFolder = Instance.new("Folder")
FrameFolder.Name = "Frame"
FrameFolder.Parent = workspace

local noiseOffset = Vector3.zero

local LODContainer = { LOD = 1 }
local BASE_LOD = 4

CreateUI(LODContainer)

local function getDensity(position: Vector3): number
	local vec = position + noiseOffset

	local d = math.clamp((math.noise(vec.X / SCALE, vec.Y / SCALE, vec.Z / SCALE) + 1) / 2, 0, 1)

	if d < 0.5 then
		return 0
	end

	if d > 0.6 then
		return 1
	end

	return (d - 0.5) * 10
end

local lastlod = -1

while true do
	local lod = BASE_LOD * LODContainer.LOD

	if lod == lastlod then
		Runservice.Heartbeat:Wait()
		continue
	end

	lastlod = lod

	FrameFolder:ClearAllChildren()

	local baseDensities: { { { number } } } = {}

	for z = 0, lod do
		local pointsXY = {}

		for y = 0, lod do
			local pointsX = {}

			for x = 0, lod do
				local position = WORLD_START_POSITION
					+ Vector3.new(
						(x / lod - 0.5) * CUBE_PHYSICAL_SIZE,
						(y / lod - 0.5) * CUBE_PHYSICAL_SIZE,
						(z / lod - 0.5) * CUBE_PHYSICAL_SIZE
					)

				table.insert(pointsX, getDensity(position))
			end

			pointsXY[y] = pointsX
		end

		baseDensities[z] = pointsXY
	end

	for z = 1, lod do
		for y = 1, lod do
			for x = 1, lod do
				local positions: { Vector3 } = {}
				local densities: { number } = {}

				for dz = 0, 1 do
					for dy = 0, 1 do
						for dx = 0, 1 do
							local pos = WORLD_START_POSITION
								+ Vector3.new(
									((x - 1 + dx) / lod - 0.5) * CUBE_PHYSICAL_SIZE,
									((y - 1 + dy) / lod - 0.5) * CUBE_PHYSICAL_SIZE,
									((z - 1 + dz) / lod - 0.5) * CUBE_PHYSICAL_SIZE
								)

							table.insert(positions, pos)
							table.insert(densities, baseDensities[z - 1 + dz][y - 1 + dy][x - 1 + dx] or 0)
						end
					end
				end

				Cube.drawCube(FrameFolder, positions, densities)
			end
		end
	end

	Runservice.Heartbeat:Wait()
end
