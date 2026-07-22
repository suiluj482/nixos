import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../core"

Item {
  id: root

  implicitWidth: row.implicitWidth + 16
  implicitHeight: 28

  // --- state ---


  // --- logic ---


  // --- Visuals ----
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
      text: "\uf07f"
      color: Theme.text
      font.pixelSize: 16
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    onClicked: {
      Quickshell.execDetached(["bash", "-c", "cliphist list | fuzzel --dmenu --width 80 | cliphist decode | wl-copy"])
    }
  }
}