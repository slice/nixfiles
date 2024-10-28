{
  pkgs,
  config,
  specialArgs,
  ...
}:

let
  nvim = specialArgs.inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  lua = code: ''
    lua <<EOF
    ${code}
    EOF
  '';
in
{
  programs.neovim = {
    enable = true;
    package = nvim;
    extraConfig = lua ''
      vim.g.sqlite_clib_path = "${pkgs.sqlite.out}/lib/libsqlite3.dylib"
      require('skip')
    '';
  };

  home.file =
    let
      mirrored = [
        "lua"
        "fnl"
        "colors"
        "after"
        ".hotpot"
        ".hotpot.lua"
      ];
    in
    builtins.listToAttrs (
      map (n: {
        name = ".config/nvim/${n}";
        value.source = config.lib.skip.ergonomic ../../nvim/${n};
      }) mirrored
    );

  home.packages = [ pkgs.neovim-remote ];
}
