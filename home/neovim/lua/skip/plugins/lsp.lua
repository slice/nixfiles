local patched_lspconfig = false

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lsp = require "skip.lsp"
      local lsc = require "lspconfig"

      if not patched_lspconfig then
        local original_bufname_valid = lsc.util.bufname_valid

        -- some day, this'll break ... :O]
        ---@diagnostic disable-next-line:duplicate-set-field
        function lsc.util.bufname_valid(bufname)
          -- reverse engineer bufnr :(
          -- lspconfig pls let me conditionally attach (but early)
          local bufs = vim.api.nvim_list_bufs()
          for _, bufnr in ipairs(bufs) do
            if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_name(bufnr) == bufname then
              if not lsp.attach_allowed(bufnr) then return false end
            end
          end

          return original_bufname_valid(bufname)
        end

        patched_lspconfig = true
      end

      -- TODO: this doesn't belong here!!!!
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

      for _, server in ipairs({
        "astro",
        "eslint",
        "cssls",
        "jsonls",
        "html",
        "bashls",
        "nixd",
        "pyright",
      }) do
        lsc[server].setup {}
      end

      -- xcrun -sdk macosx --find sourcekit-lsp
      vim.system({ "xcrun", "-sdk", "macosx", "--find", "sourcekit-lsp" }, { system = true }, function(object)
        if object.code ~= 0 then
          return
        end
        vim.schedule(function()
          local path = vim.trim(object.stdout)

          -- sourcekit-lsp only ever indicates "(" as being a trigger character
          -- via dynamic registration, but nvim-cmp doesn't seem to like it </3
          --
          -- local capabilities = vim.tbl_extend(
          --   "force",
          --   lsp.capabilities,
          --   { textDocument = { completion = { dynamicRegistration = true } } }
          -- )

          lsc.sourcekit.setup {
            cmd = { path },
            -- capabilities = capabilities,
          }
        end)
      end)

      lsc.lua_ls.setup {}

      lsc.gopls.setup {}

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
    "folke/lazydev.nvim",
    lazy = true,
    dependencies = { "Bilal2453/luvit-meta", lazy = true },
    ft = "lua",
    opts = {
      library = {
        "lazy.nvim",
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },

  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvimtools/none-ls-extras.nvim",
    },
    config = function()
      local lsp = require "skip.lsp"
      local nls = require "null-ls"

      nls.setup {
        sources = {
          nls.builtins.diagnostics.stylelint,
          require("none-ls.diagnostics.eslint_d"),
          require("none-ls.code_actions.eslint_d"),
          require("none-ls.formatting.eslint_d"),
        },
        capabilities = lsp.capabilities,
        should_attach = function(bufnr)
          return lsp.attach_allowed(bufnr)
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
