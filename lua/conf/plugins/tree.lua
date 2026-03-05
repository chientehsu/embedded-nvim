return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    -- 1. This function defines your "In-Tree" shortcuts
    local function my_on_attach(bufnr)
      local api = require("nvim-tree.api")

      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- Apply default mappings (Enter, Ctrl+], etc.)
      api.config.mappings.default_on_attach(bufnr)

      -- CUSTOM NAVIGATION (The stuff you were missing)
      vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))          -- L to Enter/Open
      vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close/Up")) -- H to Close/Back
      vim.keymap.set("n", "u", api.tree.change_root_to_parent, opts("Up a Dir")) -- U to go back to C:/Users/ah
    end

    -- 2. Pass that function into the setup
    require("nvim-tree").setup({
      on_attach = my_on_attach, -- THIS IS THE KEY
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      renderer = {
        indent_markers = {
          enable = true, -- Adds vertical lines so you don't get lost in folders
        },
      },
    })

    -- Ensure we start in the cockpit
    vim.cmd("cd C:/Users/ah/FLUX")
    
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<cr>")
  end,
}