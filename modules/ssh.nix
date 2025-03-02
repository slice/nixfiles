{ ... }:

let
  skip = (import ../lib/keys.nix).skip;
in
{
  # ssh during initrd for rescue, killed when stage-1 completes
  boot.initrd.network.ssh = {
    enable = true;
    authorizedKeys = skip;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
