local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer =       game:GetService("Players").LocalPlayer
local HttpService =       game:GetService("HttpService")
local Terrain =           workspace.Terrain

local WorldConstants = require(ReplicatedStorage.Constants.World)

local fetchChunksRemote = ReplicatedStorage.Shared.Functions.FetchChunks
local fetchChunkRemote =  ReplicatedStorage.Shared.Functions.FetchChunk


type Tab1D<T> = { [number]: T }
type Tab2D<T> = { [number]: Tab1D<T> }

type Coord2 = { X: number, Z: number }


type Column = {
  SurfaceMaterial: Enum.Material,
  Height: number
}

type Chunk = Tab2D<Column>


local function renderChunk(chunk: Chunk, x: number, z: number): ()
  for cx, row in pairs(chunk) do
    for cz, column in pairs(row) do
      local columnCoordX = x * WorldConstants.CHUNK_WIDTH + cx
      local columnCoordZ = z * WorldConstants.CHUNK_WIDTH + cz

      local columnWorldPos = Vector3.new(columnCoordX, 0, columnCoordZ) * WorldConstants.COLUMN_WIDTH


      local surfaceBallWorldPos = columnWorldPos + Vector3.new(0, column.Height - WorldConstants.SURFACE_BALL_RADIUS, 0)

      Terrain:FillBall(surfaceBallWorldPos, WorldConstants.SURFACE_BALL_RADIUS, column.SurfaceMaterial)
    end
  end
end

-- WORLD TERRAIN MANAGER

local chunks2D: Tab2D<Chunk> = {}

local function getChunk(x: number, z: number): Chunk?
  return chunks2D[x] and chunks2D[x][z]
end

local function saveChunk(chunk: Chunk, x: number, z: number): ()
  if not chunks2D[x] then
    chunks2D[x] = {}
  end

  chunks2D[x][z] = chunk
end

local function fetchChunk(x: number, z:number): Chunk
  return fetchChunkRemote:InvokeServer(x, z)
end

local function fetchChunks(coords: {Coord2}): Tab2D<Chunk>
  return HttpService:JSONDecode(fetchChunksRemote:InvokeServer(coords))
end

local function fetchAndSaveChunk(x: number, z:number): Chunk
  local chunk = fetchChunk(x, z)
  
  saveChunk(chunk, x, z)
  
  return chunk
end

local function fetchAndSaveChunks(coords: {Coord2}): Tab2D<Chunk>
  local chunks = fetchChunks(coords)

  for x, row in pairs(chunks) do
    for z, chunk in pairs(row) do
      saveChunk(chunk, x, z)
    end
  end

  return chunks
end


-- Render chunks around player

local function worldPosToChunk(pos: Vector3): Coord2
  return {
    X = math.floor(pos.X / WorldConstants.CHUNK_WIDTH / WorldConstants.COLUMN_WIDTH),
    Z = math.floor(pos.Z / WorldConstants.CHUNK_WIDTH / WorldConstants.COLUMN_WIDTH)
  }
end


local function chunksInRadius(x: number, z: number, radius: number): {Coord2}
  local centerChunk = { X=x, Z=z }
  
  local chunkPoses = {centerChunk}

  -- r = distance from center
  for r=1, radius do
    -- a = position in perpendicular line
    for a=-r + 1, r do
      table.insert(chunkPoses, { X = centerChunk.X - r, Z = centerChunk.Z + a })
      table.insert(chunkPoses, { X = centerChunk.X + r, Z = centerChunk.Z + a })
      table.insert(chunkPoses, { X = centerChunk.X + a, Z = centerChunk.Z - r })
      table.insert(chunkPoses, { X = centerChunk.X + a, Z = centerChunk.Z + r })
    end
  end

  return chunkPoses
end

local function filter_onlyEmptyChunks(coords: {Coord2}): {Coord2}
  local emptyCoords = {}
  
  for _, coord in ipairs(coords) do
    if getChunk(coord.X, coord.Z) then continue end
    
    table.insert(emptyCoords, coord)
  end
  
  return emptyCoords
end


local CHUNKS_PER_CYCLE_LIMIT = 5

local function startCheckingForEmptyChunks(character: Model)
  while character.Parent do
    print("Loop start")
    local renderedChunksCount = 0
    
    local centerChunkPos = worldPosToChunk(character.PrimaryPart.Position)

    local nearbyChunksCoords = chunksInRadius(centerChunkPos.X, centerChunkPos.Z, 2)
    print(`nearbyChunksCoords [{#nearbyChunksCoords}]:`, nearbyChunksCoords)
    local emptyNearbyChunks = filter_onlyEmptyChunks(nearbyChunksCoords)
    print(`emptyNearbyChunks [{#emptyNearbyChunks}]:`, emptyNearbyChunks)
    
    local nearbyChunks2D = fetchAndSaveChunks(nearbyChunksCoords)
    print(`nearbyChunks2D [{#nearbyChunks2D}]:`, nearbyChunks2D)

    for _, coord in ipairs(emptyNearbyChunks) do
      local chunk = nearbyChunks2D[coord.X] and nearbyChunks2D[coord.X][coord.Z]
      if not chunk then continue end
      
      renderedChunksCount += 1
      if renderedChunksCount > CHUNKS_PER_CYCLE_LIMIT then break end
      
      renderChunk(chunk, coord.X, coord.Z)
      print(`rendered chunk: {coord.X} x {coord.Z}`)
    end

    task.wait(0.2)
  end
end


LocalPlayer.CharacterAdded:Connect(function(character)
  startCheckingForEmptyChunks(character)
end)

if LocalPlayer.Character then
  task.spawn(startCheckingForEmptyChunks(LocalPlayer.Character))
end