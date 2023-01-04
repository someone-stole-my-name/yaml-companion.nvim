# yaml-companion.nvim [![Build](https://github.com/someone-stole-my-name/yaml-companion.nvim/actions/workflows/main.yml/badge.svg)](https://github.com/someone-stole-my-name/yaml-companion.nvim/actions/workflows/main.yml)

![telescope](./resources/screenshots/telescope.png)
![statusbar](./resources/screenshots/statusbar.png)

## ⚡️ Requirements

- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [yaml-language-server](https://github.com/redhat-developer/yaml-language-server)

## ✨ Features

- Builtin Kubernetes manifest autodetection
- Get/Set specific JSON schema per buffer
- Extensible autodetection + Schema Store support 

## 📦 Installation

Install the plugin and load the `telescope` extension with your preferred package manager:

**Packer**

```lua
use {
  "someone-stole-my-name/yaml-companion.nvim",
  requires = {
      { "neovim/nvim-lspconfig" },
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
  },
  config = function()
    require("telescope").load_extension("yaml_schema")
  end,
}
```

## ⚙️  Configuration

**yaml-companion** comes with the following defaults:

```lua
{
  -- Built in file matchers
  builtin_matchers = {
    -- Detects Kubernetes files based on content
    kubernetes = { enabled = true },
    cloud_init = { enabled = true }
  },

  -- Additional schemas available in Telescope picker
  schemas = {
    --{
      --name = "Kubernetes 1.22.4",
      --uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.22.4-standalone-strict/all.json",
    --},
  },

  -- Pass any additional options that will be merged in the final LSP config
  lspconfig = {
    flags = {
      debounce_text_changes = 150,
    },
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
```

```lua
local cfg = require("yaml-companion").setup({
  -- Add any options here, or leave empty to use the default settings
  -- lspconfig = {
  --   cmd = {"yaml-language-server"}
  -- },
})
require("lspconfig")["yamlls"].setup(cfg)
```

## 🚀 Usage

### Select a schema for the current buffer

No mappings included, you need to map it yourself or call it manually:

```
:Telescope yaml_schema
```

Alternatively, you can use `vim.ui.select` to use the picker of your choice. In that case, you can bind/call the function:
```lua
require("yaml-companion").open_ui_select()
```

### Get the schema name for the current buffer

You can show the current schema in your statusline using a function like:

```lua
function foo()
  local schema = require("yaml-companion").get_buf_schema(0)
  if schema then
    return schema.result[1].name
  end
  return ""
end
```
