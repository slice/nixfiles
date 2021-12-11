{ nixpkgs }:

{ pkgs, ... }:

{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.package = pkgs.nix;

  # register the `nixpkgs` flake to refer to the nixpkgs this flake is using
  # across the entire system. e.g., `nix shell nixpkgs#hello` would use the
  # same nixpkgs we are. however, `nix-shell` would not.
  nix.registry.nixpkgs.flake = nixpkgs;
}
