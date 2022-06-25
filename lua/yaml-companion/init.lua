local M = {}

local _matchers = require("yaml-companion._matchers")
local ctx = require("yaml-companion.context")

M.setup = function(opts)
  local config = require("yaml-companion.config")
  config.setup(opts, function(client, bufnr)
    ctx.setup(bufnr, client)
  end)
  vim.lsp.handlers["yaml/schema/store/initialized"] = ctx.store_initialized_handler
  return config.options.lspconfig
end

--- Set the schema used for a buffer.
---@param bufnr number: Buffer number
---@param schema table: Schema
M.set_buf_schema = function(bufnr, schema)
  ctx.schema(bufnr, schema)
end

--- Get the schema used for a buffer.
---@param bufnr number: Buffer number
M.get_buf_schema = function(bufnr)
  return ctx.schema(bufnr)
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
