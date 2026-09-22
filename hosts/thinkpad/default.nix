# The machine.
#
# Everything model- or user-specific is read from ../../machine.nix, so
# this file describes the shape of a Thinkpadism machine rather than any
# particular one. The only other file that is specific to your hardware is
# hardware-configuration.nix, next to this one.
{
  config,
  lib,
  pkgs,
  inputs,
  username,
  machine,
  ...
}: {
  imports =
    [
      ./hardware-configuration.nix

      # Your own system configuration. Yours to edit; never touched by
      # the rice.
      ./local.nix
    ]
    # Per-model tuning from nixos-hardware: the right kernel modules,
    # microcode and i915 quirks. Optional -- set nixosHardwareModule to
    # null in machine.nix on a machine it does not cover.
    ++ lib.optional (machine.nixosHardwareModule != null)
    inputs.nixos-hardware.nixosModules.${machine.nixosHardwareModule};

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
    # UEFI. If you installed in legacy BIOS mode, comment this block out
    # and use the GRUB one below instead.
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

  networking.hostName = machine.hostname;

  time.timeZone = lib.mkDefault machine.timeZone;
  i18n.defaultLocale = lib.mkDefault machine.locale;
  console.keyMap = lib.mkDefault machine.consoleKeyMap;

  users.users.${username} = {
    isNormalUser = true;
    description = "Thinkpadism";

    # Only applied when the account is created. On a machine where the
    # user already exists this is ignored, and `passwd` keeps working
    # either way (users.mutableUsers is true by default).
    initialPassword = machine.initialPassword;
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

  system.stateVersion = machine.stateVersion;
}
