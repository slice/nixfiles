# nixfiles

I manage the configuration of all of my machines with [the Nix package
manager][nix]. Here, you'll find the code to those configurations.

[nix-darwin] and [NixOS] are used to handle the system-wide configuration of any
Macs and Linux servers I manage, respectively. [home-manager] integrates with
both platforms, which is used to handle user-local configuration, packages, and
environment.

[nixos]: https://nixos.org
[nix]: https://github.com/NixOS/nix
[nix-darwin]: https://github.com/LnL7/nix-darwin
[home-manager]: https://github.com/nix-community/home-manager

## Contents

This repository is a [flake][flakes]. Right now, I export the main configuration
for my Mac through the `darwinConfigurations.dewey` output. I have elected not
to publish my NixOS configurations here (for now).

My home-manager configuration is exported as
`packages."<system>".homeConfigurations.slice`, which can be used with the
`home-manager` CLI tool.

- [`home/`](https://github.com/slice/nixfiles/tree/main/home): home-manager
  configuration. My "dotfiles".
- [`darwin/`](https://github.com/slice/nixfiles/tree/main/darwin): nix-darwin
  configuration. Doesn't do much.

[flakes]: https://nixos.wiki/wiki/Flakes
