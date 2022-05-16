local M = {}
local matchers = require("yaml-companion._matchers")

M.defaults = {
  builtin_matchers = {
    kubernetes = { enabled = true },
  },
  schemas = {},
  lspconfig = {
    flags = {
      debounce_text_changes = 150,
    },
    single_file_support = true,
    settings = {
      redhat = { telemetry = { enabled = false } },
      yaml = {
        validate = true,
        format = { enable = true },
        hover = true,
        schemaStore = {
          enable = true,
          url = "https://www.schemastore.org/api/json/catalog.json",
        },
        schemaDownload = { enable = true },
        schemas = {},
        trace = { server = "debug" },
      },
    },
  },
}

M.options = {}

function M.setup(options, on_attach)
  if options == nil then
    options = { lspconfig = {} }
  end

  -- hijack the user supplied on_attach callback to also call our own on_attach
  if options.lspconfig.on_attach then
    options.real_on_attach = options.lspconfig.on_attach
  end
  options.lspconfig.on_attach = function(client, bufnr)
    if M.options.real_on_attach then
      M.options.real_on_attach(client, bufnr)
    end
    on_attach(client, bufnr)
  end

  M.options = vim.tbl_deep_extend("force", {}, M.defaults, options or {})

  -- TODO: only load then is enabled
  matchers.load("kubernetes")
end

return M
