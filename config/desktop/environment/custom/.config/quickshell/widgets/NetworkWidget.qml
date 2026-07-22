import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Networking
import "../core"

Loader {
    active: Networking.devices.values.length > 0
    visible: active

    sourceComponent: Item {
        id: root

        implicitWidth: row.implicitWidth + 16
        implicitHeight: 28

        readonly property var wifiDevice: root.findDevice(DeviceType.Wifi)
        readonly property var wiredDevice: root.findDevice(DeviceType.Wired)
        readonly property bool hasWifi: root.wifiDevice !== null
        readonly property bool hasWired: root.wiredDevice !== null
        readonly property bool wifiEnabled: Networking.wifiEnabled

        readonly property var activeWifiNetwork: {
            if (!root.wifiDevice) return null
            const networks = root.wifiDevice.networks.values
            for (let i = 0; i < networks.length; i++) {
                if (networks[i].connected) return networks[i]
            }
            return null
        }

        readonly property bool wiredConnected: root.wiredDevice?.connected ?? false

        readonly property bool anyConnected: root.activeWifiNetwork !== null || root.wiredConnected

        readonly property string activeLabel: {
            if (root.activeWifiNetwork) return root.activeWifiNetwork.name
            return ""
        }

        function findDevice(type) {
            const devices = Networking.devices.values
            for (let i = 0; i < devices.length; i++) {
                if (devices[i].type === type) return devices[i]
            }
            return null
        }

        function iconForDevice() {
            if (root.activeWifiNetwork) return "\uf1eb" // nf-fa-wifi
            if (root.wiredConnected) return "\uf0e8" // nf-fa-plug (ethernet)
            if (root.hasWifi && !root.wifiEnabled) return "\uf1eb" // wifi dimmed
            if (root.hasWired) return "\uf0e8" // plug dimmed
            return "\uf1eb"
        }

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: mouseArea.containsMouse ? Theme.surface0 : Qt.rgba(0x1e/255, 0x1e/255, 0x2e/255, 0.4)
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: root.iconForDevice()
                font.family: "Symbols Nerd Font"
                font.pixelSize: 14
                color: {
                    if (root.anyConnected) return Theme.blue
                    return Theme.overlay0
                }
            }

            Text {
                visible: root.activeLabel !== ""
                text: root.activeLabel
                font.pixelSize: 12
                color: Theme.blue
                elide: Text.ElideRight
                Layout.maximumWidth: 120
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: popup.visible = !popup.visible
        }

        // -- Popup ---------------------------------------------------------------
        PopupWindow {
            id: popup
            grabFocus: true
            anchor.item: root
            anchor.edges: Edges.Bottom
            implicitWidth: 340
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

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Networking"
                            color: Theme.text
                            font.bold: true
                            font.pixelSize: 13
                        }
                        Text {
                            text: {
                                const parts = []
                                if (root.wiredConnected) parts.push("Ethernet connected")
                                if (root.activeWifiNetwork) parts.push("WiFi: " + root.activeWifiNetwork.name)
                                if (parts.length === 0) {
                                    if (root.hasWifi && !root.wifiEnabled) return "WiFi disabled"
                                    return "Not connected"
                                }
                                return parts.join(" | ")
                            }
                            color: Theme.subtext0
                            font.pixelSize: 11
                        }
                    }

                    // WiFi toggle (only if wifi device exists)
                    RowLayout {
                        visible: root.hasWifi
                        spacing: 4

                        Text {
                            text: "\uf1eb"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 11
                            color: root.wifiEnabled ? Theme.green : Theme.overlay0
                        }

                        Rectangle {
                            implicitWidth: 36
                            implicitHeight: 20
                            radius: 10
                            color: root.wifiEnabled ? Theme.green : Theme.surface2

                            Rectangle {
                                width: 16
                                height: 16
                                radius: 8
                                color: Theme.crust
                                x: root.wifiEnabled ? parent.width - width - 2 : 2
                                y: (parent.height - height) / 2
                                Behavior on x { NumberAnimation { duration: 100 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                            }
                        }
                    }
                }

                // -- Wired devices --
                Repeater {
                    model: Networking.devices

                    delegate: Rectangle {
                        required property var modelData
                        visible: modelData.type === DeviceType.Wired

                        Layout.fillWidth: true
                        implicitHeight: wiredCol.implicitHeight + 16
                        radius: 6
                        color: Theme.surface0

                        ColumnLayout {
                            id: wiredCol
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    text: "\uf0e8" // nf-fa-plug
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 12
                                    color: modelData.connected ? Theme.blue : Theme.overlay0
                                }

                                Text {
                                    text: modelData.name
                                    color: modelData.connected ? Theme.text : Theme.overlay0
                                    font.pixelSize: 12
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.connected ? "Connected" : "Disconnected"
                                    color: modelData.connected ? Theme.green : Theme.overlay0
                                    font.pixelSize: 11
                                }

                                Text {
                                    visible: modelData.connected
                                    text: "\uf04d" // nf-fa-stop_circle
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 12
                                    color: wiredDcArea.containsMouse ? Theme.red : Theme.overlay1

                                    MouseArea {
                                        id: wiredDcArea
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: modelData.disconnect()
                                    }
                                }
                            }

                            Text {
                                visible: modelData.connected
                                text: {
                                    let info = ""
                                    if (modelData.type === DeviceType.Wired) {
                                        const wired = modelData
                                        if (wired.linkSpeed > 0)
                                            info = wired.linkSpeed + " Mbps"
                                    }
                                    return info
                                }
                                color: Theme.overlay0
                                font.pixelSize: 10
                            }
                        }
                    }
                }

                Rectangle {
                    visible: root.hasWifi
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.surface1
                }

                // -- WiFi section --
                ColumnLayout {
                    visible: root.hasWifi
                    spacing: 8

                    // WiFi header
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Wi-Fi Networks"
                            color: Theme.subtext1
                            font.pixelSize: 11
                            Layout.fillWidth: true
                        }

                        // Scan toggle
                        Rectangle {
                            implicitWidth: 36
                            implicitHeight: 20
                            radius: 10
                            color: (root.wifiDevice?.scannerEnabled ?? false) ? Theme.blue : Theme.surface2

                            Rectangle {
                                width: 16
                                height: 16
                                radius: 8
                                color: Theme.crust
                                x: (root.wifiDevice?.scannerEnabled ?? false) ? parent.width - width - 2 : 2
                                y: (parent.height - height) / 2
                                Behavior on x { NumberAnimation { duration: 100 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (root.wifiDevice)
                                        root.wifiDevice.scannerEnabled = !root.wifiDevice.scannerEnabled
                                }
                            }
                        }
                    }

                    // WiFi network list
                    Repeater {
                        model: root.wifiDevice?.networks ?? null

                        delegate: Rectangle {
                            required property var modelData

                            Layout.fillWidth: true
                            implicitHeight: netRow.implicitHeight + 16
                            radius: 6
                            color: netMouse.containsMouse ? Theme.surface1 : Theme.surface0

                            RowLayout {
                                id: netRow
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 6

                                Text {
                                    text: "\uf1eb"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 12
                                    color: modelData.connected ? Theme.blue
                                         : (modelData.signalStrength > 0.5 ? Theme.text : Theme.overlay0)
                                }

                                Text {
                                    text: modelData.name
                                    color: modelData.connected ? Theme.blue : Theme.text
                                    font.pixelSize: 12
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: Math.round(modelData.signalStrength * 100) + "%"
                                    color: Theme.subtext1
                                    font.pixelSize: 11
                                }

                                Text {
                                    visible: modelData.security !== WifiSecurityType.None
                                    text: "\uf023" // nf-fa-lock
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 10
                                    color: Theme.overlay1
                                }

                                // Disconnect
                                Text {
                                    visible: modelData.connected
                                    text: "\uf04d" // nf-fa-stop_circle
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 12
                                    color: netDcArea.containsMouse ? Theme.red : Theme.overlay1

                                    MouseArea {
                                        id: netDcArea
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: modelData.disconnect()
                                    }
                                }

                                // Connect
                                Text {
                                    visible: !modelData.connected
                                    text: "\uf04b" // nf-fa-play
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 12
                                    color: netConnectArea.containsMouse ? Theme.green : Theme.overlay1

                                    MouseArea {
                                        id: netConnectArea
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: modelData.connect()
                                    }
                                }

                                // Forget
                                Text {
                                    visible: modelData.known && !modelData.connected
                                    text: "\uf1f8" // nf-fa-trash
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 12
                                    color: netForgetArea.containsMouse ? Theme.red : Theme.overlay1

                                    MouseArea {
                                        id: netForgetArea
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: modelData.forget()
                                    }
                                }
                            }

                            MouseArea {
                                id: netMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!modelData.connected)
                                        modelData.connect()
                                }
                            }
                        }
                    }

                    Text {
                        visible: (root.wifiDevice?.networks?.values?.length ?? 0) === 0 && root.wifiEnabled
                        text: "No networks found"
                        color: Theme.overlay0
                        font.pixelSize: 11
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface1 }

                // -- Quick actions --
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 6
                        color: nmEditorMouse.containsMouse ? Theme.surface1 : Theme.surface0

                        Text {
                            anchors.centerIn: parent
                            text: "NetworkManager"
                            color: Theme.text
                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: nmEditorMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Quickshell.execDetached(["nm-connection-editor"])
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 6
                        color: nmtuiMouse.containsMouse ? Theme.surface1 : Theme.surface0

                        Text {
                            anchors.centerIn: parent
                            text: "nmtui"
                            color: Theme.text
                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: nmtuiMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Quickshell.execDetached(["kitty", "nmtui"])
                        }
                    }
                }
            }
        }
    }
}
