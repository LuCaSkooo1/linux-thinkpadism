# Your machine's own system configuration.
#
# This file is yours. The rice upstream will never change it, so you can
# put anything here and `git pull` will not fight you.
#
# System-level things go here: packages every user needs, services,
# hardware, virtualisation, firewall rules -- the sort of thing that used
# to live in /etc/nixos/configuration.nix.
#
# User-level things (your apps, your dotfiles) go in home/local.nix
# instead.
#
# NOTE: this file is tracked by git, and it has to be -- Nix flakes only
# see git-tracked files, so a .gitignore'd file here would be silently
# invisible to the build. To keep your changes off GitHub, commit them on
# a branch you do not push. See "Keeping your own changes local" in the
# README.
{
  config,
  lib,
  pkgs,
  ...
}: {
  # environment.systemPackages = with pkgs; [
  #   vlc
  #   qbittorrent
  # ];

  # services.printing.enable = true;

  # virtualisation.docker.enable = true;
  # users.users.lucas.extraGroups = ["docker"];

  # networking.firewall.allowedTCPPorts = [22];
}
