{ pkgs, lib, ... }:

{
  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "repl"
      ];

      # keep outputs of non-garbage drvs
      keep-outputs = true;
      # keep drvs from which non-garbage store paths are built
      keep-derivations = true;

      extra-substituters = [
        "https://cache.lix.systems"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    # ensure "nixpkgs" in flake registry points to the pinned version
    # may be unnecessary
    # (https://github.com/NixOS/nixpkgs/pull/254405)
    registry.nixpkgs.to = {
      type = "path";
      path = pkgs.outPath;
    };
    nixPath = lib.mkForce [ { nixpkgs = "flake:nixpkgs"; } ];
  };
}
