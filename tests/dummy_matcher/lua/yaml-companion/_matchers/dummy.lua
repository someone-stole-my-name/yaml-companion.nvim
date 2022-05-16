local M = {}

local api = vim.api
local schema = { name = "dummy", uri = "dummy" }

M.match = function(bufnr)
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for _, line in ipairs(lines) do
    if vim.regex("^test: true"):match_str(line) then
      return schema
    end
  end
end

M.handles = function()
  return { schema }
end

return M
