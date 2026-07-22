import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../core"
import "../services"


Item {
    id: root

    implicitWidth: layout.implicitWidth + 16
    implicitHeight: 28

    // --- Pipewire wiring -------------------------------------------------
    readonly property PwNode sink: PipewireState.sink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    readonly property var audioStreams: {
        const nodes = Pipewire.nodes.values
        const streams = []
        for (let i = 0; i < nodes.length; i++) {
            const n = nodes[i]
            if (n.isStream && n.audio)
                streams.push(n)
        }
        return streams
    }

    readonly property var trackedNodes: {
        const nodes = [root.sink]
        const streams = root.audioStreams
        for (let i = 0; i < streams.length; i++)
            nodes.push(streams[i])
        return nodes
    }

    PwObjectTracker {
        objects: root.trackedNodes
    }

    function step(delta) {
        if (!sink?.ready || !sink?.audio) return
        const next = Math.max(0, Math.min(1.0, sink.audio.volume + delta))
        sink.audio.volume = next
    }

    function toggleMute() {
        if (!sink?.ready || !sink?.audio) return
        sink.audio.muted = !sink.audio.muted
    }

    function icon() {
        if (muted || volume === 0) return "\udb81\udd81" // nf-md-volume_off
        if (volume < 0.34) return "\udb81\udd7f" // nf-md-volume_low
        if (volume < 0.67) return "\udb81\udd80" // nf-md-volume_medium
        return "\udb81\udd7e" // nf-md-volume_high
    }

    // --- Visuals -----------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        radius: 6
        color: mouseArea.containsMouse ? Theme.surface0 : Qt.rgba(0x1e/255, 0x1e/255, 0x2e/255, 0.4)
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.icon()
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
            color: root.muted ? Theme.overlay0 : Theme.text
        }

        Text {
            text: root.muted ? "muted" : Math.round(root.volume * 100) + "%"
            font.pixelSize: 12
            color: Theme.text
        }
    }

    Process {
        id: pwvucontrolProc
        command: ["pwvucontrol"]
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                popup.visible = !popup.visible
            } else {
                root.toggleMute()
            }
        }

        onWheel: (wheel) => {
            root.step(wheel.angleDelta.y > 0 ? 0.05 : -0.05)
            wheel.accepted = true
        }
    }

    // --- Popup ---------------------------------------------------------------
    PopupWindow {
        id: popup
        grabFocus: true
        anchor.item: root
        anchor.edges: Edges.Bottom
        implicitWidth: 300
        implicitHeight: content.implicitHeight + 16
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: Theme.base
            border.color: Theme.surface1
        }

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            // -- Header --
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: root.icon()
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: root.muted ? Theme.overlay0 : Theme.blue
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Volume"
                        color: Theme.text
                        font.bold: true
                        font.pixelSize: 13
                    }
                    Text {
                        text: root.sink?.description ?? "No sink"
                        color: Theme.subtext0
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        Layout.maximumWidth: 200
                    }
                }

                // Percentage display
                Text {
                    text: root.muted ? "muted" : Math.round(root.volume * 100) + "%"
                    color: root.muted ? Theme.overlay0 : Theme.text
                    font.pixelSize: 13
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface1 }

            // -- Volume slider --
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "\udb81\udd7e" // nf-md-volume_high
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 12
                    color: Theme.overlay1
                }

                Slider {
                    id: volumeSlider
                    Layout.fillWidth: true
                    from: 0.0
                    to: 1.0
                    stepSize: 0.01
                    value: root.volume

                    onMoved: {
                        if (root.sink?.ready && root.sink?.audio) {
                            root.sink.audio.volume = value
                        }
                    }

                    background: Rectangle {
                        x: volumeSlider.leftPadding
                        y: volumeSlider.topPadding + (volumeSlider.availableHeight - height) / 2
                        width: volumeSlider.availableWidth
                        height: 4
                        radius: 2
                        color: Theme.surface1

                        Rectangle {
                            width: volumeSlider.availableWidth * volumeSlider.position
                            height: parent.height
                            radius: 2
                            color: Theme.blue
                        }
                    }

                    handle: Rectangle {
                        x: volumeSlider.leftPadding + (volumeSlider.availableWidth - width) * volumeSlider.visualPosition
                        y: volumeSlider.topPadding + (volumeSlider.availableHeight - height) / 2
                        width: 14
                        height: 14
                        radius: 7
                        color: Theme.crust
                        border.color: Theme.blue
                        border.width: 2
                    }
                }
            }

            // -- Mute toggle --
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                radius: 6
                color: muteArea.containsMouse ? Theme.surface1 : Theme.surface0

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6

                    Text {
                        text: root.muted ? "\udb81\udd81" : "\udb81\udd7e"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 12
                        color: root.muted ? Theme.red : Theme.text
                    }

                    Text {
                        text: root.muted ? "Unmute" : "Mute"
                        color: Theme.text
                        font.pixelSize: 12
                        Layout.fillWidth: true
                    }

                    // Mute indicator dot
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: root.muted ? Theme.red : Theme.green
                    }
                }

                MouseArea {
                    id: muteArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleMute()
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface1 }

            // -- Per-app streams --
            ColumnLayout {
                visible: root.audioStreams.length > 0
                spacing: 6

                Text {
                    text: "Applications"
                    color: Theme.subtext1
                    font.pixelSize: 11
                }

                Repeater {
                    model: root.audioStreams

                    delegate: Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        implicitHeight: streamCol.implicitHeight + 12
                        radius: 6
                        color: Theme.surface0

                        ColumnLayout {
                            id: streamCol
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    text: "\uf028" // nf-fa-volume-up
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 11
                                    color: (modelData.audio?.muted ?? false) ? Theme.overlay0 : Theme.blue
                                }

                                Text {
                                    text: modelData.description || modelData.name || "Unknown"
                                    color: (modelData.audio?.muted ?? false) ? Theme.overlay0 : Theme.text
                                    font.pixelSize: 11
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: (modelData.audio?.muted ?? false)
                                          ? "muted"
                                          : Math.round((modelData.audio?.volume ?? 0) * 100) + "%"
                                    color: Theme.subtext0
                                    font.pixelSize: 10
                                }

                                Text {
                                    text: modelData.audio?.muted ?? false ? "\udb81\udd81" : "\udb81\udd7e"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 11
                                    color: streamMuteArea.containsMouse ? Theme.red : Theme.overlay1

                                    MouseArea {
                                        id: streamMuteArea
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (modelData.ready && modelData.audio)
                                                modelData.audio.muted = !modelData.audio.muted
                                        }
                                    }
                                }
                            }

                            Slider {
                                id: streamSlider
                                Layout.fillWidth: true
                                from: 0.0
                                to: 1.0
                                stepSize: 0.01
                                value: modelData.audio?.volume ?? 0

                                onMoved: {
                                    if (modelData.ready && modelData.audio)
                                        modelData.audio.volume = value
                                }

                                background: Rectangle {
                                    x: streamSlider.leftPadding
                                    y: streamSlider.topPadding + (streamSlider.availableHeight - height) / 2
                                    width: streamSlider.availableWidth
                                    height: 3
                                    radius: 2
                                    color: Theme.surface1

                                    Rectangle {
                                        width: streamSlider.availableWidth * streamSlider.position
                                        height: parent.height
                                        radius: 2
                                        color: Theme.mauve
                                    }
                                }

                                handle: Rectangle {
                                    x: streamSlider.leftPadding + (streamSlider.availableWidth - width) * streamSlider.visualPosition
                                    y: streamSlider.topPadding + (streamSlider.availableHeight - height) / 2
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: Theme.crust
                                    border.color: Theme.mauve
                                    border.width: 2
                                }
                            }
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface1 }

            // -- Open pwvucontrol button --
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                radius: 6
                color: pwvuMouse.containsMouse ? Theme.surface1 : Theme.surface0

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6

                    Text {
                        text: "\uf1e0" // nf-fa-sliders
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 12
                        color: Theme.blue
                    }

                    Text {
                        text: "Volume Mixer (pwvucontrol)"
                        color: Theme.text
                        font.pixelSize: 12
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "\uf35d" // nf-fa-external_link
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 10
                        color: Theme.overlay1
                    }
                }

                MouseArea {
                    id: pwvuMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        pwvucontrolProc.running = true
                        popup.visible = false
                    }
                }
            }
        }
    }
}
