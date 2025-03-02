{
  pkgs,
  lib,
  config,
  ...
}:

# stolen from https://tailscale.com/blog/nixos-minecraft

let
  cfg = config.skiptech.tailscale;
in
{
  options = {
    skiptech.tailscale = {
      enable = lib.mkEnableOption "Enable Tailscale with automatic auth";

      key = lib.mkOption {
        type = lib.types.str;
        description = "Tailscale auth key used to connect to tailnet, avoiding interactive login";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # make tailscale CLI available to all users
    environment.systemPackages = [
      pkgs.tailscale
    ];

    services.tailscale = {
      enable = true;
      # exit node
      useRoutingFeatures = "server";
    };

    # needed (?) for exit node
    # https://github.com/tailscale/tailscale/issues/4432#issuecomment-1112819111
    networking.firewall.checkReversePath = "loose";

    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      after = [
        "network-pre.target"
        "tailscale.service"
      ];
      wants = [
        "network-pre.target"
        "tailscale.service"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";

      script =
        let
          inherit (pkgs) tailscale jq;
        in
        ''
          # wait for tailscaled to settle
          sleep 2

          # check if we are already authenticated to tailscale
          status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
          if [ $status = "Running" ]; then # if so, then do nothing
            exit 0
          fi

          # otherwise authenticate with tailscale
          ${tailscale}/bin/tailscale up -authkey ${lib.escapeShellArg cfg.key}
        '';
    };
  };
}
