<div align="center">

# 🔴 Linux Thinkpadism 🔴

**A red-accented retro desktop for Hyprland, tuned for NixOS and ThinkPads.**

</div>

<div align="center">

A fork of [Linux Retroism](https://github.com/diinki/linux-retroism) by diinki,
reworked around a dark/light red theme, laptop-first defaults, and a flake with
a Home Manager module.

</div>

![image](./screenshots/default.png)

> The screenshots still show upstream's teal default theme. New ones for the red
> light/dark themes are still to be taken.

---

## What this fork changes

| | |
| --- | --- |
| **Theming** | `thinkpad-light` and `thinkpad-dark`, both red-accented, with a one-click toggle |
| **Bar** | Battery, clock + date, and live CPU/RAM/temperature readouts |
| **Workspaces** | A fixed 1–10 strip that never reflows, with occupied/focused/urgent states |
| **Appearance menu** | Theme swatches *and* a wallpaper switcher, applied live |
| **Terminal tools** | One-click `yazi`, `nmtui`, `wiremix` and `btop` from the bar and start menu |
| **Icons** | The whole icon theme recolored blue → red, red folders included |
| **Hyprland** | Touchpad, trackpoint, lid switch, media keys, idle and lock config |
| **NixOS** | A flake and a Home Manager module that wire all of the above up |

---

## Install on NixOS (flake + Home Manager)

Add the flake as an input:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    thinkpadism.url = "github:LuCaSkooo1/linux-thinkpadism";
  };
}
```

Then enable the module in your Home Manager configuration:

```nix
{
  imports = [inputs.thinkpadism.homeManagerModules.default];

  programs.thinkpadism = {
    enable = true;
    theme = "thinkpad-dark";

    # Everything below is optional; these are the defaults.
    terminal = "kitty";
    tools = {
      files = "yazi";
      network = "nmtui";      # use "impala" if you run iwd rather than NetworkManager
      audio = "wiremix";
      performance = "btop";
    };

    # Monitor layout and keyboard layout belong here: Hyprland lets later
    # lines win, and this block is appended to the shipped config.
    hyprland.extraConfig = ''
      monitor = eDP-1, 1920x1200@60, 0x0, 1.5
      input:kb_layout = us
    '';
  };
}
```

On the system side you need Hyprland itself, plus a couple of daemons the shell
expects:

```nix
{
  programs.hyprland.enable = true;

  # Battery readout. The shell falls back to reading /sys directly if this is
  # off, but upower aggregates dual ThinkPad batteries properly.
  services.upower.enable = true;

  # Volume keys and the audio mixer.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Used by nmtui and the network button.
  networking.networkmanager.enable = true;
}
```

Then `home-manager switch` and log into Hyprland.

### Module options

| Option | Default | Notes |
| --- | --- | --- |
| `enable` | `false` | |
| `theme` | `"thinkpad-light"` | Seeds `settings.json` on first activation only |
| `wallpaperDirectory` | `~/Pictures/Wallpapers` | What the Appearance menu scans |
| `installWallpapers` | `true` | One-time copy; deletions stick |
| `terminal` | `"kitty"` | Also hosts the TUI tools |
| `tools.{files,network,audio,performance}` | yazi/nmtui/wiremix/btop | |
| `installPackages` | `true` | Set false to manage deps yourself |
| `hyprland.enable` | `true` | |
| `hyprland.extraConfig` | `""` | Appended to `hyprland.conf` |
| `kitty.enable` | `true` | |
| `gtk.enable` | `true` | Sets GTK + icon theme, and Qt to follow GTK |

### Just the packages

```sh
nix run github:LuCaSkooo1/linux-thinkpadism      # run the shell
nix build github:LuCaSkooo1/linux-thinkpadism#thinkpadism-icons
nix develop                                      # dev shell with qmlls and Pillow
```

---

## Install on other distros

Run `./install.sh`. It checks dependencies, backs up any config it would
replace, copies everything into `~/.config/`, and drops the wallpapers into
`~/Pictures/Wallpapers`.

Re-running it is safe: `~/.config/thinkpadism/settings.json` is seeded once and
then left alone, so your theme and wallpaper survive an update.

The GTK and icon themes still have to be moved by hand — to
`~/.local/share/themes` and `~/.local/share/icons` respectively — and selected
with `nwg-look`.

**Required:** `hyprland` (or `swayfx`), `hyprpaper` (or `swaybg`), `quickshell`,
`kitty`, `nemo`, `nwg-look`, `hyprshot` (or `grim`/`slurp`/`swappy`), `mako`,
`dconf`, `jq`, `socat`

**Optional but recommended:** `yazi`, `networkmanager` (for `nmtui`), `wiremix`,
`btop`, `brightnessctl`, `playerctl`, `wireplumber`, `hypridle`, `hyprlock`

---

## Keybinds

`SUPER` is the modifier throughout.

| Keys | Action |
| --- | --- |
| `SUPER` + `Return` | Terminal |
| `SUPER` + `D` | App launcher |
| `SUPER` + `E` | File manager |
| `SUPER` + `B` | Browser |
| `SUPER` + `T` | Appearance menu (themes + wallpapers) |
| `SUPER` + `SHIFT` + `T` | Toggle dark/light |
| `SUPER` + `SHIFT` + `E` / `N` / `A` / `P` | Files / network / audio / performance TUI |
| `SUPER` + `Q` | Close window |
| `SUPER` + `F` | Fullscreen |
| `SUPER` + `SHIFT` + `SPACE` | Toggle floating |
| `SUPER` + `1`–`0` | Switch to workspace 1–10 |
| `SUPER` + `SHIFT` + `1`–`0` | Move window to workspace 1–10 |
| `SUPER` + arrows / `hjkl` | Move focus |
| `SUPER` + `CTRL` + arrows | Resize window |
| `SUPER` + `SHIFT` + `S` | Screenshot a region |
| `SUPER` + `Escape` | Lock |

Scrolling over the workspace strip cycles workspaces; a three-finger swipe does
the same.

---

## Configuration

Runtime settings live in `~/.config/thinkpadism/settings.json`, separate from
the QML so the shell can rewrite them (and so the config can be a read-only Nix
store path). Themes, the bar's widget toggles, and the commands behind each
button are all in there.

The start menu's system summary (distro, CPU, RAM, GPU) is probed from `/proc`
and `/etc/os-release` at startup. Fill in the matching `systemDetails` field to
override what it found.

Colour schemes are defined in `configs/quickshell/Config.qml`. Anything added to
the `themes` map shows up in the Appearance menu automatically; give it a `dark`
flag and the usual colour keys.

To re-run the icon recolor after editing the source art:

```sh
python3 scripts/recolor-icons.py --check   # preview
python3 scripts/recolor-icons.py           # apply
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
