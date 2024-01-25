# `nixfiles`

This repository houses [Nix] code that is responsible for managing the
configuration and environment of my personal machines.

[nix]: https://nixos.org

## Bringup

> [!IMPORTANT]
> This procedure has only been tested on Apple silicon-based Macs.

1. Ensure that your local user metadata is correct. (This configuration
   currently requires that your username be `slice` and your user directory be
   `/Users/slice`. This should be made more flexible in the future.)

1. Install Nix via [the Determinate Nix Installer](https://determinate.systems/posts/determinate-nix-installer):

   ```
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

   The installer will describe what it intends to do before prompting you to
   continue. However, in general, it:

   - Creates a new APFS volume to house the Nix store.
   - Creates and registers Launch Daemons that mount the volume and spawn the Nix daemon.
   - Downloads and unpacks Nix.
   - Creates Nix build users and groups.
   - Writes the necessary shell profiles to make Nix usable.

   The installer detects which shell you are invoking it from and only writes
   the environment bringup scripts necessary for that shell. Since we primarily
   use Fish and it's likely that we are invoking this from a bare Zsh shell, a
   [Fish plugin](https://github.com/lilyball/nix-env.fish) is used to handle
   this for us.

1. Clone this repository to `~/src/prj/nixfiles`. (As you might guess, this
   path is _also_ hardcoded. For now. Maybe.)

1. Pop open a fresh shell so the computer knows where `nix` lives. Then,
   bootstrap `home-manager`:

   ```
   nix run home-manager/master -- switch --flake ~/src/prj/nixfiles
   ```

   (The use of `nix-darwin` is being phased out.)

1. Change your shell:

   ```
   sudo chsh -s /Users/slice/.nix-profile/bin/fish slice
   ```

1. All done.
