import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Bluetooth
import "../core"

Loader {
    active: Bluetooth.defaultAdapter
    visible: active

    sourceComponent: Item {
        id: root

        implicitWidth: row.implicitWidth + 16
        implicitHeight: 28

        readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
        readonly property int connectedCount: Bluetooth.devices.count

        function stateLabel() {
            if (!root.adapter) return "Unavailable"
            return BluetoothAdapterState.toString(root.adapter.state)
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
                text: "\uf294" // nf-fa-bluetooth
                font.family: "Symbols Nerd Font"
                font.pixelSize: 14
                color: {
                    if (!root.adapter || !root.adapter.enabled) return Theme.overlay0
                    if (root.connectedCount > 0) return Theme.blue
                    return Theme.text
                }
            }

            Text {
                visible: root.connectedCount > 0
                text: Bluetooth.devices.count > 0
                      ? (Bluetooth.devices.get(0)?.name || Bluetooth.devices.get(0)?.deviceName || "")
                      : ""
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
            implicitWidth: 320
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

                // -- Adapter header --
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: root.adapter?.name || "Bluetooth"
                            color: Theme.text
                            font.bold: true
                            font.pixelSize: 13
                        }
                        Text {
                            text: root.stateLabel()
                            color: Theme.subtext0
                            font.pixelSize: 11
                        }
                    }

                    RowLayout {
                        spacing: 20

                        // Enabled toggle
                        RowLayout {
                            spacing: 4
                            visible: root.adapter !== null

                            Rectangle {
                                implicitWidth: 36
                                implicitHeight: 20
                                radius: 10
                                color: root.adapter?.enabled ? Theme.green : Theme.surface2

                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: Theme.crust
                                    x: root.adapter?.enabled ? parent.width - width - 2 : 2
                                    y: (parent.height - height) / 2
                                    Behavior on x { NumberAnimation { duration: 100 } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (root.adapter)
                                            root.adapter.enabled = !root.adapter.enabled
                                    }
                                }
                            }
                        }

                        // Discoverable toggle
                        RowLayout {
                            spacing: 4
                            visible: root.adapter?.enabled ?? false

                            Text {
                                text: "Visible"
                                color: Theme.subtext0
                                font.pixelSize: 10
                            }

                            Rectangle {
                                implicitWidth: 36
                                implicitHeight: 20
                                radius: 10
                                color: root.adapter?.discoverable ? Theme.blue : Theme.surface2

                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: Theme.crust
                                    x: root.adapter?.discoverable ? parent.width - width - 2 : 2
                                    y: (parent.height - height) / 2
                                    Behavior on x { NumberAnimation { duration: 100 } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (root.adapter)
                                            root.adapter.discoverable = !root.adapter.discoverable
                                    }
                                }
                            }
                        }

                        // Discovering toggle
                        RowLayout {
                            spacing: 4
                            visible: root.adapter?.enabled ?? false

                            Text {
                                text: "Scanning"
                                color: Theme.subtext0
                                font.pixelSize: 10
                            }

                            Rectangle {
                                implicitWidth: 36
                                implicitHeight: 20
                                radius: 10
                                color: root.adapter?.discovering ? Theme.blue : Theme.surface2

                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: Theme.crust
                                    x: root.adapter?.discovering ? parent.width - width - 2 : 2
                                    y: (parent.height - height) / 2
                                    Behavior on x { NumberAnimation { duration: 100 } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (root.adapter)
                                            root.adapter.discovering = !root.adapter.discovering
                                            // root.adapter.discovering = true
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface1 }

                // -- Connected devices --
                Text {
                    text: "Connected (" + root.connectedCount + ")"
                    color: Theme.subtext1
                    font.pixelSize: 11
                }

                Repeater {
                    model: Bluetooth.devices

                    delegate: Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        implicitHeight: devCol.implicitHeight + 16
                        radius: 6
                        color: Theme.surface0

                        ColumnLayout {
                            id: devCol
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    text: modelData.name || modelData.deviceName
                                    color: Theme.text
                                    font.pixelSize: 12
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    visible: modelData.batteryAvailable
                                    text: Math.round(modelData.battery * 100) + "%"
                                    color: Theme.subtext1
                                    font.pixelSize: 11
                                }

                                RowLayout {
                                    spacing: 8

                                    // pair
                                    Text {
                                        text: "\udb80\udcb1" // nf-md-bluetooth_connect
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 12
                                        color: dcArea.containsMouse ? Theme.red : Theme.overlay1
                                        visible: !modelData.paired

                                        MouseArea {
                                            id: paArea
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: modelData.pair()
                                        }
                                    }
                                    
                                    // connect
                                    Text {
                                        text: "\uf04b" // nf-fa-play
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 12
                                        color: dcArea.containsMouse ? Theme.red : Theme.overlay1
                                        visible: modelData.paired && !modelData.connected

                                        MouseArea {
                                            id: cnArea
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: modelData.connect()
                                        }
                                    }

                                    // disconnect
                                    Text {
                                        text: "\uf04d" // nf-fa-stop_circle
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 12
                                        color: dcArea.containsMouse ? Theme.red : Theme.overlay1
                                        visible: modelData.connected

                                        MouseArea {
                                            id: dcArea
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: modelData.disconnect()
                                        }
                                    }

                                    // forget
                                    Text {
                                        text: "\uf1f8" // nf-fa-trash
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 12
                                        color: fgArea.containsMouse ? Theme.red : Theme.overlay1
                                        visible: modelData.paired

                                        MouseArea {
                                            id: fgArea
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: modelData.forget()
                                        }
                                    }
                                }
                            }

                            Text {
                                text: BluetoothDeviceState.toString(modelData.state)
                                color: Theme.overlay0
                                font.pixelSize: 10
                            }
                        }
                    }
                }

                Text {
                    visible: root.connectedCount === 0
                    text: "No connected devices"
                    color: Theme.overlay0
                    font.pixelSize: 11
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
                        color: btManagerMouse.containsMouse ? Theme.surface1 : Theme.surface0

                        Text {
                            anchors.centerIn: parent
                            text: "Bluetooth Settings"
                            color: Theme.text
                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: btManagerMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Quickshell.execDetached(["blueman-manager"])
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 6
                        color: btManagerMouse.containsMouse ? Theme.surface1 : Theme.surface0

                        Text {
                            anchors.centerIn: parent
                            text: "bluetoothctl"
                            color: Theme.text
                            font.pixelSize: 11
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Quickshell.execDetached(["kitty", "bluetoothctl"])
                        }
                    }
                }
            }
        }
    }
}
