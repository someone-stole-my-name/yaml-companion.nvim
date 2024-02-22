local matchers = {}

---@type Matcher[]
matchers._loaded = {}

local load_matcher = function(name)
  local ok, m = pcall(require, "yaml-companion.builtin." .. name)
  if ok then
    return m
  end

  ok, m = pcall(require, "yaml-companion._matchers." .. name)
  if not ok then
    error(string.format("'%s' matcher doesn't exist or isn't installed: %s", name, m))
  end
  return m
end

matchers.manager = setmetatable({}, {
  __index = function(t, k)
    local m = load_matcher(k)
    t[k] = {
      health = m.health or function()
        local health = vim.health
        health.info("No healthcheck provided")
      end,
      match = m.match or function(_)
        return nil
      end,
      handles = m.handles or function()
        return {}
      end,
    }
    return t[k]
  end,
})

--- Loads a matcher.
---
--- Matchers have some important keys.
---     - match:
---         function(bufnr) -> table | nil
---
---         Called once per buffer if no other matcher recognizes the file. It
---         Should return a table with the schema to be used in bufnr.
---
---     - handles:
---         function() -> nil
---
---         Should return a list of all the schemas handled by this matcher.
---         This is internally used to let users manually select the schemas
---         registered by the matcher.
---
--- TODO:
---     - setup
matchers.load = function(name)
  matchers._loaded[name] = matchers.manager[name]
  return matchers._loaded[name]
end

return matchers
