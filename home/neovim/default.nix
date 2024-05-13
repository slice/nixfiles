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
        version = "0.10.0-dev-d8b395";

        src = pkgs.fetchFromGitHub {
          owner = "neovim";
          repo = "neovim";
          rev = "d8b395b10fd033addef9765e30d9ab42e6cef264";
          hash = "sha256-TF5+4IjRiMFCA80Hqd8H1UXbHgjs6766Ll5BPAeJGd8=";
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
