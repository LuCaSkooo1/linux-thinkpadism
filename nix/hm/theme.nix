# Making the whole desktop dark, not just the parts that are easy.
#
# There are four separate systems that each decide, independently, whether
# an application draws itself light or dark. Setting one and not the
# others is what produces a dark desktop with a white Firefox window and a
# white tray menu full of missing icons:
#
#   1. GTK3 reads gtk-theme-name and gtk-application-prefer-dark-theme
#      from XSETTINGS / gsettings.
#   2. GTK4 and libadwaita ignore the theme name almost entirely and read
#      org.gnome.desktop.interface color-scheme instead.
#   3. Qt decides from its platform theme. Quickshell's tray menus are
#      real QMenus -- shell.qml sets UseQApplication -- so they follow
#      the Qt palette, not any QML colours.
#   4. Firefox, Chromium and anything else sandboxed asks the XDG
#      appearance portal, which relays the same color-scheme key over
#      D-Bus.
#
# So all four are set here, from the same source, and the icon theme is
# given a fallback with full status-icon coverage so a Bluetooth menu has
# something to draw.
self: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.thinkpadism;

  inherit (lib) mkIf mkMerge;

  pkgsFor = self.packages.${pkgs.stdenv.hostPlatform.system};

  # Whether the seeded theme is a dark one. The Appearance menu can change
  # this at runtime -- it rewrites the same gsettings keys -- so this is
  # only what the session starts as.
  isDark = lib.hasSuffix "-dark" cfg.theme || cfg.theme == "thinkpad-dark";

  gtkThemeName =
    if isDark
    then "ThinkpadismPlatinumDark"
    else "ThinkpadismPlatinum";

  colorScheme =
    if isDark
    then "prefer-dark"
    else "prefer-light";
in {
  config = mkIf (cfg.enable && cfg.gtk.enable) (mkMerge [
    {
      #####################################################################
      # 1 & 2. GTK
      #####################################################################

      gtk = {
        enable = true;

        # Sets gtk-application-prefer-dark-theme for GTK3 and
        # gtk-interface-color-scheme for GTK4. Without it, a GTK app
        # given a dark theme still renders its own light variant.
        colorScheme =
          if isDark
          then "dark"
          else "light";

        theme = {
          name = gtkThemeName;
          package = pkgsFor.thinkpadism-gtk-theme;
        };

        # GTK4 reads gtk-theme-name and then ignores it; Home Manager
        # works around that by importing the theme's GTK4 stylesheet from
        # ~/.config/gtk-4.0/gtk.css, which libadwaita does respect. Naming
        # the theme here is what turns that on.
        gtk4.theme = {
          name = gtkThemeName;
          package = pkgsFor.thinkpadism-gtk-theme;
        };

        iconTheme = {
          name = "ThinkpadismIcons";
          package = pkgsFor.thinkpadism-icons;
        };

        cursorTheme = {
          name = cfg.hyprland.cursorTheme;
          package = pkgs.adwaita-icon-theme;
          size = 24;
        };

        gtk3.extraConfig = {
          gtk-menu-images = 1;
          gtk-button-images = 1;
          # No fade on menus: this desktop does not animate.
          gtk-enable-animations = false;
        };

        gtk4.extraConfig = {
          gtk-enable-animations = false;
        };
      };

      #####################################################################
      # 3. Qt
      #####################################################################

      qt = {
        enable = true;
        # Follow GTK. This is what makes Quickshell's tray menus -- real
        # QMenus, not QML -- come up dark instead of white.
        platformTheme.name = "gtk3";
      };

      #####################################################################
      # 4. The settings every toolkit and the portal actually read
      #####################################################################

      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = colorScheme;
        gtk-theme = gtkThemeName;
        icon-theme = "ThinkpadismIcons";
        cursor-theme = cfg.hyprland.cursorTheme;
        cursor-size = 24;
        enable-animations = false;
      };

      # Belt and braces for apps that read neither gsettings nor the
      # portal, only the environment.
      home.sessionVariables = {
        # Not GTK_THEME: forcing that would override the Appearance
        # menu's light/dark toggle, which writes the gsettings keys above.
        XCURSOR_THEME = cfg.hyprland.cursorTheme;
        XCURSOR_SIZE = "24";
        QT_QPA_PLATFORMTHEME = "gtk3";
      };

      #####################################################################
      # Icon coverage
      #####################################################################

      # ThinkpadismIcons is a recoloured retro set: lovely, and nowhere
      # near complete. It inherits from Papirus-Dark, which has the
      # Bluetooth, network and power status icons that a tray menu asks
      # for -- so those have to be installed for the inheritance to
      # resolve, otherwise the menu renders with blank squares.
      home.packages = [
        pkgs.papirus-icon-theme
        pkgs.adwaita-icon-theme
        pkgs.hicolor-icon-theme
      ];
    }

    # mako follows the same palette. It reads its own config, not any of
    # the above.
    {
      services.mako = {
        enable = true;
        settings = {
          font = "monospace 10";
          background-color =
            if isDark
            then "#1b1b1bf0"
            else "#d6d3cef0";
          text-color =
            if isDark
            then "#e6e4e1"
            else "#121212";
          border-color = "#b3121d";
          progress-color =
            if isDark
            then "over #8c1620"
            else "over #b3121d";
          border-size = 1;
          border-radius = 0;
          padding = "10";
          margin = "8";
          default-timeout = 6000;
          layer = "overlay";
          anchor = "top-right";
        };
      };
    }
  ]);
}
