vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
  use("neovim/nvim-lspconfig")
  use("nvim-lua/plenary.nvim")
  use("wbthomason/packer.nvim")
  use_rocks({ "lyaml" })
end)
