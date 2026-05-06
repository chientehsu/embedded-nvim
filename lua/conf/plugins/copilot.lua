return {
  "github/copilot.vim",
  lazy = false,
  config = function()
    -- 1. Disable the Tab mapping so you can indent properly
    vim.g.copilot_no_tab_map = true
    
    -- 2. Map a different key to Accept (e.g., Ctrl + l)
    -- This keeps Tab free for your main.c indentation
    vim.keymap.set('i', '<C-l>', 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false
    })

    -- 3. Map a key to Dismiss/Hide the suggestion (e.g., Ctrl + ])
    -- Use this whenever the grey text is annoying you
    vim.keymap.set('i', '<C-]>', '<Plug>(copilot-dismiss)')

    -- 4. Filetype settings
    vim.g.copilot_filetypes = {
      ["*"] = true,
      ["markdown"] = false,
    }
  end,
}