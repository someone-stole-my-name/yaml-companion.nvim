local M = {}

local default_schema = { result = { { name = "none", uri = "none" } } }
local lsp = require("yaml-companion.lsp.requests")

M.default_schema = function()
  return default_schema
end

M.ctxs = {}

M.setup = function(bufnr, client)
  lsp.support_schema_selection(bufnr)

  local timer = vim.loop.new_timer()

  local state = {
    bufnr = bufnr,
    client = client,
    schema = default_schema,
    timer = timer,
  }

  timer:start(
    1000,
    1000,
    vim.schedule_wrap(function()
      local schema = lsp.get_jsonschema(bufnr)
      if
        schema
        and schema.result
        and schema.result[1]
        and schema.result[1].name
        and schema.result[1].uri
      then
        M.ctxs[bufnr].schema = schema
      end
    end)
  )

  M.ctxs[bufnr] = state
end

M.schema = function(bufnr, schema)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  if M.ctxs[bufnr] == nil then
    return default_schema
  end

  if schema then
    M.ctxs[bufnr].schema = schema

    local bufuri = vim.uri_from_bufnr(bufnr)
    local client = M.ctxs[bufnr].client
    local settings = M.ctxs[bufnr].client.config.settings

    -- we don't want more than 1 schema per file
    for key, _ in pairs(settings.yaml.schemas) do
      if settings.yaml.schemas[key] == bufuri then
        settings.yaml.schemas[key] = nil
      end
    end

    local override = {}
    override[schema.result[1].uri] = bufuri
    settings = vim.tbl_deep_extend("force", settings, { yaml = { schemas = override } })
    client.config.settings = vim.tbl_deep_extend(
      "force",
      settings,
      { yaml = { schemas = override } }
    )
    lsp.workspace_didchangeconfiguration(bufnr, settings)
  end

  return M.ctxs[bufnr].schema
end

return M
