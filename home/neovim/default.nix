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
        version = "0.11.0-dev";

        src = pkgs.fetchFromGitHub {
          owner = "neovim";
          repo = "neovim";
          # 2024-09-01
          rev = "61e9137394fc5229e582a64316c2ffef55d8d7af";
          hash = "sha256-fzo3m7JBEolhfLVcgCdox0Cj3kQKDhDbZTjC/8eWlj4=";
        };

        buildInputs = orig.buildInputs ++ [
          # https://github.com/neovim/neovim/pull/30042/files
          (pkgs.utf8proc.overrideAttrs (orig: {
            src = pkgs.fetchFromGitHub {
              owner = "JuliaStrings";
              repo = "utf8proc";
              rev = "3de4596fbe28956855df2ecb3c11c0bbc3535838";
              sha256 = "sha256-DNnrKLwks3hP83K56Yjh9P3cVbivzssblKIx4M/RKqw=";
            };
          }))
        ];
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
  home.file.".config/nvim/after".source = config.lib.skip.ergonomic ../../nvim/after;

  nixpkgs.overlays = [ overlay ];

  home.packages = [ pkgs.neovim-remote ];
}
