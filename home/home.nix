{ username ? "slice", server ? false }:

{ config, pkgs, ... }:

let
  textEditor = "nvim"; # pretty good if you ask me
  isDarwin = pkgs.stdenv.isDarwin;
  darwinSessionVariables = pkgs.lib.optionalAttrs isDarwin {
    # when using git, use the system ssh so we can get keychain integration
    GIT_SSH = "/usr/bin/ssh";
  };

  packagesets = with pkgs; rec {
    # packages that i need on every machine
    base = [
      # \(^_^)/ neovim
      # ... (neovim pkg is managed by h-m) ...
      neovim-remote

      # grab bag of useful programs
      yt-dlp croc jq ripgrep rlwrap curl aria p7zip httpie htop tree file wget
      fd tmux

      # nix tooling
      nixfmt nix-diff
    ];

    # language runtimes, compilers, etc.
    languages = [ nodejs-slim python39 jdk11 scala ammonite ];

    # tools to help with programming
    tooling =
      [ nodePackages.npm nodePackages.prettier python39Packages.ipython ];

    # video/audio
    multimedia = [ ffmpeg sox imagemagick ];

    # miscellaneous utilities
    utilities = [ graphviz smartmontools ];

    everything = base ++ languages ++ tooling ++ multimedia ++ utilities;
  };

  homeDirectory =
    if isDarwin then "/Users/${username}" else "/home/${username}";
in {
  imports = [ ./fish.nix ./neovim ./git.nix ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    inherit username;
    homeDirectory = pkgs.lib.mkForce homeDirectory;

    packages = if server then packagesets.base else packagesets.everything;

    sessionVariables = { EDITOR = textEditor; } // darwinSessionVariables;
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
