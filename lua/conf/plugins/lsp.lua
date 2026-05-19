return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "saghen/blink.cmp",
  },

  config = function()
    -- ============================================================
    -- LSP KEYBINDINGS (These fire when LSP attaches to a buffer)
    -- ============================================================
    vim.api.nvim_create_autocmd('LspAttach', {
      desc = 'LSP actions',
      callback = function(event)
        local opts = {buffer = event.buf}
        
        -- Navigation
        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', '<leader>k', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        
        -- Refactoring
        vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
        
        -- Diagnostics
        vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
        vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
      end,
    })

    -- ============================================================
    -- MASON: Your custom setup
    -- ✅ Already installed:
    --   - ruff (Python linter, FAST)
    --   - basedpyright (stricter than pyright, good for ML)
    --   - clang-format (C/C++ formatter)
    --   - clangd_codelldb (clangd + debugger integrated)
    --   - debugpy (Python debugger)
    --   - rust-analyzer (Rust LSP)
    --
    -- 💡 CONSIDER ADDING:
    --   - lua-language-server (for your Neovim config)
    --   - black (Python formatter, pairs well with ruff)
    -- ============================================================
    require("mason").setup({
      ensure_installed = {
        -- You already have:
        "clang-format",
        "ruff",
        "rust-analyzer",
        "debugpy",
        -- basedpyright via custom setup below
        -- clangd_codelldb via custom setup below
        
        -- Worth adding:
        "lua-language-server",  -- For your Neovim config files
        -- "black",              -- Optional: Python formatter (ruff can format too)
      },
    })

    -- ============================================================
    -- Get capabilities from Blink for all servers
    -- ============================================================
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- ============================================================
    -- MASON-LSPCONFIG: Auto-setup servers
    -- ============================================================
    require("mason-lspconfig").setup({
      handlers = {
        -- Default handler: Just set capabilities
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
          })
        end,
        
        -- ============================================================
        -- CLANGD: Your clangd_codelldb setup (C/C++)
        -- Optimized for embedded development
        -- ============================================================
        ["clangd"] = function()
		  local winlibs = "C:/Users/ah/AppData/Local/Microsoft/WinGet/Packages/BrechtSanders.WinLibs.POSIX.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe/mingw64/bin"
		  local avr = "C:/Users/ah/AVR/avr8-gnu-toolchain/bin"
		  local arm = "C:/Program Files (x86)/Arm GNU Toolchain arm-none-eabi/13.3 rel1/bin"
		  require("lspconfig").clangd.setup({
		    capabilities = capabilities,
		    cmd = {
			  "C:/EngineeringTools/LLVM/bin/clangd.exe",
			  "--background-index",
			  "--header-insertion=never",
			  "--query-driver="
			  .. winlibs .. "/*gcc*.exe,"
			  .. avr .. "/*gcc*.exe,"
			  .. arm .. "/*gcc*.exe",
		    },
			
			init_options = {
			  fallbackFlags = {
			    "-fgnuc-version=15", -- Forces Clang's parser to accept GCC 15 extensions
			  },
			},
		  })
        end,
        -- ============================================================
        -- RUST-ANALYZER: For FLUX Runtime
        -- ============================================================
        ["rust_analyzer"] = function()
          require("lspconfig").rust_analyzer.setup({
            capabilities = capabilities,
            cmd = { "rust-analyzer" },
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  allFeatures = true,
                  loadOutDirsFromCheck = true,
                  runBuildScripts = true,
                },
                procMacro = {
                  enable = true,
                },
                checkOnSave = {
                  command = "clippy",
                  extraArgs = { "--all-targets" },
                },
                inlayHints = {
                  enable = true,
                  chainingHints = true,
                  parameterHints = true,
                  typeHints = true,
                },
              }
            },
            on_attach = function(client, bufnr)
              -- Format with rustfmt on save
              vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.format()
                end
              })
            end,
          })
        end,
        
        -- ============================================================
        -- BASEDPYRIGHT: You chose this for good reason!
        -- It's MORE STRICT than pyright - better for catching bugs
        -- Perfect for ML code where precision matters
        -- ============================================================
        ["basedpyright"] = function()
          require("lspconfig").basedpyright.setup({
            capabilities = capabilities,
            settings = {
              basedpyright = {
                -- Analysis mode: stricter = catch more bugs
                analysis = {
                  typeCheckingMode = "strict",  -- Catch all type errors
                  diagnosticMode = "openFilesOnly", -- Only check open files (faster)
                  -- Add paths to your ML/FLUX modules
                  extraPaths = {
                    vim.fn.expand("~/FLUX/models"),
                    vim.fn.expand("~/FLUX/quantization"),
                    vim.fn.expand("~/FLUX/runtime"),
                  },
                },
                -- Ruff integration (you have ruff!)
                linting = {
                  enabled = true,
                  ruffEnabled = true,  -- Use YOUR ruff installation
                },
              }
            },
            on_attach = function(client, bufnr)
              -- Format on save - use ruff (fastest Python formatter)
              vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function()
                  -- Use ruff to format if available
                  -- vim.fn.executable() works cross-platform (Windows, Linux, Mac)
                  if vim.fn.executable("ruff") == 1 then
                    vim.cmd("!ruff format %")
                  end
                end
              })
            end,
          })
        end,
        
        -- ============================================================
        -- LUA: For your Neovim config
        -- ============================================================
        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                  checkThirdParty = false,
                },
                diagnostics = {
                  globals = { 'vim' },
                },
              }
            }
          })
        end,
      },
    })

    -- ============================================================
    -- DIAGNOSTIC SETTINGS
    -- ============================================================
    vim.diagnostic.config({
      underline = true,
      virtual_text = { prefix = '●' },
      float = {
        border = 'rounded',
        focusable = false,
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = ' ',
          [vim.diagnostic.severity.WARN] = ' ',
          [vim.diagnostic.severity.HINT] = ' ',
          [vim.diagnostic.severity.INFO] = ' ',
        }
      }
    })

  end
}