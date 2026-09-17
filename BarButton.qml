import QtQuick
import qs.Ui

// Bar icon for the board: opens the window, or brings it forward when it's
// already open somewhere.
BarWidget {
  id: root
  moduleName: "funcoder.devops-board"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    tooltipText: "DevOps board"
    onPressed: function(b) {
      if (root.bar) root.bar.run("omarchy-shell shell summon funcoder.devops-board '{}'")
    }
  }
}
