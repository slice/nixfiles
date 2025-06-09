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

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
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
    { flake-utils, darwin, ... }@inputs:
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
        ];
        specialArgs = { inherit inputs; };
      };

      darwinConfigurations.starfruit = darwin.lib.darwinSystem {
        modules = [
          ./hosts/grape.nix
          (
            { ... }:
            {
              # i don't remember how, but nixbld got a pretty high gid here:
              #
              # $ id _nixbld1
              # uid=351(_nixbld1) gid=350(nixbld) groups=350(nixbld),…
              ids.gids.nixbld = 350;
            }
          )
        ];
        specialArgs = { inherit inputs; };
      };
    };
}
