local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService =        game:GetService("RunService")
local Players =           game:GetService("Players")

local drawChunk =  require(script.DrawChunk)
local Vector3Utils =      require(ReplicatedStorage.Utils.Vector3)


local BLOCK_WIDTH = 8
local CHUNK_WIDTH = 64

local RENDER_DISTANCE = 12

local QualityEnum = table.freeze({
  Low = 1,
  Medium = 2,
  High = 3
})

type Chunk = {
  Folder: Folder,
  Pos: Vector3,
  Quality: number
}


local SEED = math.random(999999)
local SCALE = 250

local function heightCallback(x: number, z: number): number
  local vec = Vector2.new(x, z)
  
  local distanceFromCenter = (vec - Vector2.new(0, 0)).Magnitude
  
  local target = math.noise(x / SCALE, z / SCALE, SEED) * math.sqrt(math.abs(x) * math.abs(z))
  
  if distanceFromCenter < 50 then
    return 75
  end
  
  return target
end


local chunksFolder = Instance.new("Folder", workspace)
chunksFolder.Name = "Chunks"


local function createChunkFolder(parent: Instance, x: number, z: number): Folder
  local folder = Instance.new("Folder", parent)
  folder.Name = `{x}x{z}`

  return folder
end


local _chunksMap = {}

local function getChunk(x: number, z: number): Chunk?
  return _chunksMap[x] and _chunksMap[x][z]
end

local function setChunk(x: number, z: number, chunk: Chunk): ()
  local row = _chunksMap[x] or {}
  
  row[z] = chunk
  
  _chunksMap[x] = row
end

local function destroyChunk(chunk: Chunk): ()
  chunk.Folder:Destroy()
  
  _chunksMap[chunk.Pos.X][chunk.Pos.Z] = nil
end

local function clearChunk(chunk: Chunk): ()
  chunk.Folder:Destroy()
end

local function loadChunk(x: number, z: number): Chunk
  local chunk = getChunk(x, z)
  
  if chunk then
    clearChunk(chunk)
  else
    chunk = {
      Pos = Vector3.new(x, 0, z)
    }
  end
  
  setChunk(x, z, chunk)
  
  chunk.Folder = createChunkFolder(chunksFolder, x, z)
  
  drawChunk(chunk.Folder, x, z, CHUNK_WIDTH, BLOCK_WIDTH, heightCallback)
  
  return chunk
end


local function chunksInRadius(center: Vector3, radius: number): {Vector3}
  if not radius or radius < 0 then return {} end
  
  center = Vector3Utils.Floor(center)

  local coords = {center}

  -- r = distance from center
  for r=1, math.floor(radius) do
    -- a = position in perpendicular line
    for a=0, r * 2 - 1 do
      local v1 = Vector3.new(r, 0, r - a)
      local v2 = Vector3.new(r - a, 0, -r)
      
      table.insert(coords, center + v1)
      table.insert(coords, center + v2)

      table.insert(coords, center - v1)
      table.insert(coords, center - v2)
    end
  end

  return coords
end


local function loadFirstEmpty(poses: {Coord2}): Folder
  for _, pos in ipairs(poses) do
    if getChunk(pos.X, pos.Z) then continue end

    
    return loadChunk(pos.X, pos.Z)
  end
end

local function removeTooMuch(): ()
  local requiredChunks = {}

  for _, player in ipairs(Players:GetPlayers()) do
    local character = player.Character
    if not character then return end

    local primaryPart = character.PrimaryPart :: Part
    if not primaryPart then return end

    local characterChunkPos = primaryPart.Position / CHUNK_WIDTH

    local chunks = chunksInRadius(characterChunkPos, RENDER_DISTANCE)

    for _, chunk in ipairs(chunks) do
      local row = requiredChunks[chunk.X] or {}

      row[chunk.Z] = true

      requiredChunks[chunk.X] = row
    end
  end

  for x, row in pairs(_chunksMap) do
    for z, chunk in pairs(row) do
      if requiredChunks[x] and requiredChunks[x][z] then continue end

      destroyChunk(chunk)
    end
  end
end


local function checkAndDraw(player)
  local character = player.Character
  if not character then return end

  local primaryPart = character.PrimaryPart :: Part
  if not primaryPart then return end

  local characterChunkPos = primaryPart.Position / CHUNK_WIDTH

  local coords = chunksInRadius(characterChunkPos, RENDER_DISTANCE)

  loadFirstEmpty(coords)
end

RunService.Heartbeat:Connect(function()
  removeTooMuch()
  for _, player in ipairs(Players:GetPlayers()) do
    checkAndDraw(player)
  end
end)