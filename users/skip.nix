{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
  };

  users.users.skip = {
    isNormalUser = true; # "normal"
    description = "Skip Wolf Rousseau";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = (import ../lib/keys.nix).skip;
  };
}
