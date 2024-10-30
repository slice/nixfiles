local telescope = require('telescope')
local pickers = require('telescope.pickers')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local progress = require('fidget.progress')

local M = {}

function M.look(selected)
  local notif = progress.handle.create({
    title = 'looking glass',
    message = 'querying download url...',
    percentage = 0,
  })

  vim.system(
    { 'gh', 'api', selected.api_url, '-q', '.download_url' },
    { text = true },
    function(completed)
      if completed.code ~= 0 then
        vim.schedule(function()
          pcall(notif.cancel, notif)
          vim.notify(
            ("couldn't query download url (curl exited with %d)"):format(
              completed.code
            ),
            vim.log.levels.ERROR
          )
        end)
        return
      end

      -- lol javascript amirite
      notif.message = ('downloading %s from %s...'):format(
        selected.path,
        selected.repo
      )

      local stderr = vim.uv.new_pipe()
      local stdout = vim.uv.new_pipe()
      local file_content = ''

      process, pid = vim.uv.spawn('curl', {
        -- (-L) follows redirects, (-#) outputs progress to stderr
        args = { '-#L', vim.trim(completed.stdout) },
        stdio = { nil, stdout, stderr },
      }, function(code, _signal) ---@diagnostic disable-line: unused-local
        if code ~= 0 then
          vim.schedule_wrap(vim.notify)(
            'curl died with code ' .. tostring(code) .. ' :(',
            vim.log.levels.ERROR
          )
          return
        end

        vim.schedule(function()
          local buf = vim.api.nvim_create_buf(true, false)
          -- prevents buffer name from changing, won't try to write to the url
          -- since it's not a real file path, etc.
          vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
          vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = buf })
          vim.api.nvim_buf_set_name(buf, selected.web_url)

          local lines = vim.split(file_content, '\r?\n', {})
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

          local ft, apply_filetype =
            vim.filetype.match({ buf = buf, filename = selected.name })
          if apply_filetype then
            pcall(apply_filetype, buf)
          end
          if ft then
            vim.api.nvim_set_option_value('filetype', ft, { buf = buf })
          end

          vim.api.nvim_set_option_value('modifiable', false, { buf = buf }) -- ?

          -- this can fail if we're inside of telescope or something
          local ok, err = pcall(vim.api.nvim_set_current_buf, buf)
          if not ok then
            vim.schedule_wrap(vim.notify)(
              ("couldn't focus buffer %d from looking-glass: %s"):format(
                buf,
                err
              ),
              vim.log.levels.ERROR
            )
          end

          -- this is probably good enough
          process:close()
          stderr:close()
          stdout:close()
          notif:finish()
        end)
      end)

      vim.uv.read_start(stderr, function(err, data)
        assert(not err, err)
        if data then
          local match = data:match('([%d%.]+)%%')
          if match then
            notif.percentage = tonumber(match)
          end
        end
      end)

      vim.uv.read_start(stdout, function(err, data)
        assert(not err, err)
        if data then
          file_content = file_content .. data
        end
      end)
    end
  )
end

function M.looking_glass(opts)
  local finder = finders.new_async_job {
    -- TODO: add custom previewer to show downloaded content, and cache when
    -- migrating into a buffer. ratelimits for that endpoint are generous

    command_generator = function(prompt)
      if prompt == '' or prompt == nil then
        return nil
      end

      return { 'looking-glass', prompt }
    end,

    entry_maker = function(line)
      -- agh, no way to tell if the command failed or not -_-
      -- we unconditionally get every line from stdout here
      local ok, result = pcall(vim.json.decode, line)
      if not ok or result == nil then
        return {}
      end

      if result.error then
        -- sentinel value for errors, ignore when handling
        return { value = {}, display = result.error, ordinal = result.error }
      end

      return {
        value = result,
        display = ('%s: %s'):format(result.repo, result.path),
        ordinal = result['web_url'],
      }
    end,
  }

  pickers
    .new(opts, {
      debounce = 850,
      prompt_title = 'Looking Glass',
      finder = finder,
      -- IMPORTANT: don't use a sorter; we don't want to filter the results by
      -- the prompt. this rings especially true if any special search keywords
      -- are used (e.g. "user:slice"), as it's likely for that substring to not
      -- appear in the output at all, causing nothing to show up. ._.
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          if entry == nil then
            return
          end

          local selected = entry.value

          -- ignore "error messages"
          if vim.tbl_isempty(selected) then
            return
          end

          actions.close(prompt_bufnr)

          M.look(selected)
        end)

        return true
      end,
    })
    :find()
end

return telescope.register_extension({
  exports = { looking_glass = M.looking_glass },
})
