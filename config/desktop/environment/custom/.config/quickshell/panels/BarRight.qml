import Quickshell
import QtQuick
import "../services"

PanelWindow {
  anchors {
    top: true
    bottom: true
    right: true
  }
  exclusiveZone: 0
  implicitWidth: 6
  color: "transparent"

  Item {
    anchors.fill: parent
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true

      onClicked: NiriService.focusColumnRight()
      onWheel: (wheel) => {
        if (wheel.angleDelta.y > 0)
          NiriService.focusWorkspaceUp()
        else
          NiriService.focusWorkspaceDown()
        wheel.accepted = true
      }
    }
  }
}
