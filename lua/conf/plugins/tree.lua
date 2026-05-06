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
    -- 
    -- These override default nvim-tree keybinds
    -- Uses vim-like h/j/k/l instead of arrow keys
    -- Much faster navigation once you learn them
    -- ============================================================
    local function my_on_attach(bufnr)
      local api = require("nvim-tree.api")

      -- Create options table for keybind descriptions
      local function opts(desc)
        return {
          desc = "nvim-tree: " .. desc,
          buffer = bufnr,
          noremap = true,
          silent = true,
          nowait = true
        }
      end

      -- ============================================================
      -- APPLY DEFAULT NVIM-TREE KEYBINDS
      -- Keep standard shortcuts like:
      --   a = Create new file
      --   d = Delete file
      --   r = Rename file
      --   c = Copy file
      -- ============================================================
      api.config.mappings.default_on_attach(bufnr)

      -- ============================================================
      -- CUSTOM NAVIGATION: VIM-LIKE MOVEMENT
      -- Replace arrow keys with home-row vim keys
      -- ============================================================
      
      -- "l" = Open file or expand folder
      -- Why "l" (right)? In vim, "l" moves right
      -- Expanding a folder is like "moving right" into it
      vim.keymap.set("n", "l", api.node.open.edit, opts("Open file or expand folder"))
      
      -- "h" = Close folder or go to parent
      -- Why "h" (left)? In vim, "h" moves left
      -- Going to parent is like "moving left" up the tree
      vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close folder or go to parent"))
      
      -- "u" = Move tree root up one directory
      -- Why "u"? Mnemonic for "up"
      -- Changes which directory the tree is showing
      vim.keymap.set("n", "u", api.tree.change_root_to_parent, opts("Move root up one directory"))
	  
	  -- "cd" = Change root to the folder under cursor
      -- Focuses the tree on this folder and updates your terminal CWD
	  vim.keymap.set("n", "cd", api.tree.change_root_to_node, opts("Change root to folder"))
    end

    -- ============================================================
    -- NVIM-TREE SETUP: File explorer configuration
    -- ============================================================
    require("nvim-tree").setup({
      on_attach = my_on_attach,  -- Apply custom keybindings above

      -- ============================================================
      -- SYNC WITH CURRENT WORKING DIRECTORY
      -- 
      -- When you cd (change directory) in terminal:
      --   ✅ File tree updates to show new directory
      --   ✅ Tree root moves to current working directory
      -- 
      -- Benefits:
      --   ✅ Tree always shows relevant files
      --   ✅ Never confused about which directory you're in
      --   ✅ Automatic sync (no manual refresh needed)
      -- ============================================================
      sync_root_with_cwd = true,
      respect_buf_cwd = true,

      -- ============================================================
      -- UPDATE FOCUSED FILE: Show current file in tree
      -- 
      -- When you jump to a file:
      --   ✅ Tree highlights that file
      --   ✅ Shows you "where you are" in project structure
      --   ✅ Very helpful for understanding code organization
      -- 
      -- update_root = true:
      --   If file is in different directory, tree scrolls/moves to show it
      -- ============================================================
      update_focused_file = {
        enable = true,
        update_root = true,  -- Also moves tree root if needed
      },

      -- ============================================================
      -- VISUAL: Indent markers show folder depth
      -- 
      -- Vertical lines connect parent/child folders
      -- Makes it easy to see nesting levels at a glance
      -- Especially useful for deeply nested directories
      -- ============================================================
      renderer = {
        indent_markers = {
          enable = true,  -- Show connecting lines
        },
      },
    })

    -- ============================================================
    -- DEFAULT DIRECTORY: Start in command_access project
    -- 
    -- Dynamic path that works on Windows and Linux
    -- Gets your home directory and appends command_access folder
    -- Works for anyone, not just hardcoded to one user
    -- ============================================================
    local home = os.getenv("USERPROFILE") or os.getenv("HOME")
    local command_access_dir = home .. "/software_projects/command_access"
    vim.cmd("cd " .. command_access_dir)

    -- ============================================================
    -- KEYBIND: Toggle file tree open/close
    -- 
    -- <leader>e = Space + e = Open/close file tree
    -- Appears on left side of editor
    -- Toggle again to close and maximize code view
    -- ============================================================
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<cr>", {
      desc = "Toggle file tree"
    })
  end,
}
