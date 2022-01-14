{ pkgs, ... }:

let
  lua = code: ''
    lua <<EOF
    ${code}
    EOF
  '';
in {
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped.overrideAttrs (prev: rec {
      version = "0.6.0";

      src = pkgs.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "8f27c4a0417c001fa2dedb6346673da501ea78e5";
        sha256 = "sha256-dYu02npRmmG/JkIABwrHi2l7RFeAZMs5ZQK1NAEG838=";
      };
    });

    extraConfig = "lua require('skip')";

    # :b
    viAlias = true;
    vimAlias = true;

    plugins = [ pkgs.vimPlugins.packer-nvim ];
  };

  home.file.".config/nvim/lua".source = ./lua;

  home.packages = [ pkgs.neovim-remote ];
}
