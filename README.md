# yaml-companion.nvim [![Build](https://github.com/someone-stole-my-name/yaml-companion.nvim/actions/workflows/main.yml/badge.svg)](https://github.com/someone-stole-my-name/yaml-companion.nvim/actions/workflows/main.yml)

## ⚡️ Requirements

- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [yaml-language-server](https://github.com/redhat-developer/yaml-language-server)

## ✨ Features

- Select specific JSON schema per buffer
- Display the in-use schema
- Kubernetes + Schema Store support (No CRDs yet)

## 📦 Installation

Install the plugin and load the `telescope` extension with your preferred package manager:

**Packer**

```lua
use {
  "someone-stole-my-name/yaml-companion.nvim",
  requires = {
    { "nvim-lua/plenary.nvim"},
    { "nvim-telescope/telescope.nvim" },
  },
  config = function()
    require("telescope").load_extension("yaml_schema")
  end,
}
```

## 🚀 Usage

```lua
local cfg = require("yaml-companion").setup()
require("lspconfig")["yamlls"].setup(cfg)
```
