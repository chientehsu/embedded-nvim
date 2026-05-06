-- ============================================================
-- BASE SETTINGS & SHORTCUTS
-- ============================================================
-- 'noremap' means these keys won't trigger other mapped keys (prevents infinite loops)
-- 'silent' means Neovim won't print the command text at the bottom of the screen when used
local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

-- Create a shorter alias for the built-in Neovim keymap function to save typing
local keymap = vim.api.nvim_set_keymap

-- ============================================================
-- LEADER CONFIGURATION
-- ============================================================
-- Unbind the spacebar from its default behavior (moving the cursor right)
keymap("", "<Space>", "<Nop>", opts)
-- Set the Spacebar as your main "Leader" key for custom shortcuts
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================
-- 1. WINDOW NAVIGATION (Centered & Smooth)
-- ============================================================
-- Use Ctrl + h/j/k/l to jump between split windows
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)
-- Use Ctrl + d/u to jump down/up half a page, and 'zz' immediately centers the screen
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

-- ============================================================
-- QUICK ESCAPE BINDINGS
-- ============================================================
-- Exit Insert mode by quickly rolling jk or kj
vim.keymap.set("i", "jk", "<ESC>", { noremap = true, silent = true, desc = "Quick Escape (jk)" })
vim.keymap.set("i", "kj", "<ESC>", { noremap = true, silent = true, desc = "Quick Escape (kj)" })

-- Exit Visual mode by pressing v again
vim.keymap.set("v", "v", "<ESC>", { noremap = true, silent = true, desc = "Exit Visual Mode" })

-- ============================================================
-- 2. BUFFER MANAGEMENT (Open Files)
-- ============================================================
-- Shift + L/H to cycle through your open tabs/buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
-- Space + x to close the current tab. Shift + X to force close it without saving
keymap("n", "<leader>x", ":bd<CR>", opts)
keymap("n", "<leader>X", ":bd!<CR>", opts)

-- ============================================================
-- 3. TERMINAL & HARDWARE
-- ============================================================
-- Space + t opens a standard terminal in a horizontal split
keymap("n", "<leader>t", ":split | terminal<CR>", { desc = "Open Terminal" })
-- Ctrl + \ triggers the ToggleTerm plugin (floating terminal)
keymap("n", "<C-\\>", ":ToggleTerm<CR>", { desc = "Toggle Terminal" })

-- ============================================================
-- 4. SEARCH & HIGHLIGHTS
-- ============================================================
-- Hitting Escape clears the yellow highlights after you search for a word
keymap("n", "<ESC>", ":noh<CR>", opts)

-- ============================================================
-- 5. VISUAL MODE (Highlighting text)
-- ============================================================
-- Alt + j/k lets you physically move highlighted blocks of code up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
-- When pasting over text, this prevents the deleted text from overwriting your clipboard
keymap("v", "p", '"_dP', opts)
-- Keeps text highlighted after moving it up or down in Visual Block mode
keymap("x", "<A-j>", ":move '>+1<CR>gv=gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv=gv", opts)

-- ============================================================
-- 6. TERMINAL MODE
-- ============================================================
-- When inside a terminal, standard Vim navigation doesn't work.
-- These let you use Ctrl + h/j/k/l to escape the terminal window to a code window
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)
-- Escape leaves Terminal Insert mode and goes to Terminal Normal mode
keymap("t", "<Esc>", "<C-\\><C-n>", term_opts)

-- ============================================================
-- 7. DEBUGGER (DAP)
-- ============================================================
-- Standard Visual Studio style debugger keys (F5, F10, F11)
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'Debug: Continue' })
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end, { desc = 'Toggle Breakpoint' })
vim.keymap.set('n', '<leader>B', function()
  require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'Conditional Breakpoint' })
vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { desc = 'Toggle Debug UI' })

-- ============================================================
-- 8. CODE OUTLINE (Aerial)
-- ============================================================
-- Space + a toggles a sidebar showing all functions/variables in the current file
keymap("n", "<leader>a", ":AerialToggle!<CR>", { desc = "Toggle Code Outline" })

