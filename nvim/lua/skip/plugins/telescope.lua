local utils = require 'skip.utils'

local rg_flags = vim
  .iter({
    '--ignore',
    '--hidden',
    '--no-require-git', -- jj
    '--iglob=!**/{.git,.svn,.hg,CVS,.DS_Store,.next,.cargo,.cache,.build,.yarn/releases,.jj}/**',
  })
  :flatten()
  :totable()

local function man_pages()
  local builtin = require('telescope.builtin')
  builtin.man_pages { man_cmd = { 'apropos', '-s', '1:4:5:7', '.' } }
end

---@type LazySpec
return {
  {
    'danielfalk/smart-open.nvim',
    cond = not HEADLESS,
    commit = 'f079c3201a0a62b1582563bd5ce4256c253634d4',
    dependencies = {
      'kkharji/sqlite.lua',
    },
    config = function()
      require('telescope').load_extension('smart_open')
    end,
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    cond = not HEADLESS,
    build = 'make',
  },

  -- extensible multifuzzy finder over pretty much anything
  {
    'nvim-telescope/telescope.nvim',
    cond = not HEADLESS,

    dependencies = { 'nvim-lua/plenary.nvim' },

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
        '<Cmd>Telescope smart_open<CR>',
        desc = 'Telescope smart_open',
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
      local layout_strategies = require('telescope.pickers.layout_strategies')

      layout_strategies.compact = function(picker, cols, lines, layout_config)
        local width = math.floor(cols * 0.95)
        local width_perc_input = 0.3
        local width_input = math.floor(width * width_perc_input)
        local width_preview = width - width_input
        local left_col = math.floor((cols - width) / 2)
        -- specified heights extend upward in screen space
        local height = lines

        local layout = {
          prompt = {
            line = lines + 2,
            width = width_input,
            height = 1,
            col = left_col,
          },
          results = {
            line = lines + 3,
            width = width_input,
            height = height,
            col = left_col,
          },
          preview = {
            line = lines + 4,
            width = width_preview,
            height = height + 1, -- ?? for title ???
            col = left_col + width_input,
          },
        }

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

      for _, ext in ipairs({ 'fzf' }) do
        telescope.load_extension(ext)
      end

      telescope.setup({
        defaults = {
          -- breaks ghostty wide char expansion thingy
          winblend = 0,
          prompt_prefix = ' ',
          selection_caret = ' ',
          layout_config = { width = 0.7 },
          layout_strategy = 'compact',
          path_display = function(opts, path)
            local cwd = vim.fn.getcwd()
            local relpath = vim.fs.relpath(cwd, path)
            if relpath ~= nil then
              -- the path is relative to the cwd
              local segs = vim.split(relpath, '/')
              local tail = segs[#segs]
              local base_segs = vim.list_slice(segs, nil, #segs - 1)
              table.insert(base_segs, 1, '*')
              local base = table.concat(base_segs, '/')
              return ('%s %s'):format(tail, base),
                {
                  { { 0, #tail }, '@markup.strong' },
                  { { #tail + 1, #tail + 1 + #base }, 'Identifier' },
                }
            else
              local base, tail =
                utils.shorten(path, { return_separated_tail = true })
              return ('%s/%s'):format(base, tail),
                {
                  { { 0, #base + 1 }, 'Comment' },
                }
            end
          end,
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
          -- dynamic_preview_title = true,
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
            -- filesize_limit = 10,
            -- highlight_limit = 10,
            -- swift is too slow :/
            treesitter = { enable = true, disable = { 'swift' } },
            filetype_hook = function(filepath, bufnr, opts)
              -- always let help files through (this isn't baked into the
              -- bouncing logic because attempting to grab the ft of the
              -- preview buffer doesn't actually work (and it has no
              -- path/name), so just check here)
              if opts.ft == 'help' then
                return true
              end

              local bounced =
                require('skip.huge').bouncer(bufnr, { silently = false })
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
        pickers = {
          find_files = {
            find_command = function(_opts)
              return {
                'fd',
                '--no-require-git',
                '--type',
                'file',
                '--type',
                'symlink',
                '-H',
                '-E',
                '{.git,.jj}',
              }
            end,
          },
        },
        extensions = {
          trampoline = {
            workspace_roots = { '~/src/prj', '~/src/lib', '~/work' },
          },
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
          smart_open = {
            show_scores = true,
            match_algorithm = 'fzf',
            mappings = {
              i = {
                -- telescope buffers are prompt buffers, which treat CTRL-W as
                -- if you were in normal mode. remap to actually delete the
                -- last word (idk why this isn't needed with other pickers)
                -- https://github.com/danielfalk/smart-open.nvim/issues/71
                ['<C-w>'] = function()
                  vim.api.nvim_input('<c-s-w>')
                end,
              },
            },
          },
        },
      })

      -- automatically :tcd to repo root when opening stuff in a new tab
      --
      -- (can't use :enhance with `post`, because they're not executed when
      -- replaced, which is probably happening? instead, set `_static_post`,
      -- which always gets ran after (?)
      -- https://github.com/nvim-telescope/telescope.nvim/pull/1892)

      -- local action_set = require('telescope.actions.set')
      -- action_set.select._static_post.select = function(_, type)
      --   if type ~= 'tab' then
      --     -- only mess with <C-t>
      --     return
      --   end
      --
      --   local state = require('telescope.actions.state')
      --   local selected_value = state.get_selected_entry().value
      --   if not selected_value then
      --     return
      --   end
      --
      --   local stat = vim.uv.fs_stat(selected_value)
      --   -- check if it exists in the fs somehow
      --   if stat then
      --     local repo = vim.fs.root(selected_value, { '.git', '.jj', 'go.mod' })
      --
      --     if repo then
      --       vim.notify(('autohop: %s'):format(repo), vim.log.levels.INFO)
      --       vim.cmd.tcd(repo)
      --     end
      --   end
      -- end
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
    -- lazy = true,
    cond = not HEADLESS,
    build = 'make',
  },

  { 'slice/telescope-trampoline.nvim', cond = not HEADLESS, dev = true },
}
