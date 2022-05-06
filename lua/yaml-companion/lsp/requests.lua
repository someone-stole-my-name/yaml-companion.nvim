local M = {}

local sync_timeout = 1000

-- get all known schemas by the yamlls attached to {bufnr}
---@param bufnr number
---@return table
M.get_all_jsonschemas = function(bufnr)
  local client = require("yaml-companion.lsp.util").client(bufnr)
  if client then
    return client.request_sync(
      "yaml/get/all/jsonSchemas",
      vim.uri_from_bufnr(bufnr),
      sync_timeout,
      bufnr
    )
  end
end

-- get schemas used for {bufnr} by the yamlls attached to it
---@param bufnr number
---@return table
M.get_jsonschema = function(bufnr)
  local client = require("yaml-companion.lsp.util").client(bufnr)
  if client then
    local schemas = client.request_sync(
      "yaml/get/jsonSchema",
      vim.uri_from_bufnr(bufnr),
      sync_timeout,
      bufnr
    )
    return schemas
  end
end

return M
