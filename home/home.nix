{ config, lib, pkgs, specialArgs, ... }:

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
      htop
      tree
      file
      wget
      fd
      tmux
      cachix
      unzip

      # i edit nix files regularly on all of my machines, and having formatting
      # everywhere is nice
      nixfmt
    ];

    # language runtimes, compilers, etc.
    languages = [
      nodejs_20
      python310
      llvmPackages_12.llvm
      # (pkgs.haskellPackages.ghcWithHoogle (haskellPackages: with haskellPackages; [
      #   cabal-install lens wreq aeson lens-aeson bytestring text tagsoup
      #   http-client time haskell-language-server
      # ]))
    ];

    # tools to help with programming
    tooling = [ nodePackages.prettier shellcheck stylua nix-diff ];

    # video/audio
    multimedia = [
      (if (specialArgs.customFFmpeg or false) then
        (ffmpeg_5.override {
          # we want libfdk-aac for (allegedly) nice, high-quality aac encoding
          withFdkAac = true;
          withUnfree = true;
        })
      else
        ffmpeg_5)
      sox
      imagemagick
      mpv
    ];

    # miscellaneous utilities
    utilities = [ graphviz smartmontools colmena ];

    everything = base ++ languages ++ tooling ++ multimedia ++ utilities;
  };
in {
  imports = [ ./neovim ./fish.nix ./git.nix ./linux ]
    ++ (lib.optional (!server) ./hh3.nix);

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.overlays = [
    (self: super: {
      swaylock = super.swaylock.overrideAttrs (prev: {
        patches = (prev.patches or [ ])
          ++ [ ./linux/patches/swaylock-no_subpixel_antialiasing.patch ];
      });
    })
  ];

  home = {
    packages = if server then packagesets.base else packagesets.everything;

    sessionVariables = {
      EDITOR = textEditor;
    } // (lib.optionalAttrs pkgs.stdenv.isDarwin {
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