-- ============================================================
-- 9. CODE FORMATTING
-- ============================================================
vim.keymap.set('n', '<leader>l', function()
  local file_type = vim.bo.filetype -- Check what language we are currently using
  
  -- If C/C++, Rust, or standard LSP, trigger the language server's auto-formatter
  if file_type == 'c' or file_type == 'cpp' or file_type == 'h' or file_type == 'hpp' then
    vim.lsp.buf.format()
  elseif file_type == 'rust' then
    vim.lsp.buf.format()
  elseif file_type == 'python' then
    -- If Python, use Ruff from the command line (it is much faster)
    vim.cmd('!ruff format %')
    vim.cmd('edit!')  -- Reload the file so Neovim sees the newly formatted code
  else
    vim.lsp.buf.format()
  end
end, { desc = "Format Code" })

-- ============================================================
-- 10. HEADER ↔ SOURCE TOGGLE
-- ============================================================
local function toggle_header_source()
  local file = vim.fn.expand("%:p") -- Get full path of current file
  local root = vim.fn.expand("%:r") -- Get path WITHOUT the extension
  
  -- If we are in a .h or .hpp file, look for a matching .c or .cpp file
  if file:match("%.h$") or file:match("%.hpp$") then
    for _, ext in ipairs({".cpp", ".c", ".cc", ".cxx"}) do
      local source = root .. ext
      if vim.fn.filereadable(source) == 1 then -- If the file exists...
        vim.cmd("edit " .. source)             -- ...open it!
        return
      end
    end
    print("Source file not found")
  else
    -- If we are in a .c or .cpp file, look for a matching .h or .hpp file
    for _, ext in ipairs({".h", ".hpp", ".hxx"}) do
      local header = root .. ext
      if vim.fn.filereadable(header) == 1 then
        vim.cmd("edit " .. header)
        return
      end
    end
    print("Header file not found")
  end
end
vim.keymap.set('n', '<leader>o', toggle_header_source, { desc = "Toggle Header/Source" })

-- ============================================================
-- 11. QUICK PYTHON EXECUTION
-- ============================================================
-- Space + py instantly runs the current python script in a split terminal
vim.keymap.set('n', '<leader>py', function()
  local file = vim.fn.expand("%:p")
  vim.cmd("split | terminal python " .. file)
end, { desc = "Run Python Script" })

