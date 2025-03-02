{
  pkgs,
  lib,
  config,
  ...
}:

# stolen from https://tailscale.com/blog/nixos-minecraft

let
  cfg = config.skiptech.tailscale-auth;
in
{
  options = {
    skiptech.tailscale-auth = {
      enable = lib.mkEnableOption "Enable tailscale-auth";

      key = lib.mkOption {
        type = lib.types.str;
        description = "Tailscale auth key used to connect to tailnet, avoiding interactive login";
      };
    };
  };

  config = lib.mkIf cfg.enable {
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
