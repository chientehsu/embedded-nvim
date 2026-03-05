return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "saghen/blink.cmp", -- Link LSP to Blink
  },

  config = function()
    -- Keep your awesome keybindings!
    vim.api.nvim_create_autocmd('LspAttach', {
      desc = 'LSP actions',
      callback = function(event)
        local opts = {buffer = event.buf}
        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', '<leader>k', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
      end,
    })

	require("mason").setup({
      ensure_installed = {
        "clangd",
        "rust-analyzer",
        "pyright",
        "codelldb", -- Debugger for C/C++/Rust
        "debugpy",  -- Debugger for Python
        "clang-format",
        "ruff",
	  },
	})

    -- This tells LSP servers that Blink is handling the menu
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    require("mason-lspconfig").setup({
      handlers = {
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities -- Crucial for Blink!
          })
        end,
        
        -- Dedicated setup for C/C++
        ["clangd"] = function()
          require("lspconfig").clangd.setup({
            capabilities = capabilities,
            cmd = {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=never", -- Stops it from adding random #includes
            },
          })
        end,
      },
    })
  end
}