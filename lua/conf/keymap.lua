local opts = { noremap = true, silent = true }
local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap

-- Leader Configuration
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 1. Navigation (Centered & Smooth)
keymap("n", "<C-h>", "<C-w>h", opts) -- Move Left
keymap("n", "<C-j>", "<C-w>j", opts) -- Move Down
keymap("n", "<C-k>", "<C-w>k", opts) -- Move Up
keymap("n", "<C-l>", "<C-w>l", opts) -- Move Right
keymap("n", "<C-d>", "<C-d>zz", opts) -- Page Down (Centered)
keymap("n", "<C-u>", "<C-u>zz", opts) -- Page Up (Centered)

-- 2. Buffer Management (Tab-like switching)
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<leader>x", ":bd<CR>", { desc = "Close Buffer" })

-- 3. The "Hacker" Essentials (Embedded & AI)
-- Quick Terminal for Flashing/Serial Monitor
keymap("n", "<leader>t", ":split | terminal<CR>", { desc = "Open Hardware Terminal" })
-- Clear search highlights with ESC
keymap("n", "<ESC>", ":noh<CR>", opts)

-- 4. Visual Mode (Keep selections and move blocks)
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts) -- Paste without losing original buffer
keymap("x", "<A-j>", ":move '>+1<CR>gv=gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv=gv", opts)

-- 5. Terminal Mode (Natural navigation)
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)
keymap("t", "<Esc>", "<C-\\><C-n>", term_opts) -- Use Esc to enter Normal mode in Terminal

-- 6. Debugger (DAP)
-- We wrap these in functions so they don't load until you press the key
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end, { desc = 'Toggle Breakpoint' })
vim.keymap.set('n', '<leader>B', function()
  require('dap').set_breakpoint(vim.fn.input('Condition: '))
end, { desc = 'Conditional Breakpoint' })
vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { desc = 'Toggle Debug UI' })

-- 7. Radar (Aerial)
keymap("n", "<leader>a", ":AerialToggle!<CR>", { desc = "Toggle Code Map" })

-- 8. Smart Build & Run (The AI Engineer's Power-up)
local function smart_build()
  -- Save all files before compiling
  vim.cmd("wa") 
  
  -- Check if a Makefile exists in the current directory
  if vim.fn.filereadable("Makefile") == 1 then
    print("Building with Makefile...")
    vim.cmd("split | term make")
  elseif vim.fn.filereadable("CMakeLists.txt") == 1 then
    print("Building with CMake...")
    vim.cmd("split | term cmake --build build")
  else
    -- Fallback: Just compile the single C/C++ file you are looking at
    local file = vim.fn.expand("%")
    local output = vim.fn.expand("%:r") .. ".exe"
    print("Compiling single file: " .. file)
    vim.cmd(string.format("split | term gcc %s -o %s && .\\%s", file, output, output))
  end
end

vim.keymap.set('n', '<leader>m', smart_build, { desc = 'Smart Build/Make' })



