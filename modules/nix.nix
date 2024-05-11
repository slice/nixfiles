{
  lib,
  inputs,
  pkgs,
  ...
}:

{
  nix.settings = {
    experimental-features = "nix-command flakes repl-flake";
    trusted-users = [
      "@staff"
      "root"
    ];
  };

  # Nix >= 2.18 is broke as hell!!! (Colmena doesn't like it either)
  nix.package = pkgs.nixVersions.nix_2_18;

  # Ensure that the "nixpkgs" flake reference and nixpkgs in $NIX_PATH point to
  # the same instance of Nixpkgs. The end result is that "nix run" and "nix-shell"
  # give the same results (in theory).
  # See: https://github.com/NixOS/nixpkgs/pull/254405
  nix.registry.nixpkgs.to = {
    type = "path";
    path = inputs.nixpkgs.outPath;
  };
  nix.nixPath = lib.mkForce [ { nixpkgs = "flake:nixpkgs"; } ];
}
