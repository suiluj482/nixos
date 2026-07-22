import QtQuick
import QtQuick.Layouts
import Quickshell
import "../core"
import "../services"

Item {
    id: root

    implicitWidth: layout.implicitWidth + 16
    implicitHeight: 28

    // --- Visuals -----------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        radius: 6
        color: mouseArea.containsMouse ? "#313244" : Qt.rgba(0x1e/255, 0x1e/255, 0x2e/255, 0.4)
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: NiriService.allWorkspaces

            delegate: Item {
                required property var modelData

                implicitWidth: 20
                implicitHeight: 20

                property bool hasWindow: modelData.active_window_id != null

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: modelData.is_focused ? "#cba6f7" : "transparent"

                    Rectangle {
                        anchors.centerIn: parent
                        width: 8
                        height: 8
                        radius: 4
                        color: modelData.is_focused ? "#1e1e2e"
                             : modelData.is_active ? "#cdd6f4"
                             : "#6c7086"
                        opacity: modelData.is_focused ? 1 : modelData.is_active ? 0.8 : 0.5
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NiriService.switchToWorkspace(modelData.id)
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0)
                NiriService.focusWorkspaceUp()
            else
                NiriService.focusWorkspaceDown()
            wheel.accepted = true
        }
    }
}
