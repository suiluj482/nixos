import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../widgets"
import "../services"

PanelWindow {
  anchors {
    top: true
    left: true
    right: true
  }
  implicitHeight: 30
  color: Qt.rgba(0x1e/255, 0x1e/255, 0x2e/255, 0.4)

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    // hoverEnabled: true

    onClicked: NiriService.focusWorkspaceUp()
    onWheel: (wheel) => {
        if (wheel.angleDelta.y > 0)
          NiriService.focusColumnLeft()
        else
          NiriService.focusColumnRight()
        wheel.accepted = true
      }
  }

  Item {
    anchors.fill: parent

    // Left section
    RowLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      anchors.left: parent.left
      spacing: 4

      WorkspacesWidget {}
      LauncherWidget {}
      WindowsWidget {}
    }

    // Center section
    RowLayout {
      Layout.fillHeight: true
      anchors.centerIn: parent
      spacing: 4
      
      ClockWidget{}

      Rectangle { width: 20 }

      ActiveWindowWidget {}
    }

    // Right section
    RowLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      anchors.right: parent.right
      spacing: 4
      layoutDirection: Qt.RightToLeft

      PowerButtonWidget{}
      PowerWidget {} // tothink: mouse power
      SystemTrayWidget {}
      BluetoothWidget {}
      NetworkWidget {}

      VolumeWidget {} // todo: application mixing, mic, media/mpd
      BrightnessWidget {}
      InhibitWidget {}
      HAWidget {}      
      ClipboardWidget {}

    }

  }
}
