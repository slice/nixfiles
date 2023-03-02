{ nixpkgs }:

{ pkgs, ... }:

{
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"

      # A cache for a Haskell library for writing Discord bots: https://github.com/simmsb/calamity
      # Binaries exist for both x86_64-linux and aarch64-darwin.
      # "https://simmsb-calamity.cachix.org"
    ];

    trusted-public-keys = [
      "simmsb-calamity.cachix.org-1:CQsXXpwKsjSVu0BJFT/JSvy1j6R7rMSW2r3cRQdcuQM="
    ];
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.package = pkgs.nixVersions.stable;

  # register the `nixpkgs` flake to refer to the nixpkgs this flake is using
  # across the entire system. e.g., `nix shell nixpkgs#hello` would use the
  # same nixpkgs we are using.
  nix.registry.nixpkgs.flake = nixpkgs;
}
