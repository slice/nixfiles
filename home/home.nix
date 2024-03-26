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
      gallery-dl
      rsync

      # i edit nix files regularly on all of my machines, and having formatting
      # everywhere is nice
      nixfmt
    ];

    # language runtimes, compilers, etc.
    languages = [
      python310
      llvmPackages_12.llvm
      # (pkgs.haskellPackages.ghcWithHoogle (haskellPackages: with haskellPackages; [
      #   cabal-install lens wreq aeson lens-aeson bytestring text tagsoup
      #   http-client time haskell-language-server
      # ]))
    ];

    # tools to help with programming
    tooling = [
      nodePackages.prettier
      shellcheck
      stylua
      lua-language-server
      nil
      nix-diff
      gh
      corepack_20
      nodejs_20
      bun
      tree-sitter
    ];

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
    ];

    # miscellaneous utilities
    utilities = [ graphviz smartmontools colmena packwiz ];

    everything = base ++ languages ++ tooling ++ multimedia ++ utilities;
  };
in {
  lib.skip.ergonomic = path:
    if (specialArgs.ergonomic or false) then
      let
        # since we're in a flake, paths will always point inside of the Nix store
        # regardless of whether we interpolate them or not, so just toString it
        # and extract out the path
        matches = (builtins.match "/nix/store/[a-zA-Z0-9_-]+/(.+)"
          (builtins.toString path));
        trimmedPath = builtins.head matches;
        reconstructedPath = "${specialArgs.ergonomicRepoPath}/${trimmedPath}";
      in config.lib.file.mkOutOfStoreSymlink reconstructedPath
    else
      path;

  imports = [ ./neovim ./fish.nix ./git.nix ./linux ]
    ++ (lib.optional (!server) ./hh3.nix);

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  nixpkgs.overlays = [
    (self: super: {
      swaylock = super.swaylock.overrideAttrs (prev: {
        patches = (prev.patches or [ ])
          ++ [ ./linux/patches/swaylock-no_subpixel_antialiasing.patch ];
      });
    })

    # incorporate 9ce730064c4 - not sure why this isn't on unstable :thinking:
    # remove when merged
    (self: super: {
      x264 = super.x264.overrideAttrs (prev: {
        postPatch = ''
          patchShebangs .
        ''
          # Darwin uses `llvm-strip`, which results in a crash at runtime in assembly-based routines when `-x` is specified.
          + lib.optionalString pkgs.stdenv.isDarwin ''
            substituteInPlace Makefile --replace '$(if $(STRIP), $(STRIP) -x $@)' '$(if $(STRIP), $(STRIP) -S $@)'
          '';
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

    username = "slice";
  };

  home.file.".hammerspoon".source = config.lib.skip.ergonomic ./hammerspoon;
  home.file.".prettierrc.json".source = ./prettierrc.json;
  home.file.".stylua.toml".source = ./stylua.toml;

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
