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
      text: "\udb85\udcdf"
      color: Theme.text
      font.pixelSize: 20
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    onClicked: {
      Quickshell.execDetached(["rofi", "-show", "drun"])
    }
  }
}