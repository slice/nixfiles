# LENOVO G50-80

{ self, bloodbath, nixpkgs, home-manager, ... }:

let
  config = ({ config, pkgs, modulesPath, ... }: {
    networking.hostName = "mallard";
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 80 ];
      allowedUDPPorts = [ ];
      trustedInterfaces = [ "tailscale0" ];
    };
    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    networking.useDHCP = false;
    networking.interfaces.enp2s0.useDHCP = true;
    networking.interfaces.wlp3s0.useDHCP = true;

    services.tailscale.enable = true;
    # needed for tailscale exit node and subnet
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      # i dunno which one it is, so set both :v
      "net.ipv6.conf.all_forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    services.logind.lidSwitch = "ignore";

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    # assume intel cpu and update its microcode
    hardware.cpu.intel.updateMicrocode = true;

    # accelerated video playback
    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiIntel # i3-4030U, HD Graphics 4400
                   # Intell(R) Haswell Mobile
                   # i965
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    services.xserver.enable = false;
    sound.enable = false;
    hardware.pulseaudio.enable = false;

    user.groups.dev = {};
    users.mutableUsers = false;
    users.users.jellyfin.extraGroups = [ "render" ];
    users.users = {
      slice = {
        description = "slicey";
        extraGroups = [ "dev" "wheel" ];
        isNormalUser = true;
        shell = pkgs.fish;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOKPUkgksy3a+jCBPKPUoldnJtOtOUZ7cAeB4/3cEUPs"
        ];
      };
    };

    # ok so basically
    security.sudo.wheelNeedsPassword = false;

    boot.blacklistedKernelModules = [ "pcspkr" ];
    boot.loader = {
      timeout = 3;
      systemd-boot = {
        enable = true;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };

    services.openssh = {
      enable = true;
      permitRootLogin = "no";
      passwordAuthentication = false;
      challengeResponseAuthentication = false;
      openFirewall = false;
    };

    services = {
      jellyfin.enable = true;

      samba = {
        enable = true;
        securityType = "user";
        extraConfig = ''
          workgroup = WORKGROUP
          server string = mallard
          netbios name = mallard
          security = user
          hosts allow = 10.0.0.0/24, localhost, 100.0.0.0/8
          hosts deny = 0.0.0.0/0
          guest account = nobody
          map to guest = bad user
        '';

        shares.media = {
          path = "/srv/media";
          browseable = "yes";
          writeable = "yes";
          "guest ok" = "yes";
        };
      };
    };

    time.timeZone = "America/Los_Angeles";

    security.acme = {
      email = "tinyslices@gmail.com";
      acceptTerms = true;
    };

    system.stateVersion = "21.05";
  });

  hardwareConfig = ({ config, lib, pkgs, modulesPath, ... }: {
    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

    boot.initrd.availableKernelModules = [
      "xhci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "rtsx_usb_sdmmc"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/301d45d6-b998-409a-84c0-88b0d4894232";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/A300-D5B5";
        fsType = "vfat";
      };

    swapDevices =
      [ { device = "/dev/disk/by-uuid/d4302950-e71a-4ab6-9210-3f581c7a8aa7"; }
      ];
  });
in
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    bloodbath.nixosModule
    (import ../modules/nix.nix) { inherit nixpkgs; }
    home-manager.nixosModules.home-manager {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.slice = self.homeManagerConfigurations.skip { server = true; };
      };
    }
    hardwareConfig config
  ];
}
