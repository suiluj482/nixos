import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../core"
import "../services"

Item {
    id: root

    implicitWidth: row.implicitWidth + 16
    implicitHeight: 28

    visible: NiriService.currentWorkspaceWindows.length > 0

    // --- Visuals -----------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        radius: 6
        color: mouseArea.containsMouse ? "#313244" : Qt.rgba(0x1e/255, 0x1e/255, 0x2e/255, 0.4)
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: NiriService.currentWorkspaceWindows

            delegate: Item {
                required property var modelData

                implicitWidth: 22
                implicitHeight: 22

                property bool isFocused: NiriService.focusedWindowId === modelData.id

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: isFocused ? "#cba6f7" : "transparent"

                    IconImage {
                        anchors.centerIn: parent
                        source: Quickshell.iconPath(Utils.iconForAppId(modelData.app_id))
                        implicitSize: 18
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NiriService.focusWindow(modelData.id)
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
                NiriService.focusColumnLeft()
            else
                NiriService.focusColumnRight()
            wheel.accepted = true
        }
    }
}
