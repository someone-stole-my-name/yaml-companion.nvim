local M = {}

local kubernetes_version = require("yaml-companion.kubernetes.version")

M.defaults = {
  -- Enabled Kubernetes file autodetection
  kubernetes_autodetection_enabled = true,

  -- Additional known schemas
  schemas = {
    result = {
      {
        name = "Kubernetes",
        uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/"
          .. kubernetes_version
          .. "-standalone-strict/all.json",
      },
    },
  },
  -- pass any additional options that will be merged in the final lsp config
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
end

return M
