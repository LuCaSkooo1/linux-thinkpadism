import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

import ".."
import "../services" as Services

/* Appearance popup: dark/light toggle, colour schemes, and wallpapers.
 *
 * Both rows are horizontally flickable so the popup keeps a fixed size no
 * matter how many themes or wallpapers exist.
 */
PopupWindow {
    id: root

    property int menuWidth: 0
    property var closeCallback: function () {}

    anchor.window: taskbar
    anchor.rect.x: menuWidth
    anchor.rect.y: parentWindow.implicitHeight
    implicitWidth: 620
    implicitHeight: 360
    color: "transparent"

    Rectangle {
        id: frame
        opacity: 0
        anchors.fill: parent
        color: Config.colors.base
        layer.enabled: true

        property int topOffset: 20

        PopupWindowFrame {
            id: themeMenuFrame
            windowTitle: "Appearance"
            windowTitleIcon: "\ue40a"
            windowTitleDecorationWidth: 210

            Item {
                id: content
                anchors.fill: themeMenuFrame
                anchors.margins: 14
                anchors.topMargin: frame.topOffset + 20
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    /*=== Dark / light toggle ===*/
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Mode"
                            font.family: fontCharcoal.name
                            font.pixelSize: 13
                            color: Config.colors.text
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Repeater {
                            model: [
                                {
                                    "label": "Light",
                                    "glyph": "\ue518",
                                    "theme": Config.lightTheme
                                },
                                {
                                    "label": "Dark",
                                    "glyph": "\ue51c",
                                    "theme": Config.darkTheme
                                }
                            ]

                            Button {
                                id: modeButton
                                required property var modelData

                                readonly property bool active: Config.settings.currentTheme === modelData.theme

                                implicitWidth: 92
                                implicitHeight: 28

                                onClicked: Config.setTheme(modelData.theme)

                                background: Rectangle {
                                    anchors.fill: parent
                                    color: modeButton.active ? Config.colors.highlight : (modeHover.hovered ? Config.colors.shadow : Config.colors.base)
                                    border.width: 1
                                    border.color: modeButton.active ? Config.colors.accent : Config.colors.outline
                                }

                                NewBorder {
                                    commonBorderWidth: 2
                                    commonBorder: false
                                    lBorderwidth: 0
                                    rBorderwidth: 1
                                    tBorderwidth: 0
                                    bBorderwidth: 1
                                    zValue: -1
                                    borderColor: Config.colors.outline
                                }

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        font.family: iconFont.name
                                        font.pixelSize: 16
                                        text: modeButton.modelData.glyph
                                        color: modeButton.active ? Config.colors.accent : Config.colors.text
                                    }
                                    Text {
                                        font.family: fontMonaco.name
                                        font.pixelSize: 13
                                        text: modeButton.modelData.label
                                        color: modeButton.active ? Config.colors.accent : Config.colors.text
                                    }
                                }

                                HoverHandler {
                                    id: modeHover
                                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }

                    /*=== Colour schemes ===*/
                    Text {
                        text: "Theme"
                        font.family: fontCharcoal.name
                        font.pixelSize: 13
                        color: Config.colors.text
                    }

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 104

                        Flickable {
                            id: themeFlick
                            anchors.fill: parent
                            contentWidth: themeRow.width
                            contentHeight: height
                            flickableDirection: Flickable.HorizontalFlick
                            boundsBehavior: Flickable.DragOverBounds
                            maximumFlickVelocity: 3500
                            clip: true

                            property int swatchWidth: 12

                            RowLayout {
                                id: themeRow
                                height: themeFlick.height
                                spacing: 10

                                Repeater {
                                    model: Object.keys(Config.themes)

                                    Button {
                                        id: themeButton
                                        required property var modelData

                                        readonly property bool active: Config.settings.currentTheme === modelData

                                        implicitWidth: 150
                                        implicitHeight: 100
                                        opacity: pressed ? 0.6 : 1
                                        clip: true

                                        onReleased: Config.setTheme(modelData)

                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: themeHover.hovered ? Config.colors.shadow : Config.colors.base
                                            border.width: 1
                                            border.color: themeButton.active ? Config.colors.accent : Config.colors.outline
                                        }

                                        NewBorder {
                                            commonBorderWidth: 2
                                            commonBorder: false
                                            lBorderwidth: 0
                                            rBorderwidth: 1
                                            tBorderwidth: 0
                                            bBorderwidth: 1
                                            zValue: -1
                                            borderColor: Config.colors.outline
                                        }

                                        ColumnLayout {
                                            width: parent.width
                                            height: parent.height
                                            spacing: 2

                                            RowLayout {
                                                Layout.alignment: Qt.AlignHCenter
                                                Layout.topMargin: 10
                                                spacing: 0

                                                Repeater {
                                                    model: ["base", "accent", "highlight", "shadow", "text"]
                                                    Rectangle {
                                                        required property var modelData
                                                        implicitWidth: themeFlick.swatchWidth
                                                        implicitHeight: 46
                                                        color: Config.themes[themeButton.modelData][modelData]
                                                        border.width: 1
                                                        border.color: Config.colors.outline
                                                    }
                                                }
                                            }

                                            Text {
                                                Layout.alignment: Qt.AlignHCenter
                                                font.family: fontMonaco.name
                                                font.pixelSize: 14
                                                text: themeButton.modelData
                                                color: themeButton.active ? Config.colors.accent : Config.colors.text
                                            }

                                            Text {
                                                Layout.alignment: Qt.AlignHCenter
                                                font.family: fontMonaco.name
                                                font.pixelSize: 10
                                                opacity: 0.7
                                                text: Config.themes[themeButton.modelData].dark ? "dark" : "light"
                                                color: Config.colors.text
                                            }
                                        }

                                        HoverHandler {
                                            id: themeHover
                                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            onWheel: wheel => {
                                const delta = wheel.angleDelta.y * 0.4;
                                themeFlick.contentX = Math.max(0, Math.min(themeFlick.contentWidth - themeFlick.width, themeFlick.contentX - delta));
                            }
                        }
                    }

                    /*=== Wallpapers ===*/
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Wallpaper"
                            font.family: fontCharcoal.name
                            font.pixelSize: 13
                            color: Config.colors.text
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        Text {
                            text: Services.Wallpapers.list.length + " found"
                            font.family: fontMonaco.name
                            font.pixelSize: 11
                            opacity: 0.7
                            color: Config.colors.text
                        }
                        Button {
                            id: rescanButton
                            implicitWidth: 22
                            implicitHeight: 22
                            onClicked: Services.Wallpapers.refresh()

                            background: Rectangle {
                                anchors.fill: parent
                                color: rescanHover.hovered ? Config.colors.shadow : Config.colors.base
                                border.width: 1
                                border.color: Config.colors.outline
                            }
                            Text {
                                anchors.centerIn: parent
                                font.family: iconFont.name
                                font.pixelSize: 14
                                text: "\ue394"          // directory_sync
                                color: Config.colors.text
                            }
                            HoverHandler {
                                id: rescanHover
                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Shown when the wallpaper directory is empty or missing.
                        Text {
                            anchors.centerIn: parent
                            visible: Services.Wallpapers.list.length === 0
                            font.family: fontMonaco.name
                            font.pixelSize: 11
                            opacity: 0.6
                            color: Config.colors.text
                            horizontalAlignment: Text.AlignHCenter
                            text: "No images in " + Config.settings.wallpaperDirectory + "\nPut some there and hit rescan."
                        }

                        Flickable {
                            id: wallFlick
                            anchors.fill: parent
                            visible: Services.Wallpapers.list.length > 0
                            contentWidth: wallRow.width
                            contentHeight: height
                            flickableDirection: Flickable.HorizontalFlick
                            boundsBehavior: Flickable.DragOverBounds
                            maximumFlickVelocity: 3500
                            clip: true

                            RowLayout {
                                id: wallRow
                                height: wallFlick.height
                                spacing: 8

                                Repeater {
                                    model: Services.Wallpapers.list

                                    Button {
                                        id: wallButton
                                        required property var modelData

                                        readonly property bool active: Services.Wallpapers.current === modelData

                                        implicitWidth: 120
                                        implicitHeight: Math.max(40, wallFlick.height - 4)
                                        clip: true

                                        onClicked: Services.Wallpapers.apply(modelData, true)

                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: Config.colors.shadow
                                            border.width: 1
                                            border.color: wallButton.active ? Config.colors.accent : Config.colors.outline
                                        }

                                        Image {
                                            anchors.fill: parent
                                            anchors.margins: 1
                                            source: "file://" + wallButton.modelData
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                            // Thumbnails only; the source images
                                            // are multi-megabyte.
                                            sourceSize.width: 240
                                            cache: true
                                            opacity: wallHover.hovered || wallButton.active ? 1.0 : 0.82
                                        }

                                        // Name strip along the bottom.
                                        Rectangle {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.bottom: parent.bottom
                                            anchors.margins: 1
                                            height: 16
                                            color: Config.colors.base
                                            opacity: 0.92

                                            Text {
                                                anchors.fill: parent
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                elide: Text.ElideRight
                                                font.family: fontMonaco.name
                                                font.pixelSize: 10
                                                color: wallButton.active ? Config.colors.accent : Config.colors.text
                                                text: Services.Wallpapers.displayName(wallButton.modelData)
                                            }
                                        }

                                        HoverHandler {
                                            id: wallHover
                                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            onWheel: wheel => {
                                const delta = wheel.angleDelta.y * 0.4;
                                wallFlick.contentX = Math.max(0, Math.min(wallFlick.contentWidth - wallFlick.width, wallFlick.contentX - delta));
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

    function openThemeMenu() {
        root.visible = true;
        Services.Wallpapers.refresh();
        openAnimation.start();
    }

    function closeThemeMenu() {
        closeAnimation.start();
    }
}
