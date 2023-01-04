local M = {}

local options = require("yaml-companion.config").options
local matchers = require("yaml-companion._matchers")._loaded
local lsp = require("yaml-companion.lsp.requests")

local log = require("yaml-companion.log")

---@type Schema
local default_schema = { name = "none", uri = "none" }

---@param schema Schema
---@return boolean
local valid_schema = function(schema)
  if schema and schema.uri then
    return true
  end
  return false
end

---@return Schema[]
local options_legacy = function()
  ---@type Schema[]
  local r = {}
  if options and options.schemas and options.schemas.result then
    for _, schema in ipairs(options.schemas.result) do
      if valid_schema(schema) then
        table.insert(r, schema)
      end
    end
  end
  return r
end

---@return Schema[]
local options_new = function()
  local r = {}
  if options and options.schemas and not options.schemas.result then
    for _, schema in ipairs(options.schemas) do
      if valid_schema(schema) then
        table.insert(r, schema)
      end
    end
  end
  return r
end

---@return Schema
M.default = function()
  return default_schema
end

--- User defined schemas
---@return Schema[]
M.from_options = function()
  local r = options_legacy()
  if #r > 0 then
    log.warn(
      "Using deprecated schemas config ( '{ result = { {}, {} } }' ), please update your config and specify custom schemas as an array"
    )
  end
  r = vim.tbl_extend("keep", r, options_new())
  return r
end

--- Matcher defined schemas
---@return Schema[]
M.from_matchers = function()
  ---@type Schema[]
  local r = {}
  for _, matcher in pairs(matchers) do
    r = vim.tbl_extend("keep", r, matcher.handles())
  end
  return r
end

--- Matcher defined schemas
---@return Schema[]
M.from_store = function()
  local schemas = lsp.get_all_jsonschemas(0)
  if schemas == nil or vim.tbl_count(schemas.result or {}) == 0 then
    return {}
  end
  return schemas.result
end

---@return Schema[]
M.all = function()
  local r = M.from_options()
  r = vim.tbl_extend("keep", r, M.from_matchers())
  r = vim.tbl_extend("keep", r, M.from_store())
  return r
end

---@return Schema
---@param bufnr number
M.current = function(bufnr)
  local schema = lsp.get_jsonschema(bufnr)
  if not schema or not schema.result[1] then
    return default_schema
  end
  return schema.result[1]
end

return M
