import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../core"

Item {
    id: root
    implicitWidth: layout.implicitWidth + 20
    implicitHeight: 28

    property bool expanded: false

    // --- Visuals -----------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        radius: 6
        color: mouseArea.containsMouse ? "#313244" : Qt.rgba(0x1e/255, 0x1e/255, 0x2e/255, 0.4)
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.expanded = !root.expanded
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 6

        Text {
            id: chevron
            text: root.expanded ? "\uf077" : "\uf078"
            font: Theme.bodyFont
            color: "#cdd6f4"
            verticalAlignment: Text.AlignVCenter
        }

        Repeater {
            model: SystemTray.items.values
            delegate: TrayItem {
              visible: expanded | needsAttention
            }
        }
    }


    component TrayItem: Item {
        id: trayItem
        required property SystemTrayItem modelData

        implicitWidth: 20
        implicitHeight: 20

        property bool needsAttention: modelData.status === Status.NeedsAttention
        property bool isActive: modelData.status === Status.Active

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: "transparent"
            border.width: 2
            border.color: "#f38ba8" // red
            visible: trayItem.needsAttention
            opacity: trayItem.needsAttention ? 1 : 0
        }

        IconImage {   // todo: greyscale, do something with status
            id: icon
            anchors.fill: parent
            source: trayItem.modelData.icon
            smooth: true

            opacity: trayItem.isActive || trayItem.needsAttention ? 1.0 : 0.75
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        MouseArea {
            id: mouseAreaItem
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            hoverEnabled: true

            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    if (trayItem.modelData.onlyMenu) {
                        trayItem.modelData.display(menuAnchor, 0, 0)
                    } else {
                        trayItem.modelData.activate()
                    }
                } else if (mouse.button === Qt.MiddleButton) {
                    trayItem.modelData.secondaryActivate?.()
                } else if (mouse.button === Qt.RightButton) {
                    if (trayItem.modelData.hasMenu) {
                        menuAnchor.open()
                    }
                }
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: trayItem.modelData.menu
                anchor.item: root
                anchor.edges: Edges.Bottom
            }
        }
    }
}