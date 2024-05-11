# Mac15,8

{ inputs, ... }:

{
  imports = [ ../modules/nix.nix ];

  # home-manager.users.slice = (import ../home/home.nix) { };
  services.nix-daemon.enable = true;

  environment.systemPackages = [ inputs.home-manager.packages.aarch64-darwin.home-manager ];

  # generate system-wide run commands for shells to setup the nix environment
  programs.fish.enable = true;

  system.stateVersion = 4;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
