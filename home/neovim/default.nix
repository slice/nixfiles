{ pkgs, config, ... }:

let
  lua = code: ''
    lua <<EOF
    ${code}
    EOF
  '';

  overlay = (
    final: prev: {
      neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs {
        version = "0.10.0";

        src = pkgs.fetchFromGitHub {
          owner = "neovim";
          repo = "neovim";
          rev = "27fb62988e922c2739035f477f93cc052a4fee1e";
          hash = "sha256-FCOipXHkAbkuFw9JjEpOIJ8BkyMkjkI0Dp+SzZ4yZlw=";
        };
      };
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

  home.file.".config/nvim/lua".source = config.lib.skip.ergonomic ./lua;
  home.file.".config/nvim/colors".source = config.lib.skip.ergonomic ./colors;

  nixpkgs.overlays = [ overlay ];

  home.packages = [ pkgs.neovim-remote ];
}
