import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import QtQuick
import "../core"
import "../services"

PanelWindow {
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    anchors.bottom: true
    margins.bottom: 80
    implicitWidth: 220
    implicitHeight: 60
    color: "transparent"

    property bool osdVisible: false
    visible: osdVisible

    // readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode sink: PipewireState.sink

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: "#1e1e2e" 

        Row {
            anchors.centerIn: parent
            spacing: 12

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    const s = sink
                    if (!s || s.audio.muted) return "󰖁"
                    if (s.audio.volume < 0.33) return "󰕿"
                    if (s.audio.volume < 0.66) return "󰖀"
                    return "󰕾"
                }
                font.pixelSize: 20
                color: "#cdd6f4"
            }

            Rectangle {
                width: 120; height: 6; radius: 3
                anchors.verticalCenter: parent.verticalCenter
                color: "#45475a"
                Rectangle {
                    width: parent.width * Math.min(1.0, sink?.audio.volume ?? 0)
                    height: parent.height; radius: parent.radius
                    color: "#89b4fa"
                    Behavior on width { NumberAnimation { duration: 80 } }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: sink ? (sink.audio.muted ? "muted" : Math.round(sink.audio.volume * 100) + "%") : "—"
                font.pixelSize: 14; font.bold: true
                color: "#cdd6f4"; width: 42
            }
        }
    }

    Timer {
        id: osdTimer
        interval: 1500
        onTriggered: osdVisible = false
    }

    Connections {
        target: sink?.audio ?? null
        function onVolumeChanged() {
            osdVisible = true
            osdTimer.restart()
        }
        function onMutedChanged() {
            osdVisible = true
            osdTimer.restart()
        }
    }
}