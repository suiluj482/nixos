import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import QtQuick
import "../core"

PanelWindow {
    id: root

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    anchors.top: true
    margins.top: 48
    implicitWidth: 340
    implicitHeight: 64
    color: "transparent"

    visible: shown && laptop
    // opacity: shown ? 1 : 0
    // Behavior on opacity { NumberAnimation { duration: 200 } }

    // ── State ──────────────────────────────────────────────────────────────
    property bool shown: false
    // Highest severity already announced: 3 = none, 2 = low, 1 = critical, 0 = empty
    property int announcedLevel: 3

    readonly property bool laptop: HostConfig.deviceType == "laptop"
    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool discharging: device.state === UPowerDeviceState.Discharging
    readonly property real pct: device.percentage

    readonly property int level: {
        if (!discharging) return 3
        if (pct <= 0.05) return 0
        if (pct <= 0.10) return 1
        if (pct <= 0.20) return 2
        return 3
    }

    readonly property bool critical: level <= 1
    readonly property color alertColor: critical ? Theme.red : Theme.yellow

    function evaluate() {
        if (!laptop || !device) return

        if (device.state !== UPowerDeviceState.Discharging) {
            shown = false
            announcedLevel = 3
            return
        }

        if (level < announcedLevel) {
            announcedLevel = level
            shown = true
            hideTimer.restart()
        }
    }

    Component.onCompleted: evaluate()

    Connections {
        target: root.laptop ? root.device : null
        function onPercentageChanged() { root.evaluate() }
        function onStateChanged() { root.evaluate() }
    }

    Timer {
        id: hideTimer
        interval: root.critical ? 10000 : 6000
        onTriggered: root.shown = false
    }

    function formatDuration(seconds) {
        const h = Math.floor(seconds / 3600)
        const m = Math.floor((seconds % 3600) / 60)

        if (h > 0)
            return `${h}h ${m}m`

        return `${m}m`
    }

    function title() {
        if (level === 0) return "Battery almost empty"
        if (level === 1) return "Battery critical"
        return "Low battery"
    }

    function subtitle() {
        let t = Math.round(pct * 100) + "%"
        if (discharging && device.timeToEmpty > 0)
            t += " — " + formatDuration(device.timeToEmpty) + " remaining"
        return t
    }

    // ── UI ─────────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Theme.base
        border.color: root.alertColor
        border.width: 1

        Rectangle {
            id: pulse
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: root.alertColor
            border.width: 2
            opacity: 0
        }

        SequentialAnimation {
            running: root.shown && root.critical
            loops: Animation.Infinite
            NumberAnimation { target: pulse; property: "opacity"; to: 0.5; duration: 500 }
            NumberAnimation { target: pulse; property: "opacity"; to: 0; duration: 500 }
        }

        Row {
            anchors.centerIn: parent
            spacing: 14

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "\udb80\udc80"
                font.pixelSize: 28
                color: root.alertColor
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: root.title()
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    color: Theme.text
                }

                Text {
                    text: root.subtitle()
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.subtext0
                }
            }
        }
    }
}
