# `nixfiles`

This repository houses [Nix] code that is responsible for managing the
configuration and environment of my personal machines.

Mostly documented for my own sake.

[nix]: https://nixos.org
[home-manager]: https://github.com/nix-community/home-manager

## Bringup

<!-- prettier-ignore -->
> [!IMPORTANT]
> This procedure has only been tested on Apple silicon-based Macs.

1. Ensure that your local user metadata is correct. (This configuration
   currently requires that your username be `slice` and your user directory be
   `/Users/slice`. This should be made more flexible in the future.)

1. Install Nix via
   [the Determinate Nix Installer](https://determinate.systems/posts/determinate-nix-installer):

   ```
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

   The installer will describe what it intends to do before prompting you to
   continue. However, in general, it:

   - Creates a new APFS volume for the Nix store.
   - Creates and registers Launch Daemons that mount the volume and spawn the
     Nix daemon.
   - Downloads and unpacks Nix.
   - Creates Nix build users and groups.
   - Writes the necessary shell profiles to make Nix usable.

   The installer detects which shell you are invoking it from and only writes
   the environment bringup scripts necessary for that shell. Since I primarily
   use Fish and it's likely that the installer is being invoked from a bare Zsh
   shell, a [Fish plugin](https://github.com/lilyball/nix-env.fish) is used to
   handle this for us.

1. Clone this repository to `~/src/prj/nixfiles`. (As you might guess, this path
   is _also_ hardcoded. For now. Maybe.)

1. Pop open a fresh shell so the computer knows where `nix` lives. Then,
   bootstrap [Home Manager][home-manager]:

   ```
   nix run home-manager/master -- switch --flake ~/src/prj/nixfiles
   ```

1. Change your shell:

   ```
   sudo chsh -s ~/.nix-profile/bin/fish $USER
   ```

1. All done.

## Usage

This repository is a [flake] mostly because it makes pinning dependencies
easier. However, `flake.nix` doesn't do much; in fact, it can largely be boiled
down to:

[flake]: https://nixos.wiki/wiki/Flakes

```nix
outputs = inputs: {
  packages.aarch64-darwin.homeConfigurations.skip = import ./home/bootstrap.nix {
    inherit inputs;
    system = "aarch64-darwin";
    username = "skip";
  };

  packages.x86_64-linux.homeConfigurations.skip = import ./home/bootstrap.nix {
    inherit inputs;
    system = "x86_64-linux";
    username = "skip";
  };

  # ... etc. ...
};
```

To instantiate the `homeManagerConfiguration` outside of a flake context,
[`home/bootstrap.nix`] can be used like so:

```nix
import "${<nixfiles>}/home/bootstrap.nix" {
  system = "aarch64-darwin";
  inputs = {
    inherit nixpkgs home-manager; # etc.
  };
  server = "infer"; # all Macs are workstations
};
```

See that file for further details.
