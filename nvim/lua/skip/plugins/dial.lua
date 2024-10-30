local M = {}

function M.dial(direction, mode)
  local opts = _G._SkipDialOpts

  local resolved_group = 'default'

  local ft = vim.bo.filetype
  local ft_specific_group = opts.groups[ft]
  local redirection = opts.additional_filetypes_to_group_mappings[ft]

  if ft_specific_group ~= nil then
    resolved_group = ft
  elseif redirection ~= nil and opts.groups[redirection] ~= nil then
    resolved_group = redirection
  end

  require('dial.map').manipulate(direction, mode, resolved_group)
end

return {
  {
    'monaqa/dial.nvim',

    -- stylua: ignore
    keys = {
      { "<C-a>",  function() M.dial("increment", "normal") end },
      { "<C-x>",  function() M.dial("decrement", "normal") end },
      { "g<C-a>", function() M.dial("increment", "gnormal") end },
      { "g<C-x>", function() M.dial("decrement", "gnormal") end },
      { "<C-a>",  function() M.dial("increment", "visual") end,  mode = "v" },
      { "<C-x>",  function() M.dial("decrement", "visual") end,  mode = "v" },
      { "g<C-a>", function() M.dial("increment", "gvisual") end, mode = "v" },
      { "g<C-x>", function() M.dial("decrement", "gvisual") end, mode = "v" },
    },

    opts = function()
      local augend = require('dial.augend')

      -- these aren't defined at the top-level because we can't require dial
      -- there :/

      ---@param opts { [number]: string, preserve_case: boolean, word: boolean, cyclic: boolean, pattern_regexp: string }
      local function const(opts)
        local params = {}

        local function bubble(field)
          if opts[field] ~= nil then
            params[field] = opts[field]
            opts[field] = nil
          end
        end

        bubble('word')
        bubble('cyclic')
        bubble('preserve_case')
        bubble('pattern_regexp')

        assert(vim.islist(opts), 'const opts not a list after bubbling')

        params.elements = opts

        return augend.constant.new(params)
      end

      local default_group = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.date.alias['%Y-%m-%d'],
        const { 'true', 'false', preserve_case = true },
        const { '&&', '||', word = false },
        const { '!=', '==', word = false },
        const { '!==', '===', word = false },
        -- stylua: ignore
        const { "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth", cyclic = false, preserve_case = true },
        const {
          '1st',
          '2nd',
          '3rd',
          '4th',
          '5th',
          '6th',
          '7th',
          '8th',
          '9th',
          '10th',
          cyclic = false,
        },
        -- stylua: ignore
        const { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", preserve_case = true },
        -- stylua: ignore
        const { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", preserve_case = true },
        const { 'and', 'or', preserve_case = true },
        const { 'am', 'pm', preserve_case = true },
        const { 'yes', 'no', preserve_case = true },
        const { 'on', 'off', preserve_case = true },
        const { 'enabled', 'disabled', preserve_case = true },
        const { 'enable', 'disable', preserve_case = true },
        const { 'GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS', 'HEAD' },
        const { 'outer', 'inner', preserve_case = true },
      }

      local function extend_default(group)
        vim.list_extend(group, default_group)
        return group
      end

      local groups = {
        default = default_group,

        javascript = extend_default({
          const { 'let', 'const' },
        }),
      }

      return {
        additional_filetypes_to_group_mappings = {
          typescript = 'javascript',
          typescriptreact = 'javascript',
          javascriptreact = 'javascript',
        },

        groups = groups,
      }
    end,

    config = function(_, opts)
      _G._SkipDialOpts = opts -- :D (can't use `M` for some reason)
      require('dial.config').augends:register_group(opts.groups)
    end,
  },
}
