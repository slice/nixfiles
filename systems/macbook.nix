# Mac15,8

{ inputs, ... }:

{
  imports = [
    ../modules/nix.nix

    # https://github.com/zhaofengli/nix-homebrew
    (inputs.nix-homebrew.darwinModules.nix-homebrew)

    # https://lix.systems
    (inputs.lix-module.nixosModules.default)
  ];

  environment.systemPackages = [
    inputs.home-manager.packages.aarch64-darwin.home-manager
  ];

  # /etc/pam.d/sudo_local
  # "auth       sufficient     pam_tid.so"
  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };

  # https://github.com/zhaofengli/nix-homebrew
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "skip";
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
    autoMigrate = true;
  };

  # global rcs to setup the nix environment in all shells
  programs.fish.enable = true;

  system.stateVersion = 4;
}
