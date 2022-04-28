local M = {}

local lsp = vim.lsp

-- returns the yamlls client attached to {bufnr} if it has an active yamlls attached
M.client = function(bufnr)
  local clients = lsp.buf_get_clients(bufnr)
  for _, value in pairs(clients) do
    if value.name == "yamlls" then
      return value
    end
  end
end

return M
