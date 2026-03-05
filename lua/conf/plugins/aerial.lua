return {
  "stevearc/aerial.nvim",
  dependencies = {
     "nvim-treesitter/nvim-treesitter",
     "nvim-tree/nvim-web-devicons"
  },
  config = function()
    require("aerial").setup({
      -- Prioritize Treesitter for C/Rust/Python, fallback to LSP
      backends = { "treesitter", "lsp" },
      layout = {
        max_width = { 40, 0.2 },
        default_direction = "right",
        placement = "window",
      },
      show_guides = true,
      -- Don't open aerial automatically
      open_automatic = false,
    })
  end
}