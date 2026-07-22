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
  property bool sleepBlocked: false
  property var inhibitors: []
  property int timerDuration: 0
  property int timerRemaining: 0
  property bool timerActive: false

  readonly property var presets: [
    { label: "30m", seconds: 1800 },
    { label: "1h",  seconds: 3600 },
    { label: "2h",  seconds: 7200 },
    { label: "4h",  seconds: 14400 },
  ]

  function formatDuration(totalSeconds) {
    const h = Math.floor(totalSeconds / 3600)
    const m = Math.floor((totalSeconds % 3600) / 60)
    const s = totalSeconds % 60
    if (h > 0)
      return h + ":" + String(m).padStart(2, "0") + ":" + String(s).padStart(2, "0")
    return m + ":" + String(s).padStart(2, "0")
  }

  function startTimer(seconds) {
    timerDuration = seconds
    timerRemaining = seconds
    timerActive = true
    sleepBlocked = true
    countdownTimer.start()
  }

  function cancelTimer() {
    timerActive = false
    timerRemaining = 0
    timerDuration = 0
    countdownTimer.stop()
  }

  // --- logic ---
  Process {
    id: inhibitProcess
    command: ["systemd-inhibit", "--what=sleep", "--who=quickshell", "--why=User requested", "sleep", "infinity"]
    running: sleepBlocked
  }

  Process {
    id: listProcess
    command: ["systemd-inhibit", "--no-legend", "--no-pager", "--no-ask-password"]
    running: false

    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split('\n')
        const list = []
        for (let i = 0; i < lines.length; i++) {
          const line = lines[i].trim()
          if (line === "") continue

          // seperate parts
          const parts = line.split(/\s+/)
          if (parts.length < 6) continue
          const who = parts[0]
          const uid = parts[1]
          const user = parts[2]
          const pid = parts[3]
          const comm = parts[4]
          const what = parts[5]
          const why = parts.slice(6, parts.length - 2).join(' ')
          const mode = parts[parts.length - 1]

          // filter
          if (who === "quickshell") continue
          if (mode === "delay") continue

          list.push({ who: who, what: what, why: why, mode: mode, user: user })
        }
        inhibitors = list
      }
    }
  }

  function refreshInhibitors() {
      listProcess.running = true
  }

  Timer {
      interval: 5000
      running: popup.visible
      repeat: true
      onTriggered: refreshInhibitors()
  }

  Timer {
      id: countdownTimer
      interval: 1000
      repeat: true
      onTriggered: {
        timerRemaining--
        if (timerRemaining <= 0) {
          stop()
          timerActive = false
          sleepBlocked = false
        }
      }
  }

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
      text: "\uf186"
      color: sleepBlocked ? Theme.green : Theme.text
      font.pixelSize: 14
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    onClicked: popup.visible = !popup.visible
  }

  PopupWindow {
    id: popup
    grabFocus: true
    anchor.item: root
    anchor.edges: Edges.Bottom
    implicitWidth: 320
    implicitHeight: content.implicitHeight + 16
    color: "transparent"

    onVisibleChanged: {
      if (visible) refreshInhibitors()
    }

    Rectangle {
      anchors.fill: parent
      radius: 10
      color: Theme.base
      border.color: Theme.surface1
    }

    ColumnLayout {
      id: content
      anchors.fill: parent
      anchors.margins: 8
      spacing: 8

      Text {
        text: "Sleep Inhibitors"
        color: Theme.text
        font.bold: true
        font.pixelSize: 13
      }

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 32
        radius: 6
        color: Theme.surface0

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 8
          anchors.rightMargin: 8
          spacing: 8

          Text {
            text: "Block Sleep"
            color: Theme.text
            font.pixelSize: 12
          }

          Item { Layout.fillWidth: true }

          Rectangle {
            implicitWidth: 40
            implicitHeight: 22
            radius: 11
            color: sleepBlocked ? Theme.green : Theme.surface2

            Rectangle {
              width: 18
              height: 18
              radius: 9
              color: Theme.crust
              x: sleepBlocked ? parent.width - width - 2 : 2
              y: (parent.height - height) / 2

              Behavior on x { NumberAnimation { duration: 100 } }
            }

            MouseArea {
              anchors.fill: parent
              onClicked: {
                if (sleepBlocked) {
                  cancelTimer()
                  sleepBlocked = false
                } else {
                  sleepBlocked = true
                }
              }
            }
          }
        }
      }

      RowLayout {
        spacing: 4

        Repeater {
          model: root.presets

          delegate: Rectangle {
            required property var modelData
            property bool selected: timerActive && timerDuration === modelData.seconds

            implicitWidth: label.implicitWidth + 16
            implicitHeight: 24
            radius: 4
            color: selected ? Theme.accent : (btnMouse.containsMouse ? Theme.surface1 : Theme.surface0)

            Text {
              id: label
              anchors.centerIn: parent
              text: modelData.label
              color: selected ? Theme.crust : Theme.subtext1
              font.pixelSize: 11
            }

            MouseArea {
              id: btnMouse
              anchors.fill: parent
              hoverEnabled: true
              onClicked: startTimer(modelData.seconds)
            }
          }
        }

        Item { Layout.fillWidth: true }

        Rectangle {
          visible: timerActive
          implicitWidth: timerLabel.implicitWidth + cancelBtn.implicitWidth + 20
          implicitHeight: 24
          radius: 4
          color: Theme.surface0

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            spacing: 4

            Text {
              id: timerLabel
              text: root.formatDuration(timerRemaining)
              color: Theme.peach
              font.pixelSize: 11
              font.family: "JetBrains Mono"
            }

            Text {
              id: cancelBtn
              text: "\uf00d"
              color: cancelMouse.containsMouse ? Theme.red : Theme.overlay1
              font.pixelSize: 11

              MouseArea {
                id: cancelMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: cancelTimer()
              }
            }
          }
        }
      }

      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Theme.surface1
      }

      Text {
        text: "Active Inhibitors (" + inhibitors.length + ")"
        color: Theme.subtext1
        font.pixelSize: 11
      }

      Repeater {
        model: inhibitors

        delegate: Column {
          required property var modelData
          spacing: 2
          Layout.fillWidth: true

          RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
              text: modelData.who
              color: Theme.yellow
              font.pixelSize: 12
            }
            Text {
              text: "(" + modelData.mode + ")"
              color: Theme.overlay1
              font.pixelSize: 11
            }
            Item { Layout.fillWidth: true }
            Text {
              text: modelData.user
              color: Theme.overlay0
              font.pixelSize: 11
            }
          }

          Text {
            text: modelData.what + " \u2014 " + modelData.why
            color: Theme.subtext0
            font.pixelSize: 11
            wrapMode: Text.Wrap
            Layout.fillWidth: true
          }
        }
      }

      Text {
        visible: inhibitors.length === 0
        text: "No active inhibitors"
        color: Theme.overlay0
        font.pixelSize: 11
      }
    }
  }
}
