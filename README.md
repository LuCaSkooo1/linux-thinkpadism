<div align="center">

# 🔴 Linux Thinkpadism 🔴

**A red, retro Hyprland desktop for NixOS. Barebones: runs on any machine.**

</div>

<div align="center">

A fork of [Linux Retroism](https://github.com/diinki/linux-retroism) by diinki,
reworked around a ThinkPad-red theme and packaged as a NixOS module.

</div>

![image](./screenshots/default.png)

> The screenshots still show upstream's teal theme.

---

## What you get

Only what it takes to have a working desktop. Everything else is up to you.

| | |
| --- | --- |
| **Desktop** | Hyprland (configured in Lua), a Quickshell bar, lock screen, idle, notifications |
| **Programs** | WezTerm, Yazi, Neovim, Git, LibreWolf |
| **Theme** | ThinkPad red, dark by default — GTK, Qt and the browser included |
| **System** | Audio (PipeWire), network (NetworkManager), Bluetooth, a login screen |

Works on x86 and ARM, on real hardware or in a VM.

---

## Install

You keep your `/etc/nixos/configuration.nix` exactly as it is. You add one
file next to it and two lines to it.

**1. Install NixOS** normally, with no desktop. Log in at the console.

**2. Add the flake** next to your configuration:

```sh
cd /etc/nixos
sudo nix --extra-experimental-features 'nix-command flakes' \
  flake init -t github:LuCaSkooo1/linux-thinkpadism
```

This creates `/etc/nixos/flake.nix`. You won't need to edit it.

**3. Turn it on.** Add two lines to `/etc/nixos/configuration.nix`:

```nix
thinkpadism.enable = true;
thinkpadism.user = "yourname";   # your login name
```

**4. Build:**

```sh
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

Reboot. You land on a login screen; log in and you are in Hyprland.

That same command is how you rebuild from now on.

---

## Adding your own stuff

Nothing changes from normal NixOS — it all goes in `configuration.nix`:

```nix
environment.systemPackages = with pkgs; [ vlc gimp ];
services.printing.enable = true;
```

Then rebuild. Thinkpadism itself has just two more options besides `enable` and
`user`:

```nix
thinkpadism.theme = "thinkpad-light";      # default: thinkpad-dark
thinkpadism.keyboardLayout = "us,cz";      # Alt+Shift switches
```

To update Thinkpadism and everything else:

```sh
cd /etc/nixos
sudo nix flake update
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

If something breaks, pick the previous generation in the boot menu.

---

## Keybinds

`SUPER` throughout.

| Keys | Action |
| --- | --- |
| `Return` | Terminal |
| `D` | App launcher |
| `E` | Files (Yazi) |
| `B` | Browser |
| `T` / `SHIFT`+`T` | Appearance menu / toggle dark–light |
| `SHIFT` + `N` / `A` / `P` | Network / audio / system monitor |
| `Q` | Close window |
| `F` | Fullscreen |
| `SHIFT`+`SPACE` | Float |
| `1`–`0` | Workspace |
| `SHIFT` + `1`–`0` | Move window to workspace |
| arrows or `H` `K` `L` `N` | Move focus |
| `SHIFT`+`S` / `Print` | Screenshot region / screen, to clipboard |
| `Escape` | Lock |
| `` ` `` | Scratchpad |

In Neovim, leader is `Space`: press it and wait, and it shows what follows.

---

## How it's put together

```
flake.nix          exports the module and the template
modules/
  nixos.nix        the system half: Hyprland, portals, audio, network, login
  home.nix         the user half: bar, theme, programs (via Home Manager)
  neovim.nix       Neovim and its plugins
configs/           the actual config files — Hyprland Lua, WezTerm, Yazi,
                   Neovim, the Quickshell bar
pkgs/              the bar, icon theme, GTK themes, wallpapers
template/          the flake.nix that `nix flake init` gives you
```

To change the look or the keybinds, edit `configs/`. The Hyprland config is
plain Lua in `configs/hypr/lua/`.

### Working on it

Fork it, clone it anywhere, and build your system against your checkout
instead of GitHub:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#nixos \
  --override-input thinkpadism path:/home/you/linux-thinkpadism
```

---

## Credits

Linux Retroism, the base this is forked from, is by
[diinki](https://github.com/diinki) —
[repo](https://github.com/diinki/linux-retroism) ·
[ko-fi](https://ko-fi.com/diinki) · [youtube](https://youtube.com/@diinkikot).

Wallpapers by 96YOTTEA and others, as credited upstream.

## License

MIT, as upstream. See `LICENSE`.
