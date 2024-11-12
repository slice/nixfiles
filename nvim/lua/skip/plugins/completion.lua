-- vim: set fdm=marker:

---@type LazySpec
return {
  {
    'saghen/blink.cmp',
    lazy = false, -- plugin is already lazy
    dependencies = 'rafamadriz/friendly-snippets',
    version = 'v0.*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      fuzzy = {
        prebuilt_binaries = {
          download = false,
        },
      },
      keymap = {
        ['<Tab>'] = { 'select_and_accept', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up' },
        ['<C-f>'] = { 'scroll_documentation_down' },
      },
      highlight = {
        use_nvim_cmp_as_default = true,
      },
      trigger = {
        completion = { keyword_range = 'full' },
        signature_help = { enabled = true },
      },
      accept = { auto_brackets = { enabled = true } },
      windows = { autocomplete = { max_height = 25 } },
      nerd_font_variant = 'normal',
      sources = {
        providers = {
          lsp = {
            name = 'LSP',
            module = 'blink.cmp.sources.lsp',
            transform_items = function(_, items)
              ---@param item blink.cmp.CompletionItem
              return vim.tbl_filter(function(item)
                return item.kind ~= 14 -- keyword
              end, items)
            end,
          },
        },
      },
      kind_icons = {
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
      },
    },
    config = function(_, opts)
      local autocomplete = require('blink.cmp.windows.autocomplete')
      local original_open = autocomplete.open
      ---@diagnostic disable-next-line:duplicate-set-field
      function autocomplete.open()
        local value = original_open()
        if value == nil then
          return
        end
        -- value:set_option_values('winblend', 0)
        return value
      end

      local blink = require('blink.cmp')
      blink.setup(opts)
    end,
  },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    enabled = false,
    dependencies = {
      -- completion sources
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-calc',
      'hrsh7th/cmp-cmdline',

      -- cmp requires a snippet engine to function
      -- TODO: use built-in vim.snippet.
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip',
      'hrsh7th/vim-vsnip-integ',
    },
    keys = {
      {
        '<C-H>',
        "vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : ''",
        mode = { 'i', 's' },
        remap = true,
        expr = true,
        replace_keycodes = false,
      },
      {
        '<C-L>',
        "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : ''",
        mode = { 'i', 's' },
        remap = true,
        expr = true,
        replace_keycodes = false,
      },
    },
    config = function()
      local cmp = require 'cmp'

      -- TODO: move these out, they need to be applied by default but not override
      -- colorschemes that actually define colors for these
      vim.cmd [[
        highlight! link CmpItemKindDefault SpecialKey
        highlight! link CmpItemAbbrMatch Function
        highlight! link CmpItemAbbrMatchFuzzy Function
      ]]

      cmp.setup {
        experimental = {
          ghost_text = { hl_group = 'CmpGhostText' },
        },
        enabled = function()
          return not (vim.b.huge_bounced or vim.bo.buftype == 'prompt')
        end,
        -- formatting = {
        --   expandable_indicator = true,
        --   fields = { 'abbr' },
        --   format = function(entry, vim_item)
        --     local max = 40
        --     if vim_item.abbr:len() > max then
        --       vim_item.abbr = vim_item.abbr:sub(0, max) .. '…'
        --     end
        --     -- nuke these, these seem to still affect the window width
        --     vim_item.menu = ''
        --     vim_item.kind = ''
        --     return vim_item
        --   end,
        -- },
        snippet = {
          expand = function(args)
            vim.fn['vsnip#anonymous'](args.body)
          end,
        },
        sources = cmp.config.sources(
          -- be aggressive with resolving math expression, because sometimes
          -- the lsp source takes precedence
          { name = 'calc' },
          {
            { name = 'nvim_lsp' },
            { name = 'nvim_lsp_signature_help' },
            { name = 'vsnip' },
          },
          {
            name = 'lazydev',
            -- refers to the table above; takes precedence when this source is
            -- active
            group_index = 2,
          },
          {
            {
              name = 'buffer',
              option = {
                keyword_length = 2,
                get_bufnrs = function()
                  local bufs = {}
                  for _, win in ipairs(vim.api.nvim_list_wins()) do
                    bufs[vim.api.nvim_win_get_buf(win)] = true
                  end
                  return vim.tbl_keys(bufs)
                end,
              },
            },
          },
          { { name = 'path' } }
        ),
        mapping = {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-->'] = cmp.mapping.scroll_docs(-4),
          ['<C-=>'] = cmp.mapping.scroll_docs(4),
          ['<Tab>'] = cmp.mapping.confirm { select = true },
        },
      }

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
        }, {
          { name = 'cmdline' },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })
    end,
  },
}
