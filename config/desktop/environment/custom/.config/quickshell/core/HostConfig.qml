pragma Singleton
import Quickshell
import QtQuick

Singleton {
    readonly property string deviceType: Quickshell.env("DEVICE_TYPE")
}