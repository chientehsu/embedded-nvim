return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers", -- Shows your open files
        always_show_bufferline = true,
        separator_style = "slant", -- Gives it a cool "hacker" angled look
        show_buffer_close_icons = true,
        show_close_icon = false,
        
        -- This part makes it play nice with your File Tree
        offsets = {
          {
            filetype = "NvimTree",
            text = "FLUX CORE",
            text_align = "left",
            separator = true,
          },
        },
      },
    })
  end,
}