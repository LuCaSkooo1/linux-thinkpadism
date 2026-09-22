# NixOS module for Linux Thinkpadism.
#
# The system half of the rice: the compositor, the portals, the audio and
# network stacks, the fonts, and the ThinkPad-specific power and thermal
# handling. The user half -- themes, terminal, editor, keybinds -- is the
# Home Manager module in nix/hm.
#
# Everything here is behind `services.thinkpadism.enable`, so it can be
# imported into an existing configuration without taking it over.
self: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.thinkpadism;

  inherit (lib) mkEnableOption mkOption mkIf mkMerge mkDefault types;
in {
  options.services.thinkpadism = {
    enable = mkEnableOption "the Linux Thinkpadism desktop (system side)";

    thinkpad = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          ThinkPad power, thermal and hardware handling: TLP, battery
          charge thresholds, the tp_smapi and acpi_call modules, and a
          suspend mode that actually saves power.
        '';
      };

      batteryThresholds = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            start = mkOption {
              type = types.ints.between 0 100;
              default = 75;
              description = "Charging starts below this percentage.";
            };
            stop = mkOption {
              type = types.ints.between 0 100;
              default = 85;
              description = "Charging stops at this percentage.";
            };
          };
        });
        default = {};
        description = ''
          Battery charge thresholds, via tp_smapi/natacpi.

          Holding an old cell between 75% and 85% rather than charging it
          to full every time is the single biggest thing you can do for
          its remaining life. Set to `null` to charge to 100%.
        '';
      };

      fanControl = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Take over the fan with thinkfan.

          Off by default: the firmware's own curve is safe, and thinkfan
          needs `fan_control=1` on thinkpad_acpi, which this option sets.
          Turn it on if you would rather have a quieter machine and are
          prepared to watch the temperatures.
        '';
      };
    };

    mullvad = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Install the Mullvad VPN daemon and GUI.

        The daemon is a system service; the app in the tray talks to it.
        You still have to log in with your account number once.
      '';
    };

    greeter = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Use greetd with tuigreet as the display manager.

        A text greeter rather than SDDM or GDM: it starts in well under a
        second on spinning-rust-era hardware, and it cannot show you a
        white login screen.
      '';
    };

    user = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "lucas";
      description = ''
        The user the greeter logs in by default, and whose session gets
        the desktop. Optional; only used to set the greeter's default.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    ###################################################################
    # The compositor and its portals
    ###################################################################
    {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };

      # The portals decide what a sandboxed app sees: the file chooser it
      # gets, the screencast picker, and -- the reason this block matters
      # for theming -- the appearance setting that tells Firefox and
      # Chromium whether the desktop is dark.
      #
      # Only xdg-desktop-portal-gtk implements org.freedesktop.impl.portal.Settings,
      # so it has to be present and has to be the one that answers, or
      # every browser falls back to light.
      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
        config.hyprland = {
          default = ["hyprland" "gtk"];
          "org.freedesktop.impl.portal.Settings" = ["gtk"];
          "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
        };
      };

      # Graphical apps need somewhere to ask for a password.
      security.polkit.enable = true;
      systemd.user.services.hyprpolkitagent = {
        description = "Hyprland polkit authentication agent";
        wantedBy = ["graphical-session.target"];
        after = ["graphical-session.target"];
        serviceConfig = {
          ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
          Restart = "on-failure";
        };
      };

      environment.systemPackages = with pkgs; [
        hyprpolkitagent
        hyprpaper
        hypridle
        hyprlock
        hyprshot
        quickshell
      ];

      # The shell writes its light/dark choice here, and the portal reads
      # it back out.
      programs.dconf.enable = true;

      services.gnome.gnome-keyring.enable = true;
    }

    ###################################################################
    # Audio, network, bluetooth, power
    ###################################################################
    {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # A T420's audio is a Conexant codec over HDA; nothing here needs
        # JACK, and leaving it off keeps one fewer daemon resident.
        jack.enable = false;
      };
      security.rtkit.enable = true;

      networking.networkmanager = {
        enable = true;
        wifi.powersave = true;
      };

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = false; # a wireless radio you are not using is a radio draining the battery
        settings.General.Experimental = true; # battery reporting for BLE devices
      };
      services.blueman.enable = true;

      # The bar's battery readout. It can read /sys directly, but upower
      # aggregates a ThinkPad's main and Ultrabay batteries properly.
      services.upower.enable = true;

      services.fstrim.enable = true;

      # 4 to 8 GB of DDR3 is what these shipped with. Compressed swap in
      # RAM beats swapping to a SATA SSD, and beats it enormously on a
      # spinning disk.
      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
      };
    }

    ###################################################################
    # Fonts
    ###################################################################
    {
      fonts = {
        packages = with pkgs; [
          nerd-fonts.jetbrains-mono
          nerd-fonts.symbols-only
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          # The shell bundles Monaco and Charcoal itself; these are for
          # everything else.
          dejavu_fonts
          liberation_ttf
        ];

        fontconfig = {
          defaultFonts = {
            monospace = ["JetBrainsMono Nerd Font" "DejaVu Sans Mono"];
            sansSerif = ["Noto Sans" "DejaVu Sans"];
            serif = ["Noto Serif" "DejaVu Serif"];
            emoji = ["Noto Color Emoji"];
          };

          # The T420's panel is 1366x768 at around 125 DPI. Subpixel
          # rendering with slight hinting is what that wants; the
          # "everything off" defaults suit HiDPI and look mushy here.
          antialias = true;
          hinting = {
            enable = true;
            style = "slight";
          };
          subpixel.rgba = "rgb";
        };
      };
    }

    ###################################################################
    # Graphics: Sandy Bridge
    ###################################################################
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          # i965, not intel-media-driver: the latter is Broadwell and
          # newer only, and installing it on Sandy Bridge silently gets
          # you software decoding.
          intel-vaapi-driver
          libvdpau-va-gl
          libva-vdpau-driver
        ];
      };

      environment.sessionVariables.LIBVA_DRIVER_NAME = mkDefault "i965";
    }

    ###################################################################
    # ThinkPad hardware
    ###################################################################
    (mkIf cfg.thinkpad.enable {
      hardware.cpu.intel.updateMicrocode = true;
      hardware.enableRedistributableFirmware = true;

      boot = {
        kernelParams = [
          # s2idle on this generation is barely a power saving at all;
          # deep is a real suspend-to-RAM.
          "mem_sleep_default=deep"
          # Framebuffer compression: less memory bandwidth spent on
          # scanout, which on an integrated GPU is battery.
          "i915.enable_fbc=1"
          "i915.fastboot=1"
        ];

        # tp_smapi exposes the battery thresholds and the fan; acpi_call
        # is what several ThinkPad tools poke.
        kernelModules = ["acpi_call" "tp_smapi" "coretemp"];
        extraModulePackages = with config.boot.kernelPackages; [
          acpi_call
          tp_smapi
        ];

        extraModprobeConfig = lib.optionalString cfg.thinkpad.fanControl ''
          options thinkpad_acpi fan_control=1
        '';
      };

      services.thermald.enable = true;

      services.tlp = {
        enable = true;
        settings =
          {
            CPU_SCALING_GOVERNOR_ON_AC = "performance";
            CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
            CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
            CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

            # Sandy Bridge has no HWP; these are the p-state percentages.
            CPU_MIN_PERF_ON_AC = 0;
            CPU_MAX_PERF_ON_AC = 100;
            CPU_MIN_PERF_ON_BAT = 0;
            CPU_MAX_PERF_ON_BAT = 60;

            # Turbo off on battery: on a two-core Sandy Bridge it costs
            # far more power than the time it saves.
            CPU_BOOST_ON_AC = 1;
            CPU_BOOST_ON_BAT = 0;

            PLATFORM_PROFILE_ON_AC = "performance";
            PLATFORM_PROFILE_ON_BAT = "low-power";

            # The panel backlight is the biggest single draw.
            RADEON_DPM_STATE_ON_BAT = "battery";

            WIFI_PWR_ON_AC = "off";
            WIFI_PWR_ON_BAT = "on";

            # The optical bay, if there is still a drive in it.
            DISK_IDLE_SECS_ON_BAT = 2;
            SATA_LINKPWR_ON_BAT = "min_power";

            USB_AUTOSUSPEND = 1;
            # Never autosuspend the Bluetooth radio or a TrackPoint over
            # USB -- it makes input laggy on wake.
            USB_EXCLUDE_BTUSB = 1;
            USB_EXCLUDE_PHONE = 1;
          }
          // lib.optionalAttrs (cfg.thinkpad.batteryThresholds != null) {
            START_CHARGE_THRESH_BAT0 = cfg.thinkpad.batteryThresholds.start;
            STOP_CHARGE_THRESH_BAT0 = cfg.thinkpad.batteryThresholds.stop;
            # The Ultrabay battery, if one is fitted.
            START_CHARGE_THRESH_BAT1 = cfg.thinkpad.batteryThresholds.start;
            STOP_CHARGE_THRESH_BAT1 = cfg.thinkpad.batteryThresholds.stop;
          };
      };

      # TLP and power-profiles-daemon both want to own the governor.
      services.power-profiles-daemon.enable = false;

      services.thinkfan = mkIf cfg.thinkpad.fanControl {
        enable = true;
        # Conservative: the firmware curve with a little more headroom,
        # not a silent-at-all-costs curve.
        levels = [
          [0 0 50]
          [1 48 58]
          [2 55 65]
          [3 62 72]
          [4 68 78]
          [5 74 84]
          [7 80 32767]
        ];
      };

      environment.systemPackages = with pkgs; [
        acpi
        powertop
        lm_sensors
        tlp
      ];

      # Hyprland handles the lid and the power button itself (see
      # configs/hypr/lua/40-laptop.lua). logind must be told to keep its
      # hands off, or it acts first and the binds never fire.
      services.logind.settings.Login = {
        HandleLidSwitch = "suspend";
        # On AC or docked, closing the lid should park the machine, not
        # suspend it -- the Lua bind turns the internal panel off and the
        # session carries on wherever it is plugged in.
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";

        HandlePowerKey = "ignore";
        HandlePowerKeyLongPress = "poweroff";
      };
    })

    ###################################################################
    # Mullvad
    ###################################################################
    (mkIf cfg.mullvad {
      services.mullvad-vpn = {
        enable = true;
        # `package` is deliberately left alone: pkgs.mullvad-vpn is the
        # GUI and no longer ships the daemon, and pointing the service at
        # it trips an assertion. The daemon comes from the default
        # package; gui.enable adds the tray app on top.
        gui.enable = true;
      };

      # Mullvad manages its own DNS while connected; resolved is what it
      # talks to.
      services.resolved.enable = true;
    })

    ###################################################################
    # Greeter
    ###################################################################
    (mkIf cfg.greeter {
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = lib.concatStringsSep " " (
            [
              "${lib.getExe pkgs.tuigreet}"
              "--time"
              "--remember"
              "--remember-user-session"
              "--asterisks"
              "--theme 'border=red;text=white;prompt=red;time=red;action=white;button=red;container=black;input=white'"
              "--cmd 'uwsm start hyprland-uwsm.desktop'"
            ]
            ++ lib.optionals (cfg.user != null) ["--user-menu"]
          );
          user = "greeter";
        };
      };

      # Without this the greeter's output fights the kernel log for the
      # console and you get a garbled first frame.
      systemd.services.greetd.serviceConfig = {
        Type = "idle";
        StandardInput = "tty";
        StandardOutput = "tty";
        StandardError = "journal";
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
      };
      boot.kernelParams = ["quiet"];
    })

    ###################################################################
    # Nix itself
    ###################################################################
    {
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
        # A two-core machine building in parallel with 8 jobs just
        # thrashes. One job, both cores.
        max-jobs = 1;
        cores = 0;
      };

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      # Old generations pile up fast on a small SSD.
      boot.loader.systemd-boot.configurationLimit = mkDefault 10;
    }
  ]);
}
