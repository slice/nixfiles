{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
  };

  environment.systemPackages = [
    pkgs.ghostty.terminfo
    pkgs.kitty.terminfo
  ];

  users.users.skip = {
    description = "Skip Wolf Rousseau";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = (import ../lib/keys.nix).skip;
  };
}
