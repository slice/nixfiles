{
  description = "skip's machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # for nixd
    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { flake-utils, darwin, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        bootstrapHome = opts: import ./home/bootstrap.nix ({ inherit system inputs; } // opts);
      in
      {
        # home-manager configurations are exported separately (i.e. not tied to
        # nix-darwin) so that:
        #
        # 1) i can easily import it from linux, or otherwise externally consume
        #    it elsewhere. (good modularity)
        # 2) i don't have to `switch` nix-darwin even if i just want to `switch`
        #    home-manager
        packages.homeConfigurations.slice = bootstrapHome { username = "slice"; };
        packages.homeConfigurations.skip = bootstrapHome { username = "skip"; };
      }
    )
    # darwin configurations don't live under `.${system}` attrset matrix
    // {
      darwinConfigurations.grape = darwin.lib.darwinSystem {
        modules = [
          ./systems/macbook.nix

          # wiped 2026-02-13; downgraded from tahoe to sequoia
          (
            { ... }:
            {
              system.stateVersion = 6;
            }
          )
        ];
        specialArgs = { inherit inputs; };
      };

      darwinConfigurations.starfruit = darwin.lib.darwinSystem {
        modules = [
          ./systems/macbook.nix
          (
            { ... }:
            {
              system.stateVersion = 4;
              ids.gids.nixbld = 350;
            }
          )
        ];
        specialArgs = { inherit inputs; };
      };
    };
}
