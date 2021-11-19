# nixfiles

I manage the configuration of my machines with [the Nix package manager][nix].
Here, you'll find the code to those configurations.

[nix-darwin] and [NixOS] are used to handle the system-wide configuration of any
Macs and Linux servers I manage, respectively. [home-manager] integrates with
both of those, which is used to handle user-local configuration and packages.

[nixos]: https://nixos.org
[nix]: https://github.com/NixOS/nix
[nix-darwin]: https://github.com/LnL7/nix-darwin
[home-manager]: https://github.com/nix-community/home-manager

## Contents

This repository is a [flake][flakes]. NixOS and nix-darwin systems are exported
within `nixosConfigurations` and `darwinConfigurations`, respectively.
home-manager configurations are additionally exported within
`homeManagerConfigurations` for use in systems that are not configured through
this repository.

- [`home/`](https://github.com/slice/nixfiles/tree/main/home): home-manager
  configuration. My "dotfiles".
- [`darwin/`](https://github.com/slice/nixfiles/tree/main/darwin): nix-darwin
  configuration. Doesn't do much.

[flakes]: https://nixos.wiki/wiki/Flakes
