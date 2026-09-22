import Quickshell
import QtQuick

import ".."

/* Small hover tooltip drawn in the same chiselled style as the rest of the
 * shell. Anchored under the widget that owns it, on the taskbar window.
 *
 * Callers bind `hovered` (usually to a HoverHandler); the popup only actually
 * appears after a short delay so that sweeping the mouse across the bar does
 * not flash a trail of tooltips. */
PopupWindow {
    id: root

    property Item anchorItem: null
    property string text: ""
    property int delay: 350

    // Set by the delay timer once the pointer has rested long enough.
    property bool shouldShow: false

    // Measure the text so the window can size itself to it.
    TextMetrics {
        id: metrics
        font.family: fontMonaco.name
        font.pixelSize: 11
        text: root.text
    }

    implicitWidth: Math.ceil(metrics.width) + 16
    implicitHeight: 22
    color: "transparent"

    anchor.window: taskbar
    anchor.rect.x: {
        // mapToItem is not a reactive binding, so name shouldShow and the
        // anchor item's own geometry here: that re-runs this when the tooltip
        // is about to appear and whenever the bar relayouts, rather than
        // leaving a position computed before the first layout pass.
        shouldShow;
        if (!anchorItem)
            return 0;
        anchorItem.x;
        anchorItem.width;
        const centre = anchorItem.mapToItem(null, anchorItem.width / 2, 0).x;
        // Keep the tooltip on screen at either end of the bar.
        return Math.max(4, Math.min(taskbar.width - implicitWidth - 4, centre - implicitWidth / 2));
    }
    anchor.rect.y: taskbar.height + 2

    Rectangle {
        anchors.fill: parent
        color: Config.colors.base
        border.width: 1
        border.color: Config.colors.outline

        // Single-pixel chisel, matching the taskbar buttons.
        NewBorder {
            commonBorderWidth: 1
            commonBorder: false
            lBorderwidth: 0
            rBorderwidth: 1
            tBorderwidth: 0
            bBorderwidth: 1
            borderColor: Config.colors.shadow
            zValue: -1
        }

        Text {
            anchors.centerIn: parent
            font.family: fontMonaco.name
            font.pixelSize: 11
            text: root.text
            color: Config.colors.text
        }
    }

    Timer {
        id: showTimer
        interval: root.delay
        onTriggered: root.shouldShow = true
    }

    // Drive the delayed reveal from the caller's flag.
    property bool hovered: false
    onHoveredChanged: {
        if (hovered) {
            showTimer.restart();
        } else {
            showTimer.stop();
            shouldShow = false;
        }
    }

    visible: shouldShow && text !== ""
}
