set rtp+=.
set rtp+=../plenary.nvim/
set rtp+=../nvim-lspconfig/
set rtp+=tests/dummy_matcher/

runtime! plugin/plenary.vim
runtime! plugin/nvim-lspconfig.vim

lua << EOF
require("yaml-companion").load_matcher("dummy")
vim.lsp.set_log_level("debug")
EOF
