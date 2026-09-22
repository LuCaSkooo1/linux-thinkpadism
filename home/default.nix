# The user half of the rice.
#
# Everything here is Home Manager: themes, terminal, editor, keybinds. The
# system half -- compositor, portals, power management -- is
# services.thinkpadism in hosts/t420.
{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    inputs.self.homeManagerModules.default
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    # As with system.stateVersion: pins stateful defaults, not packages.
    # Leave it alone on an existing install.
    stateVersion = "25.11";
  };

  programs.thinkpadism = {
    enable = true;

    theme = "thinkpad-dark";

    terminal = "wezterm";
    browser = "librewolf";

    hyprland = {
      # Check yours with `hyprctl monitors`; on a T420 the internal panel
      # is usually LVDS-1 on older kernels and eDP-1 on newer ones.
      monitor = "LVDS-1";

      keyboardLayout = "us";
      keyboardOptions = "";

      # Anything machine-specific the options above do not cover. Later
      # calls win in Hyprland, so this overrides everything shipped.
      extraLua = ''
        -- The T420's panel: 1366x768 on the base model, 1600x900 on the
        -- HD+ option. Neither wants fractional scaling.
        hl.monitor({
            output   = "LVDS-1",
            mode     = "preferred",
            position = "auto",
            scale    = 1,
        })
      '';
    };

    browsers = {
      librewolf = true;
      firefox = false;
    };

    extras = {
      anime = true;
      media = true;
      toys = true;
    };
  };

  programs.git.settings.user = {
    name = "LuCaSkooo1";
    email = "lucasligas15@gmail.com";
  };

  # Let Home Manager manage itself, so `home-manager` is on PATH.
  programs.home-manager.enable = true;
}
