import QtQuick
import QtQuick.Layouts
import Quickshell
import "../services"

Item {
  id: root
  implicitWidth: row.implicitWidth + 16
  implicitHeight: 28

  visible: NiriService.focusedWindowId

  // --- Visuals ----
  Rectangle {
    anchors.fill: parent
    radius: 6
    color: mouseArea.containsMouse ? "#313244" : Qt.rgba(0x1e/255, 0x1e/255, 0x2e/255, 0.4)
  }

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: 8

    Text {
      text: NiriService.windowDisplayName(NiriService.windows[NiriService.focusedWindowId])
      color: "#cdd6f4"
      font.pixelSize: 16
    }

    Rectangle {}

    Text {
      text: "\ueab9"
      color: "#cdd6f4"
      font.pixelSize: 20

      MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onClicked: NiriService.maximizeColumn()
      }
    }

    Text {
      text: "\uf00d"
      color: "#cdd6f4"
      font.pixelSize: 20

      MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onClicked: NiriService.closeWindow()
      }
    }
  }

  MouseArea {
      id: mouseArea
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.NoButton
  }
}