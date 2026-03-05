return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    -- Get your Home folder dynamically
    local home = os.getenv("USERPROFILE") or os.getenv("HOME")
    local project_dir = home .. "\\FLUX"


    require("toggleterm").setup({
      size = function(term)
        if term.direction == "vertical" then
          return vim.o.columns * 0.5
        end
      end,
      open_mapping = [[<c-\>]], -- This makes Ctrl + \ the toggle key
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      direction = "vertical", -- This creates the "split" at the bottom
      close_on_exit = true,
      shell = "powershell.exe",   -- Ensures it uses Windows PowerShell


      dir = project_dir,
    })
  end,
}
