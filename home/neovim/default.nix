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
      version = "0.7.0";

      src = pkgs.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "333ba6569d833e22c0d291547d740d4bbfa3fdab";
        sha256 = "sha256-eYYaHpfSaYYrLkcD81Y4rsAMYDP1IJ7fLJJepkACkA8=";
      };
    });

    extraConfig = "lua require('skip')";

    # :b
    viAlias = true;
    vimAlias = true;

    plugins = [ pkgs.vimPlugins.packer-nvim ];
  };

  home.file.".config/nvim/colors".source = ./colors;
  home.file.".config/nvim/lua".source = ./lua;

  home.packages = [ pkgs.neovim-remote ];
}
