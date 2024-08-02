local rg_flags = vim
  .iter({
    "--ignore",
    "--hidden",
    "--iglob=!**/{.git,.svn,.hg,CVS,.DS_Store,.next,.cargo,.cache,.build,.yarn/releases}/**",
  })
  :flatten()
  :totable()

local builtin = require("telescope.builtin")

local function find_files()
  builtin.find_files {
    find_command = vim.iter({ "rg", rg_flags, "--files" }):flatten():totable(),
  }
end

local function man_pages()
  builtin.man_pages { man_cmd = { "apropos", "-s", "1:4:5:7", "." } }
end

return {
  -- extensible multifuzzy finder over pretty much anything
  {
    "nvim-telescope/telescope.nvim",

    -- TODO: upstream or fork
    -- branch = '0.1.x',
    -- dev = true,

    cmd = "Telescope",
    keys = {
      -- 1st layer (essential)
      { "<Leader><Space>", "<Cmd>Telescope resume<CR>" }, -- TODO: not sure if this deserves having <Space>
      { "<Leader>o", find_files, desc = "Telescope find_files" },
      { "<Leader>i", "<Cmd>Telescope oldfiles<CR>" },
      { "<Leader>b", "<Cmd>Telescope buffers sort_mru=true sort_lastused=true<CR>" },
      { "<Leader>p", "<Cmd>Telescope trampoline<CR>" },
      { "<Leader>0", "<Cmd>Telescope looking_glass<CR>" },
      { "<Leader>h", "<Cmd>Telescope help_tags<CR>" },
      { "<Leader>g", "<Cmd>Telescope live_grep<CR>" },

      -- 2nd layer
      { "<Leader>lt", "<Cmd>Telescope builtin<CR>" },
      { "<Leader>lc", "<Cmd>Telescope colorscheme<CR>" },
      { "<Leader>lm", man_pages, desc = "Telescope man_pages" },
      { "<Leader>ld", "<Cmd>Telescope diagnostics<CR>" },
      { "<Leader>lb", "<Cmd>Telescope current_buffer_fuzzy_find<CR>" },
      { "<Leader>lls", "<Cmd>Telescope lsp_workspace_symbols<CR>" },
      { "<Leader>llr", "<Cmd>Telescope lsp_references<CR>" },
    },

    config = function()
      local telescope = require("telescope")
      local action_layout = require("telescope.actions.layout")

      -- a custom, compact layout strategy that mimics @norcalli's fuzzy finder
      local layout_strategies = require("telescope.pickers.layout_strategies")
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
          prompt_prefix = "? ",
          selection_caret = "> ",
          layout_config = { width = 0.7 },
          layout_strategy = "flex_smooshed",
          border = true,
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          dynamic_preview_title = true,
          results_title = false,
          prompt_title = false,
          vimgrep_arguments = vim
            .iter({
              "rg",
              "--color=never",
              "--no-heading",
              "--with-filename",
              "--line-number",
              "--column",
              "--smart-case",
              "--fixed-strings",
              rg_flags,
            })
            :flatten()
            :totable(),
          mappings = {
            i = {
              -- immediately close the prompt when pressing <ESC> in insert mode
              ["<Esc>"] = "close",
              ["<C-u>"] = false,
              ["<M-p>"] = action_layout.toggle_preview,
            },
            n = {
              ["<C-w>"] = "delete_buffer",
            },
          },
          preview = {
            filesize_limit = 1,
            highlight_limit = 1,
            treesitter = false, -- can block on huge files
            filetype_hook = function(_filepath, bufnr, opts)
              local bounced = require("skip.huge").bouncer(bufnr, { silently = true })
              if bounced then
                -- seemingly _need_ to set the preview message in order to suppress previewing
                require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "bounced")
                return false
              end
              return true
            end,
          },
        },
        extensions = {
          trampoline = {
            workspace_roots = { "~/src/prj", "~/src/lib", "~/src/work/a8c" },
          },
        },
      })
    end,
  },

  {
    "prochri/telescope-all-recent.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "kkharji/sqlite.lua",
      "stevearc/dressing.nvim",
    },
    opts = {
      pickers = {
        help_tags = { disable = false, use_cwd = false, sorting = "frecency" },
        man_pages = { disable = false, use_cwd = false, sorting = "frecency" },
        ["trampoline#trampoline"] = {
          disable = false,
          use_cwd = false,
          sorting = "frecency",
        },
      },
    },
  },

  "slice/telescope-trampoline.nvim",
}
