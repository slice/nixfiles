{ ... }:

{
  imports = [
    ../mixins/homelab.nix
    ../modules/tailscale-autoconnect.nix
    ./hardware/marco.nix
  ];

  networking = {
    hostName = "marco";
    hostId = "97e1661b";
  };

  system.stateVersion = "24.11";

  skiptech.tailscale-auth = {
    enable = true;
    key = "tskey-auth-kh445MYSE811CNTRL-3nrcDrACxkScCatNAoB8jSzF1XKZoGQ8K";
  };
}
