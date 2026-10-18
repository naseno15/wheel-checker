import QtQuick

Item {
    id: field
    property string label: ""
    property string unit: bridge.unitLabel
    property string value: ""
    property string tone: "empty"
    property alias inputText: input.text
    readonly property bool hasFocus: input.activeFocus
    property int editWheel: -1
    property bool syncing: false
    property bool switching: false
    signal edited(string text, int wheel)

    // Compact well — slight bump for desktop readability (still not cell-stretched)
    readonly property int wellH: bridge.largeControls ? 44 : 40
    readonly property int headH: 18
    implicitHeight: headH + 4 + wellH
    implicitWidth: 120
    // Ignore parent-forced giant heights from layout
    height: implicitHeight
    width: parent ? parent.width : 180

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
        // Dark: lifted off panel (not pure black). Light: muted sunk pink-grey.
        return bridge.dark ? "#2c2020" : "#d8c4c4"
    }
    readonly property color inkTone: {
        if (tone === "ok" || tone === "warn" || tone === "bad")
            return bridge.dark ? "#ffffff" : "#141a20"
        return bridge.dark ? "#f5ecec" : "#1a1212"
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 4

        Item {
            width: parent.width
            height: field.headH
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
                width: pillLab.implicitWidth + 12
                height: 17
                radius: 8
                color: field.accent
                Text {
                    id: pillLab
                    anchors.centerIn: parent
                    text: field.statusText
                    color: "#ffffff"
                    font.family: bridge.thaiFontFamily
                    font.pixelSize: 10
                    font.weight: Font.Bold
                }
            }
        }

        Item {
            id: well
            width: parent.width
            height: field.wellH

            Rectangle {
                visible: field.tone !== "empty"
                anchors.fill: parent
                anchors.margins: -2
                radius: 10
                color: "transparent"
                border.width: 2
                border.color: Qt.rgba(field.accent.r, field.accent.g, field.accent.b, 0.5)
                z: 2
            }

            Rectangle {
                id: wellFace
                anchors.fill: parent
                radius: 9
                color: field.wellFill
                border.width: field.tone !== "empty" || input.activeFocus ? 2 : 1
                border.color: field.tone !== "empty" ? field.accent
                              : (input.activeFocus ? field.accent
                                                   : (bridge.dark ? Qt.rgba(1, 1, 1, 0.16) : "#8a5555"))
                clip: true

                // Inset shadow — top/left dark into the well
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 7
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: bridge.dark ? Qt.rgba(0, 0, 0, 0.55) : Qt.rgba(50, 20, 20, 0.4)
                        }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 6
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0.0
                            color: bridge.dark ? Qt.rgba(0, 0, 0, 0.45) : Qt.rgba(50, 20, 20, 0.32)
                        }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 3
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop {
                            position: 1.0
                            color: bridge.dark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(255, 255, 255, 0.55)
                        }
                    }
                }
            }

            Rectangle {
                visible: field.tone !== "empty"
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 3
                width: 5
                radius: 2
                color: field.accent
                z: 3
            }

            Item {
                id: unitBox
                visible: field.unit.length > 0
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: visible ? unitText.implicitWidth + 14 : 0
                z: 4
                Rectangle {
                    width: 1
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 6
                    anchors.bottomMargin: 6
                    color: bridge.dark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(60, 30, 30, 0.28)
                }
                Text {
                    id: unitText
                    anchors.centerIn: parent
                    text: field.unit
                    color: field.tone === "empty" ? (bridge.dark ? "#a89898" : "#5a3838") : field.inkTone
                    font.family: bridge.thaiFontFamily
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }
            }

            TextInput {
                id: input
                z: 4
                anchors.left: parent.left
                anchors.right: unitBox.visible ? unitBox.left : parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: field.tone !== "empty" ? 12 : 10
                anchors.rightMargin: 4
                verticalAlignment: TextInput.AlignVCenter
                color: field.inkTone
                font.family: bridge.thaiFontFamily
                font.pixelSize: bridge.largeControls ? 17 : 15
                font.weight: field.tone !== "empty" ? Font.DemiBold : Font.Normal
                selectByMouse: true
                inputMethodHints: Qt.ImhPreferNumbers
                Component.onCompleted: text = field.value

                onActiveFocusChanged: {
                    if (activeFocus)
                        field.editWheel = bridge.wheel
                }
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
    }

    onValueChanged: {
        if (input.activeFocus || syncing) return
        if (input.text !== field.value)
            showBridgeValue()
    }
}
