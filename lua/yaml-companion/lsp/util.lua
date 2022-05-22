local M = {}

local nvim_lsp = vim.lsp
local yaml_lsp = require("yaml-companion.lsp.requests")
local matchers = require("yaml-companion._matchers")._loaded

-- returns the yamlls client attached to {bufnr} if it has an active yamlls attached
M.client = function(bufnr)
  local clients = nvim_lsp.buf_get_clients(bufnr)
  for _, value in pairs(clients) do
    if value.name == "yamlls" then
      return value
    end
  end
end

--- Get all of the yaml schemas currently available to the server.
--- @return table schemas: merged list of user-defined and server-provided yaml schemas
M.get_all_yaml_schemas = function()
  local schemas = yaml_lsp.get_all_jsonschemas(0)

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