-- ============================================================
-- 12. ULTIMATE SMART BUILD SYSTEM (<leader>m)
-- ============================================================
local function smart_build()
    vim.cmd("wa") -- Automatically save all open files before building
    
    -- Gather information about the current file you are looking at
    local file_path = vim.fn.expand('%:p')
    local file_dir = vim.fn.expand('%:p:h')
    local file_name = vim.fn.expand('%:t:r')
    local file_ext = vim.fn.expand("%:e")
    local file_full = vim.fn.expand("%:t")

    -- Scan the folder (and parent folders) to see what kind of project this is
    local cargo_path = vim.fn.findfile("Cargo.toml", ".;")
    local cmake_path = vim.fn.findfile("CMakeLists.txt", ".;")
    local makefile_path = vim.fn.findfile("Makefile", ".;")

    -- 1. DETECT RUST (If Cargo.toml exists)
    if cargo_path ~= "" then
        local root = vim.fn.fnamemodify(cargo_path, ":p:h")
        print("🦀 Building Rust project...")
        require("toggleterm").exec("cd '" .. root .. "' ; cargo build")
        
    -- 2. DETECT CMAKE (If CMakeLists.txt exists)
    elseif cmake_path ~= "" then
        local root = vim.fn.fnamemodify(cmake_path, ":p:h")
        print("🔨 Building with CMake...")
        require("toggleterm").exec("cd '" .. root .. "' ; if (!(Test-Path build)) { mkdir build } ; cd build ; cmake .. ; make -j8")
        
    -- 3. DETECT STM32 & MAKEFILES (If Makefile exists)
    elseif makefile_path ~= "" then
        local root = vim.fn.fnamemodify(makefile_path, ":p:h")
        local ioc_files = vim.fn.glob(root .. "/*.ioc")
        
        -- If an .ioc file exists, it's definitely an STM32 CubeMX project
        if ioc_files ~= "" then
            local options = {
                "🐛 Debug (Standard CubeMX)",
                "🚀 Release (Optimize for Speed: -O3)",
                "📦 Release (Optimize for Size: -Os)"
            }
            
            -- Ask user for build profile
            vim.ui.select(options, { prompt = '🛠️ Select STM32 Build Profile:' }, function(choice, idx)
                if not choice then return end 
                
                -- Set the correct Makefile flags based on their choice
                local make_flags = ""
                if idx == 2 then make_flags = "DEBUG=0 OPT=-O3 "
                elseif idx == 3 then make_flags = "DEBUG=0 OPT=-Os "
                end
                
                -- Look at global memory to see if we have a saved revision name
                local default_prompt = _G.last_stm32_rev and (" (default: " .. _G.last_stm32_rev .. "): ") or " (or press Enter for standard): "
                
                vim.ui.input({ prompt = 'Enter Revision Name' .. default_prompt }, function(rev_name)
                    -- If they typed a new name, save it to global memory
                    if rev_name and rev_name ~= "" then
                        _G.last_stm32_rev = rev_name
                    end
                    
                    -- If they hit Enter (blank), load the name from global memory
                    local target_name = rev_name
                    if not target_name or target_name == "" then
                        target_name = _G.last_stm32_rev
                    end

                    -- Execute standard or custom targeted build
                    if not target_name or target_name == "" then 
                        print("🔨 Updating standard STM32 build...")
                        require("toggleterm").exec("cd '" .. root .. "' ; make clean ; make " .. make_flags .. "-j8")
                    else
                        local cmd = string.format(
                            "cd '%s' ; make clean ; make %s TARGET=%s -j8 ; arm-none-eabi-objdump -S build/%s.elf > build/%s.s",
                            root, make_flags, target_name, target_name, target_name
                        )
                        print("🚀 Compiling STM32 Revision: " .. target_name)
                        require("toggleterm").exec(cmd)
                    end
                end)
            end)
        else
            -- If no .ioc file, it's just a regular C project with a Makefile
            print("🔨 Building with generic Makefile...")
            require("toggleterm").exec("cd '" .. root .. "' ; make -j8")
        end

    -- 4. SINGLE FILE FALLBACKS (If no build system files are found)
    else
        if file_ext == "c" then
            local is_avr = false
            -- Read the first 20 lines of the file to see if AVR headers are included
            local lines = vim.fn.readfile(file_path, '', 20)
            for _, line in ipairs(lines) do
                if line:match("avr/") then
                    is_avr = true
                    break
                end
            end

            if is_avr then
                -- Look at global memory to see if we have a saved AVR revision name
                local default_prompt = _G.last_avr_rev and (" (default: " .. _G.last_avr_rev .. "): ") or " (or press Enter for standard): "
                
                vim.ui.input({ prompt = 'Enter AVR Build Name' .. default_prompt }, function(rev_name)
                    if rev_name and rev_name ~= "" then
                        _G.last_avr_rev = rev_name
                    end
                    
                    local target_name = rev_name
                    if not target_name or target_name == "" then
                        target_name = _G.last_avr_rev
                    end
            
                    if not target_name or target_name == "" then
                        target_name = file_name
                    end
            
                    print("🔨 Compiling AVR Code -> " .. target_name .. ".hex ...")
                    local full_cmd = string.format(
                        "cd '%s' ; avr-gcc -Wall -Os -mmcu=attiny85 -o %s.elf %s ; avr-objcopy -j .text -j .data -O ihex %s.elf %s.hex",
                        file_dir, target_name, file_path, target_name, target_name
                    )
                    require("toggleterm").exec(full_cmd)
                end)
            else
                print("⚙️  Compiling standard C file for PC...")
                require("toggleterm").exec(string.format("cd '%s' ; gcc -O2 %s -o %s && .\\%s", file_dir, file_full, file_name, file_name))
            end

        elseif file_ext == "cpp" or file_ext == "cc" then
            print("⚙️  Compiling C++ file...")
            require("toggleterm").exec(string.format("cd '%s' ; g++ -O2 %s -o %s && .\\%s", file_dir, file_full, file_name, file_name))
        elseif file_ext == "py" then
            print("🐍 Running Python...")
            require("toggleterm").exec(string.format("cd '%s' ; python %s", file_dir, file_full))
        elseif file_ext == "rs" then
            print("🦀 Running Rust file...")
            require("toggleterm").exec(string.format("cd '%s' ; rustc %s && .\\%s", file_dir, file_full, file_name))
        else
            print("❌ No build system or recognized filetype found.")
        end
    end
end
vim.keymap.set('n', '<leader>m', smart_build, { desc = "Smart Build / Flash / Run" })

