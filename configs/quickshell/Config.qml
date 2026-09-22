pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    //*=======================================================================*/
    // READ THIS NOTE:
    // Simply add to this list in order to create your
    // own color schemes, they will automatically show up in the theme picker.
    //
    // Every theme carries a `dark` flag; the light/dark toggle in the theme
    // menu flips between the themes named in `lightTheme` / `darkTheme`.
    property var colors: themes[themes[settings.currentTheme] == null ? 'thinkpad-dark' : settings.currentTheme]

    // The pair the light/dark toggle switches between.
    readonly property string lightTheme: "thinkpad-light"
    readonly property string darkTheme: "thinkpad-dark"
    readonly property bool isDark: colors.dark === true

    property var themes: {
        "thinkpad-light": {
            "base": "#d6d3ce",
            "shadow": "#9a9691",
            "highlight": "#f2f0ed",
            "urgent": "#ff7043",
            "accent": "#b3121d",
            "accentAlt": "#e0303c",
            "text": "#121212",
            "outline": "#141414",
            "outlineGradientFade": "#3a2022",
            "dark": false,
            "defaultWallpaperPath": ""
        },
        "thinkpad-dark": {
            "base": "#232323",
            "shadow": "#141414",
            "highlight": "#343434",
            "urgent": "#ff7043",
            "accent": "#e0303c",
            "accentAlt": "#ff5a63",
            "text": "#e6e4e1",
            "outline": "#080808",
            "outlineGradientFade": "#4a1a1e",
            "dark": true,
            "defaultWallpaperPath": ""
        },
        "default": {
            "base": "#d8d8d8",
            "shadow": "#9b9b9b",
            "highlight": "#efefef",
            "urgent": "#ff723e",
            "accent": "#207874",
            "accentAlt": "#2a9b96",
            "text": "#000000",
            "outline": "#000000",
            "outlineGradientFade": "#161616",
            "dark": false,
            "defaultWallpaperPath": ""
        },
        "yorha": {
            "base": "#d9caba",
            "shadow": "#baafa1",
            "highlight": "#f0e2d3",
            "urgent": "#ff854c",
            "accent": "#626335",
            "accentAlt": "#7d7e45",
            "text": "#3e3d38",
            "outline": "#3d3d39",
            "outlineGradientFade": "#5b5b45",
            "dark": false,
            "defaultWallpaperPath": ""
        },
        "cherry": {
            "base": "#f4c9ef",
            "shadow": "#c7a4cc",
            "highlight": "#f9d0f7",
            "urgent": "#ff936c",
            "accent": "#c950bb",
            "accentAlt": "#dd6ecf",
            "text": "#321d32",
            "outline": "#20091d",
            "outlineGradientFade": "#3e233e",
            "dark": false,
            "defaultWallpaperPath": ""
        },
        "indigo": {
            "base": "#bac4e6",
            "shadow": "#7e8bad",
            "highlight": "#d0def9",
            "urgent": "#e83939",
            "accent": "#3e7c99",
            "accentAlt": "#4f9bbd",
            "text": "#0d0d19",
            "outline": "#1a2135",
            "outlineGradientFade": "#223143",
            "dark": false,
            "defaultWallpaperPath": ""
        },
        "gleep": {
            "base": "#bae6c5",
            "shadow": "#93c48c",
            "highlight": "#ccf9e7",
            "urgent": "#ff7559",
            "accent": "#3e9949",
            "accentAlt": "#4fb85c",
            "text": "#0d1913",
            "outline": "#21351a",
            "outlineGradientFade": "#284223",
            "dark": false,
            "defaultWallpaperPath": ""
        }
    }

    enum SystemPopup {
        Startmenu,
        ThemePicker,
        AppLauncher,
        None
    }

    property bool openSettingsWindow: false

    /*=== Theme helpers ===*/

    /* Tell the rest of the desktop whether we're dark or light.
     *
     * Three separate keys, because three separate toolkits read three
     * different things:
     *
     *   color-scheme  GTK4/libadwaita, and everything that asks the XDG
     *                 appearance portal -- Firefox, LibreWolf, Chromium.
     *   gtk-theme     GTK3, which ignores color-scheme and wants to be
     *                 handed a different theme by name.
     *   prefer-dark   GTK3's own dark switch, for themes that ship both
     *                 variants in one directory.
     *
     * Writing only the first is what leaves a dark desktop with white
     * GTK3 menus and a white Firefox chrome.
     */
    readonly property string lightGtkTheme: "ThinkpadismPlatinum"
    readonly property string darkGtkTheme: "ThinkpadismPlatinumDark"

    onIsDarkChanged: syncColorScheme()
    Component.onCompleted: syncColorScheme()

    function syncColorScheme() {
        const iface = "/org/gnome/desktop/interface/";
        Quickshell.execDetached(["dconf", "write", iface + "color-scheme",
                                 isDark ? "'prefer-dark'" : "'prefer-light'"]);
        Quickshell.execDetached(["dconf", "write", iface + "gtk-theme",
                                 isDark ? ("'" + darkGtkTheme + "'") : ("'" + lightGtkTheme + "'")]);
        Quickshell.execDetached(["dconf", "write",
                                 "/org/gnome/desktop/interface/gtk-application-prefer-dark-theme",
                                 isDark ? "true" : "false"]);
    }

    // Flip between the configured light and dark themes. If the user is on
    // some other theme entirely (cherry, gleep, ...) we jump to the dark one,
    // since that is the least surprising thing a "dark mode" button can do.
    function toggleDarkMode() {
        setTheme(isDark ? lightTheme : darkTheme);
    }

    function setTheme(name) {
        if (themes[name] == null) {
            console.warn("Refusing to switch to unknown theme: " + name);
            return;
        }
        settings.currentTheme = name;
    }

    /* Where settings.json lives.
     *
     * Deliberately NOT next to the QML. Under Nix the config directory is a
     * read-only symlink into the store, so a shell that writes its settings
     * beside its own source cannot save anything -- no theme switch, no
     * wallpaper choice would survive a restart. Keeping state in
     * $XDG_CONFIG_HOME/thinkpadism/ leaves the code immutable and the
     * settings writable, which is what both Nix and a plain install want.
     */
    readonly property string settingsPath: {
        const xdg = Quickshell.env("XDG_CONFIG_HOME");
        const base = xdg && xdg !== "" ? xdg : Quickshell.env("HOME") + "/.config";
        return base + "/thinkpadism/settings.json";
    }

    property alias settings: settingsJsonAdapter.settings
    FileView {
        id: settingsFile
        path: root.settingsPath
        // when changes are made on disk, reload the file's content
        watchChanges: true
        onFileChanged: reload()
        // when changes are made to properties in the adapter, save them
        onAdapterUpdated: writeAdapter()

        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                // First run: make sure the directory exists before writing the
                // defaults into it.
                settingsDirInit.running = true;
            }
        }

        JsonAdapter {
            id: settingsJsonAdapter
            property JsonObject settings: JsonObject {
                property string version: "0.2"
                property bool militaryTimeClockFormat: true
                property string systemProfileImageSource: ""
                property string currentTheme: "thinkpad-dark"
                property bool setWallpaperToThemeWallpaper: true

                // Directory scanned by the wallpaper switcher. "~" is expanded.
                property string wallpaperDirectory: "~/Pictures/Wallpapers"
                // Last wallpaper applied, re-applied on login.
                property string currentWallpaper: ""

                property JsonObject execCommands: JsonObject {
                    property string terminal: "kitty"
                    property string files: "nemo"
                    // TUI tools, launched inside the terminal.
                    property string tuiFiles: "yazi"
                    property string tuiNetwork: "nmtui"
                    property string tuiAudio: "wiremix"
                    property string tuiPerformance: "btop"
                }
                // Left blank on purpose: the start menu probes /proc and
                // /etc/os-release for anything not set here. Fill a field in
                // to override what it found.
                property JsonObject systemDetails: JsonObject {
                    property string osName: ""
                    property string osVersion: ""
                    property string ram: ""
                    property string cpu: ""
                    property string gpu: ""
                }
                property JsonObject bar: JsonObject {
                    property int fontSize: 12
                    property int trayIconSize: 16
                    property bool monochromeTrayIcons: true

                    // Widget toggles, so the bar can be trimmed down on small screens.
                    property bool showBattery: true
                    property bool showPerformance: true
                    property bool showDate: true
                    property int workspaceCount: 10
                }

                onCurrentThemeChanged: {
                    console.info("Updated theme to: " + currentTheme);
                }
            }
        }
    }

    // Creates $XDG_CONFIG_HOME/thinkpadism/ on first run, then writes the
    // default settings into it.
    Process {
        id: settingsDirInit
        command: ["mkdir", "-p", root.settingsPath.substring(0, root.settingsPath.lastIndexOf("/"))]
        onExited: (code, status) => {
            if (code === 0)
                settingsFile.writeAdapter();
            else
                console.warn("Could not create settings directory for " + root.settingsPath);
        }
    }
}
