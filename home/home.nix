{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:

let
  server = specialArgs.server;

  textEditor = "nvim"; # pretty good if you ask me
  editorPkg = pkgs.writeShellScriptBin "editor" ''
    if [ -n "$NVIM_LOG_FILE" ]; then
      ${lib.getBin pkgs.neovim-remote}/bin/nvr --remote-tab-wait "$@"
    elif [ "$TERM_PROGRAM" = "vscode" ]; then
      code --wait "$@"
    else
      ${textEditor} "$@"
    fi
  '';
  editor = "${lib.getBin editorPkg}/bin/editor";

  packagesets = with pkgs; rec {
    # packages that i need on every machine
    base = [
      # grab bag of useful programs
      yt-dlp
      croc
      jq
      jo
      eza
      ripgrep
      gawk
      fzf
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
      rclone
      nixfmt-rfc-style
      gnused
    ];

    # language runtimes, compilers, etc.
    languages = [
      python3
      llvmPackages_12.llvm
      nodejs_23
      typescript
      deno
      luajitPackages.moonscript
      luajitPackages.fennel
      # (pkgs.haskellPackages.ghcWithHoogle (haskellPackages: with haskellPackages; [
      #   cabal-install lens wreq aeson lens-aeson bytestring text tagsoup
      #   http-client time haskell-language-server
      # ]))
    ];

    # tools to help with programming
    tooling = [
      argocd
      git-lfs
      delta
      coursier
      bash-language-server
      biome
      bun
      corepack_18
      dhall
      dhall-lsp-server
      fnlfmt
      dhall-yaml
      doctl
      fluxcd
      gh
      kubernetes-helm
      lua-language-server
      nix-diff
      nixd
      nodePackages.prettier
      jujutsu
      shellcheck
      stylua
      tree-sitter
      vscode-langservers-extracted
      yaml-language-server
    ];

    # video/audio
    multimedia = [
      ffmpeg_7
      sox
      imagemagick
    ];

    # miscellaneous utilities
    utilities = [
      graphviz
      smartmontools
      colmena
      packwiz
      _1password-cli
    ];

    everything = base ++ languages ++ tooling ++ multimedia ++ utilities;
  };
in
{
  lib.skip.ergonomic =
    path:
    if (specialArgs.ergonomic or false) then
      let
        # since we're in a flake, paths will always point inside of the Nix store
        # regardless of whether we interpolate them or not, so just toString it
        # and extract out the path
        matches = (builtins.match "/nix/store/[a-zA-Z0-9_-]+/(.+)" (builtins.toString path));
        trimmedPath = builtins.head matches;
        reconstructedPath = "${specialArgs.ergonomicRepoPath}/${trimmedPath}";
      in
      config.lib.file.mkOutOfStoreSymlink reconstructedPath
    else
      path;

  imports = [
    ./neovim
    ./fish.nix
    ./git.nix
    ./linux
  ] ++ (lib.optional (!server) ./hh3.nix);

  # has to be here because of recursion :(
  nixpkgs.overlays = [
    (self: super: {
      swaylock = super.swaylock.overrideAttrs (prev: {
        patches = (prev.patches or [ ]) ++ [ ./linux/patches/swaylock-no_subpixel_antialiasing.patch ];
      });
    })
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  news = {
    display = "silent";
    json = lib.mkForce { };
    entries = lib.mkForce [ ];
  };

  home = {
    packages = if server then packagesets.base else packagesets.everything;

    sessionVariables =
      {
        EDITOR = editor;
        LESS = "--ignore-case";
        MANPAGER = "nvim +Man!";
        # let Neovim format the man page text, not groff - so we can wrap on
        # the fly
        # MANWIDTH = 999;
      }
      // (lib.optionalAttrs pkgs.stdenv.isDarwin {
        # when using git, use the system ssh so we can get keychain integration
        GIT_SSH = "/usr/bin/ssh";
      });
  };

  home.file.".hammerspoon".source = config.lib.skip.ergonomic ./hammerspoon;
  home.file.".prettierrc.json".source = ./prettierrc.json;
  home.file.".stylua.toml".source = ../.stylua.toml;
  xdg.configFile."kitty".source = config.lib.skip.ergonomic ./kitty;

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
