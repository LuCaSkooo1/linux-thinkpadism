import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../popups" as Popups
import ".."

Scope {
    // Taskbar variants, we have one taskbar per screen.
    Variants {
        model: Quickshell.screens
        Item {
            id: root
            required property var modelData
            property int currentPopup: Config.SystemPopup.None

            PanelWindow {
                id: taskbar
                screen: root.modelData
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

                anchors {
                    top: true
                    left: true
                    right: true
                }
                implicitHeight: 35

                /*=== Taskbar Background (colors & shading) ===*/
                color: Config.colors.base
                Item {
                    id: taskbarBackground
                    anchors.fill: parent
                    NewBorder {
                        commonBorderWidth: 4
                        commonBorder: false
                        lBorderwidth: 10
                        rBorderwidth: 1
                        tBorderwidth: 10
                        bBorderwidth: 1
                        borderColor: Config.colors.shadow
                    }
                    NewBorder {
                        commonBorderWidth: 4
                        commonBorder: false
                        lBorderwidth: 10
                        rBorderwidth: 10
                        tBorderwidth: 1
                        bBorderwidth: 10
                        borderColor: Config.colors.highlight
                    }

                    Rectangle {
                        id: barBackground
                        anchors {
                            fill: parent
                            margins: 0
                        }
                        color: "transparent"
                        radius: 0
                        border.width: 1
                        border.color: Config.colors.outline
                    }
                }
                /*=== ===================================== ===*/

                /* A sunken, chiselled well. Used behind the workspace strip
                 * and the tray so both read as recessed into the bar. */
                component SunkenWell: Item {
                    default property alias contents: wellContent.data

                    // No anchors: these sit inside a RowLayout, which manages
                    // their position. The layout centres them via its own
                    // verticalCenter anchor.
                    implicitHeight: taskbar.height - 8

                    Rectangle {
                        anchors.fill: parent
                        anchors.bottomMargin: -2
                        color: Config.colors.shadow
                    }
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -1
                        anchors.bottomMargin: 1
                        color: "transparent"
                        border.width: 1
                        border.color: Config.colors.outline
                        z: -5
                    }
                    Item {
                        id: wellContent
                        anchors.fill: parent
                    }
                }

                /*=== Left group: workspaces, start, theme, TUI tools ===*/
                RowLayout {
                    id: leftGroup
                    anchors.left: parent.left
                    anchors.leftMargin: 11
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    SunkenWell {
                        // +5 rather than +4: each button carries an extra
                        // pixel of chiselled outline.
                        implicitWidth: workspaces.width + 5
                        Workspaces {
                            id: workspaces
                            anchors.leftMargin: 2
                            anchors.rightMargin: 0
                        }
                    }

                    TaskbarButton {
                        id: startmenuButton
                        isToggled: root.currentPopup == Config.SystemPopup.Startmenu
                        onClicked: taskbar.togglePopup(Config.SystemPopup.Startmenu)
                    }

                    TaskbarButton {
                        id: themeMenuButton
                        isToggled: root.currentPopup == Config.SystemPopup.ThemePicker
                        iconFontValue: "\ue3ae"
                        onClicked: taskbar.togglePopup(Config.SystemPopup.ThemePicker)
                    }

                    // Thin divider between shell popups and app launchers.
                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 18
                        color: Config.colors.outline
                        opacity: 0.35
                    }

                    QuickTools {
                        id: quickTools
                    }
                }
                /*=== ============================================== ===*/

                /*=== StartMenu & Other popup Stuff ===*/
                Popups.StartMenu {
                    id: startMenu
                    // Popups anchor in window coordinates, so offset by the group's own x.
                    menuWidth: leftGroup.x + startmenuButton.x
                    closeCallback: taskbar.closeAllPopups
                }
                Popups.ThemeMenu {
                    id: themeMenu
                    menuWidth: leftGroup.x + themeMenuButton.x
                    closeCallback: taskbar.closeAllPopups
                }
                Popups.AppLauncher {
                    id: appLauncher
                    closeCallback: taskbar.closeAllPopups
                    menuWidth: taskbar.width / 2
                    popupWidth: 500
                    screenHeight: modelData.height
                }

                /* Open `popup`, or close whatever is open if it already is.
                 * Every popup goes through here so only one can ever be up. */
                function togglePopup(popup) {
                    if (root.currentPopup === popup) {
                        taskbar.closeAllPopups();
                        return;
                    }
                    taskbar.closeAllPopups();
                    switch (popup) {
                    case Config.SystemPopup.Startmenu:
                        startMenu.openStartMenu();
                        break;
                    case Config.SystemPopup.ThemePicker:
                        themeMenu.openThemeMenu();
                        break;
                    case Config.SystemPopup.AppLauncher:
                        appLauncher.openAppLauncher();
                        break;
                    }
                    root.currentPopup = popup;
                }

                function closeAllPopups() {
                    switch (root.currentPopup) {
                    case Config.SystemPopup.Startmenu:
                        startMenu.closeStartMenu();
                        break;
                    case Config.SystemPopup.ThemePicker:
                        themeMenu.closeThemeMenu();
                        break;
                    case Config.SystemPopup.AppLauncher:
                        appLauncher.closeAppLauncher();
                        break;
                    }
                    root.currentPopup = Config.SystemPopup.None;
                }

                TaskbarButton {
                    id: appLauncherButton
                    isToggled: root.currentPopup == Config.SystemPopup.AppLauncher
                    iconFontValue: "\ue8b6"
                    anchors.centerIn: parent
                    onClicked: taskbar.togglePopup(Config.SystemPopup.AppLauncher)
                }

                Scope {
                    id: appLauncherIpc
                    property string screenName: taskbar.screen.name
                    IpcHandler {
                        target: "appLauncher_" + appLauncherIpc.screenName

                        function toggleAppLauncher() {
                            taskbar.togglePopup(Config.SystemPopup.AppLauncher);
                        }

                        function toggleThemeMenu() {
                            taskbar.togglePopup(Config.SystemPopup.ThemePicker);
                        }

                        function toggleStartMenu() {
                            taskbar.togglePopup(Config.SystemPopup.Startmenu);
                        }

                        // Bound to a key in hyprland.conf so dark/light can be
                        // flipped without reaching for the mouse.
                        function toggleDarkMode() {
                            Config.toggleDarkMode();
                        }
                    }
                }
                /*=== ============================= ===*/

                /*=== Right group: performance, battery, tray, clock ===*/
                RowLayout {
                    id: rightGroup
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    PerformanceWidget {
                        id: performanceWidget
                    }

                    Rectangle {
                        visible: performanceWidget.visible
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 18
                        color: Config.colors.outline
                        opacity: 0.35
                    }

                    BatteryWidget {
                        id: batteryWidget
                    }

                    SunkenWell {
                        implicitWidth: sysTray.width + 18
                        SysTray {
                            id: sysTray
                        }
                    }
                }
                /*=== ============================================= ===*/
            }

            /*=== POPUP CLOSING PANEL ===*/
            // This panel is strictly for detecting clicks
            // outside of popups in order to close them.
            PanelWindow {
                id: overlay
                screen: root.modelData
                color: "transparent"

                implicitHeight: screen.height

                anchors {
                    bottom: true
                    left: true
                    right: true
                }

                visible: root.currentPopup != Config.SystemPopup.None

                exclusionMode: ExclusionMode.Ignore

                MouseArea {
                    id: popupArea
                    width: Screen.width
                    height: Screen.height
                    visible: root.currentPopup != Config.SystemPopup.None
                    onClicked: {
                        taskbar.closeAllPopups();
                    }
                }
            }
            /*=== =================== ===*/
        }
    }
}
