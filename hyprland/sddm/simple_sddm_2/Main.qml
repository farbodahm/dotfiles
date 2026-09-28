// Plain greeter: mirrors ~/.config/hypr/hyprlock.conf (dimmed forest photo,
// clock, date, password field). Original astronaut layout: Main.qml.bak-kooldots
// Background is pre-blurred/dimmed: Backgrounds/plain.jpg

import QtQuick 2.15

Rectangle {
    id: root

    width: Screen.width
    height: Screen.height
    color: "#141414"

    // hyprlock sizes are logical px at scale 1.667 on the 1800px panel
    readonly property real s: height / 1080
    readonly property string fontName: "JetBrains Mono"

    property string userName: userModel.lastUser
    property int sessionIndex: sessionModel.lastIndex
    property bool failed: false

    Image {
        anchors.fill: parent
        source: "Backgrounds/plain.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    // Session names, so the corner label can show the selected one
    Repeater {
        id: sessions
        model: sessionModel
        delegate: Item { property string sessionName: model.name }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.failed = true
            password.text = ""
            password.forceActiveFocus()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            clock.text = Qt.formatTime(now, "HH:mm")
            date.text = Qt.locale("en_GB").toString(now, "dddd d MMMM")
        }
    }

    Text {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -160 * s
        color: Qt.rgba(235/255, 235/255, 235/255, 0.95)
        font.family: fontName
        font.weight: Font.Light
        font.pixelSize: 96 * s
    }

    Text {
        id: date
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -70 * s
        color: Qt.rgba(200/255, 200/255, 200/255, 0.8)
        font.family: fontName
        font.pixelSize: 16 * s
    }

    Rectangle {
        id: field
        width: 280 * s
        height: 44 * s
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 60 * s
        radius: 4 * s
        color: Qt.rgba(15/255, 15/255, 15/255, 0.6)
        border.width: Math.max(1, Math.round(s))
        border.color: root.failed ? "#c85a5a"
                    : keyboard.capsLock ? "#d7af5f"
                    : Qt.rgba(1, 1, 1, 0.25)

        TextInput {
            id: password
            anchors.fill: parent
            anchors.leftMargin: 12 * s
            anchors.rightMargin: 12 * s
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            echoMode: TextInput.Password
            passwordCharacter: "●"
            passwordMaskDelay: 0
            color: "#dcdcdc"
            font.family: fontName
            font.pixelSize: 13 * s
            font.letterSpacing: 4 * s
            clip: true
            focus: true
            cursorDelegate: Item {}
            onTextChanged: if (text.length > 0) root.failed = false
            Keys.onReturnPressed: sddm.login(root.userName, text, root.sessionIndex)
            Keys.onEnterPressed: sddm.login(root.userName, text, root.sessionIndex)
        }

        Text {
            anchors.centerIn: parent
            visible: password.text.length === 0
            text: root.failed ? "wrong password"
                : keyboard.capsLock ? "caps lock"
                : "password"
            color: Qt.rgba(1, 1, 1, root.failed ? 0.6 : 0.4)
            font.family: fontName
            font.pixelSize: 14 * s
        }
    }

    // Keyboard layout hint, like $LAYOUT in hyprlock
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 110 * s
        visible: text !== ""
        text: keyboard.layouts.length > 1 && keyboard.layouts[keyboard.currentLayout]
              ? keyboard.layouts[keyboard.currentLayout].longName : ""
        color: Qt.rgba(200/255, 200/255, 200/255, 0.5)
        font.family: fontName
        font.pixelSize: 11 * s
    }

    // Bottom corners: things a greeter needs that hyprlock doesn't.
    // Kept as quiet text so the centre matches the lock screen.
    component CornerText: Text {
        signal clicked()
        color: Qt.rgba(1, 1, 1, area.containsMouse ? 0.8 : 0.4)
        font.family: fontName
        font.pixelSize: 11 * s
        MouseArea {
            id: area
            anchors.fill: parent
            anchors.margins: -6 * s
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    // user · session; click to cycle sessions
    CornerText {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 24 * s
        text: root.userName + "  ·  " + (sessions.itemAt(root.sessionIndex)
              ? sessions.itemAt(root.sessionIndex).sessionName : "")
        onClicked: {
            root.sessionIndex = (root.sessionIndex + 1) % sessions.count
            password.forceActiveFocus()
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24 * s
        spacing: 20 * s

        CornerText { text: "suspend";  visible: sddm.canSuspend;  onClicked: sddm.suspend() }
        CornerText { text: "reboot";   visible: sddm.canReboot;   onClicked: sddm.reboot() }
        CornerText { text: "shutdown"; visible: sddm.canPowerOff; onClicked: sddm.powerOff() }
    }

    Component.onCompleted: password.forceActiveFocus()
}
