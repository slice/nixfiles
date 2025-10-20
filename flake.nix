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

    # Lix 2.93 "Bici Bici" (released 2025-05-06)
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.3-2.tar.gz";
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
        modules = [ ./systems/macbook.nix ];
        specialArgs = { inherit inputs; };
      };

      darwinConfigurations.starfruit = darwin.lib.darwinSystem {
        modules = [
          ./systems/macbook.nix
          (
            { ... }:
            {
              # i don't remember how, but nixbld has a pretty high gid on this
              # machine:
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
