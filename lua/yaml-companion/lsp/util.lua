local M = {}

local lsp = require("yaml-companion.lsp.requests")
local matchers = require("yaml-companion._matchers")._loaded

--- Get all of the yaml schemas currently available to the server.
--- @return table schemas: merged list of user-defined, server-provided, and matcher-provided yaml schemas
M.get_all_yaml_schemas = function()
  local schemas = lsp.get_all_jsonschemas(0)

  if schemas == nil then
    return
  end

  -- merge with user defined schemas
  schemas = vim.tbl_deep_extend(
    "force",
    schemas.result,
    require("yaml-companion.config").options.schemas.result or {}
  )

  -- merge with matchers exposed schemas
  for _, matcher in pairs(matchers) do
    local handles = matcher.handles() or {}
    for _, schema in ipairs(handles) do
      table.insert(schemas, schema)
    end
  end

  return schemas
end

return M
