local utils = require('skip.utils')

local folder_icon = ' '

local monochromatic_icons

return {
  {
    -- inform LSPs of file operations
    'igorlfs/nvim-lsp-file-operations', -- pls
    cond = not HEADLESS,
    dependencies = { 'echasnovski/mini.files', 'nvim-lua/plenary.nvim' },
    branch = 'fix/31',
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
    cond = not HEADLESS,
    -- stylua: ignore
    keys = {
      { "<Leader>d", function() require('mini.files').open() end,                             desc = "Open mini.files" },
      { "<Leader>e", function() require('mini.files').open(nil, false) end,                   desc = "Open mini.files to current working directory" },
      { "<Leader>f", function() require('mini.files').open(vim.api.nvim_buf_get_name(0)) end, desc = "Open mini.files to current file" },
    },
    opts = {
      -- trash
      options = {
        permanent_delete = false,
      },
      content = {
        prefix = function(entry)
          if entry.fs_type == 'directory' then
            return (folder_icon .. ' '), 'MiniFilesDirectory'
          end
          local extension = entry.name:match('%.(.+)')
          -- mostly what the default is, but adding a space after the icon for
          -- terminal emulators that can render the full thing
          local icon, hl_name = require('nvim-web-devicons').get_icon(
            entry.name,
            extension,
            { default = true }
          )
          -- vim.notify(vim.inspect(require('mini.files').get_explorer_state()))
          return icon .. ' ', hl_name
        end,
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
            pattern = { 'MiniFilesWindowUpdate', 'MiniFilesWindowOpen' },
            callback = function(args)
              local win_id = args.data.win_id
              local win_nr = vim.fn.win_id2win(win_id)

              local is_active = vim.api.nvim_get_current_win() == win_id

              local config = vim.api.nvim_win_get_config(win_id)
              config.anchor = 'SW'

              -- insert padding & icon around title
              config.title[1][1] = ' '
                .. folder_icon
                .. ' '
                .. config.title[1][1]
                .. ' '

              -- local meta = '#' .. tostring(win_nr) .. ' id:' .. tostring(win_id) .. ' '
              -- -- insert, space permitting
              -- if #meta + 1 < (config.width - #config.title[1][1]) then
              --   table.insert(config.title, { meta, 'FloatSubtitle' })
              -- end

              config.row = vim.opt.lines:get() - 2
              -- config.relative = 'win'
              vim.api.nvim_win_set_config(win_id, config)

              -- vim.notify(('%d is active? %s'):format(win_id, is_active))
              local highlights = {}
              -- vim.wo[win_id].winblend = 20
              vim.wo[win_id].cursorline = is_active
              vim.wo[win_id].number = is_active
              vim.wo[win_id].relativenumber = is_active
              if is_active then
                highlights['DevIconDefault'] = 'String'
              else
                if monochromatic_icons == nil then
                  monochromatic_icons = vim
                    .iter(require('nvim-web-devicons').get_icons())
                    :fold({}, function(acc, _k, v)
                      acc['DevIcon' .. v.name] = 'SkipMiniFilesNormalNC'
                      return acc
                    end)
                end

                highlights = vim.tbl_extend('force', {
                  MiniFilesDirectory = 'SkipMiniFilesNormalNC',
                  FloatBorder = 'SkipMiniFilesNormalNC',
                }, monochromatic_icons)
              end
              highlights = vim.tbl_extend('force', highlights, {
                Normal = 'SkipMiniFilesNormal',
                NormalNC = 'SkipMiniFilesNormalNC',
              })
              vim.wo[win_id].winhl = vim
                .iter(highlights)
                :map(function(k, v)
                  return k .. ':' .. v
                end)
                :join(',')
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
            callback = function(_args)
              -- this needs to be set more frequently, e.g. if this is done by
              -- MiniFilesWindowOpen above instead (and it needs to be
              -- scheduled, too) it doesn't work when using <
              -- vim.wo[args.data.win_id].number = true
              -- vim.wo[args.data.win_id].relativenumber = true
            end,
          },
        },
      })
    end,
  },
}
