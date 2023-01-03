local M = {}

local lsp = require("yaml-companion.lsp.util")

--- Callback to be passed to vim.ui.select to display a single schema item
--- @param schema table: Schema
local display_schema_item = function(schema)
  return schema.name or schema.uri
end

--- Callback to be passed to vim.ui.select that changes the active yaml schema
--- @param schema table: Chosen schema
local select_schema = function(schema)
  if not schema then
    return
  end
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
    { format_item = display_schema_item, prompt = "Select YAML Schema" },
    select_schema
  )
end

return M
