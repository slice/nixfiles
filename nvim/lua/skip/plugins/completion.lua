-- vim: set fdm=marker:

---@type LazySpec
return {
  {
    'saghen/blink.cmp',
    cond = not HEADLESS,
    -- i think blink is already lazy but loading its code is a little costly,
    -- so defer it anyways
    event = 'InsertEnter',
    dependencies = {
      'rafamadriz/friendly-snippets',
      -- 'folke/lazydev.nvim',
    },
    version = '1.*',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
        ['<Tab>'] = { 'select_and_accept', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up' },
        ['<C-f>'] = { 'scroll_documentation_down' },
        ['<C-k>'] = {}, -- i want digraphs
      },
      signature = { enabled = true },
      cmdline = {
        enabled = true,
        keymap = {
          preset = 'cmdline',
          ['<C-e>'] = {}, -- interferes with rsi
        },
      },
      sources = {
        default = {
          -- 'lazydev',
          'lsp',
          'path',
          'buffer',
          'snippets',
        },
        providers = {
          -- lazydev = {
          --   name = 'LazyDev',
          --   module = 'lazydev.integrations.blink',
          --   score_offset = 100,
          -- },
          lsp = {
            name = 'LSP',
            module = 'blink.cmp.sources.lsp',

            -- exclude language keywords/constants (if, else, while, etc.) from
            -- LSP completion results
            transform_items = function(_, items)
              return vim.tbl_filter(function(item)
                return item.kind
                  ~= require('blink.cmp.types').CompletionItemKind.Keyword
              end, items)
            end,
          },
        },
      },
      fuzzy = {
        sorts = { 'exact', 'score', 'sort_text' },
      },
      completion = {
        keyword = {
          -- always match against the full term regardless of cur pos
          range = 'full',
        },
        accept = {
          -- can be problematic in scala, e.g. adding () to methods who don't
          -- have an arg list
          auto_brackets = { enabled = false },
        },
        menu = {
          auto_show = true,
          draw = {
            columns = {
              { 'kind_icon', 'label', gap = 1 },
            },
          },
        },
        documentation = {
          auto_show = true,
        },
        ghost_text = { enabled = false },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        -- assume ghostty is being used, which can display nerd font icons
        -- nicely when there's a space after
        nerd_font_variant = 'normal',
        kind_icons = { -- {{{
          Text = ' ',
          Method = '\u{ea8c}',
          Function = '\u{ea8c}',
          Constructor = '\u{ea8c}',

          Field = '\u{eb5f}',
          Variable = '\u{ea88}',
          Property = '\u{f0ad}',

          Class = '\u{eb5b}',
          Interface = '\u{eb61}',
          Struct = '\u{ea91}',

          Module = '\u{f0169}',
          Unit = '󰪚',
          Value = '󰦨',
          Enum = '\u{ea95}',
          EnumMember = '\u{eb5e}',

          Keyword = '\u{eb62}',
          Constant = '\u{eb5d}',

          Snippet = '\u{eb66}',
          Color = '\u{eb5c}',
          File = '\u{eae9}',
          Reference = '\u{eb36}',
          Folder = '\u{ea83}',
          Event = '\u{ea86}',
          Operator = '\u{eb64}',
          TypeParameter = '\u{ea92}',
        }, -- }}}
      },
    },
  },
}
