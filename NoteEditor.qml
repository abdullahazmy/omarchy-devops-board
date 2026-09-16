import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Ui

// Multi-line text field in the kit's control chrome (the Ui kit only ships a
// single-line TextField). Scrolls when the text outgrows the box; Tab and
// Shift+Tab move focus instead of inserting a tab.
Item {
  id: root

  property alias text: area.text
  property string placeholderText: ""
  property bool readOnly: false
  property color foreground: Color.foreground
  property color accent: Color.accent
  property string fontFamily: Style.font.family
  property int fontSize: Style.font.body

  readonly property bool editing: area.activeFocus
  readonly property var _spec: Border.controlSpec(area.activeFocus ? "focus" : (hover.hovered ? "hover-cursor" : "normal"), foreground, accent)

  signal edited()

  function focusEditor() { area.forceActiveFocus() }
  function setText(value) {
    area.text = value || ""
    flick.contentY = 0
  }

  implicitHeight: Style.space(110)

  HoverHandler { id: hover }

  BorderSurface {
    anchors.fill: parent
    radius: Style.cornerRadius
    color: root.readOnly
      ? Util.alpha(root.foreground, 0.02)
      : Style.controlFill(area.activeFocus, hover.hovered, root.foreground, root.accent)
    borderSpec: root._spec
  }

  Flickable {
    id: flick
    anchors.fill: parent
    anchors.leftMargin: Border.left(root._spec)
    anchors.rightMargin: Border.right(root._spec)
    anchors.topMargin: Border.top(root._spec)
    anchors.bottomMargin: Border.bottom(root._spec)
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    TextArea.flickable: TextArea {
      id: area
      readOnly: root.readOnly
      wrapMode: TextArea.Wrap
      textFormat: TextEdit.PlainText
      selectByMouse: true
      persistentSelection: false
      placeholderText: root.placeholderText
      placeholderTextColor: Qt.darker(root.foreground, 1.6)
      color: root.foreground
      selectionColor: Style.selectionFillFor(root.foreground, root.accent)
      selectedTextColor: root.foreground
      font.family: root.fontFamily
      font.pixelSize: root.fontSize
      leftPadding: Style.spacing.controlPaddingX
      rightPadding: Style.spacing.controlPaddingX
      topPadding: Style.spacing.inputPaddingY
      bottomPadding: Style.spacing.inputPaddingY
      background: null
      onTextChanged: if (activeFocus) root.edited()

      Keys.onTabPressed: function(event) {
        var next = area.nextItemInFocusChain(true)
        if (next) next.forceActiveFocus()
        event.accepted = true
      }
      Keys.onBacktabPressed: function(event) {
        var prev = area.nextItemInFocusChain(false)
        if (prev) prev.forceActiveFocus()
        event.accepted = true
      }
    }

    ScrollBar.vertical: ScrollBar {
      policy: flick.contentHeight > flick.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
    }
  }
}