-- ============================================================
-- 12.1 STM32 DEDICATED REVISION BUILD (<leader>sr)
-- ============================================================
-- NOTE: I have fixed this section to correctly use the memory logic!
local function stm32_revision_build()
    local options = {
        "🐛 Debug (Standard CubeMX)",
        "🚀 Release (Optimize for Speed: -O3)",
        "📦 Release (Optimize for Size: -Os)"
    }
    
    vim.ui.select(options, { prompt = '🛠️ Select STM32 Build Profile:' }, function(choice, idx)
        if not choice then return end
        
        local make_flags = ""
        if idx == 2 then make_flags = "DEBUG=0 OPT=-O3 "
        elseif idx == 3 then make_flags = "DEBUG=0 OPT=-Os "
        end

        local default_prompt = _G.last_stm32_rev and (" (default: " .. _G.last_stm32_rev .. "): ") or " (or press Enter for standard): "
        
        vim.ui.input({ prompt = 'Enter Revision Name' .. default_prompt }, function(rev_name)
            if rev_name and rev_name ~= "" then
                _G.last_stm32_rev = rev_name
            end
            
            local target_name = rev_name
            if not target_name or target_name == "" then
                target_name = _G.last_stm32_rev
            end

            if not target_name or target_name == "" then
                print("🔨 Updating standard STM32 build...")
                require("toggleterm").exec("make clean ; make " .. make_flags .. "-j8")
            else
                local cmd = string.format(
                    "make clean ; make %s TARGET=%s -j8 ; arm-none-eabi-objdump -S build/%s.elf > build/%s.s",
                    make_flags, target_name, target_name, target_name
                )
                print("🚀 Compiling STM32 Revision: " .. target_name)
                require("toggleterm").exec(cmd)
            end
        end)
    end)
end
vim.keymap.set('n', '<leader>sr', stm32_revision_build, { desc = "Build Custom STM32 Revision" })

-- ============================================================
-- 12.2 DEDICATED AVR BUILD BACKUP (<leader>af)
-- ============================================================
vim.keymap.set('n', '<leader>af', function()
    local file_path = vim.fn.expand('%:p')
    local file_dir = vim.fn.expand('%:p:h')
    local file_name = vim.fn.expand('%:t:r') -- Defaults to 'main' or whatever the file is called

    -- Look at global memory to see if we have a saved AVR revision name
    local default_prompt = _G.last_avr_rev and (" (default: " .. _G.last_avr_rev .. "): ") or " (or press Enter for standard): "

    -- Prompt the user
    vim.ui.input({ prompt = 'Enter AVR Build Name' .. default_prompt }, function(rev_name)
        -- If they typed a new name, save it to global memory
        if rev_name and rev_name ~= "" then
            _G.last_avr_rev = rev_name
        end
        
        -- If they hit Enter (blank), try to load the name from global memory
        local target_name = rev_name
        if not target_name or target_name == "" then
            target_name = _G.last_avr_rev
        end

        -- If it's STILL blank (first time running it), fall back to the actual file name
        if not target_name or target_name == "" then
            target_name = file_name
        end

        print("🔨 Compiling AVR Code -> " .. target_name .. ".hex ...")

        -- Compiles the code using the new custom target_name for the output files
        local full_cmd = string.format(
            "cd '%s' ; avr-gcc -Wall -Os -mmcu=attiny85 -o %s.elf %s ; avr-objcopy -j .text -j .data -O ihex %s.elf %s.hex",
            file_dir, target_name, file_path, target_name, target_name
        )
        require("toggleterm").exec(full_cmd)
    end)
end, { desc = "Build AVR" })

-- ============================================================
-- 13. COMPILE WITH OPTIMIZATION FLAGS
-- ============================================================
local function compile_for_target(target)
  local file = vim.fn.expand("%")
  local output = vim.fn.expand("%:r")
  local flags = ""
  
  -- Pass different instruction set flags depending on target architecture
  if target == "arm" then
    flags = "-march=armv7-a -O3"
  elseif target == "riscv" then
    flags = "-march=rv64imac -O3"
  elseif target == "x86" then
    flags = "-march=native -O3"
  else
    flags = "-O2"
  end
  
  print("Compiling for " .. target .. "...")
  vim.cmd(string.format("split | terminal gcc %s %s -o %s", flags, file, output))
end

-- Space + ca compiles a raw C file for ARM, Space + cr for RISC-V
vim.keymap.set('n', '<leader>ca', function() compile_for_target("arm") end, { desc = "Compile for ARM" })
vim.keymap.set('n', '<leader>cr', function() compile_for_target("riscv") end, { desc = "Compile for RISC-V" })

