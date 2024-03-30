{ nixpkgs }:

{ pkgs, ... }:

{
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "slice" ];
  };

  nix.package = pkgs.nixVersions.nix_2_21;

  # see: https://github.com/NixOS/nixpkgs/pull/254405
  nix.registry.nixpkgs.to = {
    type = "path";
    path = nixpkgs.outPath;
  };
  nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
}
