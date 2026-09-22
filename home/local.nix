# Your own user configuration.
#
# This file is yours. The rice upstream will never change it.
#
# Anything that belongs to your user rather than the machine: packages
# you want on your PATH, programs whose dotfiles Home Manager should
# manage, extra Hyprland binds, shell aliases.
#
# System-level things go in hosts/thinkpad/local.nix instead.
#
# NOTE: tracked by git on purpose -- see the note in
# hosts/thinkpad/local.nix.
{
  config,
  lib,
  pkgs,
  ...
}: {
  # home.packages = with pkgs; [
  #   discord
  #   gimp
  #   obsidian
  # ];

  # programs.bash.shellAliases = {
  #   gs = "git status";
  # };

  # Extra Hyprland binds. Appended after everything the rice ships, and
  # after programs.thinkpadism.hyprland.extraLua, so these win.
  #
  # wayland.windowManager.hyprland.extraConfig = ''
  #   hl.bind("SUPER + G", hl.dsp.exec_cmd("steam"))
  # '';
}
