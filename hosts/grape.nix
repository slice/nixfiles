# Mac15,8

{ inputs, ... }:

{
  imports = [ ../modules/nix.nix ];

  # home-manager.users.slice = (import ../home/home.nix) { };

  environment.systemPackages = [ inputs.home-manager.packages.aarch64-darwin.home-manager ];

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "skip";
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
  };

  # generate system-wide run commands for shells to setup the nix environment
  programs.fish.enable = true;

  system.stateVersion = 4;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
