{ config, pkgs, ... }:

let
  textEditor = "nvim"; # pretty good if you ask me
in
{
  imports = [
    ./fish.nix
    ./git.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    username = "slice";
    homeDirectory = "/Users/slice";

    packages = with pkgs; [ httpie ];

    sessionVariables = {
      EDITOR = textEditor;
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
