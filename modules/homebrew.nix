{ inputs, ... }:

# https://github.com/zhaofengli/nix-homebrew
{
  imports = [
    (inputs.nix-homebrew.darwinModules.nix-homebrew)
  ];

  # https://github.com/zhaofengli/nix-homebrew
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "skip";
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
    autoMigrate = true;
  };
}
