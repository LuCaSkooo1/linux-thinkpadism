pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // Kept for compatibility with anything still using the combined string.
    readonly property string time: date + " | " + clock

    readonly property string date: Qt.formatDateTime(clock_.date, "ddd MMM d")

    readonly property string clock: Config.settings.militaryTimeClockFormat ? Qt.formatDateTime(clock_.date, "HH:mm") : Qt.formatDateTime(clock_.date, "h:mm AP")

    SystemClock {
        id: clock_
        // Minute precision is enough for the bar and wakes the process far
        // less often than ticking every second.
        precision: SystemClock.Minutes
    }
}
