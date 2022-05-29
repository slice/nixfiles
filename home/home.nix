{ config, pkgs, specialArgs, ... }:

let
  server = specialArgs.server;

  textEditor = "nvim"; # pretty good if you ask me

  packagesets = with pkgs; rec {
    # packages that i need on every machine
    base = [
      # grab bag of useful programs
      yt-dlp
      croc
      jq
      jo
      ripgrep
      rlwrap
      curl
      aria
      p7zip
      httpie
      htop
      tree
      file
      wget
      fd
      tmux
      # i edit nix files regularly on all of my machines, and having formatting
      # everywhere is nice
      nixfmt
    ];

    # language runtimes, compilers, etc.
    languages = [
      nodejs-slim-16_x
      python39
      # (pkgs.haskellPackages.ghcWithHoogle (haskellPackages: with haskellPackages; [
      #   cabal-install lens wreq aeson lens-aeson bytestring text tagsoup
      #   http-client time haskell-language-server
      # ]))
    ];

    # tools to help with programming
    tooling =
      [ nodePackages.npm nodePackages.prettier shellcheck stylua nix-diff ];

    # video/audio
    multimedia = [ ffmpeg sox imagemagick ];

    # miscellaneous utilities
    utilities = [ graphviz smartmontools ];

    everything = base ++ languages ++ tooling ++ multimedia ++ utilities;
  };
in {
  imports = [ ./neovim ./fish.nix ./git.nix ]
    ++ (if !server then [ ./hh3.nix ] else [ ]);

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    packages = if server then packagesets.base else packagesets.everything;

    sessionVariables = {
      EDITOR = textEditor;
    } // (pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
      # when using git, use the system ssh so we can get keychain integration
      GIT_SSH = "/usr/bin/ssh";
    });
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
