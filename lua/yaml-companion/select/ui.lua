local M = {}

local lsp = require("yaml-companion.lsp.util")
local matchers = require("yaml-companion._matchers")._loaded

--- Callback to be passed to vim.ui.select to display a single schema item
--- @param schema table: Schema
local display_schema_item = function(schema)
  return schema.name
end

--- Callback to be passed to vim.ui.select that changes the active yaml schema
--- @param schema table: Chosen schema
local select_schema = function(schema)
  local selected_schema = { result = { { name = schema.name, uri = schema.uri } } }
  require("yaml-companion.context").schema(0, selected_schema)
end

M.open_ui_select = function()
  local schemas = lsp.get_all_yaml_schemas()

  -- Don't open selection if there are no available schemas
  if schemas == nil then
    return
  end

  vim.ui.select(
    schemas,
    { format_item = display_schema_item, prompt = "Schema" },
    select_schema
  )
end

return M
