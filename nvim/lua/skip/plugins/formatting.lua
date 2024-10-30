local utils = require 'skip.utils'

return {
  {
    'stevearc/conform.nvim',
    enabled = true,
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        -- python = { "isort", "black" },
        typescript = { 'prettierd', 'prettier' },
        typescriptreact = { 'prettierd', 'prettier' },
        javascript = { 'prettierd', 'prettier' },
        javascriptreact = { 'prettierd', 'prettier' },
        fennel = { 'fnlfmt' },
        json = { 'biome' },
        css = { 'prettierd', 'prettier', 'biome' },
        markdown = { 'prettier' },
        nix = { 'nixfmt' },
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
      local conform = require 'conform'

      vim.api.nvim_create_autocmd('BufWritePre', {
        desc = 'Automatic formatting on buffer write',
        group = lsp.formatting_augroup,
        callback = function(args)
          if utils.flag_set(lsp.noformat_key) then
            return
          end
          -- don't try to format fugitive buffers
          if vim.api.nvim_buf_get_name(args.buf):find 'fugitive://' == 1 then
            return
          end

          if utils.flag_set 'LSP_FORMATTING_ONLY' then
            vim.lsp.buf.format { bufnr = args.buf }
            return
            -- return conform.format { bufnr = args.buf, lsp_fallback = "always", formatters = {} }
          end

          conform.format {
            bufnr = args.buf,
          }
        end,
      })

      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
