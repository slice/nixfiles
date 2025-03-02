let
  # 2025-03-02 (24.11)
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/5ef6c425980847c78a80d759abc476e941a9bf42.tar.gz";
in
{
  meta = {
    nixpkgs = import nixpkgs {
      config.allowUnfree = true;
    };
  };

  defaults =
    { ... }:
    {
      imports = [
        ./modules/handy.nix
        ./modules/ssh.nix
        ./modules/tailscale.nix
        ./modules/terminfo.nix
      ];
    };

  marco =
    { ... }:
    {
      deployment.tags = [ "homelab" ];

      imports = [
        ./machines/marco.nix
      ];
    };

  # TODO: polo
}
