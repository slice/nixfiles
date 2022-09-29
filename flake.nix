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

  outputs = { self, darwin, nixpkgs, home-manager, fenix, ... }@inputs:
    (let
      hm = { system, server ? false, username ? "slice"
        , homeDirectory ? "/home/slice" }:
        home-manager.lib.homeManagerConfiguration {
          modules = [
            ./home/home.nix
            ./modules/hh3.nix
            ({ ... }: {
              home.username = username;
              home.homeDirectory = homeDirectory;
            })
          ];
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit server; };
        };
    in {
      packages = {
        x86_64-linux.homeConfigurations.slice = hm {
          system = "x86_64-linux";
          server = true;
        };

        aarch64-linux.homeConfigurations.slice = hm {
          system = "aarch64-linux";
          server = true;
        };

        aarch64-darwin.homeConfigurations.slice = hm {
          system = "aarch64-darwin";
          server = false;
        };
      };

      darwinConfigurations.dewey = (import ./hosts/dewey.nix) inputs;
    });
}
