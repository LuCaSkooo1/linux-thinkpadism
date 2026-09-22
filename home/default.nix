# The user half of the rice.
#
# Everything here is Home Manager: themes, terminal, editor, keybinds. The
# system half -- compositor, portals, power management -- is
# services.thinkpadism in hosts/thinkpad.
{
  config,
  lib,
  pkgs,
  inputs,
  username,
  machine,
  ...
}: {
  imports = [
    inputs.self.homeManagerModules.default

    # Your own user configuration. Yours to edit; never touched by the
    # rice.
    ./local.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    # As with system.stateVersion: pins stateful defaults, not packages.
    # Leave it alone on an existing install.
    stateVersion = machine.stateVersion;
  };

  programs.thinkpadism = {
    enable = true;

    theme = "thinkpad-dark";

    # Where this repo lives; feeds the `rebuild` / `update` aliases and
    # Neovim's <leader>nr. Set it in machine.nix.
    flakePath = machine.flakePath;

    terminal = "wezterm";
    browser = "librewolf";

    hyprland = {
      inherit (machine) monitor;
      keyboardLayout = machine.keyboardLayout;
      keyboardOptions = machine.keyboardOptions;

      # Pin the internal panel. Anything else machine-specific that the
      # options above do not cover goes here too -- later calls win in
      # Hyprland, so this overrides everything the repo ships.
      extraLua = ''
        hl.monitor({
            output   = "${machine.monitor}",
            mode     = "${machine.monitorMode}",
            position = "auto",
            scale    = ${toString machine.monitorScale},
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

  # Your git identity. Change or drop it.
  programs.git.settings.user = {
    name = "LuCaSkooo1";
    email = "lucasligas15@gmail.com";
  };

  # Let Home Manager manage itself, so `home-manager` is on PATH.
  programs.home-manager.enable = true;
}
