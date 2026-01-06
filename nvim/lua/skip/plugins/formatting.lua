local utils = require 'skip.utils'

local prettier = { 'prettierd', 'prettier' }

return {
  {
    'stevearc/conform.nvim',
    event = 'VeryLazy',
    cond = not HEADLESS,
    enabled = true,
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'black' },
        typescript = prettier,
        terraform = { 'terraform_fmt' },
        typescriptreact = prettier,
        bzl = { 'buildifier' },
        javascript = prettier,
        javascriptreact = prettier,
        json = prettier,
        jsonc = prettier,
        html = prettier,
        css = prettier,
        markdown = { 'prettierd', 'prettier' },
        nix = { 'nixfmt' },
      },
      formatters = {
        prettierd = {
          -- don't look in `node_modules/` for deno, i just install it globally
          command = 'prettierd',
        },
      },
      default_format_opts = {
        lsp_format = 'fallback',
        timeout_ms = 500,
        stop_after_first = true,
      },
    },
    keys = {
      {
        '<Leader>lf',
        function()
          require('conform').format { timeout_ms = 2000 }
        end,
        desc = 'Conform',
      },
    },
    init = function()
      local lsp = require 'skip.lsp'

      vim.api.nvim_create_autocmd('BufWritePre', {
        desc = 'Automatic formatting on buffer write',
        group = lsp.formatting_augroup,
        callback = function(args)
          if not require 'skip.prefs'.format_on_save then
            return
          end

          if utils.is_flag_set(lsp.noformat_key, args.buf) then
            return
          end
          -- don't try to format fugitive buffers
          if vim.api.nvim_buf_get_name(args.buf):find 'fugitive://' == 1 then
            return
          end

          -- (don't lift this `require` or else it'll get eagerly loaded as
          -- `init` is _always_ called)
          local conform = require 'conform'

          if utils.is_flag_set('LSP_FORMATTING_ONLY', args.buf) then
            vim.lsp.buf.format { bufnr = args.buf }
            return -- conform.format { bufnr = args.buf, lsp_fallback = "always", formatters = {} }
          end

          conform.format {
            bufnr = args.buf,
          }
        end,
      })
    end,
  },
}
