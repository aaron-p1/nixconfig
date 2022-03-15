local helper = {}

-- Not allowed to require rocks

function helper.registerPluginWk(config)
  assert(config.map ~= nil, "Map cannot be nil")

  if package.loaded["which-key"] then
    local wk = require("which-key")

    wk.register(config.map, {
      prefix = config.prefix or "",
      buffer = config.buffer,
    })
  end
end

function helper.setOptions(optapi, table)
  for key, val in pairs(table) do
    -- check if bool option
    if tonumber(key) == nil then
      optapi[key] = val
    else
      local isno = string.sub(val, 0, 2) == "no"
      local optname = isno and string.sub(val, 3, string.len(val)) or val

      optapi[optname] = not isno
    end
  end
end

function helper.startsWith(str, start)
  return str:sub(1, #start) == start
end

function helper.endsWith(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

function helper.chain(...)
  local fnchain = { ... }
  return function(...)
    local args = { ... }
    for _, fn in ipairs(fnchain) do
      args = { fn(unpack(args)) }
    end
    return unpack(args)
  end
end

return helper
