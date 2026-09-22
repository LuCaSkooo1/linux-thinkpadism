###############################################################################
#  Your machine.
#
#  This is the only file you need to edit, besides dropping in your own
#  hardware-configuration.nix. Everything else in the repo reads from here.
###############################################################################
{
  # Your login name. The user account, its home directory and the Home
  # Manager configuration are all built from this.
  username = "lucas";

  # The machine's hostname, and the name of the flake output that builds
  # it -- so this value is also the `#t420` in:
  #
  #     sudo nixos-rebuild switch --flake .#t420
  #
  # Change both together by changing it here.
  hostname = "t420";

  # Where you cloned this repo. Only feeds the `rebuild` / `update` shell
  # aliases and Neovim's <leader>nr; the build itself does not care.
  flakePath = "/home/lucas/final";

  # The per-model module from nixos-hardware: the right kernel modules,
  # microcode and i915 quirks for this exact ThinkPad.
  #
  # Other ThinkPads are supported -- swap in "lenovo-thinkpad-x220",
  # "lenovo-thinkpad-t430", and so on. The full list is at
  # https://github.com/NixOS/nixos-hardware#devices
  #
  # Set to null on a machine nixos-hardware does not cover; everything
  # else still works, you just lose the per-model tuning.
  nixosHardwareModule = "lenovo-thinkpad-t420";

  # The internal panel's output name, used by the lid-switch binds and the
  # monitor rule. Check it with `hyprctl monitors` once you are in.
  # T420s report LVDS-1 on most kernels, eDP-1 on some.
  monitor = "LVDS-1";

  # Panel resolution. "preferred" asks the display what it wants, which is
  # right for a laptop; replace with e.g. "1600x900@60" to pin it.
  monitorMode = "preferred";

  # Scale 1: neither the 1366x768 nor the 1600x900 T420 panel wants
  # fractional scaling.
  monitorScale = 1;

  # XKB layout. A comma-separated list enables switching between them --
  # pair it with keyboardOptions below.
  keyboardLayout = "us";

  # XKB options, e.g. "grp:alt_shift_toggle" to switch layouts with
  # Alt+Shift, or "caps:escape" to make Caps Lock useful.
  keyboardOptions = "";

  timeZone = "Europe/Prague";
  locale = "en_US.UTF-8";
  consoleKeyMap = "us";

  # The NixOS release this configuration was first built against. Leave it
  # alone on an existing install: it pins stateful defaults (database
  # versions and the like), not the package set.
  stateVersion = "25.11";
}
