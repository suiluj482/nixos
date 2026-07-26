pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // --------- Attributes -------
    readonly property string socketPath: Quickshell.env("NIRI_SOCKET")
    readonly property bool available: socketPath !== undefined && socketPath !== ""

    // Workspaces keyed by id, e.g. { id, idx, output, is_active, is_focused, name }
    property var workspaces: ({})
    // Same data as a list, sorted by idx -- convenient for Repeater models
    property var allWorkspaces: []
    property string focusedWorkspaceId: ""

    function setWorkspaces(map) {
        workspaces = map;
        allWorkspaces = Object.values(map).sort((a, b) => a.idx - b.idx);
    }

    property var windows: ({})
    property var allWindows: []
    property var currentWorkspaceWindows: []
    property var focusedWindowId: null

    function windowDisplayName(win) {
        return win ? (win.title || win.app_id || "unknown") : "undefined";
    }

    // --------- Sockets -------
    // read
    Socket {
        id: eventSocket
        path: root.socketPath
        connected: root.available

        onConnectionStateChanged: {
            if (connected) {
                write('"EventStream"\n');
            }
        }

        parser: SplitParser {
            onRead: line => {
                try {
                    handleEvent(JSON.parse(line));
                } catch (e) {
                    console.warn("NiriService: failed to parse event:", line, e);
                }
            }
        }
    }

    // write
    Socket {
        id: requestSocket
        path: root.socketPath
        connected: root.available
    }

    function send(request) {
        if (!root.available || !requestSocket.connected)
            return false;
        requestSocket.write(JSON.stringify(request) + "\n");
        return true;
    }

    // ---- event handling ----
    function handleEvent(event) {
        const type = Object.keys(event)[0];
        const data = event[type];

        switch (type) {
        case "WorkspacesChanged":
            handleWorkspacesChanged(data);
            break;
        case "WorkspaceActivated":
            handleWorkspaceActivated(data);
            break;
        case "WindowsChanged":
            // console.log("NiriService: WindowsChanged —", JSON.stringify(data).substring(0, 500));
            handleWindowsChanged(data);
            break;
        case "WindowFocusChanged":
            // console.log("NiriService: WindowFocusChanged —", JSON.stringify(data));
            handleWindowFocusChanged(data);
            break;
        case "WindowOpenedOrChanged":
            // console.log("NiriService: WindowOpenedOrChanged —", JSON.stringify(data).substring(0, 500));
            handleWindowOpenedOrChanged(data);
            break;
        case "WindowClosed":
            // console.log("NiriService: WindowClosed —", JSON.stringify(data));
            handleWindowClosed(data);
            break;
        case "WindowLayoutsChanged":
            // console.log("NiriService: WindowLayoutsChanged —", JSON.stringify(data).substring(0, 500));
            handleWindowLayoutsChanged(data);
            break;
        case "WindowUrgencyChanged":
            // console.log("NiriService: WindowUrgencyChanged —", JSON.stringify(data));
            handleWindowUrgencyChanged(data);
            break;
        // default:
        //     console.log("NiriService: UNHANDLED event —", type, JSON.stringify(data).substring(0, 500));
        //     break;
        }
    }

    // ----- Action handling
    // Workspaces
    function handleWorkspacesChanged(data) {
        const map = {};
        for (const ws of data.workspaces) {
            map[ws.id] = ws;
        }
        setWorkspaces(map);

        const focused = allWorkspaces.find(w => w.is_focused);
        focusedWorkspaceId = focused ? focused.id : "";
    }

    function handleWorkspaceActivated(data) {
        const activatedWs = workspaces[data.id];
        if (!activatedWs)
            return;

        const map = {};
        for (const id in workspaces) {
            const ws = workspaces[id];
            const isMatch = ws.id === data.id;
            map[id] = Object.assign({}, ws, {
                                        is_active: ws.output === activatedWs.output ? isMatch : ws.is_active,
                                        is_focused: data.focused ? isMatch : ws.is_focused
                                    });
        }
        setWorkspaces(map);

        if (data.focused) {
            focusedWorkspaceId = data.id;
        }
    }

    // Windows
    function handleWindowsChanged(data) {
        const map = {};
        const list = [];
        let focused = "";
        for (const win of data.windows) {
            map[win.id] = win;
            list.push(win);
            if(win.is_focused) {
                focused = win.id
            }
        }
        windows = map;
        allWindows = list;
        focusedWindowId = focused
        recomputeWindowState();
    }

    function handleWindowFocusChanged(data) {
        focusedWindowId = data.id;
        recomputeWindowState();
    }

    function handleWindowOpenedOrChanged(data) {
        const win = data.window;
        const map = Object.assign({}, windows);
        map[win.id] = win;
        windows = map;
        rebuildSortedWindows();
        recomputeWindowState();
    }

    function handleWindowClosed(data) {
        const map = Object.assign({}, windows);
        delete map[data.id];
        windows = map;
        rebuildSortedWindows();
        recomputeWindowState();
    }

    function handleWindowLayoutsChanged(data) {
        const map = Object.assign({}, windows);
        for (const change of data.changes) {
            const id = change[0];
            const layout = change[1];
            if (map[id]) {
                map[id] = Object.assign({}, map[id], { layout });
            }
        }
        windows = map;
        rebuildSortedWindows();
        recomputeWindowState();
    }

    function handleWindowUrgencyChanged(data) {
        const win = windows[data.id];
        if (!win) return;
        const map = Object.assign({}, windows);
        map[data.id] = Object.assign({}, win, { is_urgent: data.urgent });
        windows = map;
    }

    // ----- Internal helpers

    function rebuildSortedWindows() {
        allWindows = Object.values(windows).sort((a, b) => {
            const aPos = a.layout ? a.layout.pos_in_scrolling_layout : null;
            const bPos = b.layout ? b.layout.pos_in_scrolling_layout : null;
            if (aPos && bPos) {
                if (aPos[0] !== bPos[0]) return aPos[0] - bPos[0];
                return aPos[1] - bPos[1];
            }
            if (aPos) return -1;
            if (bPos) return 1;
            return a.id - b.id;
        });
    }

    function recomputeWindowState() {
        currentWorkspaceWindows = allWindows.filter(w => String(w.workspace_id) === String(focusedWorkspaceId));
    }

    // ---- actions ----

    // Workspaces
    function switchToWorkspace(workspaceId) {
        return send({ "Action": { "FocusWorkspace": { "reference": { "Id": workspaceId } } } });
    }
    function switchToWorkspaceByIndex(index) {
        return send({ "Action": { "FocusWorkspace": { "reference": { "Index": index } } } });
    }
    function focusWorkspaceUp() {
        return send({ "Action": { "FocusWorkspaceUp": {} } });
    }
    function focusWorkspaceDown() {
        return send({ "Action": { "FocusWorkspaceDown": {} } });
    }

    // Windows
    function focusColumnLeft() {
        return send({ "Action": { "FocusColumnLeft": {} } });
    }
    function focusColumnRight() {
        return send({ "Action": { "FocusColumnRight": {} } });
    }
    function focusWindow(windowId) {
        return send({ "Action": { "FocusWindow": { "id": windowId } } });
    }

    function closeWindow() {
        return send({ "Action": { "CloseWindow": {} } });
    }
    function maximizeColumn() {
        return send({ "Action": { "MaximizeColumn": {} } });
    }
    function centerColumn() {
        return send({ "Action": { "CenterColumn": {} } });
    }
}
