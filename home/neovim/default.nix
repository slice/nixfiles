{ pkgs, lib, config, specialArgs, ... }:

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

    # nvim "0.10" (2023-12-16)
    neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs {
      version = "0.10.0-dev-5cefec7";

      src = pkgs.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "8f08b1efbd096850c04c2e8e2890d993bd4d9f95";
        hash = "sha256-Kaq//79n61r4e2p5N7g0MDDdUUPOj5+NnUhtLC0k23s";
      };
    };
  });
in {
  programs.neovim = {
    enable = true;
    extraConfig = lua "require('skip')";
    plugins = [ pkgs.vimPlugins.packer-nvim ];
  };

  home.file.".config/nvim/lua".source = if (specialArgs.ergonomic or false) then
    config.lib.file.mkOutOfStoreSymlink
    ("${specialArgs.ergonomicRepoLocation}/home/neovim/lua")
  else
    ./lua;

  nixpkgs.overlays = [ overlay ];

  home.packages = [ pkgs.neovim-remote ];
}
