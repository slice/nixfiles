{
  config,
  pkgs,
  lib,
  server,
  ...
}:

let
  palette = {
    pink = "#da9595";
    red = "#cd7070";
    black = "#000000";
    foreground = "#cccccc";
    lightGray = "#404040";
    midGray = "#333333";
    darkGray = "#262626";
  };
in
{
  config = lib.mkIf (!server && pkgs.stdenv.isLinux) {
    # since we're applying an overlay, make sure we build the patch and make
    # the resulting, patched binary available
    home.packages = [ pkgs.swaylock ];

    services.swayidle =
      let
        lockCommand = "${pkgs.swaylock}/bin/swaylock";
      in
      {
        enable = true;
        events = [
          {
            event = "before-sleep";
            command = lockCommand;
          }
          {
            event = "lock";
            command = lockCommand;
          }
        ];
        timeouts =
          let
            minutes = minutes: minutes * 60;
          in
          [
            {
              timeout = minutes 3;
              command = lockCommand;
            }
            {
              timeout = minutes 10;
              command = ''swaymsg "output * power off"'';
              resumeCommand = ''swaymsg "output * power on"'';
            }
          ];
      };

    programs.swaylock.settings = {
      color = "#808080";
      font = "PT Sans";
      font-size = 24;
      show-failed-attempts = true;
      show-keyboard-layout = true;
    };

    wayland.windowManager.sway = {
      enable = true;

      # NixOS also has a file in `/etc/sway/config.d` that performs the
      # equivalent of what enabling this `home-manager` option does.
      systemdIntegration = true;

      config = {
        modifier = "Mod4";

        input."type:touchpad".natural_scroll = "enabled";
        input."type:keyboard" = {
          xkb_options = "caps:escape";
          repeat_delay = "250";
          repeat_rate = "40";
        };

        defaultWorkspace = "1:work";

        output."*".bg = "~/walls/boys.png fill";
        output."eDP-1" = {
          subpixel = "none";
          scale = "2";
        };

        fonts = {
          names = [ "PragmataPro Mono" ];
          style = "Regular";
          size = 8.5;
        };

        colors.focused = rec {
          background = palette.pink;
          border = palette.red;
          childBorder = border;
          text = palette.black;
          indicator = palette.red;
        };
        colors.unfocused = rec {
          background = palette.darkGray;
          border = palette.midGray;
          childBorder = border;
          text = palette.foreground;
          indicator = palette.red;
        };
        colors.focusedInactive = rec {
          background = palette.midGray;
          border = palette.lightGray;
          childBorder = border;
          text = palette.foreground;
          indicator = palette.red;
        };

        keybindings =
          let
            cfg = config.wayland.windowManager.sway;
            mod = cfg.config.modifier;
          in
          {
            "XF86MonBrightnessUp" = "exec sudo light -A 1%";
            "XF86MonBrightnessDown" = "exec sudo light -U 1%";
            "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -3%";
            "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +3%";
            "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "XF86Search" = "exec ~/.local/bin/snap";

            "${mod}+Return" = "exec foot";
            "${mod}+q" = "exec kill $(swaymsg -t get_tree | jq '.. | select(.type?) | select(.focused).pid')";
            "${mod}+Shift+q" = "kill";
            "${mod}+d" = "exec ${cfg.config.menu}";

            # Reloading
            "${mod}+Shift+c" = "reload";
            "${mod}+Shift+e" = ''
              exec \
                swaynag -t warning \
                -m 'really exit and kill all programs?' \
                -B 'yes, exit' 'swaymsg exit' \
                -s "don't"
            '';

            # Moving focus:
            "${mod}+${cfg.config.left}" = "focus left";
            "${mod}+${cfg.config.right}" = "focus right";
            "${mod}+${cfg.config.up}" = "focus up";
            "${mod}+${cfg.config.down}" = "focus down";
            "${mod}+a" = "focus parent";
            "${mod}+Shift+a" = "focus child";

            # Moving containers:
            "${mod}+Shift+${cfg.config.left}" = "move left";
            "${mod}+Shift+${cfg.config.right}" = "move right";
            "${mod}+Shift+${cfg.config.up}" = "move up";
            "${mod}+Shift+${cfg.config.down}" = "move down";

            # Splitting. Inverted to match Vim:
            "${mod}+b" = "splitv";
            "${mod}+v" = "splith";

            # Layouts and fullscreen:
            "${mod}+s" = "layout stacking";
            "${mod}+w" = "layout tabbed";
            "${mod}+e" = "layout toggle split";
            "${mod}+f" = "fullscreen toggle";
            "${mod}+Shift+space" = "floating toggle";
            "${mod}+space" = "focus mode_toggle";

            # Switching between workspaces:
            "${mod}+1" = "workspace 1:work";
            "${mod}+2" = "workspace 2:web";
            "${mod}+3" = "workspace 3:chat";
            "${mod}+4" = "workspace number 4";
            "${mod}+5" = "workspace number 5";
            "${mod}+6" = "workspace number 6";
            "${mod}+7" = "workspace number 7";
            "${mod}+8" = "workspace number 8";
            "${mod}+9" = "workspace number 9";

            # Moving containers between workspaces:
            "${mod}+Shift+1" = "move container to workspace 1:work";
            "${mod}+Shift+2" = "move container to workspace 2:web";
            "${mod}+Shift+3" = "move container to workspace 3:chat";
            "${mod}+Shift+4" = "move container to workspace number 4";
            "${mod}+Shift+5" = "move container to workspace number 5";
            "${mod}+Shift+6" = "move container to workspace number 6";
            "${mod}+Shift+7" = "move container to workspace number 7";
            "${mod}+Shift+8" = "move container to workspace number 8";
            "${mod}+Shift+9" = "move container to workspace number 9";

            # Scratchpad:
            "${mod}+Shift+minus" = "move scratchpad";
            "${mod}+minus" = "scratchpad show";

            "${mod}+r" = "mode resize";
          };

        bars = [
          {
            position = "top";
            fonts = {
              names = [ "PragmataPro" ];
              style = "Regular";
              size = 10.0;
            };
            colors = {
              statusline = palette.foreground;
              background = palette.black;
              inactiveWorkspace = {
                background = palette.darkGray;
                border = palette.midGray;
                text = palette.foreground;
              };
              focusedWorkspace = {
                background = palette.pink;
                border = palette.red;
                text = palette.black;
              };
            };
            statusCommand = "while date +'%a, %b %d %Y %I:%M:%S %p'; do sleep 1; done";
          }
        ];
      };

      extraConfig = ''
        smart_borders on
        default_border pixel 1
        default_floating_border pixel 3
        titlebar_padding 4 2
      '';
    };
  };
}
