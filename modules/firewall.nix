{ ... }:

{
  # always trust traffic from tailscale
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
