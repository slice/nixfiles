local utils = require('skip.utils')

---@type LazySpec
return {
  {
    'https://codeberg.org/andyg/leap.nvim.git',
    dependencies = { 'tpope/vim-repeat' },
    lazy = false,
    keys = {
      {
        '<CR>',
        '<Plug>(leap-forward)',
        mode = { 'n', 'x', 'o' },
        desc = 'Leap (after cursor)',
      },
      {
        '<S-CR>',
        '<Plug>(leap-backward)',
        mode = { 'n', 'x', 'o' },
        desc = 'Leap (before cursor)',
      },
      {
        '<C-CR>',
        '<Plug>(leap-from-window)',
        mode = { 'n', 'x', 'o' },
        desc = 'Leap (other windows)',
      },
      {
        'gs',
        function()
          require 'leap.remote'.action()
        end,
        mode = { 'n', 'o' },
        desc = 'Leap (remote action)',
      },
    },
    config = function()
      local leap = require('leap')

      -- (recommended by README)
      require('leap').opts.preview = function(ch0, ch1, ch2)
        return not (
          ch1:match('%s')
          or (ch0:match('%a') and ch1:match('%a') and ch2:match('%a'))
        )
      end

      -- (recommended by README)
      leap.opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }

      -- "vRRR...y or yR{label}"
      vim.keymap.set({ 'x', 'o' }, 'R', function()
        require('leap.treesitter').select {
          opts = require('leap.user').with_traversal_keys('R', 'r'),
        }
      end, { desc = 'Leap (tree-sitter node selection)' })

      -- (recommended by README)
      do
        -- Create remote versions of all a/i text objects by inserting `r`
        -- into the middle (`iw` becomes `irw`, etc.).

        -- A trick to avoid having to create separate hardcoded mappings for
        -- each text object: when entering `ar`/`ir`, consume the next
        -- character, and create the input from that character concatenated to
        -- `a`/`i`.
        local remote_text_object = function(prefix)
          local ok, ch = pcall(vim.fn.getcharstr) -- pcall for handling <C-c>
          if not ok or (ch == vim.keycode('<esc>')) then
            return
          end
          require('leap.remote').action { input = prefix .. ch }
        end

        for _, prefix in ipairs { 'a', 'i' } do
          vim.keymap.set({ 'x', 'o' }, prefix .. 'r', function()
            remote_text_object(prefix)
          end)
        end
      end

      -- automatically paste when yanking or deleting some remote text
      utils.autocmds('LeapRemote', {
        {
          'User',
          {
            pattern = 'RemoteOperationDone',
            callback = function(event)
              if
                (vim.v.operator == 'y' or vim.v.operator == 'd')
                -- (don't paste if some special register was in use)
                and event.data.register == '"'
              then
                -- (using `=p` from unimpaired to fix indentation)
                vim.cmd('normal =p')
              end
            end,
          },
        },
      })
    end,
  },
}
