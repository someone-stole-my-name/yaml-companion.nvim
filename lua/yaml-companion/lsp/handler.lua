local M = {}

local log = require("yaml-companion.log")

--local custom_schema_content_cache = {}

M.store_initialized = function(_, _, req, _)
  local client_id = req.client_id

  require("yaml-companion").ctx.initialized_client_ids[client_id] = true

  local client = vim.lsp.get_client_by_id(client_id)
  local buffers = vim.lsp.get_buffers_by_client_id(client_id)

  for _, bufnr in ipairs(buffers) do
    log.fmt_debug("client_id=%d bufnr=%d running autodiscover", client_id, bufnr)
    require("yaml-companion").ctx.autodiscover(bufnr, client)
  end
end


return M
