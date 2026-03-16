local ArrayUtils = {}

-- Create {string}

function ArrayUtils.FromString(str: string): { string }
  local tab = {}

  for i = 1, #str do
    tab[i] = str:sub(i, i)
  end

  return tab
end

-- Create {any}

function ArrayUtils.Sum<T>(...: { T }): { T }
  local result = {}

  for _, t in ipairs({ ... }) do
    for _, v in ipairs(t) do
      table.insert(result, v)
    end
  end

  return result
end

function ArrayUtils.Map<T1, T2>(t: { T1 }, callback: (T1, number, { T1 }) -> T2): { T2 }
  local result = {}

  for i, v in ipairs(t) do
    local resultValue = callback(v, i, t)

    table.insert(result, resultValue)
  end

  return result
end

function ArrayUtils.Filter<T>(t: { T }, callback: (T, number, { T }) -> any): { T }
  local result = {}

  for i, v in ipairs(t) do
    if not callback(v, i, t) then
      continue
    end

    table.insert(result, v)
  end

  return result
end

function ArrayUtils.RemoveDuplicates<T>(t: { T }): { T }
  local result = {}
  local flags = {}

  for _, v in ipairs(t) do
    if flags[v] then
      continue
    end

    flags[v] = true

    table.insert(result, v)
  end

  return result
end

-- Search {string}

function ArrayUtils.IsAnyStartingWith(t: { string }, ss: string): boolean
  for _, v in ipairs(t) do
    if v:sub(1, #ss) == ss then
      return true
    end
  end

  return false
end

function ArrayUtils.FindFirstStartingWith(t: { string }, ss: string): string | nil
  for _, v in ipairs(t) do
    if v:sub(1, #ss) == ss then
      return v
    end
  end

  return nil
end

-- Search {any}

function ArrayUtils.Contains<T>(t: { T }, v: T): boolean
  for _, _v in ipairs(t) do
    if _v == v then
      return true
    end
  end

  return false
end

function ArrayUtils.GetLongestElement<T>(t: { T }): T
  local elem = t[1]
  local len = #elem

  for _, v in ipairs(t) do
    if #v <= len then
      continue
    end

    elem = v
    len = #elem
  end

  return elem
end

-- Nothing {any}

function ArrayUtils.ForEach<T>(t: { T }, callback: (T, number, { T }) -> ()): ()
  for i, v in ipairs(t) do
    callback(v, i, t)
  end
end

return ArrayUtils
