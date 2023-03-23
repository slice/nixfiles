{ config, lib, pkgs, server, ... }:

{
  imports = [ ./sway.nix ./cursor.nix ./firefox.nix ];

  config = lib.mkIf (!server && pkgs.stdenv.isLinux) {
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

    fonts.fontconfig.enable = true;
    xdg.configFile."fontconfig/fonts.conf".source = ./fonts.conf;
  };
}
