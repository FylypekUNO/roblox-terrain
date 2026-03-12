local ShortUtils = {}

function ShortUtils.Sort<T>(...: T): ...T
	local args = { ... }

	table.sort(args)

	return unpack(args)
end

return ShortUtils
