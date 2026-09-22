# The ThinkPad T420 this rice is built for.
#
# Everything machine-specific lives here and in hardware-configuration.nix;
# the rest of the repo is generic. To build for a different ThinkPad, copy
# this directory, swap the nixos-hardware module for yours, and add it to
# nixosConfigurations in flake.nix.
{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    # Sensible defaults for this exact machine: the right kernel
    # modules, microcode, and the i915 quirks Sandy Bridge wants.
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t420
  ];

  ###########################################################################
  # The desktop
  ###########################################################################

  services.thinkpadism = {
    enable = true;
    user = username;

    thinkpad = {
      enable = true;
      # Charge between 75% and 85%. On a cell this old, charging to full
      # every day is what finishes it off. Set to null if you need the
      # range more than the longevity.
      batteryThresholds = {
        start = 75;
        stop = 85;
      };
      # The firmware fan curve is safe; turn this on if you want a
      # quieter machine and will keep an eye on temperatures.
      fanControl = false;
    };

    mullvad = true;
    greeter = true;
  };

  ###########################################################################
  # Boot
  ###########################################################################

  boot.loader = {
    # The T420 predates UEFI-by-default but supports it. If you installed
    # in legacy BIOS mode, comment this block out and use the GRUB one
    # below instead.
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 2;
  };

  # Legacy BIOS install: swap for the block above.
  #
  # boot.loader.grub = {
  #   enable = true;
  #   device = "/dev/sda";
  # };

  ###########################################################################
  # Identity
  ###########################################################################

  networking.hostName = "t420";

  time.timeZone = lib.mkDefault "Europe/Prague";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  console.keyMap = lib.mkDefault "us";

  users.users.${username} = {
    isNormalUser = true;
    description = "Thinkpadism";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video" # brightnessctl
      "audio"
      "input"
    ];
    shell = pkgs.bash;
  };

  ###########################################################################
  # Anything else
  ###########################################################################

  environment.systemPackages = with pkgs; [
    git
    vim # a fallback that exists before Home Manager has run
    htop
    usbutils
    pciutils
  ];

  services.openssh = {
    enable = false;
    settings.PasswordAuthentication = false;
  };

  # The NixOS release this configuration was first written against. Do
  # not change it on an existing install: it pins stateful defaults
  # (database versions and the like), not the package set.
  system.stateVersion = "25.11";
}
