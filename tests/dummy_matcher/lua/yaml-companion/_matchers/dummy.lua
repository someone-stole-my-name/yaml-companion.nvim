local M = {}

local schema = { name = "dummy", uri = "dummy" }

M.match = function(lines)
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
