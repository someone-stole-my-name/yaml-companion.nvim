---@meta

---@class vim.lsp.Client
---@field workspace_did_change_configuration fun(settings: table)

---@class Schema
---@field name string | nil
---@field uri string

---@alias SchemaResult { result: Schema[] }

---@class Matcher
---@field match fun(bufnr: number): Schema | nil
---@field handles fun(): Schema[]
---@field health fun()

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
---@field new fun(config: table, standalone: boolean): Logger
