local ObjectUtils = {}

-- Create {any}

function ObjectUtils.Map<T1, T2, T3, T4>(
  t: { [T1]: T2 },
  callback: (T2, T1, { [T1]: T2 }) -> (T3, T4)
): { [T3]: T4 }
  local result = {}

  for k, v in pairs(t) do
    local resultValue, resultKey = callback(v, k, t)

    result[resultKey or k] = resultValue
  end

  return result
end

function ObjectUtils.Filter<T1, T2>(t: { [T1]: T2 }, callback: (T2, T1, { [T1]: T2 }) -> any): { [T1]: T2 }
  local result = {}

  for i, v in pairs(t) do
    if not callback(v, i, t) then
      continue
    end

    result[i] = v
  end

  return result
end

function ObjectUtils.RemoveDuplicates<T1, T2>(t: { [T1]: T2 }): { [T1]: T2 }
  local result = {}
  local flags = {}

  for k, v in pairs(t) do
    if flags[v] then
      continue
    end

    flags[v] = true

    result[k] = v
  end

  return result
end

-- Nothing {any}

function ObjectUtils.ForEach<T1, T2>(t: { [T1]: T2 }, callback: (T2, number, { [T1]: T2 }) -> ()): ()
  for k, v in pairs(t) do
    callback(v, k, t)
  end
end

-- Miscellaneous {any}

function ObjectUtils.Keys<T>(t: { [T]: any }): { T }
  local keys = {}

  for k, _ in pairs(t) do
    table.insert(keys, k)
  end

  return keys
end

return ObjectUtils
