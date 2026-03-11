local TableUtils = {}

-- Create {string}

function TableUtils.FromString(str: string): {string}
  local tab = {}

  for i = 1, #str do
    tab[i] = str:sub(i, i)
  end

  return tab
end


-- Create {any}

function TableUtils.Sum<T>(...: {T}): {T}
  local result = {}

  for _, t in ipairs({...}) do
    for _, v in ipairs(t) do
      table.insert(result, v)
    end
  end

  return result
end

function TableUtils.Map<T1, T2>(t: {T1}, callback: (T1, number, {T1}) -> (T2)): {T2}
  local result = {}

  for i, v in ipairs(t) do
    local resultValue = callback(v, i, t)

    table.insert(result, resultValue)
  end

  return result
end

function TableUtils.MapWithKeys<T1, T2, T3, T4>(t: { [T1]: T2 }, callback: (T2, T1, { [T1]: T2 }) -> (T3, T4)): { [T3]: T4 }
  local result = {}

  for k, v in pairs(t) do
    local resultValue, resultKey = callback(v, k, t)

    result[resultKey or k] = resultValue
  end

  return result
end

function TableUtils.Filter<T>(t: {T}, callback: (T, number, {T}) -> (any)): {T}
  local result = {}

  for i, v in ipairs(t) do
    if not callback(v, i, t) then continue end

    table.insert(result, v)
  end

  return result
end

function TableUtils.FilterWithKeys<T1, T2>(t: { [T1]: T2 }, callback: (T2, T1, { [T1]: T2 }) -> (any)): { [T1]: T2 }
  local result = {}

  for i, v in pairs(t) do
    if not callback(v, i, t) then continue end

    result[i] = v
  end

  return result
end

function TableUtils.RemoveDuplicates<T>(t: {T}): {T}
  local result = {}
  local flags =  {}

  for _, v in ipairs(t) do
    if flags[v] then continue end

    flags[v] = true

    table.insert(result, v)
  end

  return result
end

function TableUtils.RemoveDuplicatesWithKeys<T1, T2>(t: { [T1]: T2 }): { [T1]: T2 }
  local result = {}
  local flags =  {}

  for k, v in pairs(t) do
    if flags[v] then continue end

    flags[v] = true

    result[k] = v
  end

  return result
end

-- Search {string}

function TableUtils.IsAnyStartingWith(t: {string}, ss: string): boolean
  for _, v in ipairs(t) do
    if v:sub(1, #ss) == ss then
      return true
    end
  end

  return false
end

function TableUtils.FindFirstStartingWith(t: {string}, ss: string): string
  for _, v in ipairs(t) do
    if v:sub(1, #ss) == ss then
      return v
    end
  end
end


-- Search {any}

function TableUtils.Contains<T>(t: {T}, v: T): boolean
  for _, _v in ipairs(t) do
    if _v == v then
      return true
    end
  end

  return false
end

function TableUtils.GetLongestElement<T>(t: {T}): T
  local elem = t[1]
  local len = #elem

  for _, v in ipairs(t) do
    if #v <= len then continue end

    elem = v
    len = #elem
  end

  return elem
end


-- Nothing {any}

function TableUtils.ForEach<T>(t: {T}, callback: (T, number, {T}) -> ()): ()
  for i, v in ipairs(t) do
    callback(v, i, t)
  end
end

function TableUtils.ForEachWithKeys<T1, T2>(t: { [T1]: T2 }, callback: (T2, number, { [T1]: T2 }) -> ()): ()
  for k, v in pairs(t) do
    callback(v, k, t)
  end
end

-- Miscellaneous {any}

function TableUtils.Keys<T>(t: { [T]: any }): {T}
  local keys = {}

  for k, _ in pairs(t) do
    table.insert(keys, k)
  end

  return keys
end

return TableUtils
