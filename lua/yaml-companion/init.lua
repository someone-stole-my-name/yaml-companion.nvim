local M = {}

local ctx = require("yaml-companion.context")

M.setup = function(opts)
  local config = require("yaml-companion.config")
  config.setup(opts, function(client, bufnr)
    ctx.setup(bufnr, client)
  end)
  return config.options.lspconfig
end

M.set_buf_schema = function(bufnr, schema)
  ctx.schema(bufnr, schema)
end

M.get_buf_schema = function(bufnr)
  return ctx.schema(bufnr)
end

return M
