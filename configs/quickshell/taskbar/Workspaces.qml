import Quickshell
import Quickshell.Hyprland
import Quickshell.I3
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import ".."

/* Fixed strip of workspace buttons, 1..Config.settings.bar.workspaceCount.
 *
 * Unlike the upstream version this always draws every slot, whether or not
 * the compositor has created it yet, so the bar never reflows as windows come
 * and go. Empty slots are dimmed, occupied ones are solid, and the focused
 * one is drawn pressed-in with a red marker.
 */
RowLayout {
    id: workspaces
    spacing: 3
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter

    readonly property bool usingHyprland: Hyprland.workspaces.values.length > 0

    // Workspace ids that currently exist on *this* monitor, used to decide
    // which slots are "occupied".
    readonly property var liveIds: {
        const src = usingHyprland ? Hyprland.workspaces.values : I3.workspaces.values;
        return src.filter(w => w.monitor && w.monitor.name === taskbar.screen.name).map(w => usingHyprland ? w.id : w.number);
    }

    readonly property var urgentIds: {
        const src = usingHyprland ? Hyprland.workspaces.values : I3.workspaces.values;
        return src.filter(w => w.urgent).map(w => usingHyprland ? w.id : w.number);
    }

    readonly property int focusedId: {
        if (usingHyprland)
            return Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1;
        return I3.focusedWorkspace ? I3.focusedWorkspace.number : -1;
    }

    function switchTo(id) {
        if (usingHyprland)
            Hyprland.dispatch(`workspace ${id}`);
        else
            I3.dispatch(`workspace ${id}`);
    }

    Repeater {
        model: Config.settings.bar.workspaceCount

        Button {
            id: control

            // Repeater's `index` is 0-based; workspaces are 1-based.
            readonly property int wsId: index + 1
            readonly property bool occupied: workspaces.liveIds.indexOf(wsId) !== -1
            readonly property bool focused: workspaces.focusedId === wsId
            readonly property bool urgent: workspaces.urgentIds.indexOf(wsId) !== -1

            implicitWidth: 22
            implicitHeight: 22

            contentItem: Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                // 10 is shown as "0", the key that actually switches to it.
                text: control.wsId === 10 ? "0" : control.wsId
                font.family: fontMonaco.name
                font.pixelSize: Config.settings.bar.fontSize
                font.bold: control.focused
                color: control.focused ? Config.colors.accent : Config.colors.text
                opacity: control.occupied || control.focused ? 1.0 : 0.45
            }

            onPressed: event => {
                workspaces.switchTo(control.wsId);
                event.accepted = true;
            }

            NewBorder {
                commonBorderWidth: 2
                commonBorder: false
                lBorderwidth: -2
                rBorderwidth: 0
                tBorderwidth: -4
                bBorderwidth: -1
                borderColor: Config.colors.outline
                zValue: -1
            }

            function slotColor() {
                if (control.urgent)
                    return Config.colors.urgent;
                if (control.focused)
                    return Config.colors.highlight;
                if (mouse.hovered)
                    return Config.colors.shadow;
                return Config.colors.base;
            }

            background: Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                border.width: 1
                border.color: control.focused ? Config.colors.accent : Config.colors.outline
                width: 22
                height: 22
                color: control.slotColor()

                // Red underline marking the workspace that has windows on it.
                Rectangle {
                    visible: control.occupied && !control.focused
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 2
                    width: 8
                    height: 2
                    color: Config.colors.accent
                }
            }

            HoverHandler {
                id: mouse
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    // Scrolling anywhere over the strip cycles workspaces, which is the one
    // thing a trackpad makes genuinely pleasant.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            const dir = wheel.angleDelta.y > 0 ? -1 : 1;
            const count = Config.settings.bar.workspaceCount;
            let next = workspaces.focusedId + dir;
            if (next < 1)
                next = count;
            if (next > count)
                next = 1;
            workspaces.switchTo(next);
        }
    }
}
