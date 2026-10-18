pragma Singleton
import QtQuick

QtObject {
  id: root

  // name -> PopupWindow. Actual window visibility is the source of truth;
  // nothing here mirrors it, so external dismissals can't desync state.
  property var popups: ({})

  function register(name: string, win: var): void {
    popups[name] = win
  }

  function unregister(name: string): void {
    delete popups[name]
  }

  function toggle(name: string): void {
    const win = popups[name]
    if (!win) return

    if (win.visible) {
      win.visible = false
      return
    }

    closeAllExcept(name)
    PowerMenuState.visible = false
    win.visible = true
  }

  function closeAllExcept(name: string): void {
    for (const key in popups) {
      if (key === name) continue
      const other = popups[key]
      if (other) other.visible = false
    }
  }

  function closeAll(): void {
    for (const key in popups) {
      const win = popups[key]
      if (win) win.visible = false
    }
  }
}
