{ lib, ... }:

{
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "zpool/root";
    options = [ "zfsutil" ];
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "zpool/nix";
    options = [ "zfsutil" ];
    fsType = "zfs";
  };

  fileSystems."/var" = {
    device = "zpool/var";
    options = [ "zfsutil" ];
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "zpool/home";
    options = [ "zfsutil" ];
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/805C-A0CC";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/02919721-d807-42b9-b8fb-8dd2c62f5bea"; }
  ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
