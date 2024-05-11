{
  description = "skip's machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

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
      self,
      flake-utils,
      darwin,
      nixpkgs,
      home-manager,
      fenix,
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
        modules = [ ./hosts/grape.nix ];
        specialArgs = {
          inherit inputs;
        };
      };
    };
}
