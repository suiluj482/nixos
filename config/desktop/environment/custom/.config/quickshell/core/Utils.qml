import Quickshell
import Quickshell.Io
pragma Singleton
import QtQuick

QtObject {
    // Returns an icon name/source suitable for Image.source or IconImage
    function iconForAppId(appId: string): string {
        if (!appId || appId.length === 0)
            return "application-x-executable"

        // 1. Try exact match against installed desktop entries
        let entry = DesktopEntries.heuristicLookup(appId)
        if (entry && entry.icon) {
            return entry.icon
        }

        // 2. Try common normalizations (niri app-ids are often lowercase,
        // but desktop files may use CamelCase, reverse-DNS, etc.)
        const candidates = [
                  appId,
                  appId.toLowerCase(),
                  appId.split(".").pop(), // org.foo.Bar -> Bar
                  appId.split(".").pop().toLowerCase(),
              ]

        for (const candidate of candidates) {
            entry = DesktopEntries.heuristicLookup(candidate)
            if (entry && entry.icon)
                return entry.icon
        }

        // 3. Manual overrides for apps that never resolve cleanly
        const overrides = {
            // "kitty": "kitty",
        }
        if (overrides[appId.toLowerCase()])
            return overrides[appId.toLowerCase()]

        // 4. Generic fallback
        return "application-x-executable"
    }
}