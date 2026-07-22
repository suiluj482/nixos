import Quickshell
import Quickshell.Wayland
import QtQuick

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: background
        required property var modelData
        screen: modelData

        readonly property string wallpaperPath: "file://" + Quickshell.env("nixos") + "/data/pictures/lion.jpg"

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "quickshell:background"
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"

        Image {
            anchors.fill: parent
            source: background.wallpaperPath
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(background.modelData.width, background.modelData.height)
            asynchronous: true
        }
    }
}
