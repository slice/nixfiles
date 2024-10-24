return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- completion sources
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-cmdline",

      -- cmp requires a snippet engine to function
      -- TODO: use built-in vim.snippet.
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
      "hrsh7th/vim-vsnip-integ",
    },
    keys = {
      {
        "<C-H>",
        "vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : ''",
        mode = { "i", "s" },
        remap = true,
        expr = true,
        replace_keycodes = false,
      },
      {
        "<C-L>",
        "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : ''",
        mode = { "i", "s" },
        remap = true,
        expr = true,
        replace_keycodes = false,
      },
    },
    config = function()
      local cmp = require "cmp"

      -- TODO: move these out, they need to be applied by default but not override
      -- colorschemes that actually define colors for these
      vim.cmd [[
        highlight! link CmpItemKindDefault SpecialKey
        highlight! link CmpItemAbbrMatch Function
        highlight! link CmpItemAbbrMatchFuzzy Function
      ]]

      cmp.setup {
        experimental = {
          ghost_text = { hl_group = "CmpGhostText" },
        },
        enabled = function()
          return not (vim.b.huge_bounced or vim.bo.buftype == "prompt")
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
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        performance = {
          throttle = 5,
          debounce = 5,
        },
        sources = cmp.config.sources(
        -- be aggressive with resolving math expression, because sometimes
        -- the lsp source takes precedence
          { name = "calc" },
          {
            { name = "nvim_lsp" },
            { name = "nvim_lsp_signature_help" },
            { name = "vsnip" },
          },
          {
            name = "lazydev",
            -- refers to the table above; takes precedence when this source is
            -- active
            group_index = 2,
          },
          {
            {
              name = "buffer",
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
          { { name = "path" } }
        ),
        mapping = {
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-->"] = cmp.mapping.scroll_docs(-4),
          ["<C-=>"] = cmp.mapping.scroll_docs(4),
          ["<Tab>"] = cmp.mapping.confirm { select = true },
        },
      }

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        }),
        matching = { disallow_symbol_nonprefix_matching = false }
      })
    end,
  },
}
