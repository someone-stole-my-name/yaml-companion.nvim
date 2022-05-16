local M = {}

local _matchers = require("yaml-companion._matchers")
local ctx = require("yaml-companion.context")

M.setup = function(opts)
  local config = require("yaml-companion.config")
  config.setup(opts, function(client, bufnr)
    ctx.setup(bufnr, client)
  end)
  return config.options.lspconfig
end

M.set_buf_schema = function(bufnr, schema)
  ctx.schema(bufnr, schema)
end

M.get_buf_schema = function(bufnr)
  return ctx.schema(bufnr)
end

--- Loads a matcher.
---@param name string: Name of the matcher
M.load_matcher = function(name)
  return _matchers.load(name)
end

return M