-- ============================================================
-- 14. SERIAL MONITOR
-- ============================================================
-- Space + gs prompts for a COM/ttyUSB port and opens GNU Screen to read UART serial data
vim.keymap.set('n', '<leader>gs', function()
  local port = vim.fn.input("Serial port (default /dev/ttyUSB0): ") or "/dev/ttyUSB0"
  local baud = vim.fn.input("Baud rate (default 115200): ") or "115200"
  vim.cmd("split | terminal screen " .. port .. " " .. baud)
  print("Serial monitor opened. Press Ctrl+A then D to exit.")
end, { desc = "Open Serial Monitor" })

-- ============================================================
-- 15. DOCUMENTATION LOOKUP
-- ============================================================
-- Space + q looks up the current word under your cursor in the Linux man pages
vim.keymap.set('n', '<leader>q', function()
  local word = vim.fn.expand("<cword>")
  vim.cmd("split | terminal man " .. word)
end, { desc = "Quick Documentation" })

-- ============================================================
-- 16. TOGGLE COMMENTS
-- ============================================================
-- Maps Space + cc to standard Vim comment toggles (requires a comment plugin like Comment.nvim)
vim.keymap.set('n', '<leader>cc', 'gcc', {})
vim.keymap.set('v', '<leader>cc', 'gc', {})

-- ============================================================
-- 17. GIT COMMANDS
-- ============================================================
-- Quick shell commands for standard Git operations
vim.keymap.set('n', '<leader>gp', ':!git push<CR>', { desc = "Git Push" })
vim.keymap.set('n', '<leader>gl', ':!git pull<CR>', { desc = "Git Pull" })
vim.keymap.set('n', '<leader>gst', ':!git status<CR>', { desc = "Git Status" })

-- ============================================================
-- 18. RUN TESTS
-- ============================================================
-- Checks if test files exist, then runs them automatically
vim.keymap.set('n', '<leader>rt', function()
  if vim.fn.filereadable("run_tests.sh") == 1 then
    vim.cmd("split | terminal bash run_tests.sh")
  elseif vim.fn.filereadable("pytest.ini") == 1 then
    vim.cmd("split | terminal pytest -v")
  else
    print("No test runner found")
  end
end, { desc = "Run Tests" })

-- ============================================================
-- 19. QEMU EMULATION
-- ============================================================
-- Allows you to run ARM firmware inside a software emulator instead of hardware
vim.keymap.set('n', '<leader>qm', function()
  local binary = vim.fn.input("Firmware binary: ")
  vim.cmd("split | terminal qemu-system-arm -M virt -cpu cortex-a72 -m 256 -kernel " .. binary)
end, { desc = "QEMU Emulator" })

-- ============================================================
-- 20. QUICKFIX WINDOW NAVIGATION
-- ============================================================
-- Allows you to quickly jump between compiler errors generated by Make
vim.keymap.set('n', '<leader>cn', ':cnext<CR>', { desc = "Next Error" })
vim.keymap.set('n', '<leader>cp', ':cprev<CR>', { desc = "Previous Error" })
vim.keymap.set('n', '<leader>co', ':copen<CR>', { desc = "Open Error List" })

-- ============================================================
-- 21. RUFF LINTING
-- ============================================================
-- Space + rf checks Python files for errors using Ruff
vim.keymap.set('n', '<leader>rf', function()
  vim.cmd("!ruff check %")
end, { desc = "Ruff Lint" })

-- ============================================================
-- 22. RUFF FORMATTING
-- ============================================================
-- Space + rF instantly reformats Python code using Ruff
vim.keymap.set('n', '<leader>rF', function()
  vim.cmd("!ruff format %")
  vim.cmd("edit!")
end, { desc = "Ruff Format" })

-- ============================================================
-- 23. GITHUB COPILOT CHAT
-- ============================================================
-- Space + ch toggles the Copilot chat window open and closed (Works in Normal and Visual mode)
vim.keymap.set({"n", "v"}, "<leader>ch", ":CopilotChatToggle<CR>", { desc = "Copilot: Toggle Chat" })

-- Space + ce asks Copilot to EXPLAIN the code you have highlighted
vim.keymap.set("v", "<leader>ce", ":CopilotChatExplain<CR>", { desc = "Copilot: Explain Code" })

-- Space + cf asks Copilot to FIX bugs in the code you have highlighted
vim.keymap.set("v", "<leader>cf", ":CopilotChatFix<CR>", { desc = "Copilot: Fix Bugs" })

-- Space + cr asks Copilot to OPTIMIZE/REFACTOR the code you have highlighted
vim.keymap.set("v", "<leader>cR", ":CopilotChatOptimize<CR>", { desc = "Copilot: Optimize Code" })