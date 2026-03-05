return {
  {
    'saghen/blink.cmp',
    version = '*',
    event = "VeryLazy",
    dependencies = 'rafamadriz/friendly-snippets',

    opts = {
      keymap = { preset = 'super-tab' },
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = 'mono'
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      -- SUPER HACKER ADDITION: Signature Help
      -- This shows you the arguments for functions (e.g. your_ml_model_invoke(ctx, input...))
      signature = { enabled = true },

      completion = {
        -- Show documentation window automatically while scrolling
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = {
          draw = {
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
          },
        },
      },
    },
  },
}