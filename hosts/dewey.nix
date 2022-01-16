# MacBookAir10,1

{ darwin, home-manager, fenix, nixpkgs, ... }:

let
  patchedNixpkgs = import nixpkgs {
    system = "aarch64-darwin";
    overlays = [
      ((final: prev: {
        haskell = prev.haskell // {
          packages = prev.haskell.packages // {
            ghc8107 = prev.haskell.packages.ghc8107.override {
              ghc = prev.haskell.compiler.ghc8107.overrideAttrs (old: {
                patches = (old.patches or [ ]) ++ [
                  (final.fetchpatch {
                    url =
                      "https://gist.githubusercontent.com/slice/cc43a5061db7a8da2660d81c60030672/raw/ce96c41e5ee041f9b27b32be3353c3bb6e81cc00/fix_terminfo_ghc8107_aarch64_apple_darwin.patch";
                    sha256 = "5WlMuauNgdDqoTbdr9sTb3PI59/Rvb7jTz31JjWAFXg=";
                  })
                ];
              });
            };
          };
        };
      }))
    ];
  };
in darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    ({ ... }: {
      users.users.slice = {
        name = "slice";
        description = "Skip Rousseau";
      };

      # home-manager.users.slice = (import ../home/home.nix) { };
      services.nix-daemon.enable = true;

      environment.systemPackages = [
        home-manager.packages.aarch64-darwin.home-manager
        # (patchedNixpkgs.haskell.packages.ghc8107.ghcWithPackages
        #   (haskellPackages:
        #     with haskellPackages; [
        #       Cabal_3_6_2_0
        #       pretty-simple
        # ]))
      ];

      # generate system-wide run commands for shells to setup the nix environment.
      # typically though, run commands generated by home-manager are used instead.
      programs.fish.enable = true;
      # zsh integration is disabled for now.
      # see: https://github.com/lnl7/nix-darwin/issues/373
      programs.zsh.enable = false;

      system.stateVersion = 4;
    })

    (import ../modules/nix.nix { inherit nixpkgs; })
    (import ../modules/fenix.nix { inherit fenix; })
  ];
  inputs = { pkgs = patchedNixpkgs; };
}