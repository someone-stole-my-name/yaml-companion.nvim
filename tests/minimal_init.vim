set rtp+=.
set rtp+=../plenary.nvim/
set rtp+=../nvim-lspconfig/

runtime! plugin/plenary.vim
runtime! plugin/nvim-lspconfig.vim

lua << EOF
local yamlconfig = require("yaml-companion").setup()
require('lspconfig')['yamlls'].setup(yamlconfig)
EOF
