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
    package = (pkgs.neovim-unwrapped.overrideAttrs (final: prev: rec {
      version = "0.8";

      src = pkgs.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "d367ed9b23d481998d297d812f54b950e5511c24";
        sha256 = "sha256-mVeVjkP8JpTi2aW59ZuzQPi5YvEySVAtxko7xxAx/es=";
      };
    })).override {
      libvterm-neovim = (pkgs.libvterm-neovim.overrideAttrs (final: prev: rec {
        src = pkgs.fetchurl {
          url = "https://www.leonerd.org.uk/code/libvterm/libvterm-0.3.tar.gz";
          sha256 = "sha256-YesNZijFK98CkA39RGiqhqGnElIourimcyiYGIdIM1g=";
        };
      }));
    };

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
