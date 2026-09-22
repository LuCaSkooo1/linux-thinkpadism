pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

import ".."

/* Wallpaper discovery and switching.
 *
 * The directory from Config.settings.wallpaperDirectory is scanned for images;
 * applying one goes through hyprpaper on Hyprland and swaybg everywhere else.
 * The choice is written back to settings.json so it survives a restart.
 */
Singleton {
    id: root

    // Absolute paths of every wallpaper found, sorted by filename.
    property var list: []
    property string current: Config.settings.currentWallpaper

    readonly property bool onHyprland: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== ""

    // Expand a leading "~" since neither hyprctl nor swaybg does it for us.
    function expand(path) {
        if (path.startsWith("~/"))
            return Quickshell.env("HOME") + path.slice(1);
        return path;
    }

    function refresh() {
        scanner.running = true;
    }

    Component.onCompleted: {
        refresh();
        // Re-apply the saved wallpaper on login so the desktop comes back the
        // way it was left.
        if (current !== "")
            apply(current, false);
    }

    // Re-scan whenever the configured directory changes.
    Connections {
        target: Config.settings
        function onWallpaperDirectoryChanged() {
            root.refresh();
        }
    }

    Process {
        id: scanner
        command: ["sh", "-c", `find "${root.expand(Config.settings.wallpaperDirectory)}" -maxdepth 2 \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\) -type f 2>/dev/null | sort`]
        stdout: StdioCollector {
            onStreamFinished: {
                const found = text.split("\n").filter(l => l.trim() !== "");
                root.list = found;
                if (found.length === 0)
                    console.info("Wallpapers: nothing found in " + Config.settings.wallpaperDirectory);
            }
        }
    }

    /* Apply a wallpaper to every monitor.
     * `persist` writes the choice to settings.json; pass false when merely
     * restoring what was already saved. */
    function apply(path, persist) {
        if (!path || path === "")
            return;

        const p = expand(path);
        if (onHyprland) {
            // `reload` preloads the new image, sets it on all monitors (the
            // empty monitor field) and drops the previous one from memory.
            setter.command = ["hyprctl", "hyprpaper", "reload", `,${p}`];
        } else {
            // swaybg has no IPC, so replace the running instance.
            setter.command = ["sh", "-c", `pkill -x swaybg; swaybg -i '${p.replace(/'/g, "'\\''")}' -m fill &`];
        }
        setter.running = true;

        if (persist !== false)
            Config.settings.currentWallpaper = path;
        root.current = path;
    }

    Process {
        id: setter
        command: ["true"]
    }

    // Pretty name for the UI: filename without extension.
    function displayName(path) {
        const file = path.split("/").pop();
        const dot = file.lastIndexOf(".");
        return dot > 0 ? file.slice(0, dot) : file;
    }
}
