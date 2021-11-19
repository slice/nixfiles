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

    extraConfig = lua (builtins.readFile ./init.lua);

    plugins = with pkgs.vimPlugins; [
      vim-dirvish    # a better built-in directory browser
      vim-sneak      # sneak around
      vim-easy-align # text alignment
      vim-rsi        # readline keybindings in insert and command mode
      vim-scriptease # utilities for vim scripts
      vim-eunuch     # unix shell commands, but in vim
      vim-commentary # comment stuff out
      vim-unimpaired # handy mappings
      vim-surround   # easily edit surrounding characters
      vim-fugitive   # a git wrapper so good, it should be illegal
      vim-rhubarb    # github support for fugitive
      vim-repeat     # . more stuff
      vim-abolish    # better abbrevs, variant searching, and other stuff
      vim-cool       # :nohlsearch automatically

      vim-sayonara   # close buffers more intuitively
      {              # indentation guides
        plugin = indent-blankline-nvim;
        config = lua ''
          require("indent_blankline").setup {
            buftype_exclude = {"terminal", "help"}
          }
        '';
      }
      vim-rooter     # cd to the project root
      neoformat      # for formatting stuff without lsp

      (plug {        # open file manager or terminal
        url = "https://github.com/justinmk/vim-gtfo";
        rev = "7c7a495210a82b93e39bda72c6e4c59642dc4b07";
        sha256 = "sha256-XmYMlXk5xY/RFhnefCKbXUL9KeIXxY3QF3CFfKvEnus=";
      })
      (plug {        # superpowers for ctrl-x and ctrl-a
        url = "https://github.com/Konfekt/vim-CtrlXA";
        rev = "404ea1e055921db5679b3734108d72850d6faa76";
        sha256 = "sha256-ryf/nPbtfQL/RW+zha0O0kKQzArXHkG7Hp5ixi32b4E";
      })

                     # colorschemes
      seoul256-vim   # a nice pastel color scheme
      jellybeans-vim # it really does look like jellybeans
      zenburn        # alien salad
      (plug {        # nice colors on gray
        url = "https://github.com/baskerville/bubblegum";
        rev = "92a5069edec4de88c31a4f1fdbcff34535951f8b";
        sha256 = "sha256-RSd+/kn4A6HA4vQHHlYTBxwccCeIiqmyaSKezXZc81c";
      })
      (plug {        # pitch black + neon
        url = "https://github.com/bluz71/vim-moonfly-colors";
        rev = "759cc4490e317bc641e4cd94b2c264d35b797d05";
        sha256 = "sha256-NLxBPUlXYRX5GpJT/8qmYCm81C75mXLojRwKzod1X2M=";
      })
      (plug {        # it's like being underwater!
        url = "https://github.com/bluz71/vim-nightfly-guicolors";
        rev = "6b73be294090e5793f8df0e60742d380f32bb1f2";
        sha256 = "sha256-bDeS+UQNxCZEOaWpNHxE7kRzHYNB9y+o2AXvmILe13A=";
      })
      (plug {        # pitch black + retro colors?
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
