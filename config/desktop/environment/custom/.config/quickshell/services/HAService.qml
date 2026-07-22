pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // --------- Attributes -------
    property var cache: ({}) // entity_id -> HaEntity instance

    property Component entityComponent: Component {
        QtObject {
            property string entityId
            property var state
            property var attributes: ({})
        }
    }

    function entity(entityId) {
        if (!cache[entityId]) {
            cache[entityId] = entityComponent.createObject(root, { entityId: entityId })
            send({subscribe: {entities: [entityId]}})
        }
        return cache[entityId]
    }

    function updateEntity(entityId, state, attributes) {
        let e = cache[entityId]
        if (e) {
            e.state = state
            e.attributes = attributes
        }
    }


    // --------- Socket -------
    readonly property string socketPath: Quickshell.env("XDG_RUNTIME_DIR") + "/ha-linux.sock"
    readonly property bool hasSocketPath: socketPath !== undefined && socketPath !== ""
    property bool available: socket.connected

    Socket {
        id: socket
        path: root.socketPath
        connected: root.hasSocketPath

        onConnectionStateChanged: {
            console.log("ha socket: ", connected)
            if (connected) {
                let keys = Object.keys(cache)
                if (keys.length > 0) {
                    write(JSON.stringify({subscribe: {entities: keys}}) + "\n")
                }
            }
        }

        parser: SplitParser {
            onRead: line => {
                try {
                    handleEvent(JSON.parse(line));
                } catch (e) {
                    console.warn("HAService: failed to parse event:", line, e);
                }
            }
        }
    }

    function send(request) {
        if (!socket.connected)
            return false;
        socket.write(JSON.stringify(request) + "\n");
        return true;
    }

    // ---- event handling ----
    function handleEvent(event) {
      console.log("got ha event: entity id: " + event.entity_id)
      updateEntity(
        event.entity_id,
        event.state,
        event.attributes
      )
    }

    // ---- actions ----
    property int _msgId: 600

    function callService(domain, service, target, data) {
        console.log("HA callService: " + domain + " " + service + " " + target + " " + data)
        if (!socket.connected) return false;
        let request = {
            id: ++_msgId,
            type: "call_service",
            domain: domain,
            service: service,
            target: target,
        };
        if (data) request.service_data = data;
        return send(request);
    }

    function turnOn(entityId) {
        return callService("light", "turn_on", {entity_id: entityId});
    }

    function turnOff(entityId) {
        return callService("light", "turn_off", {entity_id: entityId});
    }

    function toggle(entityId) {
        let e = cache[entityId];
        if (!e) return false;
        if (e.state === true) {
            return turnOff(entityId);
        } else {
            return turnOn(entityId);
        }
    }

    function setBrightness(entityId, brightness) {
        return callService("light", "turn_on", {entity_id: entityId}, {brightness: Math.max(0, Math.min(255, brightness))});
    }

}
