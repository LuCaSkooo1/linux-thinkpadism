# Thinkpadism — the NixOS module.
#
# Import it from your flake, then in your configuration.nix:
#
#   thinkpadism.enable = true;
#   thinkpadism.user = "yourname";
#
# That is the whole interface. Everything below is the plumbing that makes
# a Hyprland desktop work: the compositor and its portals, audio, network,
# bluetooth, fonts and a login screen. The user half — themes, bar,
# terminal, editor — is in home.nix and is wired up here through Home
# Manager, so you never have to touch Home Manager yourself.
{
  self,
  home-manager,
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.thinkpadism;
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  imports = [home-manager.nixosModules.home-manager];

  options.thinkpadism = {
    enable = mkEnableOption "the Thinkpadism desktop";

    user = mkOption {
      type = types.str;
      example = "lucas";
      description = "The user who gets the desktop. Must already exist in users.users.";
    };

    theme = mkOption {
      type = types.enum ["thinkpad-dark" "thinkpad-light"];
      default = "thinkpad-dark";
      description = ''
        Starting theme. Only the initial value: the bar's appearance menu
        (SUPER+T) switches it at runtime and remembers your choice.
      '';
    };

    keyboardLayout = mkOption {
      type = types.str;
      default = "us";
      example = "us,cz";
      description = "XKB layout(s) for Hyprland. Several, comma-separated, switch with Alt+Shift.";
    };
  };

  config = mkIf cfg.enable {
    ###################################################################
    # Compositor
    ###################################################################

    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    # The portals decide what the file chooser looks like and — the part
    # that matters for theming — whether browsers are told the desktop is
    # dark. Only the GTK portal answers that question, so it has to be
    # here and has to be the one asked.
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
      config.hyprland = {
        default = ["hyprland" "gtk"];
        "org.freedesktop.impl.portal.Settings" = ["gtk"];
        "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
      };
    };

    # Password prompts for graphical apps.
    security.polkit.enable = true;
    systemd.user.services.hyprpolkitagent = {
      description = "Hyprland polkit agent";
      wantedBy = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
        Restart = "on-failure";
      };
    };

    # The bar writes its light/dark choice here; GTK and the portal read it.
    programs.dconf.enable = true;
    services.gnome.gnome-keyring.enable = true;

    ###################################################################
    # Login: a text greeter that starts Hyprland
    ###################################################################

    services.greetd = {
      enable = true;
      settings.default_session = {
        user = "greeter";
        command = lib.concatStringsSep " " [
          (lib.getExe pkgs.tuigreet)
          "--time --remember --asterisks"
          "--theme 'border=red;text=white;prompt=red;time=red;action=white;button=red;container=black;input=white'"
          "--cmd 'uwsm start hyprland-uwsm.desktop'"
        ];
      };
    };

    ###################################################################
    # Audio, network, bluetooth, battery — what the bar talks to
    ###################################################################

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    security.rtkit.enable = true;

    networking.networkmanager.enable = true; # nmtui, nm-applet

    hardware.bluetooth.enable = true;
    services.blueman.enable = true; # blueman-applet in the tray

    services.upower.enable = true; # the bar's battery readout

    ###################################################################
    # Fonts
    ###################################################################

    fonts.packages = with pkgs; [
      # Monaco and Charcoal: the terminal and lock screen use the same
      # face as the bar.
      self.packages.${pkgs.stdenv.hostPlatform.system}.thinkpadism-fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      noto-fonts
      noto-fonts-color-emoji
    ];
    fonts.fontconfig.defaultFonts.monospace = ["Monaco" "JetBrainsMono Nerd Font"];

    ###################################################################
    # Your user
    ###################################################################

    users.users.${cfg.user}.extraGroups = [
      "networkmanager"
      "video" # backlight keys
    ];

    # Flakes, so `nixos-rebuild --flake` works.
    nix.settings.experimental-features = ["nix-command" "flakes"];

    environment.systemPackages = [pkgs.git];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      # Move a file Home Manager would otherwise refuse to overwrite out of
      # the way, instead of failing the rebuild.
      backupFileExtension = "hm-bak";
      users.${cfg.user} = import ./home.nix {inherit self cfg;};
    };
  };
}
