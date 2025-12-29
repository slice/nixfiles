---@type LazySpec
return {
  {
    'mfussenegger/nvim-dap',
    event = 'VeryLazy',
    -- stylua: ignore
    keys = {
      {'<F5>', function() require'dap'.continue() end, mode = 'n', desc = 'dap: Continue' },
      {'<F10>', function() require'dap'.step_over() end, mode = 'n', desc = 'dap: Step Over' },
      {'<F11>', function() require'dap'.step_into() end, mode = 'n', desc = 'dap: Step Into' },
      {'<F12>', function() require'dap'.step_out() end, mode = 'n', desc = 'dap: Step Out' },

      {'<Leader>zb', function() require'dap'.toggle_breakpoint() end, desc = 'dap: Toggle Breakpoint' },
      {'<Leader>zs', function()
        local widgets = require'dap.ui.widgets'
        widgets.cursor_float(widgets.scopes)
      end, desc = 'dap: View Scopes'},
      {'<Leader>zc', function() require'dap'.repl.open() end, desc = 'dap: Open REPL' },
      {'<Leader>zr', function() require'dap'.run_last() end, desc = 'dap: Run Last' },
    },
    config = function()
      vim.fn.sign_define(
        'DapBreakpoint',
        { text = '🛑', texthl = '', linehl = '', numhl = '' }
      )
    end,
  },

  {
    'igorlfs/nvim-dap-view',
    cmd = { 'DapViewOpen', 'DapViewClose' },
    keys = {
      {
        '<Leader>zv',
        function()
          require 'dap-view'.toggle()
        end,
        mode = 'n',
        desc = 'dap-view: Toggle',
      },
    },
  },
}
