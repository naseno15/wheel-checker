import QtQuick

Item {
    id: field
    property string label: ""
    property string unit: bridge.unitLabel
    property string value: ""
    property string tone: "empty"
    property alias inputText: input.text
    readonly property bool hasFocus: input.activeFocus
    // Axle being edited — frozen while focused so blur/switch cannot retarget writes.
    property int editWheel: -1
    property bool syncing: false
    property bool switching: false  // block blur-commit while changing axle
    signal edited(string text, int wheel)

    function commit() {
        const w = editWheel >= 0 ? editWheel : bridge.wheel
        field.edited(input.text, w)
    }
    function focusInput() { input.forceActiveFocus() }

    function showBridgeValue() {
        syncing = true
        input.text = field.value
        syncing = false
    }

    Connections {
        target: bridge
        function onWheelChanged() {
            // Keystrokes already saved to editWheel — do not write again on blur.
            switching = true
            editWheel = -1
            input.focus = false
            Qt.callLater(function() {
                field.showBridgeValue()
                field.switching = false
            })
        }
        function onPageChanged() {
            if (editWheel >= 0)
                field.edited(input.text, editWheel)
            switching = true
            editWheel = -1
            input.focus = false
            Qt.callLater(function() {
                field.showBridgeValue()
                field.switching = false
            })
        }
    }

    readonly property string statusText: {
        if (tone === "ok") return bridge.t("status_ok")
        if (tone === "warn") return bridge.t("status_shop")
        if (tone === "bad") return bridge.t("status_scrap")
        return ""
    }
    readonly property color accent: {
        if (tone === "ok") return bridge.dark ? "#2ee59a" : "#0b8f52"
        if (tone === "warn") return bridge.dark ? "#ffc107" : "#d48806"
        if (tone === "bad") return bridge.dark ? "#ff5a45" : "#d92b1a"
        return bridge.dark ? "#c45c5c" : "#7a1a1e"
    }
    readonly property color wellFill: {
        if (tone === "ok") return bridge.dark ? "#0f3d2a" : "#7ad9a8"
        if (tone === "warn") return bridge.dark ? "#4a3810" : "#ffc94d"
        if (tone === "bad") return bridge.dark ? "#5a1814" : "#ff7a66"
        return bridge.dark ? Qt.rgba(0, 0, 0, 0.42) : Qt.rgba(90, 50, 50, 0.12)
    }
    readonly property color inkTone: {
        if (tone === "ok" || tone === "warn" || tone === "bad")
            return bridge.dark ? "#ffffff" : "#141a20"
        return bridge.dark ? "#f5ecec" : "#1a1212"
    }

    implicitHeight: 22 + (bridge.largeControls ? 54 : 48) + 6
    width: parent ? parent.width : 180

    Item {
        id: head
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 20
        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: field.label
            color: bridge.dark ? "#c8b0b0" : "#4a3030"
            font.family: bridge.thaiFontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }
        Rectangle {
            visible: field.statusText.length > 0
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: pillLab.implicitWidth + 14
            height: 20
            radius: 10
            color: field.accent
            Text {
                id: pillLab
                anchors.centerIn: parent
                text: field.statusText
                color: "#ffffff"
                font.family: bridge.thaiFontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
            }
        }
    }

    Item {
        id: well
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: head.bottom
        anchors.topMargin: 6
        anchors.bottom: parent.bottom

        Rectangle {
            visible: field.tone !== "empty"
            anchors.fill: parent
            anchors.margins: -3
            radius: 14
            color: "transparent"
            border.width: 2
            border.color: Qt.rgba(field.accent.r, field.accent.g, field.accent.b, bridge.dark ? 0.55 : 0.4)
        }
        Rectangle {
            anchors.fill: parent
            radius: 11
            color: field.wellFill
            border.width: field.tone !== "empty" || input.activeFocus ? 2.5 : 1
            border.color: field.tone !== "empty" ? field.accent
                          : (input.activeFocus ? (bridge.dark ? "#c45c5c" : "#7a1a1e")
                                               : (bridge.dark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(80, 40, 40, 0.16)))
        }
        Rectangle {
            visible: field.tone !== "empty"
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 3
            width: 6
            radius: 3
            color: field.accent
        }

        Item {
            id: unitBox
            visible: field.unit.length > 0
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: visible ? unitText.implicitWidth + 18 : 0
            Rectangle {
                width: 1
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                color: bridge.dark ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(20, 32, 48, 0.22)
            }
            Text {
                id: unitText
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 2
                text: field.unit
                color: field.tone === "empty" ? (bridge.dark ? "#9aa8b8" : "#5a6775") : field.inkTone
                font.family: bridge.thaiFontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
        }

        TextInput {
            id: input
            anchors.left: parent.left
            anchors.right: unitBox.visible ? unitBox.left : parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: field.tone !== "empty" ? 16 : 10
            anchors.rightMargin: 6
            verticalAlignment: TextInput.AlignVCenter
            color: field.inkTone
            font.family: bridge.thaiFontFamily
            font.pixelSize: bridge.largeControls ? 20 : 17
            font.weight: field.tone !== "empty" ? Font.DemiBold : Font.Normal
            selectByMouse: true
            // Allow digits + decimal without fighting the IME.
            inputMethodHints: Qt.ImhPreferNumbers
            Component.onCompleted: text = field.value

            onActiveFocusChanged: {
                if (activeFocus)
                    field.editWheel = bridge.wheel
            }
            // Save on every keystroke — no blur required.
            onTextChanged: {
                if (syncing || !activeFocus) return
                const w = field.editWheel >= 0 ? field.editWheel : bridge.wheel
                field.edited(text, w)
            }
            onEditingFinished: {
                if (syncing || switching) return
                const w = field.editWheel >= 0 ? field.editWheel : bridge.wheel
                field.edited(text, w)
                field.editWheel = -1
                Qt.callLater(function() {
                    if (!input.activeFocus && !field.switching)
                        field.showBridgeValue()
                })
            }
            onAccepted: {
                if (syncing || switching) return
                const w = field.editWheel >= 0 ? field.editWheel : bridge.wheel
                field.edited(text, w)
            }
        }
    }

    onValueChanged: {
        // Never overwrite while the user is typing in this box.
        if (input.activeFocus || syncing) return
        if (input.text !== field.value)
            showBridgeValue()
    }
}
