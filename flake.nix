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
      hm = { system, specialArgs ? { }, username ? "slice"
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

          # I think importing `nixpkgs` here is bad, but we need unfree
          # packages, so ... *grumble grumble*
          pkgs = import nixpkgs {
            config.allowUnfree = true;
            inherit system;
          };

          extraSpecialArgs = specialArgs;
        };
    in {
      packages = {
        x86_64-linux.homeConfigurations.slice = hm {
          system = "x86_64-linux";
          specialArgs.server = true;
        };

        aarch64-linux.homeConfigurations.slice = hm {
          system = "aarch64-linux";
          specialArgs.server = true;
        };

        aarch64-linux.homeConfigurations.asahi = hm {
          system = "aarch64-linux";
          specialArgs.server = false;
        };

        aarch64-darwin.homeConfigurations.skip =
          let homeDirectory = "/Users/skip";
          in hm {
            system = "aarch64-darwin";
            username = "skip";
            specialArgs = {
              server = false;
              # build FFmpeg with libfdk-aac support
              customFFmpeg = true;

              # create out of store symlinks for neovim's configuration files
              # for faster editing
              ergonomic = true;
              ergonomicRepoPath = "${homeDirectory}/src/prj/nixfiles";
            };
            homeDirectory = homeDirectory;
          };

        aarch64-darwin.homeConfigurations.slice =
          let homeDirectory = "/Users/slice";
          in hm {
            system = "aarch64-darwin";
            specialArgs = {
              server = false;
              # build FFmpeg with libfdk-aac support
              customFFmpeg = true;

              # create out of store symlinks for neovim's configuration files
              # for faster editing
              ergonomic = true;
              ergonomicRepoPath = "${homeDirectory}/src/prj/nixfiles";
            };
            homeDirectory = homeDirectory;
          };
      };

      darwinConfigurations.vantage = (import ./hosts/vantage.nix) inputs;
    });
}
