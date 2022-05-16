local M = {}

local default_schema = { result = { { name = "none", uri = "none" } } }
local lsp = require("yaml-companion.lsp.requests")
local matchers = require("yaml-companion._matchers")._loaded

M.default_schema = function()
  return default_schema
end

M.ctxs = {}

M.setup = function(bufnr, client)
  local timer = vim.loop.new_timer()

  local state = {
    bufnr = bufnr,
    client = client,
    schema = default_schema,
    timer = timer,
  }

  -- This timer runs periodically until
  -- it updates the context state for the buffer
  timer:start(
    1000,
    1000,
    vim.schedule_wrap(function()
      -- if we get an schema from the LSP
      local schema = lsp.get_jsonschema(bufnr)
      local options = require("yaml-companion.config").options

      if schema and schema.result and schema.result[1] and schema.result[1].uri then
        -- if LSP returns a name that means it came from SchemaStore
        -- and we can use it right away
        if schema.result[1].name then
          M.ctxs[bufnr].schema = schema
          timer:close()

          -- if it returned something without a name it means it came from our own
          -- internal schema table and we have to loop through it to get the name
        else
          for _, option_schema in ipairs(options.schemas.result) do
            if option_schema.uri == schema.result[1].uri then
              M.ctxs[bufnr].schema = {
                result = {
                  { name = option_schema.name, uri = option_schema.uri },
                },
              }
              timer:close()
            end
          end
        end

        -- if LSP is not using any schema, use registered matchers
      else
        for _, matcher in pairs(matchers) do
          local result = matcher.match(bufnr)
          if result then
            M.schema(bufnr, {
              result = {
                { name = result.name, uri = result.uri },
              },
            })
            timer:close()
          end
        end
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
    client.workspace_did_change_configuration(client.config.settings)
  end

  return M.ctxs[bufnr].schema
end

return M
