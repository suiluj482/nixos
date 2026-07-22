import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../services"

PanelWindow {
  id: powerMenu

  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  color: "transparent"

  property int col: 3
 
  // ── Button Config ─────────────────────────────
  ListModel {
    id: buttons
    ListElement { 
      icon: "󰚰"; 
      label: "update & shutdown"; 
      key: "U"; 
      cmd: "kitty bash -c 'nixos shutdown; read'" 
    }
    ListElement { 
      icon: "󰐥"; 
      label: "shutdown";          
      key: "S"; 
      cmd: "kitty bash -c 'shutdown now; read'"
    }
    ListElement { 
      icon: "󰜉"; 
      label: "reboot";            
      key: "R"; 
      cmd: "kitty bash -c 'reboot; read'"
    }
    // ListElement {
    //     icon: "󰤄";
    //     label: "hibernate";
    //     key: "H";
    //     cmd: "kitty bash -c 'echo todo; read'" }
    // ListElement {
    //     icon: "󰚰";
    //     label: "update";
    //     key: "N";
    //     cmd: "kitty bash -c 'nixos update; read'" }
    ListElement {
        icon: "\uf021"; // "\uf313"
        label: "nixos rebuild";
        key: "N";
        cmd: "kitty bash -c 'nixos rebuild; read'" }
    ListElement {
        icon: "󰖳";
        label: "windows";
        key: "W";
        cmd: "kitty bash -c 'rebootWin; read'"
    }
    ListElement {
        icon: "󰘚";
        label: "uefi";
        key: "B";
        cmd: "kitty bash -c 'sudo systemctl reboot --firmware-setup; read'"
    }
    ListElement {
        icon: "󰒲";
        label: "suspend";
        key: "Z";
        cmd: "systemctl suspend" }
    ListElement {
        icon: "󰌾";
        label: "lock";
        key: "L";
        cmd: "hyprlock"
    }
    ListElement {
        icon: "󰍃";
        label: "logout";
        key: "E";
        cmd: "loginctl terminate-session $XDG_SESSION_ID"
    }
  }

  // ── Visibilty ───
  visible: PowerMenuState.visible

  IpcHandler {
      target: "powerMenu"

      function toggle() {
          PowerMenuState.visible = !PowerMenuState.visible
      }
  }

  property int currentIndex: 0
  property int len: buttons.count

  // ── Close / run helpers ────────────────────────────────────────────────
  function close() { PowerMenuState.visible = false }

  Process {
    id: sh
    function run(cmd) {
      command = ["bash", "-c", cmd]
      startDetached()
    }
  }

  function run(cmd) {
    PowerMenuState.visible = false
    sh.run(cmd)
  }

  // ── Keyboard handling — driven entirely by the model ──────────────────
  contentItem {
    focus: true
    Keys.onPressed: event => {
      if (event.key === Qt.Key_Escape) { close(); return }
      if (event.key === Qt.Key_Right) { currentIndex = (currentIndex + 1) % len; return }
      if (event.key === Qt.Key_Left) { currentIndex = (currentIndex - 1 +len) % len; return }
      if (event.key === Qt.Key_Down) { currentIndex = (currentIndex + col) % len; return }
      if (event.key === Qt.Key_Up) { currentIndex = (currentIndex - col +len) % len; return }
      if (event.key === Qt.Key_Return) { run(buttons.get(currentIndex).cmd); return }
      const keyChar = event.text.toUpperCase()
      for (let i = 0; i < buttons.count; i++) {
        const entry = buttons.get(i)
        if (entry.key === keyChar) {
          run(entry.cmd)
          return
        }
      }
    }
  }

  // ── UI ──────────────────────────────────────────────────────────
  
  Rectangle {
    color: "#e60c0c0c"
    anchors.fill: parent

    MouseArea {
      anchors.fill: parent
      onClicked: powerMenu.close()
    }

    GridLayout {
      anchors.centerIn: parent
      columns: col
      rowSpacing: 16
      columnSpacing: 16

      Repeater {
        model: buttons
        delegate: Rectangle {
          width: 320
          height: 280
          radius: 12
          property bool active: area.containsMouse || index == currentIndex
          color: active  ? "#40ffffff" : "#26ffffff"
          border.color: active ? "#99ffffff" : "#40ffffff"
          border.width: 1

          Behavior on color { ColorAnimation { duration: 120 } }
          Behavior on border.color { ColorAnimation { duration: 120 } }

          MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: powerMenu.run(model.cmd)
          }

          ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            Text {
              Layout.alignment: Qt.AlignHCenter
              text: model.icon
              font.pixelSize: 84
              color: "white"
            }
            Text {
              Layout.alignment: Qt.AlignHCenter
              text: model.label
              font.pixelSize: 26
              color: "white"
              opacity: 0.9
            }
            Rectangle {
              Layout.alignment: Qt.AlignHCenter
              width: hint.width + 28
              height: 22
              radius: 4
              color: "#33ffffff"
              Text {
                id: hint
                anchors.centerIn: parent
                text: model.key
                font.pixelSize: 22
                font.family: "monospace"
                color: "white"
                opacity: 0.75
              }
            }
          }
        }
      }
    }
  }
}