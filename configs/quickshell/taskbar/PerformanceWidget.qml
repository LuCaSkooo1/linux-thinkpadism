import Quickshell
import QtQuick
import QtQuick.Layouts

import ".."
import "../services" as Services

/* CPU / RAM / temperature readout.
 *
 * Each metric is a glyph plus a value, with a thin red load bar underneath
 * that fills as the machine gets busier. Clicking anywhere on the widget
 * opens the TUI system monitor. */
Item {
    id: root

    // Sized by the row inside it, so the taskbar's own layout still measures
    // this widget correctly.
    implicitWidth: metrics.implicitWidth
    implicitHeight: Math.max(20, metrics.implicitHeight)
    visible: Config.settings.bar.showPerformance

    // A single metric: icon, number, and a load bar.
    component Metric: Item {
        id: metric

        property string glyph: ""
        property string label: ""
        property int load: 0            // 0-100, drives the bar
        property bool showBar: true

        implicitWidth: metricRow.implicitWidth
        implicitHeight: 20

        RowLayout {
            id: metricRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Text {
                font.family: iconFont.name
                font.pixelSize: Config.settings.bar.fontSize + 4
                text: metric.glyph
                color: Config.colors.text
                opacity: 0.8
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                text: metric.label
                font.family: fontMonaco.name
                font.pixelSize: Config.settings.bar.fontSize
                color: metric.load >= 90 ? Config.colors.accent : Config.colors.text
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Load bar pinned to the bottom of the metric.
        Rectangle {
            visible: metric.showBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 2
            color: Config.colors.shadow

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * Math.max(0, Math.min(100, metric.load)) / 100
                color: metric.load >= 90 ? Config.colors.urgent : Config.colors.accent

                Behavior on width {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    RowLayout {
        id: metrics
        anchors.fill: parent
        spacing: 8

        Metric {
            id: cpu
            glyph: "\ue322"                 // memory (chip)
            label: Services.SysMon.cpuPercent + "%"
            load: Services.SysMon.cpuPercent
        }

        Metric {
            id: ram
            glyph: "\uf7a3"                 // memory_alt (RAM sticks)
            label: Services.SysMon.memPercent + "%"
            load: Services.SysMon.memPercent
        }

        Metric {
            id: temp
            // Hidden when no thermal sensor could be found.
            visible: Services.SysMon.temperature > 0
            glyph: "\ue1ff"                 // device_thermostat
            label: Services.SysMon.temperature + "°"
            // ~45°C idle to ~95°C hot maps onto the bar.
            load: Math.round((Services.SysMon.temperature - 45) / 50 * 100)
        }
    }

    // Whole widget is a click target for the TUI monitor.
    MouseArea {
        id: mouse
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: Quickshell.execDetached(["sh", "-c", `${Config.settings.execCommands.terminal} -e ${Config.settings.execCommands.tuiPerformance}`])
    }

    Tooltip {
        anchorItem: root
        hovered: mouse.containsMouse
        text: {
            const gb = Services.SysMon.memUsedGb.toFixed(1) + " / " + Services.SysMon.memTotalGb.toFixed(1) + " GiB";
            return `CPU ${Services.SysMon.cpuPercent}%  ·  RAM ${gb}  ·  click for ${Config.settings.execCommands.tuiPerformance}`;
        }
    }
}
