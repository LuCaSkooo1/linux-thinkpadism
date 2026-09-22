<div align="center">

# 🔴 Linux Thinkpadism 🔴

**A red-accented retro Hyprland desktop, built for a ThinkPad T420, on NixOS.**

</div>

<div align="center">

A fork of [Linux Retroism](https://github.com/diinki/linux-retroism) by diinki,
reworked into a single flake that builds the whole machine: compositor, shell,
themes, terminal, editor and power management.

</div>

![image](./screenshots/default.png)

> The screenshots still show upstream's teal theme. New ones for the red dark
> theme are still to be taken.

---

## What this is

One flake, one command. `nixos-rebuild switch --flake .#<hostname>` builds the
system and the user environment together — no second `home-manager switch`
step, nothing to copy into `~/.config` by hand. Everything that differs
between machines lives in a single `machine.nix`.

| | |
| --- | --- |
| **Compositor** | Hyprland, configured in **Lua** (0.55 deprecated hyprlang) |
| **Shell** | Quickshell bar: workspaces, battery, clock, live CPU/RAM/temp |
| **Theme** | ThinkPad red, dark by default, applied to *every* toolkit |
| **Terminal** | WezTerm, tuned for Sandy Bridge graphics |
| **Files** | Yazi, themed to match |
| **Editor** | Neovim with a hand-written red colourscheme, LSP and completion |
| **Browser** | LibreWolf, hardened but usable, and dark from the first frame |
| **VPN** | Mullvad |
| **Power** | TLP, battery charge thresholds, zram, thermald |

---

## Installing on a fresh NixOS machine

From a blank disk to the desktop. You edit **two files**: `machine.nix`, and
your own hardware config.

### 1. Install NixOS, minimally

Boot the installer and do a normal install — no desktop environment, no
display manager, nothing extra. Set a password for your user, reboot, and log
in at the console.

### 2. Clone the repo

```sh
nix-shell -p git
git clone https://github.com/LuCaSkooo1/linux-thinkpadism ~/thinkpadism
cd ~/thinkpadism
```

Anywhere works — `~/thinkpadism` is just what the rest of these steps assume.

### 3. Drop in your hardware config

This is the one file in the repo that is specific to *your* disks. The
committed one is a placeholder with fake UUIDs and will not boot:

```sh
sudo nixos-generate-config --show-hardware-config \
  > hosts/thinkpad/hardware-configuration.nix
```

> **Booting in legacy BIOS mode rather than UEFI?** Open
> `hosts/thinkpad/default.nix` and swap the `systemd-boot` block for the
> commented-out GRUB one just below it.

### 4. Edit `machine.nix`

Everything that differs between machines is in this one file:

```nix
{
  username  = "lucas";        # your login name
  hostname  = "t420";         # also the flake output name
  flakePath = "/home/lucas/thinkpadism";   # where you just cloned

  nixosHardwareModule = "lenovo-thinkpad-t420";
  monitor = "LVDS-1";

  keyboardLayout = "us";
  timeZone = "Europe/Prague";
  # ...
}
```

At minimum change `username`, `flakePath` and `timeZone`. The rest has
sensible defaults, and `monitor` you can fix after first boot (step 7).

**On a different ThinkPad?** Change `nixosHardwareModule` to your model —
`"lenovo-thinkpad-x220"`, `"lenovo-thinkpad-t430"`, and so on; the list is in
[nixos-hardware](https://github.com/NixOS/nixos-hardware#devices). Set it to
`null` on a machine that isn't covered: everything still works, you just lose
the per-model tuning.

### 5. Build

```sh
sudo nixos-rebuild test --flake .#t420     # try it, without touching the bootloader
sudo nixos-rebuild switch --flake .#t420   # keep it
```

Replace `t420` with whatever you set `hostname` to.

`test` activates the new system but leaves the boot menu alone, so if
something goes wrong you reboot back into what you had. Worth doing for the
first build.

The first build takes a while. It is compiling almost nothing — it is
downloading a desktop.

> **`error: flake 'path:/etc/nixos' does not provide attribute ...`**
> You ran bare `nixos-rebuild switch`, which always reads `/etc/nixos` and
> never your clone. The `--flake .#<hostname>` part is not optional.

> **`experimental Nix feature 'nix-command' is disabled`**
> Flakes are not on yet. Prefix the command once:
> `sudo NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild ...`
> After the first successful switch this config enables them permanently.

### 6. Commit the lock file

The build writes `flake.lock`, pinning the exact revision of every input.
**Commit it.** That file is what makes this reproducible — with it, the repo
rebuilds the same desktop on any machine at any point in the future; without
it, you get whatever upstream looks like the day you build.

```sh
git add flake.lock && git commit -m "Lock inputs"
```

Updating later is `update` then `rebuild` (both aliases this config installs),
or in full:

```sh
nix flake update && sudo nixos-rebuild switch --flake .
```

Leaving the attribute off works because `hostname` in `machine.nix` matches
the flake output. If an update breaks something, the previous generation is
still in the boot menu, and `git checkout flake.lock` puts you back.

### 7. Check the panel name

Log in, open a terminal, and run:

```sh
hyprctl monitors
```

Most T420s report `LVDS-1`; some report `eDP-1`. If yours differs from what
you set, fix `monitor` in `machine.nix` and `rebuild` — the lid-switch binds
and the monitor rule both use it.

### Using it as a module instead

If you already have a NixOS configuration and just want pieces of this, the
flake exports `nixosModules.thinkpadism`, `homeManagerModules.thinkpadism`
and the individual packages. Ignore `machine.nix` and `hosts/` entirely and
set `services.thinkpadism` / `programs.thinkpadism` in your own config.

---

## Layout

```
machine.nix            EVERYTHING machine-specific — edit this one
flake.nix              inputs, the system, the exported modules
hosts/thinkpad/        the machine: bootloader, user, hardware
home/                  the user: theme choice, programs, git identity
nix/
  nixos.nix            system module — compositor, portals, power, fonts
  hm/                  home module — theming, programs, Hyprland wiring
  neovim.nix           Neovim with its plugins, from nixpkgs
  gtk-theme.nix        generates the light and dark Platinum variants
configs/
  hypr/lua/            the Hyprland config, as readable Lua modules
  wezterm/             WezTerm
  yazi/                Yazi
  nvim/                Neovim
  quickshell/          the bar and its popups (QML)
scripts/
  make-gtk-themes.py   derives both GTK themes from the upstream one
  recolor-icons.py     recolours the icon theme blue → red
```

The split is deliberate: `configs/` holds real, editable config files in each
tool's own language, and Nix only decides *where they go* and fills in the few
values that depend on the machine. You can read the Hyprland config without
reading any Nix.

---

## Hyprland is Lua now

Hyprland 0.55 deprecated `hyprlang` in favour of Lua, and this config targets
that. `hyprland.conf` is gone; `configs/hypr/lua/` holds numbered modules that
load in order:

| File | What is in it |
| --- | --- |
| `lib/theme.lua` | the palette, shared |
| `lib/programs.lua` | **generated** — commands and store paths from Nix |
| `10-options.lua` | look, feel, input, monitors |
| `20-rules.lua` | window and workspace rules |
| `30-binds.lua` | keybinds |
| `40-laptop.lua` | the F-row, the lid, the power button |
| `50-autostart.lua` | the daemons |
| `90-machine.lua` | **generated** — keyboard layout, loaded last so it wins |

`hypridle`, `hyprlock` and `hyprpaper` are still hyprlang — only the
compositor moved.

To add a bind without touching the repo's files, use `hyprland.extraLua` in
`home/default.nix`. It is appended after everything above, and Hyprland lets
the last call win.

---

## Keybinds

`SUPER` throughout.

| Keys | Action |
| --- | --- |
| `Return` | Terminal |
| `D` | App launcher |
| `E` / `SHIFT`+`E` | File manager / Yazi |
| `B` | Browser |
| `` ` `` | Scratchpad terminal |
| `T` / `SHIFT`+`T` | Appearance menu / toggle dark–light |
| `SHIFT` + `N` / `A` / `P` | Network / audio / performance TUI |
| `Q` | Close window |
| `F` / `SHIFT`+`F` | Fullscreen / maximize |
| `SHIFT`+`SPACE` | Toggle floating |
| `C` | Centre window |
| `1`–`0` | Workspace 1–10 |
| `SHIFT` + `1`–`0` | Move window to workspace |
| arrows, or `H` `N` `K` `L` | Move focus |
| `SHIFT` + arrows | Move window |
| `CTRL` + arrows | Resize window |
| `ALT`+`Tab` | Cycle windows |
| `SHIFT`+`S` / `Print` | Screenshot region / screen |
| `Escape` | Lock |

Scrolling over the desktop with `SUPER` held cycles workspaces; a three-finger
swipe does the same.

In Neovim, leader is `Space`; press it and wait, and which-key lists what
follows. In WezTerm, `CTRL`+`SHIFT`+`Space` is quick-select — it labels every
path, URL and store path on screen so you can copy one with two keystrokes.

---

## Why the dark theme took four settings

The original problem: a dark desktop, a white Firefox window, and a Bluetooth
tray menu that came up white with blank squares where icons should be.

That is not one bug. Four independent systems each decide, separately, whether
an app draws itself dark:

1. **GTK3** reads `gtk-theme-name` and `gtk-application-prefer-dark-theme`.
2. **GTK4 / libadwaita** largely ignores the theme name and reads
   `org.gnome.desktop.interface color-scheme`.
3. **Qt** follows its platform theme. The bar's tray menus are real `QMenu`s —
   `shell.qml` sets `UseQApplication` — so they follow the Qt palette, not any
   QML colour.
4. **Firefox, Chromium** ask the XDG **appearance portal**, which relays the
   same `color-scheme` key over D-Bus. Only `xdg-desktop-portal-gtk`
   implements it, so it has to be present *and* has to be the one that answers.

`nix/hm/theme.nix` sets all four from one value, and the bar's dark-mode
toggle rewrites the gsettings keys at runtime so the toggle actually moves
GTK apps.

The missing icons were separate: `ThinkpadismIcons` is a recoloured retro set
with no status icons at all, and it inherited only from Adwaita. It now
inherits `Papirus-Dark`, which is installed so the inheritance resolves.

Firefox's white *flash* on startup is a third thing again —
`browser.display.background_color`, painted before the portal has answered.
Pinned in `nix/hm/browsers.nix`.

### The GTK themes are generated

`scripts/make-gtk-themes.py` derives both variants from the upstream Platinum
theme, so the repo carries one copy of the widget geometry:

```sh
python3 scripts/make-gtk-themes.py --check   # preview
```

It works in HLS. Structural greys get their lightness inverted for the dark
variant — which also swaps the bevel highlights and shadows, so a ridge lit
from the top-left stays lit from the top-left. The `#9999FF` selection violet
is rotated onto ThinkPad red at matched lightness, so gradients keep their
shape. Semantic colours (the error red, amber warnings) are left alone. The
bitmap assets go through the same transform, which is the point: recolouring
only the CSS leaves black arrows on a black background.

---

## Things worth knowing about a T420

- **Graphics.** Sandy Bridge means `intel-vaapi-driver` (i965), not
  `intel-media-driver` — the latter is Broadwell and newer, and installing it
  here silently gets you software decoding. WezTerm is pinned to the OpenGL
  front end for the same reason: the HD 3000 has no usable Vulkan driver, and
  WebGpu falls back to software without saying so.
- **Battery.** Charging is capped at 85% and resumes below 75%. On a cell this
  old that is the single biggest thing you can do for its remaining life. Set
  `thinkpad.batteryThresholds = null` in `hosts/thinkpad` if you need the
  range more.
- **Suspend.** `mem_sleep_default=deep`. s2idle on this generation is barely a
  power saving at all.
- **Blur and animations are off**, everywhere, on purpose. They are the two
  most expensive things a compositor does and this GPU has no headroom.
- **zram** at 50% of RAM. These shipped with 4–8GB of DDR3; compressed swap in
  RAM beats swapping to the SSD by a wide margin.
- **The lid**: closing it suspends on battery, and on AC or docked just turns
  the internal panel off and carries on.
- `bat-health` prints the battery's wear. `powertop` and `sensors` are
  installed.

---

## Terminal extras

`ani-cli` is installed, which searches and streams straight into mpv with no
browser involved. `yt-dlp`, `imv`, `cava` and `fastfetch` come with it, plus
`cmatrix`, `pipes-rs`, `cbonsai` and `tty-clock` for when you want the screen
to look busy. Turn any group off with `extras.{anime,media,toys} = false`.

Shell side: `eza`, `bat`, `ripgrep`, `fd`, `fzf`, `zoxide`, `lazygit`,
`starship`, and `rebuild` / `update` / `gc` aliases that point at this repo.

---

## Customising

Machine-specific values — username, hostname, monitor, keyboard, timezone —
all live in `machine.nix`. Beyond that, almost everything is an option on
`programs.thinkpadism` in `home/default.nix` or `services.thinkpadism` in
`hosts/thinkpad/default.nix`:

```nix
programs.thinkpadism = {
  theme = "thinkpad-dark";        # or thinkpad-light, yorha, cherry, ...
  terminal = "wezterm";
  browser = "librewolf";
  tools.network = "impala";       # if you run iwd rather than NetworkManager
  neovim.languageServers = false; # saves about a gigabyte
  extras.toys = false;
  hyprland.extraLua = '' ... '';
};
```

Colour schemes for the bar live in `configs/quickshell/Config.qml`; anything
added to the `themes` map shows up in the Appearance menu automatically.

To use just one piece in your own configuration, the flake exports
`nixosModules.thinkpadism`, `homeManagerModules.thinkpadism`, and the
individual packages.

### Development

```sh
nix develop          # qmlls, pillow, alejandra, nixd, stylua
nix flake check
quickshell -p ./configs/quickshell    # run the bar against this checkout
```

---

## Credits

Linux Retroism, the base this is forked from, is by
[diinki](https://github.com/diinki) —
[repo](https://github.com/diinki/linux-retroism) ·
[ko-fi](https://ko-fi.com/diinki) · [youtube](https://youtube.com/@diinkikot).

The Platinum GTK theme is diinki's fork of a Mac OS 9 pastiche. Wallpapers by
96YOTTEA and others, as credited upstream.

## License

MIT, as upstream. See `LICENSE`.
