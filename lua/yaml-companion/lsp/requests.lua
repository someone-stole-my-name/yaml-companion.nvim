local M = {}

local lsp = vim.lsp
local sync_timeout = 1000

-- Get active yamlls client
---@param bufnr number
---@return client object
M.get_client = function(bufnr)
  local clients = lsp.get_active_clients({ bufnr = bufnr })
  for _, s_client in pairs(clients) do
    if s_client.name == "yamlls" then
      return s_client
    end
  end
end

-- let the yamlls attached to {bufnr} know that we support
-- schema selection and it should fire a 'yaml/schema/store/initialized'
-- when ready to use it
---@param bufnr number
---@return table
M.support_schema_selection = function(bufnr, client)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  client = client or M.get_client(bufnr)

  if client then
    return client.notify("yaml/supportSchemaSelection")
  end
end

-- get all known schemas by the yamlls attached to {bufnr}
---@param bufnr number
---@return table
M.get_all_jsonschemas = function(bufnr, client)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  client = client or M.get_client(bufnr)
  P(client)
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
M.get_jsonschema = function(bufnr, client)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  client = client or M.get_client(bufnr)

  if client then
    local schemas =
    client.request_sync("yaml/get/jsonSchema", vim.uri_from_bufnr(bufnr), sync_timeout, bufnr)
    return schemas
  end
end

return M
