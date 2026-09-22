# Home Manager module for Linux Thinkpadism.
#
# The options live in options.nix; this file holds the core config --
# packages, the settings.json seed and the wallpapers -- and pulls in the
# rest.
#
# Usage, in your flake:
#
#   inputs.thinkpadism.url = "github:LuCaSkooo1/linux-thinkpadism";
#
#   home-manager.users.you = {
#     imports = [inputs.thinkpadism.homeManagerModules.default];
#     programs.thinkpadism.enable = true;
#   };
self: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.thinkpadism;

  inherit (lib) mkIf mkMerge;

  pkgsFor = self.packages.${pkgs.stdenv.hostPlatform.system};
  configs = "${self}/configs";

  settingsSeed = "${configs}/thinkpadism/settings.json";

  # Copies the bundled wallpapers into the user's wallpaper directory,
  # once.
  #
  # Guarded by a stamp file rather than `cp -n`, so a wallpaper you delete
  # stays deleted instead of reappearing on the next switch. Delete the
  # stamp to get them back.
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

  # settings.json is state, not configuration: the shell rewrites it
  # whenever you switch theme or wallpaper. It is seeded on first
  # activation and then left alone, so a switch never clobbers a choice
  # made from the Appearance menu.
  seedSettings = pkgs.writeShellScript "thinkpadism-seed-settings" ''
    set -eu

    settingsDir="''${XDG_CONFIG_HOME:-$HOME/.config}/thinkpadism"
    settingsFile="$settingsDir/settings.json"

    # Already seeded: leave the saved theme and wallpaper alone. Written
    # as an if rather than `[ -e ] && exit`, which would trip set -e.
    if [ -e "$settingsFile" ]; then
      exit 0
    fi

    mkdir -p "$settingsDir"

    ${lib.getExe pkgs.jq} -S \
      --arg theme ${lib.escapeShellArg cfg.theme} \
      --arg wallpaperDirectory ${lib.escapeShellArg cfg.wallpaperDirectory} \
      --arg terminal ${lib.escapeShellArg cfg.terminal} \
      --arg files ${lib.escapeShellArg cfg.fileManager} \
      --arg tuiFiles ${lib.escapeShellArg cfg.tools.files} \
      --arg network ${lib.escapeShellArg cfg.tools.network} \
      --arg audio ${lib.escapeShellArg cfg.tools.audio} \
      --arg performance ${lib.escapeShellArg cfg.tools.performance} \
      '.settings.currentTheme = $theme
       | .settings.wallpaperDirectory = $wallpaperDirectory
       | .settings.execCommands.terminal = $terminal
       | .settings.execCommands.files = $files
       | .settings.execCommands.tuiFiles = $tuiFiles
       | .settings.execCommands.tuiNetwork = $network
       | .settings.execCommands.tuiAudio = $audio
       | .settings.execCommands.tuiPerformance = $performance' \
      ${settingsSeed} > "$settingsFile"

    chmod 0644 "$settingsFile"
  '';
in {
  imports = [
    (import ./options.nix self)
    (import ./hyprland.nix self)
    (import ./theme.nix self)
    (import ./programs.nix self)
    (import ./browsers.nix self)
  ];

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages =
        [cfg.package]
        ++ lib.optionals cfg.installPackages (with pkgs; [
          # TUI tools reached from the bar and the keybinds. Resolved by
          # name, so overriding tools.* to something already installed
          # still works.
          wiremix
          networkmanager # provides nmtui

          # Graphical helpers.
          nemo
          nwg-look
          pavucontrol
          wdisplays

          # Screenshots, clipboard, notifications.
          hyprshot
          grim
          slurp
          wl-clipboard
          cliphist

          # Hardware control behind the ThinkPad function keys.
          brightnessctl
          playerctl
          wireplumber # provides wpctl

          # Used by the launcher keybind and the shell's own helpers.
          jq
          socat
          dconf

          # Everyday terminal tools the aliases above assume.
          eza
          ripgrep
          fd
          dust
          tree
          unzip
          wget
          curl
          lazygit
        ]);

      # The shell's own fonts are bundled in the QML tree, but GTK apps
      # and the lock screen want them installed properly.
      fonts.fontconfig.enable = true;

      # Seed settings.json once, then never touch it again. A plain
      # mutable file rather than a Home Manager symlink, because the
      # shell rewrites it whenever you switch theme or wallpaper.
      home.activation.thinkpadismSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
        run ${seedSettings}
      '';
    }

    (mkIf cfg.installWallpapers {
      home.activation.thinkpadismWallpapers = lib.hm.dag.entryAfter ["writeBoundary"] ''
        run ${installWallpapers}
      '';
    })

    ###################################################################
    # The extras
    ###################################################################

    (mkIf cfg.extras.anime {
      home.packages = with pkgs; [
        # Search, pick and stream an episode without a browser anywhere
        # in the loop. Drives mpv over yt-dlp.
        ani-cli
        mpv
        yt-dlp
        # ani-cli shells out to all three.
        fzf
        gnused
        gnugrep
      ];
    })

    (mkIf cfg.extras.media {
      home.packages = with pkgs; [
        mpv
        imv # image viewer, Wayland-native
        cava # the audio visualiser, for when the bar is not enough
        ffmpeg
        # Terminal image preview, which yazi and others pick up.
        chafa
      ];
    })

    (mkIf cfg.extras.toys {
      home.packages = with pkgs; [
        fastfetch
        cmatrix
        pipes-rs
        cbonsai
        tty-clock
      ];
    })
  ]);
}
