{ fenix }:

{ pkgs, ... }:

{
  nixpkgs.overlays = [ fenix.overlay ];
  environment.systemPackages = with pkgs.fenix.stable; [
    cargo
    clippy
    rustc
    rust-src
    rustfmt
    pkgs.rust-analyzer
  ];
}
