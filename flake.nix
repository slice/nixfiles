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

    bloodbath = {
      url = "github:slice/bloodbath";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, darwin, nixpkgs, home-manager, fenix, ... }@inputs: {
    packages = {
      aarch64-darwin.homeConfigurations.slice =
        home-manager.lib.homeManagerConfiguration {
          system = "aarch64-darwin";
          username = "slice";
          homeDirectory = "/Users/slice";
          configuration.imports = [ ./home/home.nix ];
          extraModules = [ ./modules/hh3.nix ];
          extraSpecialArgs = { server = false; };
          # needed to avoid a conflict; see https://github.com/nix-community/home-manager/issues/2073
          stateVersion = "21.05";
        };
    };

    darwinConfigurations.dewey = (import ./hosts/dewey.nix) inputs;
  };
}
