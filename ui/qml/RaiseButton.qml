import QtQuick

Item {
    id: btn
    property string label: ""
    property string iconName: ""
    property bool accent: false
    property bool primaryWide: false
    signal clicked()

    implicitWidth: primaryWide ? 160 : Math.max(88, row.implicitWidth + 28)
    implicitHeight: bridge.largeControls ? 48 : 42
    property real sink: tap.pressed ? 1 : 0
    Behavior on sink { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

    // Soft drop shadow stack — raised feel
    Repeater {
        model: 3
        delegate: Rectangle {
            required property int index
            anchors.fill: parent
            anchors.topMargin: 2 + index + btn.sink * 2
            anchors.bottomMargin: -(3 - index) * (1 - btn.sink)
            anchors.leftMargin: 1
            anchors.rightMargin: 1
            radius: 12
            z: -1
            opacity: (1 - btn.sink) * (0.18 - index * 0.04)
            color: bridge.dark ? "#000000" : "#6a4a4a"
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: btn.sink
        radius: 12
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: btn.accent
                      ? (bridge.dark ? "#a83236" : "#8b2428")
                      : (bridge.dark ? "#2a1c1c" : "#ffffff")
            }
            GradientStop {
                position: 1.0
                color: btn.accent
                      ? (bridge.dark ? "#6d191e" : "#5c1418")
                      : (bridge.dark ? "#1a1212" : "#f0e8e8")
            }
        }
        border.width: 1
        border.color: btn.accent
                      ? (bridge.dark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(255, 255, 255, 0.35))
                      : (bridge.dark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(255, 255, 255, 0.85))
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: parent.height * 0.45
            radius: 12
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, bridge.dark ? 0.12 : 0.55) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        anchors.verticalCenterOffset: btn.sink * 0.5
        spacing: 8
        IconLabel {
            visible: btn.iconName.length > 0
            name: btn.iconName
            color: btn.accent ? "#ffffff" : (bridge.dark ? "#f5ecec" : "#1a1212")
            font.pixelSize: 20
            width: visible ? implicitWidth : 0
        }
        Text {
            visible: btn.label.trim().length > 0
            text: btn.label
            color: btn.accent ? "#ffffff" : (bridge.dark ? "#f5ecec" : "#1a1212")
            font.family: bridge.thaiFontFamily
            font.pixelSize: 14
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    TapHandler {
        id: tap
        onTapped: btn.clicked()
    }
}
