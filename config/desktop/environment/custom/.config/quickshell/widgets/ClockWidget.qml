import QtQuick
import QtQuick.Layouts
import Quickshell
import "../core"


Item {
  id: root
  implicitWidth: row.implicitWidth + 16
  implicitHeight: 28

  property string format: "ddd, MMM dd - HH:mm" // "HH:mm"

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
      id: clock
      color: Theme.text
      font: Theme.bodyFont
      text: Qt.formatDateTime(new Date(), root.format)

      Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.text = Qt.formatDateTime(new Date(), root.format)
      }
    }
  }

  MouseArea {
      id: mouseArea
      anchors.fill: parent
      hoverEnabled: true
  }
}