return {
  -- extensible multifuzzy finder over pretty much anything
  {
    'nvim-telescope/telescope.nvim',

    -- TODO: upstream or fork
    -- branch = '0.1.x',
    -- dev = true,

    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },

    cmd = 'Telescope',
    keys = {
      -- 1st layer (essential)
      { '<Leader><Space>', '<Cmd>Telescope resume<CR>' }, -- TODO: not sure if this deserves having <Space>
      { '<Leader>o', '<Cmd>Telescope find_files<CR>' },
      { '<Leader>i', '<Cmd>Telescope oldfiles<CR>' },
      { '<Leader>b', '<Cmd>Telescope buffers sort_mru=true sort_lastused=true<CR>' },
      {
        '<Leader>p',
        '<Cmd>lua require"telescope".extensions.trampoline.trampoline.project{}<CR>',
        desc = 'Telescope trampoline',
      },
      { '<Leader>h', '<Cmd>Telescope help_tags<CR>' },
      { '<Leader>g', '<Cmd>Telescope live_grep<CR>' },
      {
        '<Leader>d',
        '<Cmd>Telescope file_browser cwd=%:p:h<CR>',
        desc = 'Telescope file_browser (from current file)',
      },
      { '<Leader>f', '<Cmd>Telescope file_browser<CR>' },

      -- 2nd layer
      { '<Leader>lt', '<Cmd>Telescope builtin<CR>' },
      { '<Leader>lc', '<Cmd>Telescope colorscheme<CR>' },
      { '<Leader>ld', '<Cmd>Telescope diagnostics<CR>' },
      { '<Leader>lb', '<Cmd>Telescope current_buffer_fuzzy_find<CR>' },
      { '<Leader>lls', '<Cmd>Telescope lsp_workspace_symbols<CR>' },
      { '<Leader>llr', '<Cmd>Telescope lsp_references<CR>' },
    },

    config = function()
      local telescope = require('telescope')
      local fb_actions = require('telescope._extensions.file_browser.actions')
      local action_layout = require('telescope.actions.layout')

      -- a custom, compact layout strategy that mimics @norcalli's fuzzy finder
      local layout_strategies = require('telescope.pickers.layout_strategies')
      layout_strategies.compact = function(picker, cols, lines, layout_config)
        local layout = layout_strategies.vertical(picker, cols, lines, layout_config)

        -- make the prompt flush with the status line
        layout.prompt.line = lines + 1
        -- make the results flush with the prompt
        layout.results.line = lines + 3
        local results_height = 40
        layout.results.height = results_height
        if layout.preview then
          local preview_height = 20
          layout.preview.line = lines - preview_height - results_height + 1
          layout.preview.height = preview_height
        end

        return layout
      end

      layout_strategies.flex_smooshed = function(picker, cols, lines, layout_config)
        local layout = layout_strategies.flex(picker, cols, lines, layout_config)

        layout.results.height = layout.results.height + 1

        return layout
      end

      telescope.setup({
        defaults = {
          prompt_prefix = '? ',
          selection_caret = '> ',
          layout_config = { width = 0.7 },
          layout_strategy = 'flex_smooshed',
          border = false,
          dynamic_preview_title = true,
          results_title = false,
          prompt_title = false,
          mappings = {
            i = {
              -- immediately close the prompt when pressing <ESC> in insert mode
              ['<Esc>'] = 'close',
              ['<C-u>'] = false,
              ['<M-p>'] = action_layout.toggle_preview,
            },
            n = {
              ['<C-w>'] = 'delete_buffer',
            },
          },
        },
        extensions = {
          file_browser = {
            disable_devicons = true,
            mappings = {
              ['i'] = {
                ['<S-cr>'] = fb_actions.create_from_prompt,
                ['<C-o>'] = fb_actions.open,
                -- unmap <C-w> to have it delete words again, but since we're
                -- in a prompt buffer we need to use shift
                ['<C-w>'] = { '<C-S-w>', type = 'command' },
                ['<C-d>'] = fb_actions.change_cwd,
              },
            },
          },
        },
      })

      telescope.load_extension('fzf')
      telescope.load_extension('file_browser')
    end,
  },

  -- file browser for telescope
  'nvim-telescope/telescope-file-browser.nvim',

  { 'slice/telescope-trampoline.nvim', dev = true },
}
