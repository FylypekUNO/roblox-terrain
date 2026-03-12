--!strict

local Runservice = game:GetService("RunService")

local Cube = require(script.Cube)
local CreateUI = require(script.UI)
local Table = require(script.Cube.Utils.Table)

local WorkspaceCube = workspace:WaitForChild("TheCube")

local CUBE_PHYSICAL_SIZE = WorkspaceCube.Size.X

local SCALE = 5

local WORLD_CENTER_POSITION = WorkspaceCube.Position

local FrameFolder = Instance.new("Folder")
FrameFolder.Name = "Frame"
FrameFolder.Parent = workspace

local noiseOffset = Vector3.zero

local LODContainer = { LOD = 1, Smoothness = 1 }

CreateUI(LODContainer)

local zFolders = {}

local function getDensity(position: Vector3): number
	local vec = position + noiseOffset

	return math.clamp((math.noise(vec.X / SCALE, vec.Y / SCALE, vec.Z / SCALE) + 1) / 2, 0, 1)
end

local lastLOD = 0
local lastSmoothness = 0

while Runservice.Heartbeat:Wait() do
	local lod = LODContainer.LOD
	local smoothness = LODContainer.Smoothness

	-- noiseOffset += Vector3.new(0.1, 0.1, 0.1)

	if lod == lastLOD and smoothness == lastSmoothness then
		continue
	end

	if lod ~= #zFolders or smoothness ~= lastSmoothness then
		FrameFolder:ClearAllChildren()
		zFolders = {}

		for z = 1, lod do
			local zFolder = Instance.new("Folder")
			zFolder.Name = "Z_" .. tostring(z)
			zFolder.Parent = FrameFolder

			zFolders[z] = zFolder
		end
	end

	lastLOD = lod
	lastSmoothness = smoothness

	local baseDensities: { { { number } } } = {}

	for z = 0, lod do
		local pointsXY = {}

		for y = 0, lod do
			local pointsX = {}

			for x = 0, lod do
				local position = WORLD_CENTER_POSITION
					+ Vector3.new(
						(x / lod - 0.5) * CUBE_PHYSICAL_SIZE,
						(y / lod - 0.5) * CUBE_PHYSICAL_SIZE,
						(z / lod - 0.5) * CUBE_PHYSICAL_SIZE
					)

				local density = getDensity(position)

				if density <= 0.5 then
					pointsX[x] = 0
				else
					pointsX[x] = 1
				end
			end

			pointsXY[y] = pointsX
		end

		baseDensities[z] = pointsXY
	end

	for z = 1, lod do
		local zFolder = zFolders[z]

		zFolder:ClearAllChildren()

		for y = 1, lod do
			for x = 1, lod do
				local positions: { Vector3 } = {}
				local densities: { number } = {}

				for dz = 0, 1 do
					for dy = 0, 1 do
						for dx = 0, 1 do
							local pos = WORLD_CENTER_POSITION
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

				-- if there are both solid and air densities, get new density for them and drawTheCube
				local hasSolid = table.find(densities, 1) ~= nil
				local hasAir = table.find(densities, 0) ~= nil

				if not (hasSolid and hasAir) then
					continue
				end

				local newDensities: { number } = Table.MapArray(positions, function(position)
					local baseDensity = getDensity(position)

					if baseDensity <= 0.5 then
						return math.pow(baseDensity * 2, smoothness) / 2
					else
						return 1 - math.pow((1 - baseDensity) * 2, smoothness) / 2
					end
				end)

				Cube.drawCube(zFolder, positions, newDensities)
			end
		end

		if lastLOD ~= LODContainer.LOD or lastSmoothness ~= LODContainer.Smoothness then
			break
		end

		Runservice.Heartbeat:Wait()
	end
end
