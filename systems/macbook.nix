# Mac15,8

{ inputs, ... }:

{
  imports = [
    ../modules/nix.nix
    ../modules/darwin/homebrew.nix
    ../modules/darwin/pam.nix

    # https://lix.systems
    (inputs.lix-module.nixosModules.default)
  ];

  environment.systemPackages = [
    inputs.home-manager.packages.aarch64-darwin.home-manager
  ];

  # global rcs to setup the nix environment in all shells
  programs.fish.enable = true;

  system.stateVersion = 4;
}
