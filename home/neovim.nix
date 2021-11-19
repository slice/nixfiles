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
in {
  programs.neovim = {
    enable = true;

    # :P
    viAlias = true;
    vimAlias = true;

    extraConfig = ''
      lua << EOF
      ${builtins.readFile ./neovim.lua}
      EOF
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
      indent-blankline-nvim # indentation guides
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

      nvim-colorizer-lua
      plenary-nvim
      telescope-nvim
      nvim-cmp
      cmp-nvim-lua
      cmp-buffer
      cmp-nvim-lsp
    ];
  };
}
