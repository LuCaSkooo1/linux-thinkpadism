# Linux Thinkpadism | Quickshell Frontend

Before going into details:

I must point out the fact that this is my first time using Qt/QML/Quickshell for
a project like this.

I will likely update and refactor the quickshell project to improve things with time, as
the initial versions may not follow best practices for design or readability.

## Style Variants

You can add your own color-schemes in the `Config.qml` file, they will be updated
and added automatically to the theme switcher UI.

Various other settings can be changed/set by editing the `settings.json` file; although
those values can also be changed using the settings GUI.

> I am planning on making a GUI for creating and adding your own themes.

## Where settings live

Runtime settings are read from and written to
`$XDG_CONFIG_HOME/thinkpadism/settings.json` (usually
`~/.config/thinkpadism/settings.json`), **not** from this directory.

That split exists so the QML can be immutable — under Nix this directory is a
read-only symlink into the store, and a shell that wrote its settings beside
its own source could not save a theme or wallpaper change at all.

`configs/thinkpadism/settings.json` in the repo is the seed copied into place
on first install. The shell writes the file itself if it is missing.
