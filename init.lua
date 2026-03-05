require "conf"
-- Fix Neovide starting in Program Files
if vim.g.neovide then
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            -- This moves you to your User folder (e.g., C:\Users\ah)
            vim.cmd("cd " .. vim.fn.expand("~"))
        end,
    })
end