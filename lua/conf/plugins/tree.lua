return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,  -- Load immediately on startup (file tree should be ready)
  dependencies = {
    "nvim-tree/nvim-web-devicons",  -- Icons for different file types
  },
  config = function()
    -- ============================================================
    -- CUSTOM KEYBINDINGS FOR FILE TREE
    -- ============================================================
    local function my_on_attach(bufnr)
      local api = require("nvim-tree.api")

      local function opts(desc)
        return {
          desc = "nvim-tree: " .. desc,
          buffer = bufnr,
          noremap = true,
          silent = true,
          nowait = true
        }
      end

      api.config.mappings.default_on_attach(bufnr)
      
      vim.keymap.set("n", "l", api.node.open.edit, opts("Open file or expand folder"))
      vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close folder or go to parent"))
      vim.keymap.set("n", "u", api.tree.change_root_to_parent, opts("Move root up one directory"))
      vim.keymap.set("n", "cd", api.tree.change_root_to_node, opts("Change root to folder"))
    end

    -- ============================================================
    -- NVIM-TREE SETUP: File explorer configuration
    -- ============================================================
    require("nvim-tree").setup({
      on_attach = my_on_attach,

      view = {
        width = 30,
        side = "left",
      },

      sync_root_with_cwd = true,
      respect_buf_cwd = true,

      update_focused_file = {
        enable = true,
        update_root = false,  -- Prevents layout snapping on window close
      },

      actions = {
        open_file = {
          quit_on_open = false,
          window_picker = {
            enable = true,
          },
        },
      },

      renderer = {
        indent_markers = {
          enable = true,
        },
      },
    })

    -- ============================================================
    -- DEFAULT DIRECTORY: Start in command_access project
    -- ============================================================
    local home = os.getenv("USERPROFILE") or os.getenv("HOME")
    local command_access_dir = home .. "/software_projects/command_access"
    vim.cmd("cd " .. command_access_dir)

    -- ============================================================
    -- KEYBIND: Toggle file tree open/close
    -- ============================================================
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<cr>", {
      desc = "Toggle file tree"
    })

    -- ============================================================
    -- NATIVE LUA BUFFER DELETE (NO PLUGINS REQUIRED)
    -- Swaps to the previous buffer safely before wiping the current one
    -- ============================================================
    _G.safe_buf_delete = function(force)
      local current_buf = vim.api.nvim_get_current_buf()
      
      -- Check if file has unsaved changes
      if not force and vim.bo[current_buf].modified then
        local choice = vim.fn.confirm(("Save changes to %s?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
        if choice == 1 then
          vim.cmd("w")
        elseif choice ~= 2 then
          return -- Cancelled
        end
      end

      -- Native fallback: Go to previous buffer layout position first
      vim.cmd("bprevious")
      
      -- If it didn't switch (only 1 buffer opened), open an empty scratch buffer
      if vim.api.nvim_get_current_buf() == current_buf then
        vim.cmd("enew")
      end

      -- Finally, wipe out the old buffer cleanly out of memory
      vim.api.nvim_buf_delete(current_buf, { force = true })
    end

    -- ============================================================
    -- INTERCEPT MUSCLE MEMORY ':bd' AND ':bd!' UNSETS
    -- Redirects directly to our global native lua engine function
    -- ============================================================
    vim.cmd([[
      cnoreabbrev <expr> bd ((getcmdtype() == ':' && getcmdline() == 'bd') ? 'lua _G.safe_buf_delete(false)' : 'bd')
      cnoreabbrev <expr> bd! ((getcmdtype() == ':' && getcmdline() == 'bd!') ? 'lua _G.safe_buf_delete(true)' : 'bd!')
    ]])

    -- ============================================================
    -- EMERGENCY GUARD: Close Neovim if NvimTree is the only window left
    -- ============================================================
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("NvimTreeClosePrevention", { clear = true }),
      callback = function()
        local layout = vim.fn.winlayout()
        if layout[1] == "leaf" and vim.bo[vim.api.nvim_win_get_buf(layout[2])].filetype == "NvimTree" and #vim.api.nvim_list_wins() == 1 then
          vim.cmd("quit")
        end
      end,
    })
  end,
}