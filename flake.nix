{
  description = "skip's machines";

  inputs = {
    # https://github.com/NixOS/nixpkgs/issues/335533
    nixpkgs.url = "github:nixos/nixpkgs/0cb2fd7c59fed0cd82ef858cbcbdb552b9a33465";

    flake-utils.url = "github:numtide/flake-utils";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
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

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      flake-utils,
      darwin,
      lix-module,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        bootstrap = opts: import ./home/bootstrap.nix ({ inherit system inputs; } // opts);
      in
      {
        packages.homeConfigurations.slice = bootstrap { username = "slice"; };
        packages.homeConfigurations.skip = bootstrap { username = "skip"; };
      }
    )
    // {
      darwinConfigurations.grape = darwin.lib.darwinSystem {
        modules = [
          ./hosts/grape.nix
          lix-module.nixosModules.default
        ];
        specialArgs = {
          inherit inputs;
        };
      };

      darwinConfigurations.starfruit = darwin.lib.darwinSystem {
        modules = [
          ./hosts/grape.nix
          lix-module.nixosModules.default
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };
}
