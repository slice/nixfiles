{ ... }:

# server in my house
{
  imports = [
    ../modules/systemd-boot.nix
    ../modules/locale.nix
    ../modules/firewall.nix
    ../modules/sudo.nix
    ../users/skip.nix
  ];
}
