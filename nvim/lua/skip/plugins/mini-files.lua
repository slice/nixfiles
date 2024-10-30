local utils = require('skip.utils')

return {
  {
    -- inform LSPs of file operations
    'antosha417/nvim-lsp-file-operations',
    dependencies = { 'echasnovski/mini.files', 'nvim-lua/plenary.nvim' },
    config = function()
      require('lsp-file-operations').setup()

      utils.autocmds('LspFileOperations', {
        {
          'User',
          {
            pattern = { 'MiniFilesActionMove', 'MiniFilesActionRename' },
            callback = function(event)
              require('lsp-file-operations.did-rename').callback({
                old_name = event.data.from,
                new_name = event.data.to,
              })
            end,
          },
        },
        {
          'User',
          {
            pattern = { 'MiniFilesActionDelete' },
            callback = function(event)
              require('lsp-file-operations.did-delete').callback({
                fname = event.from,
              })
            end,
          },
        },
        {
          'User',
          {
            pattern = { 'MiniFilesActionCopy', 'MiniFilesActionCreate' },
            callback = function(event)
              require('lsp-file-operations.did-create').callback({
                fname = event.to,
              })
            end,
          },
        },
      })
    end,
  },

  {
    'echasnovski/mini.files',
    version = '*',
    -- stylua: ignore
    keys = {
      { "<Leader>d", function() require('mini.files').open() end,                             desc = "Open mini.files" },
      { "<Leader>e", function() require('mini.files').open(nil, false) end,                   desc = "Open mini.files to current working directory" },
      { "<Leader>f", function() require('mini.files').open(vim.api.nvim_buf_get_name(0)) end, desc = "Open mini.files to current file" },
    },
    opts = {
      -- hide icons
      content = { prefix = function() end },
      -- trash
      options = {
        permanent_delete = false,
      },
    },
    config = function(_, opts)
      require('mini.files').setup(opts)

      vim.cmd [[hi! link MiniFilesTitleFocused Question]]

      local function map_split(buf_id, lhs, direction)
        local function rhs()
          local cur_target = MiniFiles.get_explorer_state().target_window
          local new_target = vim.api.nvim_win_call(cur_target, function()
            vim.cmd(direction .. ' split')
            return vim.api.nvim_get_current_win()
          end)

          MiniFiles.set_target_window(new_target)
        end

        local desc = 'Split ' .. direction
        vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
      end

      local function files_set_cwd()
        -- Works only if cursor is on the valid file system entry
        local cur_entry_path = MiniFiles.get_fs_entry().path
        local cur_directory = vim.fs.dirname(cur_entry_path)
        vim.cmd.tcd(cur_directory)
        vim.notify(':tcd ' .. cur_directory, vim.log.levels.INFO)
      end

      local function files_open_in_tab()
        local cur_entry_path = MiniFiles.get_fs_entry().path
        MiniFiles.close()
        vim.cmd.tabedit(cur_entry_path)
      end

      utils.autocmds('SkipMiniFiles', {
        {
          'User',
          {
            pattern = 'MiniFilesWindowOpen',
            callback = function(args)
              local win_id = args.data.win_id
              vim.wo[win_id].winblend = 20
            end,
          },
        },
        {
          'User',
          {
            pattern = 'MiniFilesBufferCreate',
            callback = function(args)
              local buf_id = args.data.buf_id
              map_split(buf_id, '<C-s>', 'belowright horizontal')
              map_split(buf_id, '<C-v>', 'belowright vertical')
              vim.keymap.set('n', '<C-d>', files_set_cwd, { buffer = buf_id })
              vim.keymap.set(
                'n',
                '<C-t>',
                files_open_in_tab,
                { buffer = buf_id }
              )
            end,
          },
        },
        {
          'User',
          {
            pattern = 'MiniFilesWindowUpdate',
            callback = function(args)
              -- this needs to be set more frequently, e.g. if this is done by
              -- MiniFilesWindowOpen above instead (and it needs to be
              -- scheduled, too) it doesn't work when using <
              vim.wo[args.data.win_id].number = true
              vim.wo[args.data.win_id].relativenumber = true
            end,
          },
        },
      })
    end,
  },
}
