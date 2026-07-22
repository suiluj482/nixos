import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "../services"
import "../core"


Loader {
    active: HAService.available // HostConfig.deviceType == "tower" ? true : false
    visible: active

    sourceComponent: Item {
        id: root

        implicitWidth: layout.implicitWidth + 16
        implicitHeight: 28

        // --- Visuals -----------------------------------------------------------
        Rectangle {
            anchors.fill: parent
            radius: 6
            color: mouseArea.containsMouse ? "#313244" : Qt.rgba(0x1e/255, 0x1e/255, 0x2e/255, 0.4)
        }

        RowLayout {
            id: layout
            anchors.centerIn: parent
            spacing: 6

            // Co2
            Text {
                text: HAService.entity("sensor.co2_mini_co2").state
                font.pixelSize: 12
                color: "#cdd6f4"
            }
            Text {
                text: "\udb81\udfe4"
                font.pixelSize: 20
                color: "#cdd6f4"
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
              text: "Home Assistant"
              color: Theme.text
              font.bold: true
              font.pixelSize: 13
            }

            Light { name: "Desk Light"; entityId: "light.studio_light_general_desk" }
            Light { name: "Central Light"; entityId: "light.studio_light_general_central" }
            Light { name: "Living Room Light"; entityId: "light.studio_light_general_living_room" }

            Light { name: "Esstisch"; entityId: "light.esstisch_light" }
            Light { name: "Bedroom"; entityId: "light.bedroom" }

          }
        }
    }



    component Light: Rectangle {
      id: light
      Layout.fillWidth: true
      implicitHeight: 32
      radius: 6
      color: Theme.surface0

      property string name: "Desk Light"
      property string entityId: "light.studio_light_general_desk"

      property bool isOn: HAService.entity(entityId).state
      property int brightness: Number(HAService.entity(entityId).attributes.brightness)

      RowLayout {
        id: lightRow
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        Text {
            visible: light.isOn
            text: Math.round(light.brightness*100/255) + "%"
            font.pixelSize: 18
            color: "#cdd6f4"
        }

        Text {
          text: light.icon()
          color: "yellow"
          font.pixelSize: 20
        }

        Text {
          text: light.name
          color: Theme.text
          font.pixelSize: 18
        }

        Item { Layout.fillWidth: true }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: HAService.toggle(light.entityId)
        onWheel: wheelEvent => {
            let step = 25
            let delta = wheelEvent.angleDelta.y > 0 ? step : -step
            light.brightness = Math.max(0, Math.min(255, light.brightness + delta))
            debounceTimer.restart()
            lockTimer.restart()
        }
      }

      Timer {
        id: debounceTimer
        interval: 100
        onTriggered: {
            HAService.setBrightness(light.entityId, light.brightness)
        }
      }
      Timer {
        id: lockTimer
        interval: 1000
        onTriggered: {}
      }

      Connections {
        target: HAService.entity(light.entityId)
        function onAttributesChanged() {
            if (lockTimer.running) return
            light.brightness = Number(target.attributes.brightness)
        }
      } 

      function icon(){
          if (!isOn) return "\udb83\ude50"
          let percent = Math.round(light.brightness*100/255)
          if (percent < 10) return "\udb86\ude4e"
          if (percent < 20) return "\udb86\ude4f"
          if (percent < 30) return "\udb86\ude50"
          if (percent < 40) return "\udb86\ude51"
          if (percent < 50) return "\udb86\ude52"
          if (percent < 60) return "\udb86\ude53"
          if (percent < 70) return "\udb86\ude54"
          if (percent < 80) return "\udb86\ude55"
          if (percent < 90) return "\udb86\ude56"
          return "\udb81\udee8"
      }
    }

}