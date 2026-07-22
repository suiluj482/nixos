import QtQuick
import QtQuick.Layouts
import Quickshell
import "../core"
import "../services"

Rectangle {
  id: powerButton
  Layout.fillHeight: true
  width: powerLabel.implicitWidth + 15
  color: powerButtonMouseArea.containsMouse ? "#313244" : Qt.rgba(0x1e/255, 0x1e/255, 0x2e/255, 0.4)
  Text {
    id: powerLabel
    anchors.centerIn: parent
    text: "⏻"
    color: Theme.text
    font: Theme.bodyFont
  }
  MouseArea {
    id: powerButtonMouseArea
    anchors.fill: parent
    hoverEnabled: true
    onClicked: PowerMenuState.toggle()
  }
}