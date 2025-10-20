# `nixfiles`

[Nix] code that is responsible for managing the configuration and environment of
my personal machines.

Mostly documented for my own sake. I am trapped in a prison of my own design.

[nix]: https://nixos.org
[home-manager]: https://github.com/nix-community/home-manager
[nix-darwin]: https://github.com/LnL7/nix-darwin

## Bringup

<!-- prettier-ignore -->
> [!WARNING]
> This procedure has only been tested on Macs with Apple silicon.

<!-- prettier-ignore -->
> [!IMPORTANT]
> [nix-darwin] configurations will only work if your hostname matches a
> corresponding configuration in [`flake.nix`](./flake.nix).

1. Install Nix. Let's use [Lix](https://lix.systems/):

   ```
   curl -sSf -L https://install.lix.systems/lix | sh -s -- install
   ```

   The installer will describe what it intends to do before prompting you to
   continue. However, in general, it:
   - Creates a new APFS volume for the Nix store.
   - Creates and registers Launch Daemons that mount the volume and spawn the
     Nix daemon.
   - Downloads and unpacks Nix.
   - Creates Nix build users and groups.
   - Writes the necessary shell profiles to make Nix usable.

1. Clone this repository to `~/src/prj/nixfiles`. (As you might guess, this path
   is also hardcoded. For now. Maybe.)

1. Pop open a fresh shell so the computer knows where `nix` lives. Then,
   bootstrap [Home Manager][home-manager]:

   ```
   nix run home-manager/master -- switch --flake ~/src/prj/nixfiles
   ```

   and [nix-darwin] (substitute `HOSTNAME` as appropriate):

   ```sh
   nix build ~/src/prj/nixfiles#darwinConfigurations.HOSTNAME.system --verbose
   sudo ./result/sw/bin/darwin-rebuild switch --flake ~/src/prj/nixfiles
   unlink result
   ```

   You will likely have to mess with some files in `/etc` to let nix-darwin
   manage the environment. Also note that this will explode if [Homebrew](https://brew.sh/)
   has already been installed, because [nix-homebrew](https://github.com/zhaofengli/nix-homebrew) is being used.

1. Change your shell:

   ```
   sudo chsh -s ~/.nix-profile/bin/fish $USER
   ```

1. If you set up nix-darwin, then you probably have
   [two Nix installations](https://github.com/LnL7/nix-darwin/issues/931) now,
   which needs to be fixed.

   This can be accomplished by removing the Nix that was used to
   bootstrap, which basically boils down to uninstalling a package from
   `root`'s user environment:

   ```sh
   sudo nix-env --uninstall lix-2.93.0
   ```

   (Nix is required to bootstrap nix-darwin, but nix-darwin essentially acts as
   a Nix installation in and of itself by managing a Nix daemon for you.
   Furthermore, a nix-darwin module is used to version-manage Nix, which will
   conflict with the Nix binary that was previously used to bootstrap this
   entire setup.)

   Guidance:
   - Use `nix doctor` to verify that you don't have conflicting `nix` binaries
     in your `PATH`.
   - Use `launchctl` to ensure that you only have a single Nix daemon (e.g.
     `launchctl print system`, `launchctl disable system/…`, etc.)

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
[`home/bootstrap.nix`](./home/bootstrap.nix) can be used like so:

```nix
import "${<nixfiles>}/home/bootstrap.nix" {
  system = "aarch64-darwin";
  inputs = {
    inherit nixpkgs home-manager; # etc.
  };
  server = "infer"; # all Macs are workstations
};
```

Check out that file for more details.
