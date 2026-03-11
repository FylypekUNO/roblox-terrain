local Terrain = workspace.Terrain


type Map2D<T> = { [number]: { [number]: T }}

type Coord2 = { X: number, Z: number }


local function perlinNoise(seed: number, x: number, z: number, size: number): number
  local value = math.noise(seed, x / size, z / size)

  return value / 2 + 0.5
end

local function heightHeatNoise(x: number, z: number): number
  local HEIGHT_NOISE_SEED = 394857
  local HEIGHT_NOISE_SIZE = 300

  return perlinNoise(HEIGHT_NOISE_SEED, x, z, HEIGHT_NOISE_SIZE)
end


local WEDGE_THICKNESS = 0

local WEDGE = Instance.new("WedgePart")
WEDGE.Anchored = true
WEDGE.TopSurface = Enum.SurfaceType.Smooth
WEDGE.BottomSurface = Enum.SurfaceType.Smooth
WEDGE.CastShadow = false

-- Source: https://create.roblox.com/store/asset/5656315743
local function drawTriangle3D(parent: Instance, a: Vector3, b: Vector3, c: Vector3)
  local ab, ac, bc = b - a, c - a, c - b
  local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)

  if (abd > acd and abd > bcd) then
    c, a = a, c
  elseif (acd > bcd and acd > abd) then
    a, b = b, a
  end

  ab, ac, bc = b - a, c - a, c - b

  local right = ac:Cross(ab).unit
  local up = bc:Cross(right).unit
  local back = bc.unit

  local height = math.abs(ab:Dot(up))
  

  local w1 = WEDGE:Clone()
  w1.Size = Vector3.new(WEDGE_THICKNESS, height, math.abs(ab:Dot(back)))
  w1.CFrame = CFrame.fromMatrix((a + b) / 2, right, up, back)
  w1.Parent = parent

  local absoluteHeightW1 = math.abs(w1.Position.Y - 20) * 1.25
  w1.Color = Color3.fromRGB(75 + absoluteHeightW1, 151 + absoluteHeightW1, 75 + absoluteHeightW1)

  local w2 = WEDGE:Clone()
  w2.Size = Vector3.new(WEDGE_THICKNESS, height, math.abs(ac:Dot(back)))
  w2.CFrame = CFrame.fromMatrix((a + c)/2, -right, up, -back)
  w2.Parent = parent

  local absoluteHeightW2 = math.abs(w2.Position.Y - 20) * 1.25
  w2.Color = Color3.fromRGB(75 + absoluteHeightW2, 151 + absoluteHeightW2, 75 + absoluteHeightW2)

  return w1, w2
end

local CHUNK_WIDTH = 128

local function generateChunkHeatMap(noiseCallback: (x: number, z: number) -> (number), chunkX: number, chunkZ: number, quality: number): Map2D<number>
  local map = {}

  local posDiff = CHUNK_WIDTH / quality

  local chunkOffset = Vector3.new(chunkX, 0, chunkZ) * CHUNK_WIDTH

  for x=0, quality do
    local row = {}

    local posX = chunkOffset.X + x * posDiff

    for z=0, quality do
      local posZ = chunkOffset.Z + z * posDiff
      
      row[z] = noiseCallback(posX, posZ)
    end

    map[x] = row
  end

  return map
end

local function generateChunkHeightMap(chunkX: number, chunkZ: number, quality: number): Map2D<number>
  return generateChunkHeatMap(function(x, z)
    local heat = heightHeatNoise(x, z)
    
    return 10 + heat * 100
  end, chunkX, chunkZ, quality)
end

local function drawChunk(parent: Instance, chunkX: number, chunkZ: number, heightMap: Map2D<number>): Folder
  local folder = Instance.new("Folder", parent)
  folder.Name = `{chunkX}x{chunkZ}`
  
  local pointsCountInLine = #heightMap
  local posDiff = CHUNK_WIDTH / (pointsCountInLine)
  
  local chunkOffset = Vector3.new(chunkX, 0, chunkZ) * CHUNK_WIDTH
  
  for x=0, pointsCountInLine - 1 do
    local pos1 = chunkOffset + Vector3.new(x * posDiff, heightMap[x][0], 0)
    local pos2 = Vector3.new(pos1.X + posDiff, heightMap[x + 1][0], pos1.Z)

    for z=0, pointsCountInLine - 1 do
      local pos3 = Vector3.new(pos1.X, heightMap[x][z + 1], pos1.Z + posDiff)
      
      local w1, w2 = drawTriangle3D(folder, pos1, pos2, pos3)
      
      pos1 = pos3
      pos3 = Vector3.new(pos1.X + posDiff, heightMap[x + 1][z + 1], pos1.Z)
      
      local w3, w4 = drawTriangle3D(folder, pos1, pos2, pos3)
      
      pos2 = pos3
    end
  end
  
  return folder
end




-- Tests

local RADIUS_IN_CHUNKS = 8
local START_POS = Vector3.new(0, 0, 0)

local function chunksInRadius(x: number, z: number, radius: number): {Coord2}
  local chunksCoords = {{ X=x, Z=z }}

  -- r = distance from center
  for r=1, radius do
    -- a = position in perpendicular line
    for a=0, r * 2 - 1 do
      table.insert(chunksCoords, { X = x - r, Z = z - r + a })
      table.insert(chunksCoords, { X = x + r, Z = z + r - a })
      table.insert(chunksCoords, { Z = z - r, X = x + r - a })
      table.insert(chunksCoords, { Z = z + r, X = x - r + a })
    end
  end

  return chunksCoords
end


local function measureTime(func: () -> ())
  local startTime = os.clock()

  func()

  local endTime = os.clock()

  return endTime - startTime
end



local chunksFolder = Instance.new("Folder", workspace)
chunksFolder.Name = "Chunks"


local function drawFirstNotRendered(coords: {Coord2}): Folder
  for _, coord in ipairs(coords) do
    if chunksFolder:FindFirstChild(`{coord.X}x{coord.Z}`) then continue end

    local chunkHeightMap = generateChunkHeightMap(coord.X, coord.Z, 8)
    local chunkFolder = drawChunk(chunksFolder, coord.X, coord.Z, chunkHeightMap)
    
    return chunkFolder
  end
end

local function infinitelyDrawTerrainAroundPlayer()
  local RunService = game:GetService("RunService")
  local Player = game:GetService("Players").LocalPlayer
  
  local function checkAndDrawInfinitely()
    local character = Player.Character
    if not character then return end
    
    local primaryPart = character.PrimaryPart
    if not primaryPart then return end
    
    local characterCoord = { 
      X = math.floor(primaryPart.Position.X / CHUNK_WIDTH),
      Z = math.floor(primaryPart.Position.Z / CHUNK_WIDTH),
    }
    
    local coords = chunksInRadius(characterCoord.X, characterCoord.Z, 4)
    
    drawFirstNotRendered(coords)
  end
  
  local thread = coroutine.create(function()
    while true do
      checkAndDrawInfinitely()
      coroutine.yield()
    end
  end)
  
  RunService.Heartbeat:Connect(function()
    coroutine.resume(thread)
  end)
end

infinitelyDrawTerrainAroundPlayer()