local M = {}

local _matchers = require("yaml-companion._matchers")
M.ctx = {}

M.setup = function(opts)
  local config = require("yaml-companion.config")
  config.setup(opts, function(client, bufnr)
    require("yaml-companion.context").setup(bufnr, client)
  end)
  M.ctx = require("yaml-companion.context")
  require("yaml-companion.log").new({ level = config.options.log_level }, true)
  return config.options.lspconfig
end

--- Set the schema used for a buffer.
---@param bufnr number: Buffer number
---@param schema SchemaResult | Schema
M.set_buf_schema = function(bufnr, schema)
  M.ctx.schema(bufnr, schema)
end

--- Get the schema used for a buffer.
---@param bufnr number: Buffer number
M.get_buf_schema = function(bufnr)
  -- TODO: remove the result and instead return a Schema directly
  -- this will break existing clients :/
  return { result = { M.ctx.schema(bufnr) } }
end

--- Loads a matcher.
---@param name string: Name of the matcher
M.load_matcher = function(name)
  return _matchers.load(name)
end

--- Opens a vim.ui.select menu to choose a schema
M.open_ui_select = function()
  require("yaml-companion.select.ui").open_ui_select()
end

return M
