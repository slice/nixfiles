{
  config,
  lib,
  pkgs,
  server,
  ...
}:

{
  imports = [
    ./sway.nix
    ./cursor.nix
    ./firefox.nix
  ];

  config = lib.mkIf (!server && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = with pkgs; [
      # desktop applications
      gimp
      pinta

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
      noto-fonts-cjk-sans
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
