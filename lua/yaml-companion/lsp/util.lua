local M = {}

local log = require("yaml-companion.log")

local sync_timeout = 5000

---@param bufnr number
---@return vim.lsp.Client | nil
M.get_client = function(bufnr)
  return vim.lsp.get_clients({ name = "yamlls", bufnr = bufnr })[1]
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

return M
