# slice's neovim 0.5+ config (:
# <o_/ *quack *quack*
# (nix edition)

{ pkgs, ... }:

let
  # function stolen from: https://github.com/nbardiuk/dotfiles/blob/b82ca0d28ba3726c46350b3d1063c4259dced2d9/nix/.config/nixpkgs/home/nvim.nix
  #
  # Copyright © 2020 Nazarii Bardiuk
  # 
  # Permission is hereby granted, free of charge, to any person obtaining a copy of
  # this software and associated documentation files (the “Software”), to deal in
  # the Software without restriction, including without limitation the rights to
  # use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
  # of the Software, and to permit persons to whom the Software is furnished to do
  # so, subject to the following conditions:
  #
  # The above copyright notice and this permission notice shall be included in all
  # copies or substantial portions of the Software.
  #
  # THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  # SOFTWARE.
  #
  # ... thanks!
  plug = { url, rev, sha256 }:
    pkgs.vimUtils.buildVimPluginFrom2Nix {
      pname = with pkgs.lib; last (splitString "/" url);
      version = rev;
      src = pkgs.fetchgit { inherit url rev sha256; };
    };

  lua = code: "lua << EOF\n${code}\nEOF";
in {
  programs.neovim = {
    enable = true;

    # :P
    viAlias = true;
    vimAlias = true;

    extraConfig = lua ''
      local cmd = vim.cmd
      local fn = vim.fn
      local opt = vim.opt

      local g = vim.g

      -- }}}

      function greet()
        cmd [[echo "(>^_^>) ♥ ♥ ♥ (<^_^<)"]]
      end

      cmd [[command! Greet :lua greet()<CR>]]
      greet()

      -- options {{{

      -- opt.cursorline = true
      opt.colorcolumn = {80,120}
      opt.completeopt = {'menu','menuone','noselect'}
      opt.guicursor:append {'a:blinkwait1000', 'a:blinkon1000', 'a:blinkoff1000'}
      opt.hidden = true
      opt.ignorecase = true
      opt.inccommand = 'nosplit'
      opt.joinspaces = false
      opt.list = true
      opt.listchars = {tab='> ', trail='·', nbsp='+'}
      opt.modeline = true
      opt.mouse = 'a'
      opt.swapfile = false
      -- lower the duration to trigger CursorHold for faster hovers. we won't be
      -- updating swapfiles this often because they're turned off.
      opt.updatetime = 1000
      opt.wrap = false
      opt.number = true
      opt.relativenumber = true
      opt.splitright = true
      opt.shortmess:append('I'):remove('F')
      opt.smartcase = true
      opt.statusline = [[%f %r%m%=%l/%L,%c (%P)]]
      opt.shada = [['1000]] -- remember 1000 oldfiles
      opt.termguicolors = true
      opt.undodir = fn.stdpath('data') .. '/undo'
      opt.undofile = true
      local blend = 10
      opt.pumblend = blend -- extremely important
      opt.winblend = blend

      opt.expandtab = true
      opt.tabstop = 8
      opt.softtabstop = 2
      opt.shiftwidth = 2

      -- }}}

      -- plugin options {{{

      -- avoid loading the autoload portions of netrw so "e ." uses dirvish, but we
      -- can still use :GBrowse from fugitive
      g.loaded_netrwPlugin = true

      -- g['sneak#label'] = true
      g['float_preview#docked'] = false
      g.seoul256_background = 236
      g.zenburn_old_Visual = true
      g.zenburn_alternate_Visual = true
      g.zenburn_italic_Comment = true
      g.zenburn_subdued_LineNr = true

      g.rooter_patterns = {'.git'}
      g.rooter_manual_only = true
      g.rooter_cd_cmd = 'tcd'

      g.nightflyCursorColor = true
      g.nightflyUndercurls = false
      g.nightflyItalics = false

      g.moonflyCursorColor = true
      g.moonflyUndercurls = false
      g.moonflyItalics = true

      -- }}}

      cmd('colorscheme zenburn')

      -- maps {{{

      g.mapleader = ' '

      -- from: https://github.com/wbthomason/dotfiles/blob/5117f6d76c64baa661368e85a25ca463ff858a05/neovim/.config/nvim/lua/config/utils.lua
      local function map(modes, lhs, rhs, opts)
        opts = opts or {}
        if opts.noremap == nil then
          opts.noremap = true
        end
        if type(modes) == 'string' then
          modes = {modes}
        end
        for _, mode in ipairs(modes) do
          vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
        end
      end

      -- have i_CTRL-U make the previous word uppercase instead
      map('i', '<c-u>', '<esc>gUiwea')

      function POPTERM_TOGGLE()
        if IS_POPTERM() then
          -- if we're currently inside a popterm, just hide it
          POPTERM_HIDE()
        else
          POPTERM_NEXT()
        end
      end

      -- jump around windows easier. this is probably breaking something?
      map('n', '<C-H>', '<C-W><C-H>')
      map('n', '<C-J>', '<C-W><C-J>')
      map('n', '<C-K>', '<C-W><C-K>')
      map('n', '<C-L>', '<C-W><C-L>')

      -- lsp...
      function setup_lsp_buf()
        vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        map_buf('n', '<c-]>', '<cmd>lua vim.lsp.buf.definition()<CR>')
        map_buf('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
        map_buf('n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>')
        map_buf('n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>')
        map_buf('n', '<leader>lf', '<cmd>lua vim.lsp.buf.formatting_sync(nil, 2000)<CR>')
        vim.cmd([[autocmd CursorHold <buffer> lua vim.lsp.diagnostic.show_line_diagnostics({ focusable = false })]])
      end

      -- nvim-popterm.lua
      map('n', '<a-tab>', '<cmd>lua POPTERM_TOGGLE()<CR>')
      map('t', '<a-tab>', '<cmd>lua POPTERM_TOGGLE()<CR>')
      -- because neovide doesn't have some mappings yet because of keyboard support
      map('n', '<leader>0', '<cmd> lua POPTERM_TOGGLE()<CR>')

      -- cd to vcs root
      map('n', '<leader>r', '<cmd>Rooter<CR>')

      -- quickly open :terminals
      map('n', '<leader>te', '<cmd>tabnew +terminal<CR>')
      map('n', '<leader>ts', '<cmd>below split +terminal<CR>')
      map('n', '<leader>tv', '<cmd>vsplit +terminal<CR>')

      -- telescope
      map('n', '<leader>o', '<cmd>Telescope find_files<CR>')
      map('n', '<leader>i', '<cmd>Telescope oldfiles<CR>')
      map('n', '<leader>b', '<cmd>Telescope buffers<CR>')

      map('n', '<leader>lp', "<cmd>lua require'telescope'.extensions.trampoline.trampoline.project{}<CR>")
      map('n', '<leader>lt', '<cmd>Telescope builtin<CR>')
      map('n', '<leader>lg', '<cmd>Telescope live_grep<CR>')
      map('n', '<leader>lb', '<cmd>Telescope file_browser hidden=true<CR>')
      map('n', '<leader>lc', '<cmd>Telescope colorscheme<CR>')
      map('n', '<leader>lls', '<cmd>Telescope lsp_workspace_symbols<CR>')
      map('n', '<leader>lld', '<cmd>Telescope lsp_workspace_diagnostics<CR>')
      map('n', '<leader>llr', '<cmd>Telescope lsp_references<CR>')
      map('n', '<leader>lla', '<cmd>Telescope lsp_code_actions<CR>')

      -- vimrc; https://learnvimscriptthehardway.stevelosh.com/chapters/08.html
      map('n', '<leader>ve', "bufname('%') == ${"''"} ? '<cmd>edit $MYVIMRC<CR>' : '<cmd>vsplit $MYVIMRC<CR>'", {expr = true})
      map('n', '<leader>vs', '<cmd>luafile $MYVIMRC<CR>')

      -- packer; formerly plug
      map('n', '<leader>pi', '<cmd>PackerInstall<CR>')
      map('n', '<leader>pu', '<cmd>PackerUpdate<CR>')
      map('n', '<leader>ps', '<cmd>PackerSync<CR>')
      map('n', '<leader>pc', '<cmd>PackerCompile<CR>')

      -- compe
      -- function _G.compe()
      --   if vim.fn.pumvisible() == 1 then
      --     -- if the popup menu is already visible, pass the key through
      --     return vim.api.nvim_replace_termcodes("<c-n>", true, true, true)
      --   else
      --     -- invoke compe
      --     return vim.fn['compe#complete']()
      --   end
      -- end

      -- map('i', '<c-n>', 'v:lua.compe()', {expr=true})

      -- neoformat
      map('n', '<leader>nf', '<cmd>Neoformat<CR>')

      -- align stuff easily
      -- NOTE: need noremap=false because of <Plug>
      map('x', 'ga', '<Plug>(EasyAlign)', {noremap = false})
      map('n', 'ga', '<Plug>(EasyAlign)', {noremap = false})

      -- use <leader>l to hide highlights from searching
      -- TODO: find a good plugin to do this automatically?
      map('n', '<leader>m', '<cmd>nohlsearch<CR>')

      -- Q enters ex mode by default, so let's bind it to gq instead
      -- (as suggested by :h gq)
      map('n', 'Q', 'gq', {noremap = false})
      map('v', 'Q', 'gq', {noremap = false})

      -- replace :bdelete with sayonara
      map('c', 'bd', 'Sayonara!')

      -- quick access to telescope
      map('c', 'Ts', 'Telescope')

      -- snippets.nvim
      map('i', '<c-l>', "<cmd>lua return require'snippets'.expand_or_advance(1)<CR>")
      map('i', '<c-h>', "<cmd>lua return require'snippets'.advance_snippet(-1)<CR>")

      local command_aliases = {
        -- sometimes i hold down shift for too long o_o
        W = 'w',
        Wq = 'wq',
        Wqa = 'wqa',
        Q = 'q',
        Qa = 'qa',
        Bd = 'bd',
      }

      for lhs, rhs in pairs(command_aliases) do
        cmd(string.format('command! -bang %s %s<bang>', lhs, rhs))
      end

      -- maps so we can use :diffput and :diffget in visual mode
      -- (can't use d because it means delete already)
      map('v', 'fp', ":'<,'>diffput<CR>")
      map('v', 'fo', ":'<,'>diffget<CR>")

      -- autocmds {{{

      -- from: https://github.com/wbthomason/dotfiles/blob/5117f6d76c64baa661368e85a25ca463ff858a05/neovim/.config/nvim/lua/config/utils.lua
      local function aug(group, cmds)
        if type(cmds) == 'string' then
          cmds = {cmds}
        end
        cmd('augroup ' .. group)
        cmd('autocmd!') -- clear existing group
        for _, c in ipairs(cmds) do
          cmd('autocmd ' .. c)
        end
        cmd('augroup END')
      end

      -- personal colorscheme tweaks
      aug('colorschemes', {
        'ColorScheme bubblegum-256-dark'
          .. ' highlight Todo gui=bold'
          .. ' | highlight Folded gui=reverse'
          .. ' | highlight! link MatchParen LineNr'
          .. ' | highlight! IndentBlanklineChar guifg=#3d3d3d',
        -- style floating windows legible for popterms; make comments italic
        'ColorScheme landscape'
          .. ' highlight NormalFloat guifg=#dddddd guibg=#222222'
          .. ' | highlight Comment guifg=#999999 gui=italic',
        -- 'ColorScheme dogrun'
        --   .. ' highlight IndentBlanklineIndent1 guibg=#303345'
        --   .. ' | highlight IndentBlanklineIndent2 guibg=#303345'
      })

      -- metals_config = require("metals").bare_config
      -- metals_config.settings = {
      --   showImplicitArguments = true,
      --   showInferredType = true
      -- }

      aug('metals', {
        'FileType scala,sbt lua require("metals").initialize_or_attach(metals_config)'
          .. '; setup_lsp_buf()'
      })

      aug('completion', {
        -- "BufEnter * lua require'completion'.on_attach()"
        -- 'CompleteDone * if pumvisible() == 0 | pclose | endif'
      })

      aug('filetypes', {
        -- enable spellchecking in git commits, reformat paragraphs as you type
        'FileType gitcommit setlocal spell formatoptions=tan | normal ] '
      })

      -- highlight when yanking (built-in)
      aug('yank', 'TextYankPost * silent! lua vim.highlight.on_yank()')

      local lang_indent_settings = {
        go = {width = 4, tabs = true},
        scss = {width = 2, tabs = false},
        sass = {width = 2, tabs = false},
      }

      local language_settings_autocmds = {}
      for extension, settings in pairs(lang_indent_settings) do
        local width = settings['width']

        local expandtab = 'expandtab'
        if settings['tabs'] then
          expandtab = 'noexpandtab'
        end

        local autocmd = string.format(
          'FileType %s setlocal tabstop=%d softtabstop=%d shiftwidth=%d %s',
          extension, width, width, width, expandtab
        )
        table.insert(language_settings_autocmds, autocmd)
      end

      vim.list_extend(language_settings_autocmds, {
        'BufNewFile,BufReadPre *.sc,*.sbt setfiletype scala',
        'BufNewFile,BufReadPre,BufReadPost *.ts,*.tsx setfiletype typescriptreact',
      })

      aug('language_settings', language_settings_autocmds)

      -- hide line numbers in terminals
      aug('terminal_numbers', 'TermOpen * setlocal nonumber norelativenumber')

      -- automatically neoformat
      -- TODO: use prettierd
      -- local autoformat_extensions = {'js', 'css', 'html', 'yml', 'yaml'}
      -- autoformat_extensions = table.concat(
      --   vim.tbl_map(function(ext) return '*.' .. ext end, autoformat_extensions),
      --   ','
      -- )
      -- aug(
      --   'autoformatting',
      --   'BufWritePre ' .. autoformat_extensions .. ' silent! undojoin | Neoformat'
      -- )

      aug(
        'packer',
        'User PackerCompileDone '
          .. 'echohl DiffAdd | '
          .. 'echomsg "... packer.nvim loader file compiled!" | '
          .. 'echohl None'
      )

      -- }}}

      -- gui {{{

      g.neovide_cursor_animation_length = 0.02
      g.neovide_cursor_trail_length = 2
      g.neovide_cursor_vfx_mode = "railgun"
      g.neovide_cursor_vfx_particle_density = 25
      g.neovide_cursor_vfx_particle_curl = 0.005
      g.neovide_cursor_animate_in_insert_mode = false
      opt.guifont = "PragmataPro Mono:h16"

      -- }}}

      -- >:O {{{

      function map_buf(mode, key, result)
        vim.api.nvim_buf_set_keymap(0, mode, key, result, {noremap = true, silent = true})
      end

      vim.cmd [[
      function! SynStack()
        if !exists("*synstack")
          return
        endif
        echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
      endfunc
      ]]

      -- }}}

      -- highlights {{{

      -- cmd [[highlight! link Sneak IncSearch]]
      -- cmd [[highlight! link SneakLabel IncSearch]]

      -- }}}
    '';

    plugins = with pkgs.vimPlugins; [
      vim-dirvish           # a better built-in directory browser
      vim-sneak             # sneak around
      vim-easy-align        # text alignment
      vim-rsi               # readline keybindings in insert and command mode
      vim-scriptease        # utilities for vim scripts
      vim-eunuch            # unix shell commands, but in vim
      vim-commentary        # comment stuff out
      vim-unimpaired        # handy mappings
      vim-surround          # easily edit surrounding characters
      vim-fugitive          # a git wrapper so good, it should be illegal
      vim-rhubarb           # github support for fugitive
      vim-repeat            # . more stuff
      vim-abolish           # better abbrevs, variant searching, and other stuff

      vim-sayonara          # close buffers more intuitively
      {
        plugin = indent-blankline-nvim; # indentation guides
        config = lua ''
          require("indent_blankline").setup {
            buftype_exclude = {"terminal", "help"}
          }
        '';
      }
      vim-rooter            # cd to the project root

      (plug {
        url = "https://github.com/justinmk/vim-gtfo";
        rev = "7c7a495210a82b93e39bda72c6e4c59642dc4b07";
        sha256 = "sha256-XmYMlXk5xY/RFhnefCKbXUL9KeIXxY3QF3CFfKvEnus=";
      })
      (plug {
        url = "https://github.com/Konfekt/vim-CtrlXA";
        rev = "404ea1e055921db5679b3734108d72850d6faa76";
        sha256 = "sha256-ryf/nPbtfQL/RW+zha0O0kKQzArXHkG7Hp5ixi32b4E";
      })

      # colorschemes
      seoul256-vim
      jellybeans-vim
      zenburn
      (plug {
        url = "https://github.com/baskerville/bubblegum";
        rev = "92a5069edec4de88c31a4f1fdbcff34535951f8b";
        sha256 = "sha256-RSd+/kn4A6HA4vQHHlYTBxwccCeIiqmyaSKezXZc81c";
      })
      (plug {
        url = "https://github.com/bluz71/vim-moonfly-colors";
        rev = "759cc4490e317bc641e4cd94b2c264d35b797d05";
        sha256 = "sha256-NLxBPUlXYRX5GpJT/8qmYCm81C75mXLojRwKzod1X2M=";
      })
      (plug {
        url = "https://github.com/bluz71/vim-nightfly-guicolors";
        rev = "6b73be294090e5793f8df0e60742d380f32bb1f2";
        sha256 = "sha256-bDeS+UQNxCZEOaWpNHxE7kRzHYNB9y+o2AXvmILe13A=";
      })
      (plug {
        url = "https://github.com/itchyny/landscape.vim";
        rev = "dcdd360f98d35d3b2c0bd1ce9f29ee053f906d07";
        sha256 = "sha256-rzr9lHFoAIyYWHebZhgvHH09dx/Wey4tudQBB+GjY6A";
      })

      # language support
      vim-nix
      rust-vim
      vim-javascript
      vim-jsx-pretty

      # lua
      {
        plugin = nvim-lspconfig;
        config = lua ''
          local nvim_lsp = require 'lspconfig'

          vim.cmd [[highlight! link LspDiagnosticsDefaultError Error]]
          vim.cmd [[highlight! link LspDiagnosticsDefaultWarning Number]]

          vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics, {
              -- make warnings and errors appear over hints
              severity_sort = true
            }
          )

          local function on_attach(client)
            setup_lsp_buf()
            if vim.api.nvim_buf_get_option(0, 'filetype') == 'rust' then
              vim.cmd([[autocmd BufEnter,BufWritePost <buffer> ]] ..
                [[:lua require('lsp_extensions.inlay_hints').request ]] ..
                [[{ prefix = ' :: ', enabled = {'ChainingHint', 'TypeHint', 'ParameterHint'}}]])
            end
          end

          nvim_lsp.rust_analyzer.setup {
            on_attach = on_attach,
            settings = {
              ['rust-analyzer'] = {
                assist = {
                  importMergeBehavior = 'last',
                  importPrefix = 'by_self'
                },
                cargo = {
                  loadOutDirsFromCheck = true
                },
                procMacro = {
                  enable = true
                }
              }
            }
          }
        '';
      }
      {
        plugin = plug {
          url = "https://github.com/slice/nvim-popterm.lua";
          rev = "5bfa1213bb2eec11037faf8c43cfd79857b09d24";
          sha256 = "sha256-dhB60e9NQwtfjJJoP0974gs/mWxFw4WpaKRbJBA6ycw=";
        };
        config = lua ''
          local popterm = require('popterm')
          popterm.config.window_height = 0.8
          vim.cmd [[highlight! link PopTermLabel WildMenu]]
        '';
      }
      {
        plugin = nvim-colorizer-lua;
        config = lua ''
          vim.opt.termguicolors = true
          require('colorizer').setup()
        '';
      }
      {
        plugin = telescope-nvim;
        config = lua ''
          local actions = require('telescope.actions')
          local telescope = require('telescope')

          telescope.setup {
            defaults = {
              prompt_prefix = '? ',
              winblend = 10,
              -- don't go into normal mode, just close
              mappings = { i = { ["<esc>"] = actions.close } }
            }
          }

          -- telescope.load_extension('trampoline')
        '';
      }

      # completion
      {
        plugin = nvim-cmp;
        config = lua ''
          local cmp = require('cmp')
          cmp.setup {
            -- completion = {
            --   completeopt = 'menu,menuone,noinsert'
            -- },
            sources = {
              { name = 'buffer' },
              { name = 'nvim_lsp' }
            }
          }
          vim.cmd [[highlight! link CmpItemKindDefault SpecialKey]]
        '';
      }
      cmp-buffer
      cmp-nvim-lsp
    ];
  };
}
