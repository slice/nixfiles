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

  outputs = { self, darwin, nixpkgs, home-manager, fenix, ... } @ inputs:
    {
      homeManagerConfigurations.skip = import ./home/home.nix;
      darwinConfigurations.dewey = (import ./hosts/dewey.nix) inputs;
      nixosConfigurations.mallard = (import ./hosts/mallard.nix) inputs;
    };
}
