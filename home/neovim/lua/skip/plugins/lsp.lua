local patched_lspconfig = false

local original_jump = vim.lsp.util.jump_to_location

function vim.lsp.util.jump_to_location(...)
  -- cheeky
  vim.opt.hidden = true
  original_jump(...)
  vim.opt.hidden = false
end

return {
  -- proper lua editing support for neovim

  {
    "neovim/nvim-lspconfig",
    dependencies = { "folke/neodev.nvim" },
    config = function()
      local lsp = require "skip.lsp"
      local lsc = require "lspconfig"

      if patched_lspconfig then
        return
      end
      patched_lspconfig = true

      local original_bufname_valid = lsc.util.bufname_valid
      -- some day, this'll break ... :O]
      function lsc.util.bufname_valid(bufname)
        if not lsp.attach_allowed(bufname) then
          return false
        end
        return original_bufname_valid(bufname)
      end

      -- TODO: this doesn't belong here
      vim.diagnostic.config {
        -- make warnings and errors appear over hints
        severity_sort = true,
        float = {
          header = "",
        },
      }

      lsc.util.default_config = vim.tbl_extend("force", lsc.util.default_config, {
        capabilities = lsp.capabilities,
      })

      lsc.astro.setup {}

      lsc.sourcekit.setup {}

      lsc.lua_ls.setup {
        -- for some reason, neodev doesn't properly hook itself into lspconfig
        -- _if we're using split plugin specs with lazy.nvim_, so do it manually
        -- here. neodev's override functionality still kicks in, too
        on_new_config = function(config, root_dir)
          require("neodev.lsp").on_new_config(config, root_dir)
        end,
      }

      lsc.pyright.setup {}

      lsc.hls.setup {
        filetypes = { "haskell", "lhaskell", "cabal" },
      }

      lsc.rust_analyzer.setup {
        capabilities = lsp.capabilities,
        settings = {
          ["rust-analyzer"] = {
            imports = {
              granularity = {
                group = "module",
              },
              prefix = "crate",
            },
            procMacro = {
              enable = true,
            },
          },
        },
      }
    end,
  },

  {
    "folke/neodev.nvim",
    opts = {
      override = function(root_dir, library)
        -- TODO: use neoconf
        if root_dir:find("nixfiles", 1, true) then
          library.enabled = true
          library.plugins = true
        end
      end,
    },
  },

  {
    "nvimtools/none-ls.nvim",
    config = function()
      local lsp = require "skip.lsp"
      local nls = require "null-ls"

      nls.setup {
        sources = {
          -- nls.builtins.formatting.prettier,
          -- ahggggghhhhhh
          nls.builtins.diagnostics.shellcheck,
          nls.builtins.diagnostics.stylelint,
          nls.builtins.diagnostics.eslint_d,
          nls.builtins.code_actions.eslint_d,
        },
        capabilities = lsp.capabilities,
        should_attach = function(bufnr)
          return lsp.attach_allowed(vim.api.nvim_buf_get_name(bufnr))
        end,
      }
    end,
  },

  -- interacts with tsserver, runs LSP "server" in-process
  {
    "pmizio/typescript-tools.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      settings = {
        expose_as_code_action = "all",
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeCompletionsForModuleExports = true,
          quotePreference = "single",
        },
        -- tsserver_format_options = {
        --   semicolons = "remove",
        -- },
      },
    },
  },
}
