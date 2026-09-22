pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick

/* Battery state for the taskbar.
 *
 * UPower is the primary source: its "display device" already aggregates the
 * multiple batteries a ThinkPad may carry into one figure. When upower is not
 * running (it is not enabled by default on a minimal NixOS install) we fall
 * back to reading /sys/class/power_supply directly, summing every battery
 * present, so the indicator still works.
 */
Singleton {
    id: root

    readonly property bool upowerReady: UPower.displayDevice && UPower.displayDevice.isLaptopBattery && UPower.displayDevice.percentage > 0

    // True when a battery exists at all; the widget hides itself otherwise
    // (desktops, VMs).
    readonly property bool available: upowerReady || sysfsPercent >= 0

    readonly property int percent: upowerReady ? Math.round(UPower.displayDevice.percentage * 100) : Math.max(0, sysfsPercent)

    readonly property bool charging: upowerReady ? (UPower.displayDevice.state === UPowerDeviceState.Charging || UPower.displayDevice.state === UPowerDeviceState.FullyCharged) : sysfsCharging

    readonly property bool full: percent >= 97 && charging

    // Seconds remaining, 0 when unknown.
    readonly property int timeRemaining: {
        if (!upowerReady)
            return 0;
        return charging ? UPower.displayDevice.timeToFull : UPower.displayDevice.timeToEmpty;
    }

    readonly property bool low: !charging && percent <= 20
    readonly property bool critical: !charging && percent <= 10

    /*=== sysfs fallback ===*/
    property int sysfsPercent: -1
    property bool sysfsCharging: false

    Timer {
        // Only poll sysfs when UPower is not answering.
        running: !root.upowerReady
        interval: 15000
        repeat: true
        triggeredOnStart: true
        onTriggered: sysfsProbe.running = true
    }

    Process {
        id: sysfsProbe
        command: ["sh", "-c", `
            total=0; count=0; charging=0
            for b in /sys/class/power_supply/BAT*; do
                [ -r "$b/capacity" ] || continue
                cap=$(cat "$b/capacity" 2>/dev/null) || continue
                total=$((total + cap)); count=$((count + 1))
                st=$(cat "$b/status" 2>/dev/null)
                case "$st" in Charging|Full) charging=1 ;; esac
            done
            if [ "$count" -gt 0 ]; then
                echo "$((total / count)) $charging"
            else
                echo "-1 0"
            fi
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(" ");
                if (parts.length < 2)
                    return;
                root.sysfsPercent = parseInt(parts[0], 10);
                root.sysfsCharging = parts[1] === "1";
            }
        }
    }

    // Material Symbols glyph matching the current charge level.
    readonly property string icon: {
        if (charging)
            return "\ue1a3";          // battery_charging_full
        if (critical)
            return "\ue19c";          // battery_alert
        if (percent >= 95)
            return "\ue1a4";          // battery_full
        if (percent >= 85)
            return "\uebd2";          // battery_6_bar
        if (percent >= 70)
            return "\uebd4";          // battery_5_bar
        if (percent >= 55)
            return "\uebe2";          // battery_4_bar
        if (percent >= 40)
            return "\uebdd";          // battery_3_bar
        if (percent >= 25)
            return "\uebe0";          // battery_2_bar
        if (percent >= 10)
            return "\uebd9";          // battery_1_bar
        return "\uebdc";              // battery_0_bar
    }

    // "1h 24m" / "24m", empty when the remaining time is unknown.
    function formatTime(seconds) {
        if (!seconds || seconds <= 0)
            return "";
        const h = Math.floor(seconds / 3600);
        const m = Math.floor((seconds % 3600) / 60);
        return h > 0 ? `${h}h ${m}m` : `${m}m`;
    }
}
