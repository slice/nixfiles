{ config, pkgs, ... }:

let
  textEditor = "nvim"; # pretty good if you ask me

  # fenix for rust toolchain
  fenix = import (fetchTarball "https://github.com/nix-community/fenix/archive/f112dc90b9a55621ad0bb751e9793a032d040dba.tar.gz") { };
in
{
  imports = [
    ./fish.nix
    ./git.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    username = "slice";
    homeDirectory = "/Users/slice";

    packages = with pkgs; [
      neovim
      neovim-remote

      fenix.default.toolchain
      nodejs
      python39
      pkgs.python39Packages.ipython

      ffmpeg
      sox
      imagemagick
      yt-dlp

      croc
      graphviz
      jq
      ripgrep
      rlwrap
      curl
      tree
      aria
      p7zip
      smartmontools
      httpie
    ];

    sessionVariables = {
      EDITOR = textEditor;
      # use macOS's ssh so we can get keychain integration
      GIT_SSH = "/usr/bin/ssh";
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
