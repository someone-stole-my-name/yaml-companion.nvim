local M = {}

local log = require("yaml-companion.log")

local matchers = require("yaml-companion._matchers")._loaded

local sync_timeout = 5000

---@param bufnr number
---@return vim.lsp.client | nil
M.get_client = function(bufnr)
  return vim.lsp.get_active_clients({ name = "yamlls", bufnr = bufnr })[1]
end

---@param bufnr number
---@param method string
---@return table | nil
M.request_sync = function(bufnr, method)
  local client = require("yaml-companion.lsp.util").get_client(bufnr)

  if client then
    local response, error =
      client.request_sync(method, { vim.uri_from_bufnr(bufnr) }, sync_timeout, bufnr)

    if error then
      log.fmt_error("bufnr=%d error=%s", bufnr, error)
    end

    if response and response.err then
      log.fmt_error("bufnr=%d error=%s", bufnr, response.err)
    end

    return response
  end
end

--- Get all of the yaml schemas currently available to the server.
--- @return SchemaResult | nil schemas: merged list of user-defined, server-provided, and matcher-provided yaml schemas
M.get_all_yaml_schemas = function()
  local schemas = require("yaml-companion.lsp.requests").get_all_jsonschemas(0)
  if schemas == nil or vim.tbl_count(schemas.result or {}) == 0 then
    vim.notify("Schemas not loaded yet.")
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
