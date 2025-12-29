-- vim: set fdm=marker:

local lsp = require 'skip.lsp'
local utils = require 'skip.utils'

return {
  {
    'neovim/nvim-lspconfig',
    cond = not HEADLESS,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      vim.lsp.config('*', {
        root_dir = function(bufnr, on_dir)
          if lsp.attach_allowed(bufnr) then
            on_dir(
              vim.fs.root(bufnr, { '.git', '.jj', '.github', 'package.json' })
            )
          end
        end,
        capabilities = lsp.capabilities,
      })

      -- diagnostic config {{{
      -- TODO: this doesn't belong here!!!!
      local signs = {
        [vim.diagnostic.severity.ERROR] = '󰋔 ',
        [vim.diagnostic.severity.WARN] = ' ',
        [vim.diagnostic.severity.HINT] = ' ',
        [vim.diagnostic.severity.INFO] = ' ',
      }
      vim.diagnostic.config {
        -- make warnings and errors appear over hints
        severity_sort = true,
        virtual_text = {
          prefix = function(diagnostic, _index, _total)
            return signs[diagnostic.severity] or '󰟶 '
          end,
        },
        signs = {
          text = signs,
        },
        float = {
          header = '',
        },
      }
      -- }}}

      -- yamlls {{{
      vim.lsp.config('yamlls', {
        settings = {
          yaml = {
            schemas = {
              kubernetes = '*.k8s.{yml,yaml}',
              ['http://json.schemastore.org/github-workflow'] = '/.github/workflows/*',
              ['http://json.schemastore.org/github-action'] = '/.github/action.{yml,yaml}',
              ['http://json.schemastore.org/prettierrc'] = '.prettierrc.{yml,yaml}',
              ['http://json.schemastore.org/kustomization'] = 'kustomization.{yml,yaml}',
              ['http://json.schemastore.org/chart'] = 'Chart.{yml,yaml}',
              ['https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/application_v1alpha1.json'] = '*.argo-application.{yml,yaml}',
              ['https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/appproject_v1alpha1.json'] = '*.argo-appproject.{yml,yaml}',
              ['https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/applicationset_v1alpha1.json'] = '*.argo-applicationset.{yml,yaml}',
            },
          },
        },
      })
      -- }}}
      -- vtsls {{{
      vim.lsp.config('vtsls', {
        settings = {
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = 'always' },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = 'literals' },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
            format = { enable = false },
          },
          javascript = {
            format = { enable = false },
          },
        },
      })
      -- }}}
      -- gh_actions_ls {{{
      vim.lsp.config('gh_actions_ls', {
        filetypes = { 'yaml.github' },
      })
      -- }}}
      -- tailwindcss {{{
      vim.lsp.config('tailwindcss', {
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                { 'cva\\(([^)]*)\\)', '["\'`]([^"\'`]*).*?["\'`]' },
                { 'cx\\(([^)]*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
              },
            },
          },
        },
      })
      -- }}}
      -- cssls,jsonls,html {{{
      for _, server in ipairs({
        'cssls',
        'jsonls',
        'html',
      }) do
        vim.lsp.config(server, {
          settings = {
            css = {
              lint = {
                -- TODO: https://github.com/tailwindlabs/tailwindcss/discussions/5258#discussioncomment-1979394
                unknownAtRules = 'ignore',
              },
            },
          },
        })
      end
      -- }}}
      -- sourcekit {{{
      vim.system(
        { 'xcrun', '-sdk', 'macosx', '--find', 'sourcekit-lsp' },
        { system = true },
        function(object)
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

            vim.lsp.config('sourcekit', {
              cmd = { path },
              -- capabilities = capabilities,
            })
          end)
        end
      )
      -- }}}
      -- rust_analyzer {{{
      vim.lsp.config('rust_analyzer', {
        capabilities = lsp.capabilities,
        settings = {
          ['rust-analyzer'] = {
            imports = {
              granularity = {
                group = 'module',
              },
              prefix = 'crate',
            },
            cargo = {
              features = 'all',
              buildScripts = {
                enable = true,
              },
            },
            files = {
              excludeDirs = {
                '.cargo',
                '.direnv',
                '.git',
                'node_modules',
                'target',
              },
            },
            procMacro = {
              enable = true,
            },
          },
        },
      })
      -- }}}

      vim.lsp.enable({
        'bashls',
        'cssls',
        'gh_actions_ls',
        'gopls',
        'html',
        'jsonls',
        'lua_ls',
        'pyright',
        'rust_analyzer',
        'sourcekit',
        'tailwindcss',
        'vtsls',
        'yamlls',
      })
    end,
  },

  {
    'scalameta/nvim-metals',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    ft = { 'scala', 'sbt', 'java' },
    cond = not HEADLESS,
    opts = function()
      local c = require 'metals'.bare_config()
      -- c.init_options.statusBarProvider = 'off'
      c.capabilities = lsp.capabilities
      c.settings = {
        -- 2025-12-19
        serverVersion = '1.6.4',
        scalafixRulesDependencies = {
          'org.typelevel::typelevel-scalafix:0.5.0',
          'com.github.xuwei-k::scalafix-rules:0.6.1',
        },
      }
    end,
    config = function(self, metals_config)
      local nvim_metals_group =
        vim.api.nvim_create_augroup('nvim-metals', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = self.ft,
        callback = function()
          local metals = require 'metals'
          metals.initialize_or_attach(metals_config)

          -- (this is too slow, and runs async anyhow)
          --
          -- vim.api.nvim_create_autocmd('BufWritePre', {
          --   buffer = info.buf,
          --   desc = 'Run Scalafix before writing buffer',
          --   callback = function()
          --     if utils.flag_set(lsp.noformat_key) then
          --       return
          --     end
          --     metals.run_scalafix()
          --   end,
          -- })
        end,
        group = nvim_metals_group,
      })
    end,
  },

  {
    'folke/lazydev.nvim',
    cond = not HEADLESS,
    dependencies = { 'Bilal2453/luvit-meta', lazy = true },
    ft = 'lua',
    opts = {
      library = {
        'lazy.nvim',
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'nvimtools/none-ls.nvim',
    cond = not HEADLESS,
    dependencies = {
      'nvimtools/none-ls-extras.nvim',
    },
    config = function()
      local nls = require 'null-ls'
      local nls_helpers = require 'null-ls.helpers'
      local nls_utils = require 'null-ls.utils'

      nls.setup {
        debug = true,
        sources = {
          -- nls.builtins.diagnostics.stylelint,
          require('none-ls.diagnostics.eslint_d').with({
            cwd = nls_helpers.cache.by_bufnr(function(params)
              -- this normally searches for cosmiconfig file that looks like
              -- .eslintrc.yml and sets the root to the first one found in
              -- ancestors. but we don't want that because it'd stop at an
              -- eslintrc that only intends to contain local overrides, when a
              -- parent one might have more rules (and context-sensitive
              -- relative paths). just start at package.json
              return nls_utils.root_pattern('package.json')(params.bufname)
            end),
            filter = function(diag)
              return not (
                diag.message
                == 'failed to decode json: Expected value but found invalid token at character 1'
              )
            end,
          }),
          require('none-ls.code_actions.eslint_d'),
          require('none-ls.formatting.eslint_d'),
        },
        capabilities = lsp.capabilities,
        should_attach = function(bufnr)
          return lsp.attach_allowed(bufnr)
        end,
      }
    end,
  },
}
