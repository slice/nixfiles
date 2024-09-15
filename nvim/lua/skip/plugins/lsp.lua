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
            if
                vim.api.nvim_buf_is_valid(bufnr)
                and vim.api.nvim_buf_is_loaded(bufnr)
                and vim.api.nvim_buf_get_name(bufnr) == bufname
            then
              if not lsp.attach_allowed(bufnr) then
                return false
              end
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

      lsc.yamlls.setup {
        settings = {
          yaml = {
            schemas = {
              kubernetes = "*.k8s.{yml,yaml}",
              ["http://json.schemastore.org/github-workflow"] = "/.github/workflows/*",
              ["http://json.schemastore.org/github-action"] = "/.github/action.{yml,yaml}",
              ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
              ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
              ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
              ["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/application_v1alpha1.json"] = "*.argo-application.{yml,yaml}",
              ["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/appproject_v1alpha1.json"] = "*.argo-appproject.{yml,yaml}",
              ["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/applicationset_v1alpha1.json"] = "*.argo-applicationset.{yml,yaml}",
            },
          },
        },
        handlers = {
          ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
            local is_k8s_file = vim.endswith(result.uri, ".k8s.yml") or vim.endswith(result.uri, ".k8s.yaml")
            if not is_k8s_file then
              return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
            end

            local filtered_diagnostics = vim
                .iter(result.diagnostics)
                :filter(function(diagnostic)
                  return not (
                    diagnostic.message == "Matches multiple schemas when only one must validate."
                    and diagnostic.code == 0
                  )
                end)
                :totable()

            return vim.lsp.diagnostic.on_publish_diagnostics(
              err,
              vim.tbl_extend("force", result, { diagnostics = filtered_diagnostics }),
              ctx,
              config
            )
          end,
        },
      }

      -- lsp.eslint.setup {}
      lsc.nixd.setup {}
      lsc.pyright.setup {}
      lsc.lua_ls.setup {}
      lsc.gopls.setup {}
      lsc.bashls.setup {}
      lsc.dhall_lsp_server.setup {}

      for _, server in ipairs({
        "cssls",
        "jsonls",
        "html",
      }) do
        lsc[server].setup {
          handlers = {
            ["textDocument/diagnostic"] = function(err, result, ctx, config)
              if err.code == -32601 and err.message:find("Unhandled method") then
                -- html language server always returns an error in response to
                -- neovim querying it for diagnostics (?), so just ignore this
                -- to avoid polluting notifications
                return {}, nil
              end
              return vim.lsp.diagnostic.on_diagnostic(err, result, ctx, config)
            end,
          },
        }
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

      lsc.hls.setup {
        filetypes = { "haskell", "lhaskell", "cabal" },
        settings = {
          haskell = {
            plugin = {
              rename = { config = { crossModule = true } },
            },
          },
        },
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
            files = {
              excludeDirs = { ".cargo", ".direnv", ".git", "node_modules", "target" },
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
      local nls_helpers = require "null-ls.helpers"
      local nls_utils = require "null-ls.utils"

      nls.setup {
        debug = true,
        sources = {
          nls.builtins.diagnostics.stylelint,
          require("none-ls.diagnostics.eslint").with({
            cwd = nls_helpers.cache.by_bufnr(function(params)
              -- this normally searches for cosmiconfig file that looks like
              -- .eslintrc.yml and sets the root to the first one found in
              -- ancestors. but we don't want that because it'd stop at an
              -- eslintrc that only intends to contain local overrides, when a
              -- parent one might have more rules (and context-sensitive
              -- relative paths). just start at package.json
              return nls_utils.root_pattern("package.json")(params.bufname)
            end),
          }),
          require("none-ls.code_actions.eslint"),
          require("none-ls.formatting.eslint"),
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
        publish_diagnostic_on = "change",
        expose_as_code_action = "all",
        -- code_lens = "all",
        -- disable_member_code_lens = true,
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeCompletionsForModuleExports = true,
          quotePreference = "single",
        },
        tsserver_format_options = {
          semicolons = "remove",
        },
      },
    },
  },
}
