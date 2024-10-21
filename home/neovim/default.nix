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

  home.file.".config/nvim/lua".source = config.lib.skip.ergonomic ../../nvim/lua;
  home.file.".config/nvim/colors".source = config.lib.skip.ergonomic ../../nvim/colors;
  home.file.".config/nvim/after".source = config.lib.skip.ergonomic ../../nvim/after;

  home.packages = [ pkgs.neovim-remote ];
}
