import QtQuick

// Co-Co picker sized to fit card width — 6 axles always visible, tank between bogies.
Item {
    id: d
    property color ink: "#f5ecec"
    property color muted: "#b8a0a0"
    property color accent: "#c45c5c"
    property bool dark: true
    property string fontFamily: ""
    property string fleetLabel: ""
    property string locoNumber: ""
    property int wheel: 0
    property bool largeControls: false
    signal wheelPicked(int wi)

    readonly property int pad: 10
    readonly property int innerW: Math.max(200, Math.round(width - pad * 2))
    readonly property int midGap: Math.max(28, Math.round(innerW * 0.11))
    readonly property int axleGap: 6
    // Fit 6 dots + 4 inner gaps + mid tank into innerW
    readonly property int axle: {
        const budget = innerW - midGap - axleGap * 4
        const maxDot = largeControls ? 46 : 42
        return Math.max(32, Math.min(maxDot, Math.floor(budget / 6)))
    }
    readonly property int bogieW: axle * 3 + axleGap * 2
    readonly property int bodyH: largeControls ? 52 : 48
    readonly property int frameH: 5
    readonly property int stemH: 8
    readonly property int tankH: Math.round(axle * 0.78)
    readonly property int underH: stemH + axle
    height: pad * 2 + bodyH + frameH + underH + 2

    readonly property color cardBg: dark ? "#141010" : "#f0e8e8"
    readonly property color plate: dark ? "#2a1c1c" : "#e4d4d4"
    readonly property color plateEdge: dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(80, 30, 30, 0.16)
    readonly property color tankFill: dark ? "#1e1414" : "#b89a9a"
    readonly property color sled: dark ? "#1a1212" : "#c4a8a8"
    readonly property color frameFill: dark ? "#0c0808" : "#8a6a6a"

    component AxleDot: Item {
        id: dot
        property int wi: 0
        property bool on: false
        width: d.axle
        height: d.axle

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: dot.on ? d.accent : (d.dark ? "#1e1414" : "#ffffff")
            border.width: dot.on ? 2 : 1
            border.color: dot.on ? Qt.rgba(1, 1, 1, 0.9)
                                 : (d.dark ? Qt.rgba(196 / 255, 92 / 255, 92 / 255, 0.55) : d.accent)

            Text {
                anchors.centerIn: parent
                text: "" + (dot.wi + 1)
                color: dot.on ? "#ffffff" : d.ink
                font.family: d.fontFamily
                font.pixelSize: Math.max(11, Math.round(d.axle * 0.40))
                font.weight: Font.DemiBold
            }
        }

        TapHandler {
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: d.wheelPicked(dot.wi)
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: d.cardBg
        border.width: 1
        border.color: d.plateEdge
        clip: true

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: d.pad
            spacing: 0

            Rectangle {
                width: parent.width
                height: d.bodyH
                radius: 10
                color: d.plate
                border.width: 1
                border.color: d.plateEdge

                Column {
                    anchors.centerIn: parent
                    spacing: 1
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: d.fleetLabel
                        color: d.muted
                        font.family: d.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: d.locoNumber.length ? d.locoNumber : "—"
                        color: d.accent
                        font.family: d.fontFamily
                        font.pixelSize: 24
                        font.weight: Font.Bold
                    }
                }
            }

            Rectangle {
                width: parent.width - 6
                anchors.horizontalCenter: parent.horizontalCenter
                height: d.frameH
                radius: 2
                color: d.frameFill
            }

            Item {
                width: parent.width
                height: d.underH

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    height: d.underH
                    spacing: 0

                    Item {
                        width: d.bogieW
                        height: parent.height
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            y: d.stemH - 1
                            height: 4
                            radius: 2
                            color: d.sled
                        }
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            spacing: d.axleGap
                            AxleDot { wi: 0; on: d.wheel === 0 }
                            AxleDot { wi: 1; on: d.wheel === 1 }
                            AxleDot { wi: 2; on: d.wheel === 2 }
                        }
                    }

                    Item {
                        width: d.midGap
                        height: parent.height

                        Rectangle {
                            width: 3
                            height: d.stemH + 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            color: d.frameFill
                        }

                        Rectangle {
                            width: Math.max(18, Math.min(parent.width - 6, Math.round(d.axle * 0.85)))
                            height: d.tankH
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: Math.max(0, Math.round((d.axle - d.tankH) / 2))
                            radius: 4
                            color: d.tankFill
                            border.width: 1
                            border.color: d.plateEdge

                            Rectangle {
                                anchors.centerIn: parent
                                width: 1
                                height: parent.height * 0.55
                                color: d.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.10)
                            }
                        }
                    }

                    Item {
                        width: d.bogieW
                        height: parent.height
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            y: d.stemH - 1
                            height: 4
                            radius: 2
                            color: d.sled
                        }
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            spacing: d.axleGap
                            AxleDot { wi: 3; on: d.wheel === 3 }
                            AxleDot { wi: 4; on: d.wheel === 4 }
                            AxleDot { wi: 5; on: d.wheel === 5 }
                        }
                    }
                }
            }
        }
    }
}
