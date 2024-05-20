local M = {}

local api = vim.api

local schema = {
  name = "cloud-init",
  uri = "https://raw.githubusercontent.com/canonical/cloud-init/main/cloudinit/config/schemas/versions.schema.cloud-config.json",
}

M.match = function(bufnr)
  local first_line = api.nvim_buf_get_lines(bufnr, 0, 1, false)
  if vim.regex("^#cloud-config"):match_str(first_line[1]) then
    return schema
  end
end

return M
