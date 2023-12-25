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

    # nvim "0.10" (2023-12-21)
    neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs {
      version = "0.10.0-dev-af93a7";

      src = pkgs.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "af93a74a0f4afa9a3a4f55ffdf28141eaf776d22";
        hash = "sha256-Kaq//79n61r4e2p5N7g0MDDdUUPOj5+NnUhtLC0k23s";
      };
    };
  });
in {
  programs.neovim = {
    enable = true;
    extraConfig = lua "require('skip')";
  };

  home.file.".config/nvim/lua".source =
    config.lib.skip.ergonomic "home/neovim/lua" ./lua;

  nixpkgs.overlays = [ overlay ];

  home.packages = [ pkgs.neovim-remote ];
}
