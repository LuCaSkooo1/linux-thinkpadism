# Home Manager module for Linux Thinkpadism.
#
# Usage, in your flake:
#
#   inputs.thinkpadism.url = "github:LuCaSkooo1/linux-thinkpadism";
#
#   homeConfigurations.you = home-manager.lib.homeManagerConfiguration {
#     modules = [
#       inputs.thinkpadism.homeManagerModules.default
#       { programs.thinkpadism.enable = true; }
#     ];
#   };
self: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.thinkpadism;

  inherit (lib) mkEnableOption mkOption mkIf mkMerge types literalExpression;

  pkgsFor = self.packages.${pkgs.stdenv.hostPlatform.system};

  # The repo's config trees, referenced straight out of the flake source.
  configs = "${self}/configs";

  # settings.json is state, not configuration: the shell rewrites it whenever
  # you switch theme or wallpaper. It is seeded on first activation and then
  # left alone, so a `home-manager switch` never clobbers your choices.
  settingsSeed = "${configs}/thinkpadism/settings.json";

  # Copies the bundled wallpapers into the user's wallpaper directory, once.
  #
  # Guarded by a stamp file rather than `cp -n`, so a wallpaper you delete
  # stays deleted instead of reappearing on the next `home-manager switch`.
  # Delete the stamp to get them back.
  installWallpapers = pkgs.writeShellScript "thinkpadism-install-wallpapers" ''
    set -eu

    dir=${lib.escapeShellArg cfg.wallpaperDirectory}
    stamp="''${XDG_STATE_HOME:-$HOME/.local/state}/thinkpadism/wallpapers-installed"

    if [ -e "$stamp" ]; then
      exit 0
    fi

    mkdir -p "$dir" "$(dirname "$stamp")"
    cp ${pkgsFor.thinkpadism-wallpapers}/share/wallpapers/thinkpadism/*.png "$dir/"
    # Store paths are read-only; make the copies editable.
    chmod u+w "$dir"/*.png

    touch "$stamp"
  '';

  # Copies the seed into place on first run and folds this module's options
  # into it. A no-op once the file exists.
  seedSettings = pkgs.writeShellScript "thinkpadism-seed-settings" ''
    set -eu

    settingsDir="''${XDG_CONFIG_HOME:-$HOME/.config}/thinkpadism"
    settingsFile="$settingsDir/settings.json"

    # Already seeded: leave the user's saved theme and wallpaper alone.
    # Written as an if rather than `[ -e ] && exit`, which trips `set -e`.
    if [ -e "$settingsFile" ]; then
      exit 0
    fi

    mkdir -p "$settingsDir"

    ${lib.getExe pkgs.jq} -S \
      --arg theme ${lib.escapeShellArg cfg.theme} \
      --arg wallpaperDirectory ${lib.escapeShellArg cfg.wallpaperDirectory} \
      --arg terminal ${lib.escapeShellArg cfg.terminal} \
      --arg files ${lib.escapeShellArg cfg.tools.files} \
      --arg network ${lib.escapeShellArg cfg.tools.network} \
      --arg audio ${lib.escapeShellArg cfg.tools.audio} \
      --arg performance ${lib.escapeShellArg cfg.tools.performance} \
      '.settings.currentTheme = $theme
       | .settings.wallpaperDirectory = $wallpaperDirectory
       | .settings.execCommands.terminal = $terminal
       | .settings.execCommands.tuiFiles = $files
       | .settings.execCommands.tuiNetwork = $network
       | .settings.execCommands.tuiAudio = $audio
       | .settings.execCommands.tuiPerformance = $performance' \
      ${settingsSeed} > "$settingsFile"

    chmod 0644 "$settingsFile"
  '';
in {
  options.programs.thinkpadism = {
    enable = mkEnableOption "the Linux Thinkpadism desktop shell";

    package = mkOption {
      type = types.package;
      default = pkgsFor.thinkpadism;
      defaultText = literalExpression "thinkpadism.packages.\${system}.thinkpadism";
      description = "The Quickshell shell package to install.";
    };

    theme = mkOption {
      type = types.enum ["thinkpad-light" "thinkpad-dark" "default" "yorha" "cherry" "indigo" "gleep"];
      default = "thinkpad-light";
      description = ''
        Theme to seed settings.json with on first activation.

        Only the initial value: the Appearance menu writes the file itself
        afterwards, and this option will not fight it.
      '';
    };

    wallpaperDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Pictures/Wallpapers";
      defaultText = literalExpression ''"''${config.home.homeDirectory}/Pictures/Wallpapers"'';
      description = "Directory the Appearance menu scans for wallpapers.";
    };

    installWallpapers = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Copy the wallpapers shipped with the rice into
        {option}`programs.thinkpadism.wallpaperDirectory`.

        Copied rather than symlinked, so you can delete the ones you do not
        want without Home Manager putting them back.
      '';
    };

    terminal = mkOption {
      type = types.str;
      default = "kitty";
      description = "Terminal the shell launches, and hosts the TUI tools in.";
    };

    tools = {
      files = mkOption {
        type = types.str;
        default = "yazi";
        description = "TUI file manager.";
      };
      network = mkOption {
        type = types.str;
        default = "nmtui";
        description = "TUI network manager. Use `impala` if you run iwd rather than NetworkManager.";
      };
      audio = mkOption {
        type = types.str;
        default = "wiremix";
        description = "TUI audio mixer.";
      };
      performance = mkOption {
        type = types.str;
        default = "btop";
        description = "TUI system monitor.";
      };
    };

    installPackages = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Install the runtime dependencies (terminal, TUI tools, screenshot and
        notification daemons, and so on) into {option}`home.packages`.

        Turn this off if you would rather pull them in through
        {option}`environment.systemPackages` yourself.
      '';
    };

    hyprland = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Manage the Hyprland, hyprpaper, hypridle and hyprlock configs.

          Turn this off to keep your own Hyprland config; you will then need
          to start `thinkpadism` yourself with an `exec-once`.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        example = literalExpression ''
          '''
            monitor = eDP-1, 1920x1200@60, 0x0, 1.5
            input:kb_layout = de
          '''
        '';
        description = ''
          Appended to the shipped hyprland.conf.

          The right place for monitor layout and keyboard layout, since later
          lines win in Hyprland.
        '';
      };
    };

    kitty = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Manage the kitty config and colour themes.";
      };
    };

    gtk = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Set the GTK and icon themes to the ones shipped here, via
          {option}`gtk.*`. Requires Home Manager's gtk module.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages =
        [cfg.package]
        ++ lib.optionals cfg.installPackages (with pkgs; [
          # Terminal and TUI tools. Resolved by name so overriding
          # `tools.*` to something already installed still works.
          yazi
          wiremix
          btop
          networkmanager # provides nmtui

          # Graphical helpers the shell and keybinds reach for.
          nemo
          nwg-look
          pavucontrol

          # Screenshots, clipboard, notifications.
          hyprshot
          grim
          slurp
          wl-clipboard
          mako

          # Hardware control bound to the ThinkPad function keys.
          brightnessctl
          playerctl
          wireplumber # provides wpctl

          # Used by the launcher keybind and the shell's own helpers.
          jq
          socat
          dconf
        ])
        ++ lib.optional cfg.kitty.enable pkgs.kitty;

      # The shell's own fonts are bundled in the QML tree, but GTK apps and
      # the lock screen want them installed too.
      fonts.fontconfig.enable = true;

      # Seed settings.json once, then never touch it again. Written as a plain
      # mutable file rather than a Home Manager symlink, because the shell
      # rewrites it whenever you switch theme or wallpaper.
      home.activation.thinkpadismSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
        run ${seedSettings}
      '';
    }

    (mkIf cfg.installWallpapers {
      home.activation.thinkpadismWallpapers = lib.hm.dag.entryAfter ["writeBoundary"] ''
        run ${installWallpapers}
      '';
    })

    (mkIf cfg.hyprland.enable {
      xdg.configFile = {
        # The shipped config, plus the user's own monitor/layout lines. Later
        # lines win in Hyprland, so appending is the right way to override
        # everything except variables -- those live in programs.conf, which is
        # sourced before the keybinds that expand them.
        "hypr/hyprland.conf".text =
          builtins.readFile "${configs}/hypr/hyprland.conf"
          + ''

            # --- Managed by the Thinkpadism Home Manager module ---
          ''
          + cfg.hyprland.extraConfig;

        # Regenerated from the module's options rather than copied.
        "hypr/programs.conf".text = ''
          # Generated by the Thinkpadism Home Manager module. Do not edit;
          # set programs.thinkpadism.terminal / .tools.* instead.

          # Launch the shell by store path rather than trusting $PATH.
          exec-once = ${lib.getExe cfg.package}

          $terminal    = ${cfg.terminal}
          $fileManager = nemo
          $browser     = firefox

          $tuiFiles       = ${cfg.terminal} -e ${cfg.tools.files}
          $tuiNetwork     = ${cfg.terminal} -e ${cfg.tools.network}
          $tuiAudio       = ${cfg.terminal} -e ${cfg.tools.audio}
          $tuiPerformance = ${cfg.terminal} -e ${cfg.tools.performance}

          $focusedMonitor = $(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
          $menu           = quickshell ipc call appLauncher_$focusedMonitor toggleAppLauncher
          $appearanceMenu = quickshell ipc call appLauncher_$focusedMonitor toggleThemeMenu
          $toggleDarkMode = quickshell ipc call appLauncher_$focusedMonitor toggleDarkMode
        '';

        "hypr/hyprpaper.conf".source = "${configs}/hypr/hyprpaper.conf";
        "hypr/hypridle.conf".source = "${configs}/hypr/hypridle.conf";
        "hypr/hyprlock.conf".source = "${configs}/hypr/hyprlock.conf";
      };
    })

    (mkIf cfg.kitty.enable {
      xdg.configFile = {
        "kitty/kitty.conf".source = "${configs}/kitty/kitty.conf";
        "kitty/common.conf".source = "${configs}/kitty/common.conf";
        "kitty/thinkpad_light_theme.conf".source = "${configs}/kitty/thinkpad_light_theme.conf";
        "kitty/thinkpad_dark_theme.conf".source = "${configs}/kitty/thinkpad_dark_theme.conf";
        "kitty/default_theme.conf".source = "${configs}/kitty/default_theme.conf";
        "kitty/cherry_theme.conf".source = "${configs}/kitty/cherry_theme.conf";
        "kitty/gleep_theme.conf".source = "${configs}/kitty/gleep_theme.conf";
        "kitty/indigo_theme.conf".source = "${configs}/kitty/indigo_theme.conf";
        "kitty/yorha_theme.conf".source = "${configs}/kitty/yorha_theme.conf";
      };
    })

    (mkIf cfg.gtk.enable {
      gtk = {
        enable = true;
        theme = {
          name = "ClassicPlatinumStreamlined";
          package = pkgsFor.thinkpadism-gtk-theme;
        };
        iconTheme = {
          name = "ThinkpadismIcons";
          package = pkgsFor.thinkpadism-icons;
        };
      };

      # Qt apps follow the same palette rather than defaulting to Adwaita.
      qt = {
        enable = true;
        platformTheme.name = "gtk3";
      };
    })
  ]);
}
