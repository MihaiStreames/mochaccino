import QtQuick 2.15
import QtQuick.Controls 2.0
import SddmComponents 2.0

import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    width: 640
    height: 480

    readonly property color textColor: config.stringValue("basicTextColor") || "#ffffff"
    readonly property color accentColor: config.stringValue("accentColor") || "#cccccc"
    readonly property color subtleColor: config.stringValue("subtleColor") || "#888888"
    readonly property color sessionColor: config.stringValue("sessionColor") || "#aaaaaa"

    property int currentUsersIndex: userModel.lastIndex
    property int currentSessionsIndex: sessionModel.lastIndex
    property int usernameRole: Qt.UserRole + 1
    property int realNameRole: Qt.UserRole + 2
    property int sessionNameRole: Qt.UserRole + 4
    property string currentUsername: config.boolValue("showUserRealNameByDefault") ?
        userModel.data(userModel.index(currentUsersIndex, 0), realNameRole)
        : userModel.data(userModel.index(currentUsersIndex, 0), usernameRole)
    property string currentSession: sessionModel.data(sessionModel.index(currentSessionsIndex, 0), sessionNameRole)

    property int passwordFontSize: config.intValue("passwordFontSize") || 26
    property int usersFontSize: config.intValue("usersFontSize") || 28
    property int sessionsFontSize: config.intValue("sessionsFontSize") || 16
    property int helpFontSize: config.intValue("helpFontSize") || 14
    property int clockFontSize: config.intValue("clockFontSize") || 72
    property int dateFontSize: config.intValue("dateFontSize") || 18
    property string defaultFont: config.stringValue("font") || "monospace"
    property string helpFont: config.stringValue("helpFont") || defaultFont


    function usersCycleSelectPrev() {
        if (currentUsersIndex - 1 < 0) {
            currentUsersIndex = userModel.count - 1;
        } else {
            currentUsersIndex--;
        }
    }

    function usersCycleSelectNext() {
        if (currentUsersIndex >= userModel.count - 1) {
            currentUsersIndex = 0;
        } else {
            currentUsersIndex++;
        }
    }

    function bgFillMode() {
        switch(config.stringValue("backgroundFillMode"))
        {
            case "aspect":
                return Image.PreserveAspectCrop;

            case "fill":
                return Image.Stretch;

            case "tile":
                return Image.Tile;

            case "pad":
                return Image.Pad

            default:
                return Image.Pad;
        }
    }

    function sessionsCycleSelectPrev() {
        if (currentSessionsIndex - 1 < 0) {
            currentSessionsIndex = sessionModel.rowCount() - 1;
        } else {
            currentSessionsIndex--;
        }
    }

    function sessionsCycleSelectNext() {
        if (currentSessionsIndex >= sessionModel.rowCount() - 1) {
            currentSessionsIndex = 0;
        } else {
            currentSessionsIndex++;
        }
    }

    Timer {
        id: clockTimer
        interval: 30000
        running: config.boolValue("showClock")
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date();
            clockText.text = Qt.formatDateTime(now, "HH:mm");
            dateText.text = Qt.formatDateTime(now, "dddd, MMMM d");
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            wrongFade.restart();
            shakeAnimation.start();
            passwordInput.clear();
        }
        function onLoginSucceeded() {
            wrongBorder.opacity = 0;
        }
    }

    Item {
        id: mainFrame
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x
        y: geometry.y
        width: geometry.width
        height: geometry.height

        Shortcut {
            sequences: ["Alt+U", "F2"]
            onActivated: {
                if (!username.visible) {
                    username.visible = true;
                    return;
                }
                usersCycleSelectNext();
            }
        }
        Shortcut {
            sequences: ["Alt+Ctrl+S", "Ctrl+F3"]
            onActivated: {
                if (!sessionName.visible) {
                    sessionName.visible = true;
                    return;
                }
                sessionsCycleSelectPrev();
            }
        }

        Shortcut {
            sequences: ["Alt+S", "F3"]
            onActivated: {
                if (!sessionName.visible) {
                    sessionName.visible = true;
                    return;
                }
                sessionsCycleSelectNext();
            }
        }
        Shortcut {
            sequences: ["Alt+Ctrl+U", "Ctrl+F2"]
            onActivated: {
                if (!username.visible) {
                    username.visible = true;
                    return;
                }
                usersCycleSelectPrev();
            }
        }

        Shortcut {
            sequence: "F10"
            onActivated: {
                if (sddm.canSuspend) {
                    sddm.suspend();
                }
            }
        }
        Shortcut {
            sequence: "F11"
            onActivated: {
                if (sddm.canPowerOff) {
                    sddm.powerOff();
                }
            }
        }
        Shortcut {
            sequence: "F12"
            onActivated: {
                if (sddm.canReboot) {
                    sddm.reboot();
                }
            }
        }

        Shortcut {
            sequence: "F1"
            onActivated: {
                helpOverlay.visible = !helpOverlay.visible;
            }
        }


        // === Background ===
        Rectangle {
            id: background
            visible: true
            anchors.fill: parent
            color: config.stringValue("backgroundFill") || "transparent"

            Image {
                id: image
                anchors.fill: parent
                source: config.stringValue("background")
                smooth: true
                fillMode: bgFillMode()
                z: 1
            }

            FastBlur {
                id: fastBlur
                z: 2
                anchors.fill: image
                source: image
                radius: config.intValue("blurRadius")
            }

            // Radial vignette overlay — darker edges, subtly lighter center
            RadialGradient {
                anchors.fill: parent
                z: 3
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#00000000" }
                    GradientStop { position: 0.55; color: "#00000000" }
                    GradientStop { position: 1.0; color: "#80000000" }
                }
            }
        }


        // === Content ===
        Item {
            id: content
            anchors.fill: parent
            opacity: 0

            // Centered group
            Column {
                id: centerGroup
                anchors.centerIn: parent
                spacing: 0

                // Logo
                Image {
                    id: logoImage
                    source: config.stringValue("logo") || ""
                    visible: source != ""
                    width: config.intValue("logoSize") || 256
                    height: width
                    smooth: true
                    mipmap: true
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Item { width: 1; height: 40; visible: logoImage.visible }

            // Clock
            Text {
                id: clockText
                visible: config.boolValue("showClock")
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: clockFontSize
                font.family: defaultFont
                font.bold: true
                font.letterSpacing: 6
                color: config.stringValue("clockColor") || accentColor
            }
            Item { width: 1; height: 6; visible: clockText.visible }

            // Date
            Text {
                id: dateText
                visible: config.boolValue("showClock")
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: dateFontSize
                font.family: defaultFont
                color: config.stringValue("dateColor") || subtleColor
            }
            Item { width: 1; height: username.visible ? 40 : 50; visible: dateText.visible }

            // Username
            UsersChoose {
                id: username
                text: currentUsername
                visible: config.boolValue("showUsersByDefault")
                width: mainFrame.width / 2.5 / 48 * usersFontSize
                height: usersFontSize * 2.5
                anchors.horizontalCenter: parent.horizontalCenter
                onPrevClicked: {
                    usersCycleSelectPrev();
                }
                onNextClicked: {
                    usersCycleSelectNext();
                }
            }
            Item { width: 1; height: 30; visible: username.visible }

            // Password input
            TextInput {
                id: passwordInput
                width: mainFrame.width * (config.realValue("passwordInputWidth") || 0.18)
                height: 200 / 96 * passwordFontSize
                font.pointSize: passwordFontSize
                font.bold: true
                font.letterSpacing: 20 / 96 * passwordFontSize
                font.family: defaultFont

                property int shakeOffset: 0

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: shakeOffset

                echoMode: config.boolValue("passwordMask") === false ? TextInput.Normal : TextInput.Password
                color: config.stringValue("passwordTextColor") || textColor
                selectionColor: textColor
                selectedTextColor: "#000000"
                clip: true
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                passwordCharacter: config.stringValue("passwordCharacter") || "*"
                cursorVisible: config.boolValue("passwordInputCursorVisible")
                onAccepted: {
                    if (text != "" || config.boolValue("passwordAllowEmpty")) {
                        sddm.login(userModel.data(userModel.index(currentUsersIndex, 0), usernameRole)
 || "123test", text, currentSessionsIndex);
                    }
                }
                Rectangle {
                    z: -1
                    anchors.fill: parent
                    color: config.stringValue("passwordInputBackground") || "transparent"
                    radius: config.intValue("passwordInputRadius") || 10
                    border.width: config.intValue("passwordInputBorderWidth") || 0
                    border.color: config.stringValue("passwordInputBorderColor") || "#ffffff"
                }
                cursorDelegate: Rectangle {
                    function getCursorColor() {
                        if (config.stringValue("passwordCursorColor").length == 7 && config.stringValue("passwordCursorColor")[0] == "#") {
                            return config.stringValue("passwordCursorColor");
                        } else if (config.stringValue("passwordCursorColor") == "constantRandom" ||
                                   config.stringValue("passwordCursorColor") == "random") {
                            return generateRandomColor();
                        } else {
                            return textColor
                        }
                    }
                    id: passwordInputCursor
                    width: 18 / 96 * passwordFontSize
                    visible: config.boolValue("passwordInputCursorVisible")
                    onHeightChanged: height = passwordInput.height / 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: getCursorColor()
                    property color currentColor: color

                    SequentialAnimation on color {
                        loops: Animation.Infinite
                        PauseAnimation { duration: 100 }
                        ColorAnimation { from: currentColor; to: "transparent"; duration: 0 }
                        PauseAnimation { duration: 500 }
                        ColorAnimation { from: "transparent"; to: currentColor; duration: 0 }
                        PauseAnimation { duration: 400 }
                        running: config.boolValue("cursorBlinkAnimation")
                    }

                    function generateRandomColor() {
                        var color_ = "#";
                        for (var i = 0; i < 3; i++) {
                            var color_number = parseInt(Math.random() * 255);
                            var hex_color = color_number.toString(16);
                            if (color_number < 16) {
                                hex_color = "0" + hex_color;
                            }
                            color_ += hex_color;
                        }
                        return color_;
                    }
                    Connections {
                        target: passwordInput
                        function onTextEdited() {
                            if (config.stringValue("passwordCursorColor") == "random") {
                                passwordInputCursor.currentColor = generateRandomColor();
                            }
                        }
                    }
                }
            }

            }

            // Session selector
            SessionsChoose {
                id: sessionName
                text: currentSession
                visible: config.boolValue("showSessionsByDefault")
                width: mainFrame.width / 2.5 / 24 * sessionsFontSize
                height: sessionsFontSize * 2.5
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: powerRow.top
                    bottomMargin: 15
                }
                onPrevClicked: {
                    sessionsCycleSelectPrev();
                }
                onNextClicked: {
                    sessionsCycleSelectNext();
                }
            }

            // Power action hints
            Row {
                id: powerRow
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 25
                spacing: 20

                Text {
                    text: "F10 Suspend"
                    font.pointSize: 11
                    font.family: defaultFont
                    color: subtleColor
                    opacity: 0.6
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (sddm.canSuspend) sddm.suspend();
                        }
                    }
                }
                Text {
                    text: "\u00b7"
                    font.pointSize: 11
                    color: subtleColor
                    opacity: 0.3
                }
                Text {
                    text: "F11 Power Off"
                    font.pointSize: 11
                    font.family: defaultFont
                    color: subtleColor
                    opacity: 0.6
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (sddm.canPowerOff) sddm.powerOff();
                        }
                    }
                }
                Text {
                    text: "\u00b7"
                    font.pointSize: 11
                    color: subtleColor
                    opacity: 0.3
                }
                Text {
                    text: "F12 Reboot"
                    font.pointSize: 11
                    font.family: defaultFont
                    color: subtleColor
                    opacity: 0.6
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (sddm.canReboot) sddm.reboot();
                        }
                    }
                }
            }
        }


        // === Help overlay ===
        Rectangle {
            id: helpOverlay
            visible: false
            anchors.fill: parent
            color: "#CC191919"
            z: 10

            MouseArea {
                anchors.fill: parent
                onClicked: helpOverlay.visible = false
            }

            Text {
                id: helpMessage
                text: "Keyboard Shortcuts\n\n" +
                      "F1                  Toggle this help\n" +
                      "F2 / Alt+U          Next user\n" +
                      "Ctrl+F2 / Alt+Ctrl+U    Previous user\n" +
                      "F3 / Alt+S          Next session\n" +
                      "Ctrl+F3 / Alt+Ctrl+S    Previous session\n" +
                      "F10                 Suspend\n" +
                      "F11                 Power off\n" +
                      "F12                 Reboot"
                color: textColor
                font.pointSize: helpFontSize
                font.family: helpFont
                lineHeight: 1.6
                anchors.centerIn: parent
            }
        }


        // === Wrong password border ===
        Rectangle {
            id: wrongBorder
            anchors.fill: parent
            z: 15
            border.color: config.stringValue("wrongPasswordBorderColor") || "#cc2222"
            border.width: 4
            color: "transparent"
            opacity: 0
        }

        NumberAnimation {
            id: wrongFade
            target: wrongBorder
            property: "opacity"
            from: 1
            to: 0
            duration: 2000
            easing.type: Easing.OutCubic
        }

        // === Fade in ===
        NumberAnimation {
            id: fadeIn
            target: content
            property: "opacity"
            from: 0
            to: 1
            duration: 800
            easing.type: Easing.OutCubic
        }

        // === Password shake ===
        SequentialAnimation {
            id: shakeAnimation
            NumberAnimation { target: passwordInput; property: "shakeOffset"; to: -20; duration: 40; easing.type: Easing.InOutQuad }
            NumberAnimation { target: passwordInput; property: "shakeOffset"; to: 20; duration: 80; easing.type: Easing.InOutQuad }
            NumberAnimation { target: passwordInput; property: "shakeOffset"; to: -15; duration: 80; easing.type: Easing.InOutQuad }
            NumberAnimation { target: passwordInput; property: "shakeOffset"; to: 10; duration: 80; easing.type: Easing.InOutQuad }
            NumberAnimation { target: passwordInput; property: "shakeOffset"; to: -5; duration: 60; easing.type: Easing.InOutQuad }
            NumberAnimation { target: passwordInput; property: "shakeOffset"; to: 0; duration: 40; easing.type: Easing.OutQuad }
        }

        Component.onCompleted: {
            passwordInput.forceActiveFocus();
            fadeIn.start();
        }

    }

    Loader {
        active: config.boolValue("hideCursor") || false
        anchors.fill: parent
        sourceComponent: MouseArea {
            enabled: false
            cursorShape: Qt.BlankCursor
        }
    }
}
