{ config, pkgs, ... }:

let
  textEditor = "nvim"; # pretty good if you ask me
  isDarwin = pkgs.stdenv.isDarwin;
  darwinSessionVariables = pkgs.lib.optionalAttrs isDarwin {
    # when using git, use the system ssh so we can get keychain integration
    GIT_SSH = "/usr/bin/ssh";
  };
in
{
  imports = [
    ./fish.nix
    ./git.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = rec {
    username = "slice";
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";

    packages = with pkgs; [
      # text editors
      neovim
      neovim-remote

      # languages
      nodejs-slim
      python39
      jdk11
      scala
      ammonite

      # language tools
      nixfmt
      pkgs.nodePackages.npm
      pkgs.nodePackages.prettier
      pkgs.python39Packages.ipython

      # multimedia
      ffmpeg
      sox
      imagemagick
      yt-dlp

      # utilities
      croc
      graphviz
      jq
      ripgrep
      rlwrap
      curl
      aria
      p7zip
      smartmontools
      httpie
      htop
    ];

    sessionVariables = {
      EDITOR = textEditor;
    } // darwinSessionVariables;
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
