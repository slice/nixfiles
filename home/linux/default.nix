{ config, lib, pkgs, specialArgs, ... }:

{
  imports = [ ./sway.nix ./cursor.nix ];

  config = lib.mkIf (!specialArgs.server && pkgs.stdenv.isLinux) {
    fonts.fontconfig.enable = true;

    programs.firefox = {
      enable = true;
      profiles.default = {
        search = {
          default = "Google";
          engines = {
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }];

              icon =
                "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "Bing".metaData.hidden = true;
            "Amazon.com".metaData.hidden = true;
            "eBay".metaData.hidden = true;
          };

          force = true;
          order = [ "Google" "DuckDuckGo" ];
        };
        settings = let mouseWheelMultiplier = 30;
        in {
          "mousewheel.default.delta_multiplier_x" = mouseWheelMultiplier;
          "mousewheel.default.delta_multiplier_y" = mouseWheelMultiplier;
          "mousewheel.default.delta_multiplier_z" = mouseWheelMultiplier;
          "browser.compactmode.show" = true;
        };
      };
    };

    home.packages = with pkgs; [
      # desktop applications
      gimp
      pinta
      (let
        pristineXdgOpen = runCommandWith {
          name = "pristine-xdg-open";
          derivationArgs.nativeBuildInputs = [ makeWrapper ];
        } ''
          # Wrap xdg-open, unsetting `LD_LIBRARY_PATH` becuase it's used by
          # the `armcord` package to inject libraries at runtime; these conflict
          # with Firefox, etc.
          makeWrapper ${xdg-utils}/bin/xdg-open $out/bin/xdg-open \
            --unset LD_LIBRARY_PATH
        '';
      in armcord.overrideAttrs (final: prev: {
        postInstall = ''
          makeWrapper $out/bin/armcord $out/bin/armcord-good \
            --append-flags "--ozone-platform-hint=auto" \
            --prefix PATH : "${pristineXdgOpen}/bin"
        '';
      }))

      # toolchains, development
      cargo
      rustc
      openssl
      # pkg-config
      # gnumake

      # utilities
      wl-clipboard
      xdg-utils
      alsa-utils
      pavucontrol
      pulseaudio
      light
      slurp
      grim
      swayimg
      wev

      # fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      paratype-pt-sans
      source-serif
      source-sans
      source-han-sans
      source-han-serif
      source-code-pro
    ];

    xdg.configFile."fontconfig/fonts.conf".source = ./fonts.conf;
  };
}
