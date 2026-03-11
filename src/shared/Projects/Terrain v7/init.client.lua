local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService =        game:GetService("RunService")
local Players =           game:GetService("Players")

local drawChunk =  		    require(script.DrawChunk)
local generateVerticesMap = require(script.GenerateVerticesMap)
local Vector3Utils =        require(ReplicatedStorage.Utils.Vector3)
local Vector2Utils =        require(ReplicatedStorage.Utils.Vector2)
local TableUtils =          require(ReplicatedStorage.Utils.Table)


local BLOCK_WIDTH = 16
local CHUNK_WIDTH = 256
local BLOCKS_PER_SIDE = math.floor(CHUNK_WIDTH / BLOCK_WIDTH)

local RENDER_DISTANCE = 6

local SEED = 123123123
local SCALE = 250

local chunksFolder = Instance.new("Folder", workspace)
chunksFolder.Name = "Chunks"

local function _getChunkIndex(x: number, z: number): string
	return `{x}x{z}`
end


local function createChunkFolder(parent: Instance, x: number, z: number): Folder
  	local folder = Instance.new("Folder", parent)
	folder.Name = _getChunkIndex(x, z)
	
	folder:SetAttribute("x", x)
	folder:SetAttribute("z", z)

  	return folder
end

local _chunksMap: {[string]: Folder} = {}


local function getChunk(x: number, z: number): Folder?
  	return _chunksMap[_getChunkIndex(x, z)]
end

local function setChunk(x: number, z: number, folder: Folder): ()
  	_chunksMap[_getChunkIndex(x, z)] = folder
end

local function retrieveChunk(x: number, z: number): Folder
  	local chunk = getChunk(x, z)
  
	if chunk then return chunk end
  
	local folder = createChunkFolder(chunksFolder, x, z)

	local startPos = Vector3.new(x * CHUNK_WIDTH, 0, z * CHUNK_WIDTH)
	
	local verticesMap = generateVerticesMap(startPos, CHUNK_WIDTH, BLOCKS_PER_SIDE, SCALE, SEED)
	drawChunk(folder, verticesMap, #verticesMap)
	
	setChunk(x, z, folder)
  
  	return folder
end


local function chunksInRadius(center: Vector2, radius: number): {Vector2}
  if not radius or radius < 0 then return {} end
  
  center = Vector2Utils.Floor(center)

  local coords = {center}

  -- r = distance from center
  for r=1, math.floor(radius) do
    -- a = position in perpendicular line
    for a=0, r * 2 - 1 do
      local v1 = Vector2.new(r, r - a)
      local v2 = Vector2.new(r - a, -r)
      
      table.insert(coords, center + v1)
      table.insert(coords, center + v2)

      table.insert(coords, center - v1)
      table.insert(coords, center - v2)
    end
  end

  return coords
end


local function loadFirstEmpty(poses: {Vector2}): Folder
  for _, pos in ipairs(poses) do
	if getChunk(pos.X, pos.Y) then continue end
    
    return retrieveChunk(pos.X, pos.Y)
  end
end

local function removeTooMuch(): ()
	local pending = 3
	
  	for _, player in ipairs(Players:GetPlayers()) do
    	local character = player.Character
    	if not character then return end

    	local primaryPart = character.PrimaryPart :: Part
    	if not primaryPart then return end

    	local characterChunkPos = primaryPart.Position / CHUNK_WIDTH

    	local requiredChunks = chunksInRadius(Vector2.new(characterChunkPos.X, characterChunkPos.Z), RENDER_DISTANCE)

		for _, chunk in pairs(_chunksMap) do
			local chunkPos = Vector2.new(chunk:GetAttribute("x"), chunk:GetAttribute("z"))
			
			if pending <= 0 then return end
			pending -= 1
		
			if TableUtils.Contains(requiredChunks, chunkPos) then continue end
		
			_chunksMap[chunk.Name] = nil
			chunk:Destroy()
    	end
  	end
end


local function checkAndDraw(player)
  local character = player.Character
  if not character then return end

  local primaryPart = character.PrimaryPart :: Part
  if not primaryPart then return end

  local characterChunkPos = primaryPart.Position / CHUNK_WIDTH

  local coords = chunksInRadius(Vector2.new(characterChunkPos.X, characterChunkPos.Z), RENDER_DISTANCE)

  loadFirstEmpty(coords)
end

while true do
  	removeTooMuch()
  	for _, player in ipairs(Players:GetPlayers()) do
    	checkAndDraw(player)
	end
	
	RunService.Heartbeat:Wait()
end