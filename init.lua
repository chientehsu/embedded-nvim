require "conf"
if vim.g.neovide then
    vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			-- 1. Find your Home folder dynamically
            local home = vim.fn.expand("~")
            -- 2. Define your Startup Project Path
            local project_folder = home .. "\\FLUX"
            -- 3. Move the whole editor to the project
            vim.cmd("cd " .. project_folder)
        end,
    })
end