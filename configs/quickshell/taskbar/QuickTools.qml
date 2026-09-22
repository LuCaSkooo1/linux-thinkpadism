import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

import ".."

/* Quick launchers for the terminal tools.
 *
 * Each button opens the configured TUI inside the configured terminal, so
 * swapping yazi for ranger or nmtui for impala is a settings.json edit and
 * nothing more. */
RowLayout {
    id: root
    spacing: 3

    component ToolButton: Button {
        id: btn

        property string glyph: ""
        property string tool: ""
        property string tip: ""

        implicitWidth: 22
        implicitHeight: 22

        onClicked: root.launch(tool)

        NewBorder {
            commonBorderWidth: 1
            commonBorder: false
            lBorderwidth: 0
            rBorderwidth: 1
            tBorderwidth: 0
            bBorderwidth: 1
            borderColor: Config.colors.outline
            zValue: -1
        }

        background: Rectangle {
            anchors.fill: parent
            border.width: 1
            border.color: hover.hovered ? Config.colors.accent : Config.colors.outline
            color: btn.pressed ? Config.colors.shadow : "transparent"

            Text {
                anchors.centerIn: parent
                font.family: iconFont.name
                font.pixelSize: 16
                text: btn.glyph
                color: hover.hovered ? Config.colors.accent : Config.colors.text
            }
        }

        HoverHandler {
            id: hover
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            cursorShape: Qt.PointingHandCursor
        }

        Tooltip {
            anchorItem: btn
            hovered: hover.hovered
            text: btn.tip
        }
    }

    /* Run `tool` inside the configured terminal.
     * Goes through `sh -c` so the terminal name and the tool can each carry
     * their own arguments in settings.json. */
    function launch(tool) {
        if (!tool || tool === "")
            return;
        Quickshell.execDetached(["sh", "-c", `${Config.settings.execCommands.terminal} -e ${tool}`]);
    }

    ToolButton {
        glyph: ""                 // folder
        tool: Config.settings.execCommands.tuiFiles
        tip: "Files — " + Config.settings.execCommands.tuiFiles
    }
    ToolButton {
        glyph: ""                 // wifi
        tool: Config.settings.execCommands.tuiNetwork
        tip: "Network — " + Config.settings.execCommands.tuiNetwork
    }
    ToolButton {
        glyph: ""                 // volume_up
        tool: Config.settings.execCommands.tuiAudio
        tip: "Audio — " + Config.settings.execCommands.tuiAudio
    }
    ToolButton {
        glyph: ""                 // speed
        tool: Config.settings.execCommands.tuiPerformance
        tip: "Performance — " + Config.settings.execCommands.tuiPerformance
    }
}
