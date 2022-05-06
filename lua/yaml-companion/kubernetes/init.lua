local M = {}

M.looks_like_kubernetes = function(bufnr)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  local resources = require("yaml-companion.kubernetes.resources")
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for _, line in ipairs(lines) do
    for _, resource in ipairs(resources) do
      if vim.regex("^kind: " .. resource .. "$"):match_str(line) then
        return true
      end
    end
  end
end

return M
