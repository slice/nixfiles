# https://lix.systems/add-to-config/
#
# using the "advanced", overlay-based approach that is "more robust, as it uses
# an overlay to rewire other tools that depend on Nix, ensuring consistency
# across your setup"

{ pkgs, ... }:

let
  lixVersion = "latest";
in
{
  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.lixPackageSets.${lixVersion})
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];

  nix.package = pkgs.lixPackageSets.${lixVersion}.lix;
}
