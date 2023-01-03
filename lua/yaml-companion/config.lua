local M = {}
local matchers = require("yaml-companion._matchers")
local add_hook_after = require("lspconfig.util").add_hook_after

M.defaults = {
  log_level = {
    lsp = "info",
    context = "info",
  },
  builtin_matchers = {
    kubernetes = { enabled = true },
    cloud_init = { enabled = true },
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
        schemas = { result = {} },
        trace = { server = "debug" },
      },
    },
  },
}

M.options = {}

function M.setup(options, on_attach)
  if options == nil then
    options = {}
  end

  if options.lspconfig == nil then
    options.lspconfig = {}
  end

  M.options = vim.tbl_deep_extend("force", {}, M.defaults, options or {})

  M.options.lspconfig.on_attach = add_hook_after(options.lspconfig.on_attach, on_attach)


  for name, matcher in pairs(M.options.builtin_matchers) do
    if matcher.enabled then
      matchers.load(name)
    end
  end
end

return M
