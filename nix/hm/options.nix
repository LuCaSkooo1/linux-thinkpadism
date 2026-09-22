# Option declarations for programs.thinkpadism.
self: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

  pkgsFor = self.packages.${pkgs.stdenv.hostPlatform.system};
in {
  options.programs.thinkpadism = {
    enable = mkEnableOption "the Linux Thinkpadism desktop";

    package = mkOption {
      type = types.package;
      default = pkgsFor.thinkpadism;
      defaultText = literalExpression "thinkpadism.packages.\${system}.thinkpadism";
      description = "The Quickshell shell package to install.";
    };

    theme = mkOption {
      type = types.enum ["thinkpad-dark" "thinkpad-light" "default" "yorha" "cherry" "indigo" "gleep"];
      default = "thinkpad-dark";
      description = ''
        Theme to seed {file}`settings.json` with on first activation.

        Only the initial value: the Appearance menu rewrites the file
        itself afterwards, and this option will not fight it.
      '';
    };

    flakePath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/linux-thinkpadism";
      defaultText = literalExpression ''"''${config.home.homeDirectory}/linux-thinkpadism"'';
      description = ''
        Where this repository lives on disk.

        Only used for convenience: the `rebuild`, `rebuild-test` and
        `update` aliases, and the keymap that opens the flake in Neovim.
        Nothing about the build depends on it.
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
        Copy the bundled wallpapers into
        {option}`programs.thinkpadism.wallpaperDirectory`.

        Copied rather than symlinked, and guarded by a stamp file, so a
        wallpaper you delete stays deleted.
      '';
    };

    installPackages = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Install the runtime dependencies -- terminal, TUI tools,
        screenshot and notification daemons and so on -- into
        {option}`home.packages`.

        Turn this off to pull them in through
        {option}`environment.systemPackages` yourself.
      '';
    };

    terminal = mkOption {
      type = types.str;
      default = "wezterm";
      description = ''
        Terminal the desktop launches, and hosts the TUI tools in.

        Must accept `-e <command>`; wezterm, kitty, foot and alacritty
        all do.
      '';
    };

    browser = mkOption {
      type = types.str;
      default = "librewolf";
      description = "Browser bound to SUPER+B.";
    };

    fileManager = mkOption {
      type = types.str;
      default = "nemo";
      description = "Graphical file manager bound to SUPER+E.";
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

    hyprland = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Manage the Hyprland, hyprpaper, hypridle and hyprlock configs.

          The Hyprland config is Lua (Hyprland 0.55+ deprecated hyprlang);
          hypridle, hyprlock and hyprpaper are still hyprlang, because
          only the compositor moved.
        '';
      };

      monitor = mkOption {
        type = types.str;
        default = "eDP-1";
        description = ''
          The internal panel's output name, used by the lid-switch binds.
          Check it with `hyprctl monitors`.
        '';
      };

      keyboardLayout = mkOption {
        type = types.str;
        default = "us";
        example = "us,se";
        description = "XKB layout(s). A comma-separated list enables switching.";
      };

      keyboardOptions = mkOption {
        type = types.str;
        default = "";
        example = "grp:alt_shift_toggle,caps:escape";
        description = "XKB options, e.g. a layout-switch chord or remapping Caps Lock.";
      };

      cursorTheme = mkOption {
        type = types.str;
        default = "Adwaita";
        description = "XCursor theme name, applied at session start.";
      };

      extraLua = mkOption {
        type = types.lines;
        default = "";
        example = literalExpression ''
          '''
            hl.monitor({ output = "eDP-1", mode = "1600x900@60", scale = 1 })
            hl.bind("SUPER + G", hl.dsp.exec_cmd("steam"))
          '''
        '';
        description = ''
          Lua appended to the generated {file}`hyprland.lua`, after every
          shipped module. Later calls win in Hyprland, so this is the
          right place for anything machine-specific that the options above
          do not already cover.
        '';
      };
    };

    gtk = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Manage the GTK, Qt, icon and cursor themes, and tell every
          toolkit and the XDG portals which colour scheme is in use.

          This is what stops Firefox opening white and GTK menus rendering
          light on a dark desktop.
        '';
      };
    };

    wezterm.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Install and configure WezTerm.";
    };

    yazi.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Install and configure Yazi.";
    };

    neovim.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Install and configure Neovim.";
    };

    neovim.languageServers = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Include language servers and formatters with Neovim.

        Turning this off saves around a gigabyte of closure, at the cost
        of completion and diagnostics.
      '';
    };

    browsers = {
      librewolf = mkOption {
        type = types.bool;
        default = true;
        description = "Install LibreWolf, themed dark and pre-hardened.";
      };

      firefox = mkOption {
        type = types.bool;
        default = false;
        description = "Install Firefox alongside LibreWolf, with the same dark defaults.";
      };
    };

    extras = {
      anime = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Install `ani-cli` and the mpv/yt-dlp stack it drives, for
          watching things from the terminal.
        '';
      };

      media = mkOption {
        type = types.bool;
        default = true;
        description = "Install the terminal media tools: mpv, cava, ncmpcpp-adjacent bits.";
      };

      toys = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Install the pointless-but-good terminal toys: pipes, cmatrix,
          a bonsai tree, and fastfetch for the screenshot.
        '';
      };
    };
  };
}
