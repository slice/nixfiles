{ fenix }:

{ pkgs, ... }:

{
  nixpkgs.overlays = [ fenix.overlay ];
  environment.systemPackages = [
    (pkgs.fenix.complete.withComponents [
      "cargo" "clippy" "rust-src" "rustc" "rustfmt"
    ])
    pkgs.rust-analyzer
  ];
}
