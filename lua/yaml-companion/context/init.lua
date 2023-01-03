local M = {}

local lsp = require("yaml-companion.lsp.requests")
local matchers = require("yaml-companion._matchers")._loaded

local log = require("yaml-companion.log")

---@type SchemaResult
local default_schema = { result = { { name = "none", uri = "none" } } }

---@return SchemaResult
M.default_schema = function()
  return default_schema
end

---@type { client: vim.lsp.client, schema: SchemaResult, executed: boolean}[]
M.ctxs = {}
M.initialized_client_ids = {}

---@param bufnr number
---@param client vim.lsp.client
---@return SchemaResult | nil
M.autodiscover = function(bufnr, client)
  if not M.ctxs[bufnr] then
    log.fmt_error("bufnr=%d client_id=%d doesn't exists", bufnr, client.id)
    return
  end

  if not M.initialized_client_ids[client.id] then
    log.fmt_debug("bufnr=%d client_id=%d is not yet initialized", bufnr, client.id)
    return
  end

  if M.ctxs[bufnr].executed then
    log.fmt_debug("bufnr=%d client_id=%d already executed", bufnr, client.id)
    return M.ctxs[bufnr].schema
  end

  M.ctxs[bufnr].executed = true
  local schema = lsp.get_jsonschema(bufnr)
  local options = require("yaml-companion.config").options

  if schema and schema.result and schema.result[1] and schema.result[1].uri then
    -- if LSP returns a name that means it came from SchemaStore
    -- and we can use it right away
    if schema.result[1].name then
      M.ctxs[bufnr].schema = schema
      log.fmt_debug(
        "bufnr=%d client_id=%d schema=%s an SchemaStore defined schema matched this file",
        bufnr,
        client.id,
        schema.result[1].name
      )
      return M.ctxs[bufnr].schema

      -- if it returned something without a name it means it came from our own
      -- internal schema table and we have to loop through it to get the name
    elseif options and options.schemas and options.schemas.result then
      for _, option_schema in ipairs(options.schemas.result) do
        if option_schema.uri == schema.result[1].uri then
          M.ctxs[bufnr].schema = {
            result = {
              { name = option_schema.name, uri = option_schema.uri },
            },
          }
          log.fmt_debug(
            "bufnr=%d client_id=%d schema=%s an user defined schema matched this file",
            bufnr,
            client.id,
            option_schema.name
          )
          return M.ctxs[bufnr].schema
        end
      end
      log.fmt_debug(
        "bufnr=%d client_id=%d schema=%s no user defined schema matched this file",
        bufnr,
        client.id
      )
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
        log.fmt_debug(
          "bufnr=%d client_id=%d schema=%s a registered matcher matched this file",
          bufnr,
          client.id,
          result.name
        )
        return M.ctxs[bufnr].schema
      end
    end

    log.fmt_debug("bufnr=%d client_id=%d no registered matcher matched this file", bufnr, client.id)
  end

  -- No schema matched
  log.fmt_debug("bufnr=%d client_id=%d no registered schema matches", bufnr, client.id)

  return {}
end

---@param bufnr number
---@param client vim.lsp.client
M.setup = function(bufnr, client)
  if client.name ~= "yamlls" then
    return
  end

  -- The server does support formatting but it is disabled by default
  -- https://github.com/redhat-developer/yaml-language-server/issues/486
  if require("yaml-companion.config").options.formatting then
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.documentRangeFormattingProvider = true
  end

  -- remove yamlls from not yaml files
  -- https://github.com/towolf/vim-helm/issues/15
  if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype == "helm" then
    vim.diagnostic.disable(bufnr)
    vim.defer_fn(function()
      vim.diagnostic.reset(nil, bufnr)
    end, 1000)
    vim.lsp.buf_detach_client(bufnr, client.id)
  end

  local state = {
    client = client,
    schema = default_schema,
    executed = false,
  }

  M.ctxs[bufnr] = state

  -- The first time this won't work because the client is not initialized yet
  -- but it will be called once per client from the initialized_handler when it is.
  M.autodiscover(bufnr, client)
end

---@param bufnr number
---@param schema SchemaResult | nil
---@return SchemaResult
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
    local settings = client.config.settings

    -- we don't want more than 1 schema per file
    for key, _ in pairs(settings.yaml.schemas) do
      if settings.yaml.schemas[key] == bufuri then
        settings.yaml.schemas[key] = nil
      end
    end

    local override = {}
    override[schema.result[1].uri] = bufuri

    log.fmt_debug("file=%s schema=%s set new override", bufuri, schema.result[1].uri)

    settings = vim.tbl_deep_extend("force", settings, { yaml = { schemas = override } })
    client.config.settings =
      vim.tbl_deep_extend("force", settings, { yaml = { schemas = override } })
    client.workspace_did_change_configuration(client.config.settings)
  end

  return M.ctxs[bufnr].schema
end

return M
