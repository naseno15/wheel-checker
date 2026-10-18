import QtQuick

Item {
    id: dd
    property string label: ""
    property string placeholder: ""
    property var model: []
    property string currentText: ""
    property bool open: false
    signal picked(string value)

    width: parent ? parent.width : 200
    height: bridge.largeControls ? 48 : 42
    z: open ? 20 : 0

    RaiseButton {
        id: head
        anchors.fill: parent
        label: dd.currentText.length > 0 ? dd.currentText : (dd.placeholder.length > 0 ? dd.placeholder : dd.label)
        iconName: "expand_more"
        onClicked: dd.open = !dd.open
    }

    Rectangle {
        id: panel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.bottom
        anchors.topMargin: 6
        height: dd.open ? Math.min(220, col.implicitHeight + 12) : 0
        radius: 12
        clip: true
        visible: height > 0.5
        color: bridge.dark ? "#2a1c1c" : "#f5ecec"
        border.color: bridge.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(80, 30, 30, 0.12)
        opacity: dd.open ? 1 : 0
        Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 140 } }

        Flickable {
            anchors.fill: parent
            anchors.margins: 6
            contentHeight: col.height
            clip: true
            Column {
                id: col
                width: parent.width
                spacing: 4
                Repeater {
                    model: dd.model
                    delegate: Rectangle {
                        required property string modelData
                        width: col.width
                        height: bridge.largeControls ? 42 : 36
                        radius: 10
                        color: tap.pressed ? (bridge.dark ? "#a83236" : "#7a1a1e") : "transparent"
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            text: modelData
                            color: tap.pressed ? "#ffffff"
                                 : (bridge.dark ? "#f5ecec" : "#1a1212")
                            font.family: bridge.thaiFontFamily
                            font.pixelSize: 14
                        }
                        TapHandler {
                            id: tap
                            onTapped: {
                                dd.currentText = modelData
                                dd.open = false
                                dd.picked(modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    TapHandler {
        enabled: dd.open
        // catch outside via parent overlay in Main when needed — keep simple
    }
}
