{ nixpkgs }:

{ pkgs, ... }:

{
  nix.settings = { trusted-users = [ "slice" ]; };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.package = pkgs.nixVersions.stable;

  # register the `nixpkgs` flake to refer to the nixpkgs this flake is using
  # across the entire system. e.g., `nix shell nixpkgs#hello` would use the
  # same nixpkgs we are using.
  nix.registry.nixpkgs.flake = nixpkgs;
}
