{
  description = "skip's machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jujutsu = {
      url = "github:martinvonz/jj";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
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
