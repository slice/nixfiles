# https://lix.systems/add-to-config/
#
# using the "advanced", overlay-based approach that is "more robust, as it uses
# an overlay to rewire other tools that depend on Nix, ensuring consistency
# across your setup"

{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];

  nix.package = pkgs.lixPackageSets.stable.lix;
}
