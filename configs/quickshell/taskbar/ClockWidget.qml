import QtQuick
import QtQuick.Layouts

import ".."

/* Date and clock. The date can be hidden from settings.json for narrow
 * screens, and the clock honours the 12/24 hour preference. */
RowLayout {
    id: root
    spacing: 6

    Text {
        visible: Config.settings.bar.showDate
        text: Time.date
        color: Config.colors.text
        opacity: 0.75
        font.pixelSize: Config.settings.bar.fontSize
        font.family: fontMonaco.name
        verticalAlignment: Text.AlignVCenter
    }

    // Retro separator pip between date and time.
    Rectangle {
        visible: Config.settings.bar.showDate
        implicitWidth: 1
        implicitHeight: 12
        color: Config.colors.outline
        opacity: 0.4
    }

    Text {
        text: Time.clock
        color: Config.colors.text
        font.pixelSize: Config.settings.bar.fontSize
        font.family: fontMonaco.name
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
