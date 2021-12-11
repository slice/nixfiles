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
      hmConfig = {
        configuration.imports = [ ./home/home.nix ];
        extraModules = [ ./modules/hh3.nix ];
      };
    in {
      packages = {
        x86_64-linux.homeConfigurations.slice =
          home-manager.lib.homeManagerConfiguration (hmConfig // {
            system = "x86_64-linux";
            username = "slice";
            homeDirectory = "/home/slice";
            extraSpecialArgs = { server = true; };
            # needed to avoid a conflict; see https://github.com/nix-community/home-manager/issues/2073
            stateVersion = "21.05";
          });
        aarch64-darwin.homeConfigurations.slice =
          home-manager.lib.homeManagerConfiguration (hmConfig // {
            system = "aarch64-darwin";
            username = "slice";
            homeDirectory = "/Users/slice";
            extraSpecialArgs = { server = false; };
            # ditto
            stateVersion = "21.05";
          });
      };

      darwinConfigurations.dewey = (import ./hosts/dewey.nix) inputs;
    });
}
