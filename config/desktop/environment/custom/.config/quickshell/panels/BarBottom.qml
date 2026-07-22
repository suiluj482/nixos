import Quickshell
import QtQuick
import "../services"

PanelWindow {
  anchors {
    bottom: true
    left: true
    right: true
  }
  exclusiveZone: 0
  implicitHeight: 8
  color: "transparent"

  Item {
    anchors.fill: parent
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true

      onClicked: NiriService.focusWorkspaceDown()
      onWheel: (wheel) => {
        if (wheel.angleDelta.y > 0)
          NiriService.focusColumnLeft()
        else
          NiriService.focusColumnRight()
        wheel.accepted = true
      }
    }
  }
}