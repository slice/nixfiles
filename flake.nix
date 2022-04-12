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
      baseHomeConfig = {
        configuration.imports = [ ./home/home.nix ];
        extraModules = [ ./modules/hh3.nix ];
      };

      hm = { system, username ? "slice", homeDirectory ? "/home/slice"
        , server ? false }:
        home-manager.lib.homeManagerConfiguration (baseHomeConfig // {
          inherit username system homeDirectory;
          extraSpecialArgs = { inherit server; };
          stateVersion = "21.05";
        });
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
