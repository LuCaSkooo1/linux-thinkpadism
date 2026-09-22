import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

import ".."

/* NOTE:
*  This entire module is quite a mess, and is likely going to get a complete re-write.
*  I'm experimenting with creating the entire window frame/designs with SVG in order to
*  skip the need of creating everything out of rectangles and borders.
*/
PopupWindow {
    id: root

    property int menuWidth: 0
    property var closeCallback: function () {}
    anchor.window: taskbar
    anchor.rect.x: menuWidth
    anchor.rect.y: parentWindow.implicitHeight
    implicitWidth: 480
    implicitHeight: 276
    color: "transparent"

    Rectangle {
        id: frame
        opacity: 0
        anchors.fill: parent
        color: Config.colors.base
        layer.enabled: true

        property int topOffset: 20

        PopupWindowFrame {
            id: startMenuFrame
            windowTitle: "Your Computer"
            windowTitleIcon: "\ue30c"
            windowTitleDecorationWidth: 150
            Item {
                id: content
                anchors.fill: startMenuFrame
                anchors.margins: 18
                anchors.topMargin: frame.topOffset + 18

                ColumnLayout {
                    spacing: 8
                    RowLayout {
                        spacing: 8
                        implicitWidth: content.width

                        Item {
                            id: profile
                            implicitWidth: 150
                            implicitHeight: 150

                            readonly property bool hasImage: Config.settings.systemProfileImageSource !== "" && profileImage.status === Image.Ready

                            Image {
                                id: profileImage
                                asynchronous: true
                                anchors.fill: parent
                                source: Config.settings.systemProfileImageSource
                                fillMode: Image.PreserveAspectCrop
                                clip: true
                                visible: profile.hasImage
                            }

                            // Placeholder until a picture is set in settings.json.
                            Item {
                                anchors.fill: parent
                                visible: !profile.hasImage

                                Rectangle {
                                    anchors.fill: parent
                                    color: Config.colors.shadow
                                    opacity: 0.35
                                }
                                Text {
                                    anchors.centerIn: parent
                                    font.family: iconFont.name
                                    font.pixelSize: 72
                                    opacity: 0.35
                                    color: Config.colors.text
                                    text: "\ue30c"          // desktop_windows
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: Config.colors.outline
                                border.width: 1
                            }
                        }
                        Item {
                            id: headerContent
                            Layout.fillWidth: true
                            implicitHeight: 150
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: Config.colors.outline
                                border.width: 1
                            }

                            Item {
                                anchors.fill: parent
                                anchors.margins: 8
                                ColumnLayout {
                                    spacing: 8

                                    RowLayout {
                                        spacing: 8
                                        Text {
                                            font.family: iconFont.name
                                            font.pixelSize: 16
                                            text: "\ue161"
                                            color: Config.colors.text
                                        }
                                        Text {
                                            font.family: fontMonaco.name
                                            font.pixelSize: 14
                                            text: Config.settings.systemDetails.osName
                                            color: Config.colors.text
                                        }
                                    }
                                    RowLayout {
                                        spacing: 8
                                        Text {
                                            font.family: iconFont.name
                                            font.pixelSize: 16
                                            text: "\ue394"
                                            color: Config.colors.text
                                        }
                                        Text {
                                            font.family: fontMonaco.name
                                            font.pixelSize: 14
                                            text: Config.settings.systemDetails.osVersion
                                            color: Config.colors.text
                                        }
                                    }
                                    RowLayout {
                                        spacing: 8
                                        Text {
                                            font.family: iconFont.name
                                            font.pixelSize: 16
                                            text: "\uf7a3"
                                            color: Config.colors.text
                                        }
                                        Text {
                                            font.family: fontMonaco.name
                                            font.pixelSize: 14
                                            text: Config.settings.systemDetails.ram
                                            color: Config.colors.text
                                        }
                                    }
                                    RowLayout {
                                        spacing: 8
                                        Text {
                                            font.family: iconFont.name
                                            font.pixelSize: 16
                                            text: "\ue322"
                                            color: Config.colors.text
                                        }
                                        Text {
                                            font.family: fontMonaco.name
                                            font.pixelSize: 14
                                            text: Config.settings.systemDetails.cpu
                                            color: Config.colors.text
                                        }
                                    }
                                    RowLayout {
                                        spacing: 8
                                        Text {
                                            font.family: iconFont.name
                                            font.pixelSize: 16
                                            text: "\ue2ac"
                                            color: Config.colors.text
                                        }

                                        Text {
                                            font.family: fontMonaco.name
                                            font.pixelSize: 14
                                            text: Config.settings.systemDetails.gpu
                                            color: Config.colors.text
                                        }
                                    }
                                }
                            }
                        }
                    }
                    RowLayout {
                        spacing: 8
                        implicitWidth: content.width

                        // Terminal tools, stacked beside the big launchers.
                        Item {
                            implicitWidth: 150
                            implicitHeight: 60
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: Config.colors.outline
                                border.width: 1
                            }
                            GridLayout {
                                anchors.centerIn: parent
                                columns: 2
                                rowSpacing: 4
                                columnSpacing: 4

                                Repeater {
                                    model: [
                                        {
                                            "glyph": "\ue2c7",
                                            "tool": Config.settings.execCommands.tuiFiles
                                        },
                                        {
                                            "glyph": "\ue63e",
                                            "tool": Config.settings.execCommands.tuiNetwork
                                        },
                                        {
                                            "glyph": "\ue050",
                                            "tool": Config.settings.execCommands.tuiAudio
                                        },
                                        {
                                            "glyph": "\ue9e4",
                                            "tool": Config.settings.execCommands.tuiPerformance
                                        }
                                    ]

                                    Button {
                                        id: tuiButton
                                        required property var modelData

                                        implicitWidth: 24
                                        implicitHeight: 24

                                        onClicked: () => {
                                            root.launchTui(modelData.tool);
                                            root.closeCallback();
                                        }

                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: tuiHover.hovered ? Config.colors.shadow : "transparent"
                                            border.width: 1
                                            border.color: Config.colors.outline
                                        }
                                        Text {
                                            anchors.centerIn: parent
                                            font.family: iconFont.name
                                            font.pixelSize: 15
                                            color: tuiHover.hovered ? Config.colors.accent : Config.colors.text
                                            text: tuiButton.modelData.glyph
                                        }
                                        HoverHandler {
                                            id: tuiHover
                                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: 60
                            Layout.leftMargin: 1
                            RowLayout {
                                spacing: 14

                                Repeater {
                                    model: [
                                        {
                                            "glyph": "\ue2c7",
                                            "action": "files"
                                        },
                                        {
                                            "glyph": "\ueb8e",
                                            "action": "terminal"
                                        },
                                        {
                                            "glyph": "\ue8b8",
                                            "action": "settings"
                                        },
                                        {
                                            "glyph": "\uf418",
                                            "action": "power"
                                        }
                                    ]

                                    Button {
                                        id: bigButton
                                        required property var modelData

                                        implicitHeight: 60
                                        implicitWidth: 60

                                        onClicked: () => {
                                            root.runAction(modelData.action);
                                        }

                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: Config.colors.outline
                                            opacity: bigHover.hovered ? (0.2 + (bigButton.pressed ? 0.2 : 0.0)) : 0.1
                                            border.width: 1
                                        }
                                        NewBorder {
                                            commonBorderWidth: 2
                                            commonBorder: false
                                            lBorderwidth: 2
                                            rBorderwidth: 2
                                            tBorderwidth: 2
                                            bBorderwidth: 2
                                            zValue: -1
                                            borderColor: Config.colors.shadow
                                        }
                                        NewBorder {
                                            commonBorderWidth: 2
                                            commonBorder: false
                                            lBorderwidth: 2
                                            rBorderwidth: 0
                                            tBorderwidth: 2
                                            bBorderwidth: 0
                                            zValue: -1
                                            opacity: 0.8
                                            borderColor: Config.colors.highlight
                                        }
                                        Text {
                                            anchors.centerIn: parent
                                            font.family: iconFont.name
                                            font.pixelSize: 48
                                            opacity: bigHover.hovered ? 0.85 : 0.4
                                            color: bigHover.hovered && bigButton.modelData.action === "power" ? Config.colors.urgent : (bigHover.hovered ? Config.colors.accent : Config.colors.text)
                                            text: bigButton.modelData.glyph
                                        }
                                        HoverHandler {
                                            id: bigHover
                                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }


        /*=== Animations ===*/
        OpacityAnimator {
            id: openAnimation
            target: frame
            from: 0
            to: 1
            duration: 140
            easing.type: Easing.OutCubic
        }
        OpacityAnimator {
            id: closeAnimation
            target: frame
            from: 1
            to: 0
            duration: 80
            easing.type: Easing.InOutQuad
            onFinished: root.visible = false
        }
    }

    /* Run one of the four big launcher buttons. */
    function runAction(action) {
        switch (action) {
        case "files":
            Quickshell.execDetached(Config.settings.execCommands.files);
            break;
        case "terminal":
            Quickshell.execDetached(Config.settings.execCommands.terminal);
            break;
        case "settings":
            Config.openSettingsWindow = true;
            break;
        case "power":
            // Handed to the session manager rather than run directly, so it
            // respects inhibitors and whatever the distro wired up.
            Quickshell.execDetached(["sh", "-c", "loginctl poweroff || systemctl poweroff"]);
            break;
        }
        root.closeCallback();
    }

    /* Open a terminal tool in the configured terminal. */
    function launchTui(tool) {
        if (!tool || tool === "")
            return;
        Quickshell.execDetached(["sh", "-c", `${Config.settings.execCommands.terminal} -e ${tool}`]);
    }

    function openStartMenu() {
        root.visible = true;
        openAnimation.start();
    }

    function closeStartMenu() {
        closeAnimation.start();
    }
}
