{ pkgs, ... }:

{
  # so i don't have to run tic on all of my boxes
  environment.systemPackages = (
    map (pkg: pkg.terminfo) [
      pkgs.ghostty
      pkgs.kitty
      pkgs.alacritty
      pkgs.foot
      pkgs.st
      pkgs.tmux
    ]
  );
}
