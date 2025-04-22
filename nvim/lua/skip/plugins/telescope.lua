local rg_flags = vim
  .iter({
    '--ignore',
    '--hidden',
    '--no-require-git', -- jj
    '--iglob=!**/{.git,.svn,.hg,CVS,.DS_Store,.next,.cargo,.cache,.build,.yarn/releases,.jj}/**',
  })
  :flatten()
  :totable()

local utils = require('skip.utils')

local function find_files() end

local function man_pages()
  local builtin = require('telescope.builtin')
  builtin.man_pages { man_cmd = { 'apropos', '-s', '1:4:5:7', '.' } }
end

---@type LazySpec
return {

  -- extensible multifuzzy finder over pretty much anything
  {
    'nvim-telescope/telescope.nvim',
    cond = not HEADLESS,

    -- TODO: upstream or fork
    -- branch = '0.1.x',
    -- dev = true,

    -- here because loading order woes
    -- we need to call telescope setup _before_ load_extension. how to enforce
    -- that?
    dependencies = {
      {
        'danielfalk/smart-open.nvim',
        dependencies = {
          'kkharji/sqlite.lua',
          'nvim-telescope/telescope-fzf-native.nvim',
        },
      },
    },

    cmd = 'Telescope',
    keys = {
      -- config editing (evolved from https://learnvimscriptthehardway.stevelosh.com/chapters/08.html)
      {
        '<Leader>ve',
        '<cmd>Telescope find_files cwd=~/src/prj/nixfiles<CR>',
      },
      {
        '<Leader>vg',
        '<cmd>Telescope live_grep cwd=~/src/prj/nixfiles<CR>',
      },

      -- 1st layer (essential)
      { '<Leader><Space>', '<Cmd>Telescope resume<CR>' }, -- TODO: not sure if this deserves having <Space>
      { '<Leader>0', '<Cmd>Telescope looking_glass<CR>' },
      {
        '<Leader>b',
        '<Cmd>Telescope buffers sort_mru=true sort_lastused=true<CR>',
      },
      { '<Leader>g', '<Cmd>Telescope live_grep<CR>' },
      { '<Leader>h', '<Cmd>Telescope help_tags<CR>' },
      { '<Leader>i', '<Cmd>Telescope oldfiles<CR>' },
      { '<Leader>k', '<Cmd>Telescope lsp_references<CR>' },
      {
        '<Leader>o',
        function()
          require('telescope.builtin').find_files {
            find_command = vim
              .iter({ 'rg', rg_flags, '--files' })
              :flatten()
              :totable(),
          }
        end,
        desc = 'Telescope find_files',
      },
      { '<Leader>p', '<Cmd>Telescope trampoline<CR>' },
      { '<Leader>/', '<Cmd>Telescope current_buffer_fuzzy_find<CR>' },
      -- {
      --   -- '<Leader><Leader>',
      --   '<Leader>o',
      --   function()
      --     require('telescope').extensions.smart_open.smart_open {
      --       cwd_only = true,
      --     }
      --   end,
      --   desc = 'Telescope smart_open',
      -- },

      -- 2nd layer
      { '<Leader>lt', '<Cmd>Telescope builtin<CR>' },
      { '<Leader>lc', '<Cmd>Telescope colorscheme<CR>' },
      { '<Leader>lh', '<Cmd>Telescope highlights<CR>' },
      {
        '<Leader>lm',
        man_pages,
        desc = 'Telescope man_pages',
      },
      {
        '<Leader>ld',
        '<Cmd>Telescope diagnostics bufnr=0<CR>',
        desc = 'Telescope diagnostics (buffer)',
      },
      {
        '<Leader>lD',
        '<Cmd>Telescope diagnostics<CR>',
        desc = 'Telescope diagnostics (workspace)',
      },
      {
        '<Leader>ls',
        '<Cmd>Telescope lsp_document_symbols<CR>',
        desc = 'Telescope lsp_document_symbols',
      },
      {
        '<Leader>s',
        '<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>',
        desc = 'Telescope lsp_dynamic_workspace_symbols',
      },
      {
        '<Leader>lS',
        '<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>',
        desc = 'Telescope lsp_dynamic_workspace_symbols',
      },
    },

    config = function()
      local telescope = require('telescope')
      local action_layout = require('telescope.actions.layout')

      -- a custom, compact layout strategy that mimics @norcalli's fuzzy finder
      local layout_strategies = require('telescope.pickers.layout_strategies')
      layout_strategies.compact = function(picker, cols, lines, layout_config)
        local layout =
          layout_strategies.vertical(picker, cols, lines, layout_config)

        -- make the prompt flush with the status line
        layout.prompt.line = lines + 1
        -- make the results flush with the prompt
        layout.results.line = lines + 3

        local results_height = math.floor(lines * 0.4)
        layout.results.height = results_height
        if layout.preview then
          local preview_height = lines - results_height
          layout.preview.line = lines - preview_height - results_height + 2
          layout.preview.height = preview_height
        end

        return layout
      end

      layout_strategies.flex_smooshed = function(
        picker,
        cols,
        lines,
        layout_config
      )
        local layout =
          layout_strategies.flex(picker, cols, lines, layout_config)

        layout.results.height = layout.results.height + 1

        return layout
      end

      telescope.setup({
        defaults = {
          winblend = 0,
          prompt_prefix = '? ',
          selection_caret = '> ',
          layout_config = { width = 0.7 },
          layout_strategy = 'compact',
          border = false,
          -- borderchars = {
          --   '─',
          --   '│',
          --   '─',
          --   '│',
          --   '┌',
          --   '┐',
          --   '┘',
          --   '└',
          -- },
          dynamic_preview_title = true,
          results_title = false,
          prompt_title = false,
          vimgrep_arguments = vim
            .iter({
              'rg',
              '--color=never',
              '--no-heading',
              '--with-filename',
              '--line-number',
              '--column',
              '--smart-case',
              '--fixed-strings',
              rg_flags,
            })
            :flatten()
            :totable(),
          pickers = {
            find_files = {
              find_command = vim
                .iter({ 'rg', rg_flags, '--files' })
                :flatten()
                :totable(),
            },
          },
          mappings = {
            i = {
              -- immediately close the prompt when pressing <ESC> in insert mode
              ['<Esc>'] = 'close',
              -- ["<C-u>"] = false,
              ['<M-p>'] = action_layout.toggle_preview,
            },
            n = {
              ['<C-w>'] = 'delete_buffer',
            },
          },
          preview = {
            -- max limits in MB
            filesize_limit = 1,
            highlight_limit = 1,
            treesitter = true,
            filetype_hook = function(_filepath, bufnr, opts)
              local bounced =
                require('skip.huge').bouncer(bufnr, { silently = true })
              if bounced then
                -- seemingly _need_ to set the preview message in order to suppress previewing
                require('telescope.previewers.utils').set_preview_message(
                  bufnr,
                  opts.winid,
                  'bounced'
                )
                return false
              end
              return true
            end,
          },
        },
        extensions = {
          trampoline = {
            workspace_roots = { '~/src/prj', '~/src/lib', '~/work' },
          },
          smart_open = {
            show_scores = true,
            match_algorithm = 'fzf',
            mappings = {
              i = {
                -- telescope buffers are prompt buffers, which treat CTRL-W as
                -- if you were in normal mode. remap to actually delete the
                -- last word (idk why this isn't needed with other pickers)
                ['<C-w>'] = { '<C-S-w>', type = 'command' },
              },
            },
          },
        },
      })

      telescope.load_extension('smart_open')
    end,
  },

  {
    'prochri/telescope-all-recent.nvim',
    enabled = true,
    cond = not HEADLESS,
    event = 'VeryLazy',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'kkharji/sqlite.lua',
      'stevearc/dressing.nvim',
    },
    opts = {
      pickers = {
        -- oldfiles = { disable = false, use_cwd = true, sorting = "frecency" },
        help_tags = { disable = false, use_cwd = false, sorting = 'frecency' },
        man_pages = { disable = false, use_cwd = false, sorting = 'frecency' },
        ['trampoline#trampoline'] = {
          disable = false,
          use_cwd = false,
          sorting = 'frecency',
        },
      },
    },
  },

  {
    'nvim-telescope/telescope-fzf-native.nvim',
    lazy = true,
    cond = not HEADLESS,
    build = 'make',
    opts = {
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
    config = function(_, opts)
      local telescope = require('telescope')
      telescope.load_extension('fzf')
      telescope.setup {
        extensions = { fzf = opts },
      }
    end,
  },

  { 'slice/telescope-trampoline.nvim', cond = not HEADLESS },
}
