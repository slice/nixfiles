{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.cachix
    pkgs.colmena
    pkgs.croc
    pkgs.curl
    pkgs.fd
    pkgs.file
    pkgs.htop
    pkgs.jq
    pkgs.killall
    pkgs.neovim
    pkgs.niv
    pkgs.rclone
    pkgs.ripgrep
    pkgs.rlwrap
    pkgs.rsync
    pkgs.smartmontools
    pkgs.tree
    pkgs.unzip
    pkgs.wget
  ];
}
