{
  description = "skip's machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, darwin, nixpkgs, home-manager, fenix }: {
    darwinConfigurations.dewey = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        # nix-darwin
        ./darwin/darwin.nix

        # home-manager
        home-manager.darwinModule

        # nix
        ({ pkgs, ... }: {
          nix.extraOptions = "experimental-features = nix-command flakes";
          nix.package = pkgs.nix;
          nix.registry.nixpkgs.flake = nixpkgs;
        })

        # fenix
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ fenix.overlay ];
          environment.systemPackages = [
            (pkgs.fenix.complete.withComponents [
              "cargo"
              "clippy"
              "rust-src"
              "rustc"
              "rustfmt"
            ])
            pkgs.rust-analyzer
          ];
        })
      ];

      inputs = { pkgs = nixpkgs; };
    };
  };
}
