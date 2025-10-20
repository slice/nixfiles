{
  system,
  inputs,
  username ? "skip",
  homeDirectory ? (
    if system == "aarch64-linux" || system == "x86_64-linux" then
      "/home/${username}"
    else
      "/Users/${username}"
  ),
  specialArgs ? { },
  server ? "infer",
}:

let
  inherit (inputs) home-manager nixpkgs;
  inherit (nixpkgs) lib;

  isLinux = system == "x86_64-linux" || system == "aarch64-linux";
  isDarwin = system == "aarch64-darwin" || system == "x86_64-darwin";

  serverResolved = if server == "infer" then isLinux else server;
  nixpkgsOptions = {
    config.allowUnfree = true;
    inherit system;
  };
in
home-manager.lib.homeManagerConfiguration {
  modules = [
    ./home.nix
    (
      { ... }:
      {
        home.username = username;
        home.homeDirectory = homeDirectory;
      }
    )
  ];

  # see: https://zimbatm.com/notes/1000-instances-of-nixpkgs
  # do we _need_ to do this? maybe as long as we only do it once (here), it's ok.
  pkgs = import nixpkgs nixpkgsOptions;

  extraSpecialArgs =
    let
      workstationArgs = {
        # creates out-of-store symlinks for some configs so you don't
        # constantly incur the overhead of a nix build
        ergonomic = true;
        ergonomicRepoPath = "${homeDirectory}/src/prj/nixfiles";
      };
    in
    {
      # always forward flake inputs
      inherit inputs;
      server = serverResolved;
    }
    // (lib.optionalAttrs (!serverResolved) workstationArgs)
    // specialArgs;
}
