{ pkgs, lib, ... }:

let
  lua = code: ''
    lua <<EOF
    ${code}
    EOF
  '';

  overlay = (final: prev: {
    libvterm-neovim = prev.libvterm-neovim.overrideAttrs {
      version = "0.3.3";
      src = builtins.fetchurl {
        url =
          "https://launchpad.net/libvterm/trunk/v0.3/+download/libvterm-0.3.3.tar.gz";
        sha256 = "sha256:1q16fbznm54p24hqvw8c9v3347apk86ybsxyghsbsa11vm1ny589";
      };
    };
    neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs {
      version = "0.10.0-dev-5cefec7";

      src = pkgs.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        # nvim 0.10 (2023-11-04)
        rev = "5cefec7349610853910c21a0215f85a4d47132d1";
        hash = "sha256-A7LYzyDK8B4HXg9bLSxG7OvFiI8W0rJEMZrgcjtcE0Q=";
      };
    };
  });
in {
  programs.neovim = {
    enable = true;
    extraConfig = "lua require('skip')";
    plugins = [ pkgs.vimPlugins.packer-nvim ];
  };

  home.file.".config/nvim/colors".source = ./colors;
  home.file.".config/nvim/lua".source = ./lua;

  nixpkgs.overlays = [ overlay ];

  home.packages = [ pkgs.neovim-remote ];
}
