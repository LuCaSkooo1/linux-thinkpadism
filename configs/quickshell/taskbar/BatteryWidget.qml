import Quickshell
import QtQuick
import QtQuick.Layouts

import ".."
import "../services" as Services

/* Battery indicator: glyph, percentage, and a tooltip with time remaining.
 * Hides itself entirely on machines without a battery. */
RowLayout {
    id: root
    spacing: 3
    visible: Config.settings.bar.showBattery && Services.Battery.available

    readonly property color stateColor: {
        if (Services.Battery.critical)
            return Config.colors.urgent;
        if (Services.Battery.low)
            return Config.colors.accent;
        return Config.colors.text;
    }

    Text {
        id: batteryIcon
        font.family: iconFont.name
        font.pixelSize: Config.settings.bar.fontSize + 6
        text: Services.Battery.icon
        color: root.stateColor
        verticalAlignment: Text.AlignVCenter
    }

    // Pulse when the charge gets dangerous. Static otherwise, in keeping with
    // the rest of the bar. Declared outside the Text and targeted explicitly,
    // since an Animation has no `parent` to fall back on.
    SequentialAnimation {
        id: criticalPulse
        running: Services.Battery.critical
        loops: Animation.Infinite

        NumberAnimation {
            target: batteryIcon
            property: "opacity"
            from: 1.0
            to: 0.35
            duration: 800
        }
        NumberAnimation {
            target: batteryIcon
            property: "opacity"
            from: 0.35
            to: 1.0
            duration: 800
        }

        // Leave the glyph fully visible when the pulse stops mid-fade.
        onRunningChanged: if (!running)
            batteryIcon.opacity = 1.0
    }

    Text {
        text: Services.Battery.percent + "%"
        color: root.stateColor
        font.pixelSize: Config.settings.bar.fontSize
        font.family: fontMonaco.name
        verticalAlignment: Text.AlignVCenter
    }

    HoverHandler {
        id: mouse
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    Tooltip {
        anchorItem: root
        hovered: mouse.hovered
        text: {
            const remaining = Services.Battery.formatTime(Services.Battery.timeRemaining);
            if (Services.Battery.full)
                return "Battery full";
            if (Services.Battery.charging)
                return remaining !== "" ? `Charging — ${remaining} until full` : "Charging";
            return remaining !== "" ? `${remaining} remaining` : `${Services.Battery.percent}% remaining`;
        }
    }
}
