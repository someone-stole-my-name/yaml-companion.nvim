local M = {}

local api = vim.api
local resources = require("yaml-companion.builtin.kubernetes.resources")
local version = require("yaml-companion.builtin.kubernetes.version")
local uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/"
    .. version
    .. "-standalone-strict/all.json"

local schema = {
  name = "Kubernetes",
  uri = uri,
}

M.match = function(bufnr)
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for _, line in ipairs(lines) do
    for _, resource in ipairs(resources) do
      if vim.regex("^kind: " .. resource .. "$"):match_str(line) then
        return schema
      end
    end
  end
end

M.handles = function()
  return { schema }
end

return M
