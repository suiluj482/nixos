import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "../core"
import "../services"

Loader {
    active: HostConfig.deviceType == "laptop" ? true : false
    visible: active

    sourceComponent: Item {
        id: root

        implicitWidth: row.implicitWidth + 16
        implicitHeight: 28
        
        property UPowerDevice device: UPower.displayDevice

        function icon() {
            if(
                device.state === UPowerDeviceState.Charging
                || device.state === UPowerDeviceState.FullyCharged
            ) {
                if (device.percentage < 0.1) return "\udb82\udc9c"
                if (device.percentage < 0.2) return "\udb80\udc86"
                if (device.percentage < 0.3) return "\udb80\udc87"
                if (device.percentage < 0.4) return "\udb80\udc88"
                if (device.percentage < 0.5) return "\udb82\udc9d"
                if (device.percentage < 0.6) return "\udb80\udc89"
                if (device.percentage < 0.7) return "\udb82\udc9e"
                if (device.percentage < 0.8) return "\udb80\udc8a"
                if (device.percentage < 0.9) return "\udb80\udc8b"
                return "\udb80\udc85"
            }
            if (device.percentage < 0.1) return "\udb80\udc7a"
            if (device.percentage < 0.2) return "\udb80\udc7b"
            if (device.percentage < 0.3) return "\udb80\udc7c"
            if (device.percentage < 0.4) return "\udb80\udc7d"
            if (device.percentage < 0.5) return "\udb80\udc7e"
            if (device.percentage < 0.6) return "\udb80\udc7f"
            if (device.percentage < 0.7) return "\udb80\udc80"
            if (device.percentage < 0.8) return "\udb80\udc81"
            if (device.percentage < 0.9) return "\udb80\udc82"
            return "\udb80\udc79"
        }
        function profileIcon(profile) {
            if(profile === PowerProfile.PowerSaver) return "\uf06c"
            if(profile === PowerProfile.Balanced) return "\uf24e"
            if(profile === PowerProfile.Performance) return "\udb85\udc0b"
            return "\uea87"
        }
        function remainingTime() {
            if (device.state === UPowerDeviceState.Charging && device.timeToFull > 0)
                return "Full in " + formatDuration(device.timeToFull)

            if (device.state === UPowerDeviceState.Discharging && device.timeToEmpty > 0)
                return "Empty in " + formatDuration(device.timeToEmpty)
            return ""
        }
        function formatDuration(seconds) {
            const h = Math.floor(seconds / 3600)
            const m = Math.floor((seconds % 3600) / 60)

            if (h > 0)
                return `${h}h ${m}m`

            return `${m}m`
        }

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
                text: icon()
                font.pixelSize: 14
                color: "#cdd6f4"
            }
            Text {
                text: Math.round(device.percentage * 100) + "%"
                color: "#cdd6f4"
                font.pixelSize: 12
            }
            // Text {
            //     text: profileIcon(PowerProfiles.profile)
            //     font.pixelSize: 14
            //     color: "#cdd6f4"
            // }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true

            onClicked: popup.visible = !popup.visible
        }

        // PopUp
        PopupWindow {
            id: popup

            grabFocus: true

            anchor.item: root
            anchor.edges: Edges.Bottom

            implicitWidth: 320
            implicitHeight: content.implicitHeight + 16

            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: "#1e1e2e"
                border.color: "#45475a"
            }

            ColumnLayout {
                id: content
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                Text {
                    text: `Battery ${(device.percentage * 100).toFixed(0)}%`
                    color: "#cdd6f4"
                    font.bold: true
                }
                Text {
                    text: remainingTime()
                    color: "#bac2de"
                }

                // -- Profiles
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#45475a"
                }
                Text {
                    text: "Power Profile"
                    color: "#cdd6f4"
                    font.bold: true
                }

                Repeater {
                    model: [
                        PowerProfile.PowerSaver,
                        PowerProfile.Balanced,
                        PowerProfile.Performance
                    ]

                    delegate: Rectangle {
                        required property var modelData

                        visible:
                            modelData !== PowerProfile.Performance
                            || PowerProfiles.hasPerformanceProfile

                        Layout.fillWidth: true
                        implicitHeight: 32
                        radius: 6

                        color:
                            PowerProfiles.profile === modelData
                                ? "#89b4fa"
                                : "#313244"

                        // Text {
                        //     anchors.left: parent.left
                        //     anchors.leftMargin: 8
                        //     anchors.verticalCenter: parent.verticalCenter
                        //     text: profileIcon(modelData)
                        //     font.pixelSize: 14
                        //     color:
                        //         PowerProfiles.profile === modelData
                        //             ? "#11111b"
                        //             : "#cdd6f4"
                        // }
                        Text {
                            anchors.centerIn: parent
                            text: PowerProfile.toString(modelData)
                            color:
                                PowerProfiles.profile === modelData
                                    ? "#11111b"
                                    : "#cdd6f4"
                        }


                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                PowerProfiles.profile = modelData
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#45475a"

                    visible: PowerProfiles.holds.length > 0
                }

                Text {
                    visible: PowerProfiles.holds.length > 0
                    text: "Active Holds"
                    color: "#cdd6f4"
                    font.bold: true
                }

                Repeater {
                    model: PowerProfiles.holds

                    delegate: Column {
                        required property var modelData

                        spacing: 2

                        Text {
                            text: modelData.applicationId
                            color: "#f9e2af"
                        }

                        Text {
                            text:
                                `${profileName(modelData.profile)} — ${modelData.reason}`
                            color: "#bac2de"
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }
    }
}
