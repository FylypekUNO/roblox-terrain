local TableUtils = require(script.Parent.Parent.Utils.Table)

local patterns: { [string]: { number } } = {
	["11111111"] = {},
}

local function add(pattern: string | { string }): ()
	if type(pattern) == "table" then
		for _, pat in ipairs(pattern) do
			add(pat)
		end

		return
	end

	local query = ""
	local cornersDict: { [number]: number } = {}

	for i = 1, #pattern do
		local c = pattern:sub(i, i)

		if c == "0" then
			query = query .. "0"
		elseif c == "X" then
			query = query .. "1"
			-- No drawing
		else
			query = query .. "1"
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

local function creator(baseFunction: (pattern: string) -> string): (patterns: string | { string }) -> { string }
	local function finalFunction(patterns: string | { string }): { string }
		if type(patterns) == "string" then
			return finalFunction({ patterns })
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
