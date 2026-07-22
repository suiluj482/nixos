import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Io
import "../core"

Item {
    id: root

    implicitWidth: row.implicitWidth + 16
    implicitHeight: 28

    // ---- configuration ----
    property string backend: HostConfig.deviceType == "desktop" ? "ddcutil" : "brightnessctl"
    property int ddcutilDisplay: 1 // only used for "ddcutil"
    property int step: 5 // percent per scroll tick
    property int pollIntervalMs: 4000 // brightnessctl polling only

    // ---- state ----
    property int percent: 0
    property int ddcMax: 100
    property bool ready: false


    // ---- Logic ----
    function setPercent(p) {
        p = Math.max(0, Math.min(100, p))
        root.percent = p // optimistic UI update, applied after debounce
        debounce.restart()
    }

    // actually change it
    function applyPercent(p) {
        if (root.backend === "ddcutil") {
            const value = Math.round((p / 100) * root.ddcMax)
            setProc.command = ["ddcutil", "setvcp", "10", String(value),
                               "--display", String(root.ddcutilDisplay)]
        } else {
            setProc.command = ["brightnessctl", "set", p + "%"]
        }
        setProc.running = true
    }

    // debounce for ddcutil
    Timer {
        id: debounce
        interval: root.backend === "ddcutil" ? 250 : 0
        onTriggered: root.applyPercent(root.percent)
    }

    // get brightness
    Process {
        id: getProc
        command: root.backend === "ddcutil"
                 ? ["ddcutil", "getvcp", "10", "--display", String(root.ddcutilDisplay)]
                 : ["brightnessctl", "-m"] // -P: percentage, -m: bare value
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.backend === "ddcutil") {
                    const m = this.text.match(/current value\s*=\s*(\d+).*max value\s*=\s*(\d+)/)
                    if (m) {
                        root.ddcMax = parseInt(m[2])
                        root.percent = Math.round((parseInt(m[1]) / root.ddcMax) * 100)
                    }
                } else {
                    root.percent = parseInt(this.text.split(",")[3])
                }
                root.ready = true
            }
        }
    }
    Process { id: setProc }

    // regular Pooling for brightnessctl
    Timer {
        interval: root.pollIntervalMs
        running: root.backend !== "ddcutil"
        repeat: true
        triggeredOnStart: true
        onTriggered: getProc.running = true
    }
    Component.onCompleted: getProc.running = true


    // --- Visuals -----------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        radius: 6
        color: mouseArea.containsMouse ? "#313244" : Qt.rgba(0x1e/255, 0x1e/255, 0x2e/255, 0.4)
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.percent > 66 ? "🔆" : "🔅"
            font.pixelSize: 14
            color: "#cdd6f4"
        }
        Text {
            text: root.ready ? root.percent + "%" : "…"
            color: "#cdd6f4"
            font.pixelSize: 12
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
          getProc.running = true
          // popup.visible = !popup.visible
        }
        
        onWheel: (wheel) => {
                const delta = wheel.angleDelta.y > 0 ? root.step : -root.step
                root.setPercent(root.percent + delta)
            }
    }

    // PopupWindow {
    //     id: popup
    //     anchor.item: root
    //     implicitWidth: 32
    //     implicitHeight: 130
    //     visible: false
    //     color: "transparent"

    //     Rectangle {
    //         anchors.fill: parent
    //         radius: 6
    //         color: "#1e1e2e"
    //         border.color: "#313244"

    //         Slider {
    //             anchors.fill: parent
    //             anchors.margins: 6
    //             orientation: Qt.Vertical
    //             from: 0
    //             to: 100
    //             value: root.percent
    //             onMoved: root.setPercent(Math.round(value))
    //         }
    //     }
    // }
}
