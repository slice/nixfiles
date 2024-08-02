{ pkgs, config, ... }:

let
  lua = code: ''
    lua <<EOF
    ${code}
    EOF
  '';

  overlay = (
    final: prev: {
      neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (orig: {
        version = "0.10.0";

        src = pkgs.fetchFromGitHub {
          owner = "neovim";
          repo = "neovim";
          # 2024-08-01 (has fix for https://github.com/neovim/neovim/issues/28987 somewhere in tree)
          rev = "720b309c786c4a258adccc9c468d433fb0f755b9";
          hash = "sha256-+mr1KCwb5kiDFIwVGnLb+qjuqjfS0sRSckp6hzTgrOk";
        };

        buildInputs = orig.buildInputs ++ [ pkgs.utf8proc ];
      });
    }
  );
in
{
  programs.neovim = {
    enable = true;
    extraConfig = lua ''
      vim.g.sqlite_clib_path = "${pkgs.sqlite.out}/lib/libsqlite3.dylib"
      require('skip')
    '';
  };

  home.file.".config/nvim/lua".source = config.lib.skip.ergonomic ../../nvim/lua;
  home.file.".config/nvim/colors".source = config.lib.skip.ergonomic ../../nvim/colors;

  nixpkgs.overlays = [ overlay ];

  home.packages = [ pkgs.neovim-remote ];
}
