###############################################################################
#  REPLACE THIS FILE.
#
#  It is a placeholder so the flake evaluates on a machine that is not the
#  T420. It will not boot anything.
#
#  On the real machine, after `nixos-install` or from the installer:
#
#      sudo nixos-generate-config --show-hardware-config \
#        > hosts/t420/hardware-configuration.nix
#
#  then commit the result. That is the one file in this repo that is
#  genuinely specific to your disks.
###############################################################################
{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  # Placeholder UUIDs. `nixos-generate-config` fills in the real ones.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0000-0000";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
