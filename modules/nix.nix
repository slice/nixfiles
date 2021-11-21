{ nixpkgs }:

{ pkgs, ... }:

{
  nix.extraOptions = "experimental-features = nix-command flakes";
  nix.package = pkgs.nix;
  nix.registry.nixpkgs.flake = nixpkgs;
}
