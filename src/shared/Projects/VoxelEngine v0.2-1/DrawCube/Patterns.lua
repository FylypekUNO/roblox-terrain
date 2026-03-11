local TableUtils = require(script.Parent.Parent.Utils.Table)


local patterns: {[string]: {number}} = {
	---- Outside Walls
	--["11110000"] = {1, 2, 3, 4},
	--["00001111"] = {5, 6, 7, 8},
	--["11001100"] = {1, 2, 5, 6},
	--["00110011"] = {3, 4, 7, 8},
	--["10101010"] = {1, 3, 5, 7},
	--["01010101"] = {2, 4, 6, 8},

	---- Outside Triangular Walls
	--["11100000"] = {1, 2, 3},
	--["11010000"] = {1, 2, 4},
	--["10110000"] = {1, 3, 4},
	--["01110000"] = {2, 3, 4},

	--["00001110"] = {5, 6, 7},
	--["00001101"] = {5, 6, 8},
	--["00001011"] = {5, 7, 8},
	--["00000111"] = {6, 7, 8},

	--["11001000"] = {1, 2, 5},
	--["11000100"] = {1, 2, 6},
	--["10001100"] = {1, 5, 6},
	--["01001100"] = {2, 5, 6},

	--["00110010"] = {3, 4, 7},
	--["00110001"] = {3, 4, 8},
	--["00100011"] = {3, 7, 8},
	--["00010011"] = {4, 7, 8},

	--["10101000"] = {1, 3, 5},
	--["10100010"] = {1, 3, 7},
	--["10001010"] = {1, 5, 7},
	--["00101010"] = {3, 5, 7},

	--["01010100"] = {2, 4, 6},
	--["01010001"] = {2, 4, 8},
	--["01000101"] = {2, 6, 8},
	--["00010101"] = {4, 6, 8},

	---- Inside Walls
	--["00111100"] = {3, 4, 5, 6},
	--["11111100"] = {3, 4, 5, 6},
	--["00111111"] = {3, 4, 5, 6},
	--["11110101"] = {1, 3, 6, 8},

	---- Upper half-Corners
	--["11101000"] = {2, 3, 5},
	--["01110001"] = {2, 3, 8},
	--["11010100"] = {1, 4, 6},
	--["10110010"] = {1, 4, 7},

	---- Lower half-Corners
	--["10001110"] = {6, 7, 1},
	--["00010111"] = {6, 7, 4},
	--["01001101"] = {5, 8, 2},
	--["00101011"] = {5, 8, 3},

	---- Semi-Corners
	--["11100100"] = {1, 3, 6, 2},

	["11111111"] = {},
}

local function add(pattern: string | {string}): ()
	if type(pattern) == "table" then
		for _, pat in ipairs(pattern) do
			add(pat)
		end
		
		return
	end
	
	local query = ""
	local cornersDict: {[number]: number} = {}

	for i = 1, #pattern do
		local c = pattern:sub(i, i)

		if c == '0' then
			query = query .. '0'
		elseif c == 'X' then
			query = query .. '1'
			-- No drawing
		else
			query = query .. '1'
			cornersDict[tonumber(c)] = i
		end
	end
	
	local corners = {}
	
	for index, corner in pairs(cornersDict) do
		table.insert(corners, corner)
	end

	patterns[query] = cornersDict
end

local function _flipX(pattern: string): string
	local p = TableUtils.FromString(pattern)
	
	return `{p[3]}{p[4]}{p[1]}{p[2]}{p[7]}{p[8]}{p[5]}{p[6]}`
end

local function _flipY(pattern: string): string
	local p = TableUtils.FromString(pattern)
	
	return `{p[5]}{p[6]}{p[7]}{p[8]}{p[1]}{p[2]}{p[3]}{p[4]}`
end

local function _flipZ(pattern: string): string
	local p = TableUtils.FromString(pattern)
	
	return `{p[2]}{p[1]}{p[4]}{p[3]}{p[6]}{p[5]}{p[8]}{p[7]}`
end


local function _rotateX(pattern: string): string
	local p = TableUtils.FromString(pattern)

	return `{p[5]}{p[1]}{p[6]}{p[2]}{p[7]}{p[3]}{p[8]}{p[4]}`
end

local function _rotateY(pattern: string): string
	local p = TableUtils.FromString(pattern)

	return `{p[2]}{p[3]}{p[4]}{p[1]}{p[5]}{p[6]}{p[7]}{p[8]}`
end

local function _rotateZ(pattern: string): string
	local p = TableUtils.FromString(pattern)

	return `{p[3]}{p[4]}{p[7]}{p[8]}{p[1]}{p[2]}{p[5]}{p[6]}`
end


--
--
--

local function creator(baseFunction: (pattern: string) -> string): (patterns: string | {string}) -> {string}
	local function finalFunction(patterns: string | {string}): {string}
	
		if type(patterns) == "string" then
			return finalFunction({patterns})
		end

		local newPatterns = {}

		for _, pattern in ipairs(patterns) do
			table.insert(newPatterns, baseFunction(pattern))
		end

		return TableUtils.Sum(patterns, newPatterns)
	end
	
	return finalFunction
end

local flipX = creator(_flipX)
local flipY = creator(_flipY)
local flipZ = creator(_flipZ)

local rotateX = creator(_rotateX)
local rotateY = creator(_rotateY)
local rotateZ = creator(_rotateZ)

--
--
--
--
--
--
--
--
--
--
--
--
--

-- Ignored
add(flipX(flipY(flipZ(rotateX(rotateY(rotateZ("X00X000X")))))))


add(flipX(flipY(flipZ("14200300")))) -- Weird ones v1
add(flipX(flipY(flipZ("20X4031X")))) -- Weird ones v2
add(flipX(flipY(flipZ("02301540")))) -- Weird ones v3
add(flipX(flipY(flipZ("00210304")))) -- Weird ones v4
add(flipX(flipY(flipZ("01240300")))) -- Weird ones v5
add(flipX(flipY(flipZ("02053041")))) -- Weird ones v6
add(flipX(flipY(flipZ("62300451")))) -- Weird ones v7
--add(flipX(flipY(flipZ("00523410")))) -- Weird ones v8

add(flipX(flipY(flipZ("12000034")))) -- Inside Walls v1
add(flipX(flipY(flipZ(rotateX(rotateZ("12XX0034")))))) -- Inside Walls (Filled)
add(flipX(flipY(flipZ(rotateX(rotateY("1200XX34")))))) -- Inside Walls (Filled)

add(flipX(flipY(flipZ("01200340")))) -- Inside Walls v2
add(flipX(flipY(flipZ("012X034X")))) -- Inside Walls (Filled)
add(flipX(flipY(flipZ("X120X340")))) -- Inside Walls (Filled)

add(flipX(flipY(flipZ("012X3XXX")))) -- Cut Corners
add(flipX(flipY(flipZ("10X2X3XX")))) -- Cut Corners

add(flipX(flipY(flipZ("X1203000")))) -- Corners

add(flipX(flipY(flipZ(rotateX(rotateZ("214X0003")))))) -- Corner Wedges


add(flipX(flipY(flipZ(rotateX(rotateZ("12340000")))))) -- Full Walls
add(rotateZ(rotateX(flipY(rotateY(rotateY(rotateY("12300000"))))))) -- Triangular Walls

--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--



print(patterns)


return patterns