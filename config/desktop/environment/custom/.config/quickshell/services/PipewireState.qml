pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire


Item {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    // readonly property real volume: sink?.audio?.volume ?? 0
    // readonly property bool muted: sink?.audio?.muted ?? false

    // Required: keeps the node bound so .audio is populated and writable.
    // Without this, sink.audio can be null or stale.
    PwObjectTracker {
        objects: [root.sink]
    }
}