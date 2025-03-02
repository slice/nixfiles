{ ... }:

{
  imports = [
    ../mixins/homelab.nix
    ../modules/zfs.nix
    ./hardware/marco.nix
  ];

  networking = {
    hostName = "marco";
    hostId = "97e1661b";
  };

  skiptech.tailscale = {
    enable = true;
    key = "tskey-auth-kh445MYSE811CNTRL-3nrcDrACxkScCatNAoB8jSzF1XKZoGQ8K";
  };

  system.stateVersion = "24.11";
}
