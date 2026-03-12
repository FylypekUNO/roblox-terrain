--!strict

local drawTriangle3D = 	require(script.Parent.DrawTriangle3D)
local drawLine3D =			require(script.Parent.DrawLine3D)
local patterns = 				require(script.Patterns)
local Types = 					require(script.Parent.Types)


local function writeQuery(blocks: {Types.BlockData}): string
	local query = ""

	for _, block in ipairs(blocks) do
		query = query .. (block.Material == "dirt" and '1' or '0')
	end

	return query
end


local function countQuery(query: string): number
	local count = 0

	for i = 1, #query do
		if (query:sub(i, i) == "1") then
			count += 1
		end
	end

	return count
end

local function drawCube(parent: Instance, blocks: {Types.BlockData}): ()
	local query = writeQuery(blocks)

	if countQuery(query) < 3 then return end

	local pattern = patterns[query]

	if pattern then
		if #pattern > 2 then
			drawTriangle3D(parent, blocks[pattern[1]].Position, blocks[pattern[2]].Position, blocks[pattern[3]].Position)
		end
		
		if #pattern > 3 then
			drawTriangle3D(parent, blocks[pattern[2]].Position, blocks[pattern[3]].Position, blocks[pattern[4]].Position)
		end
		
		if #pattern > 4 then
			drawTriangle3D(parent, blocks[pattern[2]].Position, blocks[pattern[4]].Position, blocks[pattern[5]].Position)
		end
	end
	
	for i = 1, 8 do
		local b1 = blocks[i]

		if b1.Material == "air" then continue end

		for j = i + 1, 8 do
			local b2 = blocks[j]

			if b2.Material == "air" then continue end

			drawLine3D(parent, b1.Position, b2.Position, Color3.new(1/b1.Position.X, 1/b1.Position.Y, 1/b1.Position.Z), 0.02)
		end 
	end
	

	
end

return drawCube