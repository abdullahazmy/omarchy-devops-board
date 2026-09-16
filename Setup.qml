import QtQuick
import qs.Commons
import qs.Ui

// Connection form: organization, project and a personal access token. The
// token goes to devops.py over stdin and is kept in the desktop keyring.
Item {
  id: root

  property var app: null

  property bool busy: false
  property string errorText: ""

  readonly property bool demo: !!(app && app.status && app.status.demo)
  readonly property bool reconnecting: !!(app && app.status && app.status.connected) && !demo

  function focusDefault() {
    errorText = ""
    if (app && app.status && !demo) {
      if (orgField.text === "" && app.status.org) orgField.text = app.status.org
      if (projectField.text === "" && app.status.project) projectField.text = app.status.project
    }
    tokenField.text = ""
    if (orgField.text === "") orgField.forceActiveFocus()
    else if (projectField.text === "") projectField.forceActiveFocus()
    else tokenField.forceActiveFocus()
  }

  function connect() {
    if (busy) return
    errorText = ""
    busy = true
    app.run(["connect"], { org: orgField.text, project: projectField.text, token: tokenField.text }, function(data) {
      busy = false
      tokenField.text = ""
      if (data.error) {
        errorText = data.error
        tokenField.forceActiveFocus()
        return
      }
      app.connected(data)
    })
  }

  function useDemo(on) {
    busy = true
    app.run(["demo", on ? "on" : "off"], null, function(data) {
      busy = false
      app.status = null
      app.board = null
      app.expanded = ({})
      app.iterationId = ""
      app.loadStatus()
    })
  }

  function disconnect() {
    busy = true
    app.run(["disconnect"], null, function(data) {
      busy = false
      app.status = null
      app.board = null
      app.rebuild()
      app.loadStatus()
    })
  }

  Keys.onPressed: function(event) {
    if (event.key === Qt.Key_Escape) {
      if (app.status && app.status.connected) {
        app.view = app.board ? "board" : "loading"
        app.focusKeys()
      } else {
        app.dismiss()
      }
      event.accepted = true
    }
  }

  Column {
    anchors.centerIn: parent
    width: Math.min(parent.width, Style.space(520))
    spacing: Style.space(14)

    Row {
      spacing: Style.space(14)

      Text {
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: app ? app.glyphBoard : ""
        color: app ? app.foreground : Color.foreground
        font.family: app ? app.fontFamily : Style.font.family
        font.pixelSize: Style.font.display
      }

      Column {
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(2)

        Text {
          textFormat: Text.PlainText
          text: "Azure DevOps sprint board"
          color: app.foreground
          font.family: app.fontFamily
          font.pixelSize: Style.font.heading
          font.bold: true
        }

        Text {
          textFormat: Text.PlainText
          text: (root.reconnecting ? "Connection" : "Connect your organization").toUpperCase()
          color: app.dim
          font.family: app.fontFamily
          font.pixelSize: Style.font.caption
          font.bold: true
          font.letterSpacing: 1.2
        }
      }
    }

    PanelSeparator { foreground: app.foreground }

    Column {
      width: parent.width
      spacing: Style.spacing.labelGap

      PanelSectionHeader { text: "ORGANIZATION"; foreground: app.foreground; fontFamily: app.fontFamily }

      TextField {
        id: orgField
        width: parent.width
        placeholderText: "https://dev.azure.com/your-org, or paste any board URL"
        foreground: app.foreground
        enabled: !root.busy
        onAccepted: projectField.text === "" ? projectField.forceActiveFocus() : tokenField.forceActiveFocus()
        KeyNavigation.tab: projectField
      }
    }

    Column {
      width: parent.width
      spacing: Style.spacing.labelGap

      PanelSectionHeader { text: "PROJECT"; foreground: app.foreground; fontFamily: app.fontFamily }

      TextField {
        id: projectField
        width: parent.width
        placeholderText: "Project name (filled in from a pasted board URL)"
        foreground: app.foreground
        enabled: !root.busy
        onAccepted: tokenField.forceActiveFocus()
        KeyNavigation.tab: tokenField
      }
    }

    Column {
      width: parent.width
      spacing: Style.spacing.labelGap

      PanelSectionHeader { text: "PERSONAL ACCESS TOKEN"; foreground: app.foreground; fontFamily: app.fontFamily }

      TextField {
        id: tokenField
        width: parent.width
        password: true
        placeholderText: root.reconnecting ? "Leave empty to keep the saved token" : "Paste the token"
        foreground: app.foreground
        enabled: !root.busy
        onAccepted: root.connect()
        KeyNavigation.tab: connectButton
      }

      Text {
        width: parent.width
        textFormat: Text.PlainText
        wrapMode: Text.WordWrap
        text: "Create one under User settings → Personal access tokens with the scopes Work Items (Read & write) and Project and Team (Read). It is stored in your keyring."
        color: app.dim
        font.family: app.fontFamily
        font.pixelSize: Style.font.caption
        topPadding: Style.spacing.xs
      }
    }

    Text {
      visible: root.errorText !== ""
      width: parent.width
      textFormat: Text.PlainText
      wrapMode: Text.WordWrap
      text: root.errorText
      color: app.urgent
      font.family: app.fontFamily
      font.pixelSize: Style.font.bodySmall
    }

    Item {
      width: parent.width
      height: connectButton.implicitHeight

      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.spacing.sm

        Button {
          text: app.status && app.status.demo ? "Leave demo" : "Try with demo data"
          fontSize: Style.font.bodySmall
          foreground: app.foreground
          fontFamily: app.fontFamily
          focusable: true
          enabled: !root.busy
          onClicked: root.useDemo(!(app.status && app.status.demo))
        }

        Button {
          visible: root.reconnecting && !(app.status && app.status.demo)
          text: "Forget token"
          fontSize: Style.font.bodySmall
          foreground: app.foreground
          fontFamily: app.fontFamily
          focusable: true
          enabled: !root.busy
          onClicked: root.disconnect()
        }
      }

      Button {
        id: connectButton
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: root.busy ? "Connecting…" : (root.reconnecting ? "Save" : "Connect")
        fontSize: Style.font.bodySmall
        foreground: app.foreground
        fontFamily: app.fontFamily
        bordered: true
        focusable: true
        enabled: !root.busy
        onClicked: root.connect()
      }
    }

    Text {
      width: parent.width
      textFormat: Text.PlainText
      text: "Enter next field  ·  Tab move  ·  Esc " + (root.reconnecting ? "back" : "close")
      color: app.foreground
      opacity: 0.5
      font.family: app.fontFamily
      font.pixelSize: Style.font.caption
      horizontalAlignment: Text.AlignRight
    }
  }
}
