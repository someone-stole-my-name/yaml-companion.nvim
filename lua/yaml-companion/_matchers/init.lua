local matchers = {}

matchers._loaded = {}

local load_matcher = function(name)
  local ok, m = pcall(require, "yaml-companion.builtin." .. name)
  if ok then
    return m
  end

  local ok, m = pcall(require, "yaml-companion._matchers." .. name)
  if not ok then
    error(string.format("'%s' matcher doesn't exist or isn't installed: %s", name, m))
  end
  return m
end

matchers.manager = setmetatable({}, {
  __index = function(t, k)
    local m = load_matcher(k)
    t[k] = {
      match = m.match or function()
        return false
      end,
      handles = m.handles or function()
        return {}
      end,
    }
    return t[k]
  end,
})

matchers.load = function(name)
  matchers._loaded[name] = matchers.manager[name]
  return matchers._loaded[name]
end

return matchers
