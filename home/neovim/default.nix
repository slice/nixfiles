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

    # nvim "0.10" (2024-03-03)
    neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs {
      version = "0.10.0-dev-3df121";

      src = pkgs.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "3df1211ebc4c7ec4562d0ad0fa51a24569b81e15";
        hash = "sha256-qRRv4bLd59uQaOuGiD8W1SRsS2hiBBdIWUYYU1lySo4=";
      };
    };
  });
in {
  programs.neovim = {
    enable = true;
    extraConfig = lua ''
      vim.g.sqlite_clib_path = "${pkgs.sqlite.out}/lib/libsqlite3.dylib"
      require('skip')
    '';
  };

  home.file.".config/nvim/lua".source = config.lib.skip.ergonomic ./lua;
  home.file.".config/nvim/colors".source = config.lib.skip.ergonomic ./colors;

  nixpkgs.overlays = [ overlay ];

  home.packages = [ pkgs.neovim-remote ];
}
