return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",            -- The beautiful UI
      "nvim-neotest/nvim-nio",           -- Required dependency
      "williamboman/mason.nvim",         -- To ensure engines are there
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      -- Automatically open UI when debugging starts
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- C / C++ / Rust Setup (using codelldb)
      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
      }
      -- Reuse C++ config for C and Rust
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.rust = dap.configurations.cpp
    end,
  },
}