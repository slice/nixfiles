{ config, lib, pkgs, server, ... }:

{
  config = lib.mkIf (!server && pkgs.stdenv.isLinux) {
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
  };
}
