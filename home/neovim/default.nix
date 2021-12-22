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
        rev = "v${version}";
        sha256 = "sha256-mVVZiDjAsAs4PgC8lHf0Ro1uKJ4OKonoPtF59eUd888=";
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
