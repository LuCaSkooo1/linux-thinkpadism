pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

/* Lightweight system monitor.
 *
 * Everything here is read straight out of /proc and /sys so it works on a
 * bare NixOS install with no monitoring daemon running. Values are polled on
 * a timer rather than watched, since these files change continuously and
 * inotify is useless on procfs.
 */
Singleton {
    id: root

    // Poll interval in milliseconds. 2s is a decent compromise between a
    // responsive readout and staying out of the way of the CPU we measure.
    property int interval: 2000

    readonly property int cpuPercent: Math.round(cpuUsage * 100)
    readonly property int memPercent: memTotal > 0 ? Math.round((memTotal - memAvailable) / memTotal * 100) : 0
    readonly property real memUsedGb: (memTotal - memAvailable) / 1048576
    readonly property real memTotalGb: memTotal / 1048576
    readonly property int temperature: cpuTemp

    property real cpuUsage: 0
    property int memTotal: 0
    property int memAvailable: 0
    property int cpuTemp: 0

    // Previous /proc/stat counters, used to turn cumulative jiffies into a rate.
    property int prevIdle: -1
    property int prevTotal: -1

    // The thermal zone holding the CPU package temperature. Discovered once at
    // startup because the numbering differs between machines.
    property string thermalPath: ""

    /*=== Static system details, probed once at startup ===*/
    // Used by the start menu when settings.json leaves them blank.
    property string cpuModel: ""
    property string gpuModel: ""
    property string osName: ""
    property string osVersion: ""

    // Human-readable total memory, e.g. "32 GiB".
    readonly property string memTotalPretty: memTotal > 0 ? Math.round(memTotalGb) + " GiB" : ""

    Process {
        id: probeSystem
        running: true
        command: ["sh", "-c", `
            # CPU model, trimmed of the marketing padding Intel puts in it.
            cpu=$(sed -n 's/^model name[[:space:]]*:[[:space:]]*//p' /proc/cpuinfo | head -1)
            [ -z "$cpu" ] && cpu=$(sed -n 's/^Model[[:space:]]*:[[:space:]]*//p' /proc/cpuinfo | head -1)
            cpu=$(echo "$cpu" | sed 's/([RrCc])//g; s/(TM)//g; s/(tm)//g; s/ CPU @.*//; s/  */ /g')

            # GPU: first VGA/3D controller lspci knows about, if lspci exists.
            gpu=$(lspci 2>/dev/null | sed -n 's/.*VGA compatible controller: //p' | head -1)
            [ -z "$gpu" ] && gpu=$(lspci 2>/dev/null | sed -n 's/.*3D controller: //p' | head -1)

            # Distro name and version.
            name=""; version=""
            if [ -r /etc/os-release ]; then
                name=$(. /etc/os-release 2>/dev/null && echo "$NAME")
                version=$(. /etc/os-release 2>/dev/null && echo "$VERSION_ID")
                [ -z "$version" ] && version=$(. /etc/os-release 2>/dev/null && echo "$BUILD_ID")
            fi

            # One field per line, in a fixed order.
            echo "$cpu"
            echo "$gpu"
            echo "$name"
            echo "$version"
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n");
                root.cpuModel = (lines[0] || "").trim();
                root.gpuModel = (lines[1] || "").trim();
                root.osName = (lines[2] || "").trim();
                root.osVersion = (lines[3] || "").trim();
            }
        }
    }

    Timer {
        interval: root.interval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            procStat.reload();
            procMeminfo.reload();
            if (root.thermalPath !== "")
                thermalFile.reload();
        }
    }

    /*=== CPU ===*/
    FileView {
        id: procStat
        path: "/proc/stat"
        onLoaded: root.parseStat(text())
        onLoadFailed: error => console.warn("SysMon: cannot read /proc/stat")
    }

    function parseStat(data) {
        // First line is the aggregate across all cores:
        //   cpu  user nice system idle iowait irq softirq steal guest guest_nice
        const line = data.split("\n")[0];
        if (!line || !line.startsWith("cpu "))
            return;

        const parts = line.trim().split(/\s+/).slice(1).map(v => parseInt(v, 10));
        if (parts.length < 5)
            return;

        // idle + iowait count as "not working".
        const idle = parts[3] + parts[4];
        let total = 0;
        for (let i = 0; i < parts.length; i++)
            total += parts[i];

        if (prevTotal >= 0) {
            const totalDelta = total - prevTotal;
            const idleDelta = idle - prevIdle;
            if (totalDelta > 0)
                cpuUsage = Math.max(0, Math.min(1, (totalDelta - idleDelta) / totalDelta));
        }

        prevIdle = idle;
        prevTotal = total;
    }

    /*=== Memory ===*/
    FileView {
        id: procMeminfo
        path: "/proc/meminfo"
        onLoaded: root.parseMeminfo(text())
        onLoadFailed: error => console.warn("SysMon: cannot read /proc/meminfo")
    }

    function parseMeminfo(data) {
        const lines = data.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            // Values are in kB.
            if (line.startsWith("MemTotal:"))
                memTotal = parseInt(line.split(/\s+/)[1], 10);
            else if (line.startsWith("MemAvailable:"))
                memAvailable = parseInt(line.split(/\s+/)[1], 10);

            if (memTotal > 0 && memAvailable > 0)
                break;
        }
    }

    /*=== Temperature ===*/
    FileView {
        id: thermalFile
        path: root.thermalPath
        onLoaded: {
            const v = parseInt(text().trim(), 10);
            // Kernel reports millidegrees.
            if (!isNaN(v))
                root.cpuTemp = Math.round(v / 1000);
        }
        onLoadFailed: error => root.cpuTemp = 0
    }

    // Find the hwmon/thermal entry that reports package temperature. Prefers
    // coretemp (Intel) / k10temp (AMD), falling back to acpitz which every
    // ThinkPad exposes.
    Process {
        id: findThermal
        running: true
        command: ["sh", "-c", `
            for hw in /sys/class/hwmon/hwmon*; do
                name=$(cat "$hw/name" 2>/dev/null)
                case "$name" in
                    coretemp|k10temp|zenpower|thinkpad)
                        if [ -f "$hw/temp1_input" ]; then echo "$hw/temp1_input"; exit 0; fi
                        ;;
                esac
            done
            for tz in /sys/class/thermal/thermal_zone*; do
                type=$(cat "$tz/type" 2>/dev/null)
                case "$type" in
                    x86_pkg_temp|acpitz)
                        echo "$tz/temp"; exit 0
                        ;;
                esac
            done
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim();
                if (p !== "")
                    root.thermalPath = p;
                else
                    console.info("SysMon: no thermal sensor found, hiding temperature");
            }
        }
    }
}
