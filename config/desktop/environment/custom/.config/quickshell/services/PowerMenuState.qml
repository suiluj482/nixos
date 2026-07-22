pragma Singleton
import QtQuick

QtObject {
  property bool visible: false

  function toggle(): void {
    visible = !visible
  }
}