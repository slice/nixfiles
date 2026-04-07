-- vim: fdm=marker

local lsp = require 'skip.lsp'

return {
  {
    'neovim/nvim-lspconfig',
    cond = not HEADLESS,
    event = 'VeryLazy',
    config = function()
      vim.lsp.config('*', {
        root_dir = function(bufnr, on_dir)
          -- respect huge functionality, and ban certain paths from getting
          -- LSPs attached to them
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
          format = function(diag)
            if diag.source == 'rustc' then
              local lines = vim.split(
                diag.message,
                '\n',
                { plain = true, trimempty = true }
              )
              return lines[1]
            end
            return diag.message
          end,
          prefix = function(_diag, _index, _total)
            return ''
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

      -- relay {{{
      vim.lsp.config['relay'] = {
        cmd = { 'pnpx', 'relay-compiler', 'lsp' },
        filetypes = { 'typescriptreact', 'graphql', 'typescript' },
        root_markers = { 'relay.config.json' },
      }
      vim.lsp.enable('relay')
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
      vim.lsp.enable('yamlls')
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
      vim.lsp.enable('vtsls')
      -- }}}
      -- gh_actions_ls {{{
      vim.lsp.config('gh_actions_ls', {
        filetypes = { 'yaml.github' },
      })
      vim.lsp.enable('gh_actions_ls')
      -- }}}
      -- tailwindcss {{{
      vim.lsp.config('tailwindcss', {
        settings = {
          tailwindCSS = {
            lint = {
              cssConflict = 'warning',
              invalidApply = 'error',
              invalidConfigPath = 'error',
              invalidScreen = 'error',
              invalidTailwindDirective = 'error',
              invalidVariant = 'error',
              recommendedVariantOrder = 'warning',
            },
            classAttributes = {
              'class',
              '.*[cC]lassName.*',
            },
            experimental = {
              classRegex = {
                { 'cva\\(([^)]*)\\)', '["\'`]([^"\'`]*).*?["\'`]' },
                { 'cx\\(([^)]*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
              },
            },
          },
        },
      })
      vim.lsp.enable('tailwindcss')
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
        vim.lsp.enable(server)
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
      vim.lsp.enable('sourcekit')
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
            check = { command = 'clippy' },
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
      vim.lsp.enable('rust_analyzer')
      -- }}}
      -- postgres_lsp {{{
      vim.lsp.config('postgres_lsp', {
        -- only attach if there's actually a postgres-language-server.jsonc, so
        -- we don't attach to e.g. SQLite files
        root_dir = function(bufnr, on_dir)
          local root = vim.fs.root(bufnr, 'postgres-language-server.jsonc')
          if root then
            on_dir(root)
          end
        end,
      })
      vim.lsp.enable('postgres_lsp')
      -- }}}
      -- haskell-language-server {{{
      vim.lsp.config('hls', {
        cmd = {
          'haskell-language-server-wrapper',
          '--lsp',
        },
        settings = {
          haskell = {
            formattingProvider = 'fourmolu',
          },
        },
        cmd_env = {
          -- BTW: HLS is not --threaded
          GHCRTS = vim
            .iter({
              -- LSP servers are latency sensitive. use concurrent mark-and-sweep
              -- garbage collector
              '--nonmoving-gc',
              -- how big gen 0 allocs go (per os thread)
              '-A64m',
              -- suggested heap size
              '-H4G',
              -- never return memory to OS, keep pages around (i have RAM :3)
              '-Fd0',
            })
            :join(' '),
        },
        filetypes = { 'haskell', 'lhaskell', 'cabal' },
      })
      vim.lsp.enable('hls') -- }}}

      vim.lsp.enable({
        'bashls',
        'gopls',
        -- 'lua_ls',
        'pyright',
      })
    end,
  },

  -- metals {{{
  {
    'scalameta/nvim-metals',
    enabled = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    ft = { 'scala', 'sbt', 'java' },
    cond = not HEADLESS,
    opts = function()
      local metals_config = require 'metals'.bare_config()

      -- we assume JDK 25 (LTS) or later, for the most part
      local beefy = {
        '-XX:+UnlockExperimentalVMOptions',

        -- stack, inlining
        '-Xss4m',
        '-XX:MaxInlineLevel=20',

        -- (stable starting with JDK 25, experimental in JDK 24)
        '-XX:+UseCompactObjectHeaders',

        -- avoid latency when touching platform memory by allocating everything
        -- up front. use an insanely large java heap size because i have a lot
        -- of ram ^^
        --
        -- https://docs.oracle.com/en/java/javase/25/gctuning/z-garbage-collector.html#GUID-683A80ED-98CF-43A5-86BC-240E2900E53E:~:text=Allowing%20the%20GC%20to%20commit
        '-Xms12g',
        '-Xmx12g',
        '-XX:+AlwaysPreTouch',

        '-XX:+UseZGC',
        -- (on JDK 24 and later, ZGC is always generational)
        '-XX:+ZGenerational',
      }

      -- enable LSP progress notifications; need something like fidget.nvim
      -- to handle them
      metals_config.init_options.statusBarProvider = 'off'
      metals_config.capabilities = lsp.capabilities
      metals_config.settings = {
        fallbackScalaVersion = '3.8.1',
        -- latest as of 2026-02-08
        bloopVersion = '2.0.18',
        serverVersion = '1.6.5',
        serverProperties = beefy,
        bloopJvmProperties = beefy,

        inlayHints = {
          byNameParameters = { enable = true },
          hintsInPatternMatch = { enable = true },
          -- implicitArguments = { enable = true },
          -- implicitConversions = { enable = true },
          inferredTypes = { enable = true },
          typeParameters = { enable = true },
        },
        enableSemanticHighlighting = false,
        autoImportBuild = 'all',
        verboseCompilation = true,

        -- NOTE don't use `::` because scalafix rules aren't published for
        -- Scala 3. using 2.13 seems to work
        scalafixRulesDependencies = {
          -- published 2025-01-22
          'org.typelevel:typelevel-scalafix_2.13:0.5.0',

          -- published 2025-12-29
          'com.github.xuwei-k:scalafix-rules_2.13:0.6.22',
        },
      }
      metals_config.on_attach = function(client, bufnr)
        vim.notify(
          (':O] metals called on_attach for %d'):format(bufnr),
          vim.log.levels.INFO
        )
        require 'skip.lsp'.setup_lsp_buf(client, bufnr)
        require 'metals'.setup_dap()
      end

      return metals_config
    end,
    config = function(_, metals_config)
      local nvim_metals_group =
        vim.api.nvim_create_augroup('nvim-metals', { clear = true })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'scala', 'sbt', 'java' },
        callback = function(ctx)
          local metals = require 'metals'

          local function set_up_early_metals_keymaps(bufnr)
            vim.keymap.set('n', '<Leader>mc', function()
              require 'telescope'.extensions.metals.commands()
            end, {
              desc = 'Telescope: Metals Commands',
              buffer = bufnr,
            })

            vim.keymap.set('n', '<Leader>mi', function()
              metals.organize_imports()
            end, {
              desc = 'Metals: Organize Imports',
              buffer = bufnr,
            })

            vim.keymap.set('n', '<Leader>md', function()
              metals.run_doctor()
            end, {
              desc = 'Metals: Doctor',
              buffer = bufnr,
            })

            vim.keymap.set('n', '<Leader>mr', function()
              metals.reset_workspace()
            end, {
              desc = 'Metals: Reset Workspace',
              buffer = bufnr,
            })

            vim.keymap.set('n', '<Leader>mq', function()
              metals.quick_worksheet()
            end, {
              desc = 'Metals: Quick Worksheet',
              buffer = bufnr,
            })

            vim.keymap.set('n', '<Leader>mn', function()
              metals.new_scala_file()
            end, {
              desc = 'Metals: New Scala File',
              buffer = bufnr,
            })
          end

          set_up_early_metals_keymaps(ctx.buf)

          vim.notify(
            (':O] telling metals to attach to %d'):format(ctx.buf),
            vim.log.levels.INFO
          )
          -- or else we get a ton of press ENTER prompts from metals :[
          vim.opt.cmdheight = 2
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
  -- }}}

  {
    'folke/lazydev.nvim',
    -- cond = not HEADLESS,
    enabled = false,
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
    event = 'VeryLazy',
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
