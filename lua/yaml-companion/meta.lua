---@meta

---@class vim.lsp.client
---@field id number
---@field name string
---@field server_capabilities table
---@field config table
---@field workspace_did_change_configuration fun(settings: table)
---@field request_sync fun(method: string, params: table | nil, timeout_ms: number | nil, bufnr: number): { err: string, result: string} | nil, string

---@class Schema
---@field name string | nil
---@field uri string

---@alias SchemaResult { result: Schema[] }

---@class Matcher
---@field match fun(bufnr: number): Schema | nil
---@field handles fun(): Schema[]

---@class ConfigOptions
---@field log_level "debug" | "trace" | "info" | "warn" | "error" | "fatal"
---@field formatting boolean
---@field schemas Schema[] | SchemaResult
---@field lspconfig table
---@field builtin_matchers table

---@class Logger
---@field fmt_debug fun(fmt: string, ...: any)
---@field fmt_error fun(fmt: string, ...: any)
---@field warn fun(message: string)
