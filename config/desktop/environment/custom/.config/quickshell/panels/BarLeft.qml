import QtQuick
import Quickshell
import "../services"

PanelWindow {
  anchors {
    top: true
    bottom: true
    left: true
  }
  // exclusiveZone: 0
  implicitWidth: 6
  color: "transparent"

  Item {
    anchors.fill: parent
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: NiriService.focusColumnLeft()

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
