local RunService = game:GetService("RunService")

local drawTriangle3D = require(script.Parent.DrawTriangle3D)

local function drawChunk(
	wedgesContainer: Instance, 
	verticesMap: {[number]: {[number]: Vector3}},
	verticesPerSide: number
): ()
	for x = 1, verticesPerSide - 1 do
		local pos1 = verticesMap[x][1]
		local pos2 = verticesMap[x + 1][1]

		for z = 2, verticesPerSide do
			local pos3 = verticesMap[x][z]
			
			-- 2
			-- |\
			-- 1-3
		    drawTriangle3D(wedgesContainer, pos1, pos2, pos3)

		    pos1 = pos3
		    pos3 = verticesMap[x + 1][z]

			-- 2-3
			--  \|
			--   1
		    drawTriangle3D(wedgesContainer, pos1, pos2, pos3)

		    pos2 = pos3
		end
		
		RunService.Heartbeat:Wait()
	end
	
	
end
  
return drawChunk