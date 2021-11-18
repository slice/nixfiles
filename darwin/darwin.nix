{ config, pkgs, ... }:

{
  imports = [
    ./fixup_fish_paths.nix
  ];

  # The user account isn't managed by nix-darwin (accordingly, it's not in
  # users.knownUsers either), but I need to tell it that I exist.
  users.users.slice = {
    name = "slice";
    description = "Skip Rousseau";
    home = "/Users/slice";
  };

  home-manager.users.slice = import ../home/home.nix;

  # Most package should be specified with home-manager instead.
  environment.systemPackages = [];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Generate system-wide run commands for shells to setup the nix environment.
  # Typically though, run commands generated by home-manager are used instead.
  programs.zsh.enable = false; # Disabled for now.
                               # See: https://github.com/LnL7/nix-darwin/issues/373
  programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
