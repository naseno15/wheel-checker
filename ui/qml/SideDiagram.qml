import QtQuick

// Co-Co picker: scales to fill available width — tall body, mid fuel, Cab 1 / Cab 2.
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

    readonly property int pad: 14
    readonly property int idW: Math.max(120, Math.min(168, Math.round(width * 0.13)))
    readonly property int cabH: 18
    // Fill the diagram bay — derive wheel size from leftover width
    readonly property int availW: Math.max(280, width - idW - pad * 2 - 12)
    readonly property int targetPick: Math.round(availW * 0.94)
    readonly property int midGap: Math.max(48, Math.round(targetPick * 0.13))
    readonly property int axGap: Math.max(8, Math.round(targetPick * 0.018))
    // pickW = 6*axW + 4*axGap + midGap
    readonly property int axW: Math.max(40, Math.floor((targetPick - midGap - 4 * axGap) / 6))
    readonly property int wheelR: Math.max(18, Math.floor((axW - 4) / 2))
    readonly property int pickW: axW * 6 + axGap * 4 + midGap
    readonly property int bodyH: Math.max(78, Math.round(wheelR * 2.9))
    readonly property int underH: wheelR * 2 + 16
    height: pad * 2 + cabH + bodyH + underH + 18

    readonly property color panelBg: dark ? "#161010" : "#f4ecec"
    readonly property color bodyFill: dark ? "#3a2828" : "#d2bcbc"
    readonly property color bodyTop: dark ? "#4a3434" : "#e4d0d0"
    readonly property color tankFill: dark ? "#241818" : "#a88888"
    readonly property color rail: dark ? "#5a4040" : "#8a6a6a"
    readonly property color edge: dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(80, 30, 30, 0.22)

    component AxleBtn: Item {
        id: ax
        property int wi: 0
        property bool on: false
        width: d.axW
        height: d.underH

        Rectangle {
            width: d.wheelR * 2
            height: d.wheelR * 2
            radius: d.wheelR
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            color: ax.on ? d.accent : (d.dark ? "#1e1414" : "#ffffff")
            border.width: ax.on ? 2.5 : 2
            border.color: ax.on ? "#ffffff" : d.accent
            Rectangle {
                width: Math.max(8, d.wheelR * 0.48)
                height: width
                radius: width / 2
                anchors.centerIn: parent
                color: ax.on ? Qt.rgba(1, 1, 1, 0.35) : (d.dark ? "#3a2828" : "#d0bcbc")
            }
            Text {
                anchors.centerIn: parent
                text: "" + (ax.wi + 1)
                color: ax.on ? "#ffffff" : d.ink
                font.family: d.fontFamily
                font.pixelSize: Math.max(12, Math.round(d.wheelR * 0.85))
                font.weight: Font.Bold
            }
        }
        TapHandler {
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: d.wheelPicked(ax.wi)
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: d.panelBg
        border.width: 1
        border.color: d.edge

        Row {
            anchors.fill: parent
            anchors.margins: d.pad
            spacing: 12

            Rectangle {
                width: d.idW
                height: parent.height
                radius: 8
                color: d.dark ? "#1e1414" : "#ffffff"
                border.width: 1
                border.color: d.edge
                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 8
                    spacing: 3
                    Text {
                        width: parent.width
                        text: d.fleetLabel.length ? d.fleetLabel : "—"
                        elide: Text.ElideRight
                        color: d.muted
                        font.family: d.fontFamily
                        font.pixelSize: 11
                    }
                    Text {
                        width: parent.width
                        text: d.locoNumber.length ? d.locoNumber : "—"
                        color: d.accent
                        font.family: d.fontFamily
                        font.pixelSize: 24
                        font.weight: Font.Bold
                    }
                    Text {
                        width: parent.width
                        text: "เพลา " + (d.wheel + 1)
                        color: d.ink
                        font.family: d.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                    Text {
                        width: parent.width
                        text: d.wheel < 3 ? "Cab 1" : "Cab 2"
                        color: d.muted
                        font.family: d.fontFamily
                        font.pixelSize: 12
                    }
                }
            }

            Item {
                width: parent.width - d.idW - 12
                height: parent.height

                Item {
                    width: d.pickW
                    height: parent.height
                    anchors.centerIn: parent

                    Text {
                        text: "Cab 1"
                        anchors.left: parent.left
                        anchors.top: parent.top
                        color: d.muted
                        font.family: d.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: "Cab 2"
                        anchors.right: parent.right
                        anchors.top: parent.top
                        color: d.muted
                        font.family: d.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }

                    Rectangle {
                        id: body
                        width: d.pickW
                        height: d.bodyH
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: d.cabH
                        radius: 8
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: d.bodyTop }
                            GradientStop { position: 1.0; color: d.bodyFill }
                        }
                        border.width: 1
                        border.color: d.edge
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 1
                            height: Math.max(8, Math.round(d.bodyH * 0.12))
                            radius: 5
                            color: d.dark ? Qt.rgba(0, 0, 0, 0.35) : Qt.rgba(0, 0, 0, 0.12)
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 6
                            color: d.dark ? "#120c0c" : "#6a4a4a"
                        }
                        Rectangle {
                            width: Math.max(22, Math.round(d.wheelR * 1.1))
                            height: Math.max(18, Math.round(d.bodyH * 0.28))
                            radius: 3
                            x: 12
                            y: Math.round(d.bodyH * 0.22)
                            color: d.dark ? "#1a2836" : "#a8c0d0"
                        }
                        Rectangle {
                            width: Math.max(22, Math.round(d.wheelR * 1.1))
                            height: Math.max(18, Math.round(d.bodyH * 0.28))
                            radius: 3
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            y: Math.round(d.bodyH * 0.22)
                            color: d.dark ? "#1a2836" : "#a8c0d0"
                        }
                    }

                    Item {
                        width: d.pickW
                        height: d.underH
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: body.bottom
                        anchors.topMargin: 2

                        Row {
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            height: parent.height
                            spacing: d.midGap

                            Row {
                                spacing: d.axGap
                                height: parent.height
                                AxleBtn { wi: 0; on: d.wheel === 0 }
                                AxleBtn { wi: 1; on: d.wheel === 1 }
                                AxleBtn { wi: 2; on: d.wheel === 2 }
                            }
                            Row {
                                spacing: d.axGap
                                height: parent.height
                                AxleBtn { wi: 3; on: d.wheel === 3 }
                                AxleBtn { wi: 4; on: d.wheel === 4 }
                                AxleBtn { wi: 5; on: d.wheel === 5 }
                            }
                        }

                        Rectangle {
                            width: Math.max(32, d.midGap - 14)
                            height: Math.max(40, d.underH - 10)
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 6
                            color: d.tankFill
                            border.width: 1
                            border.color: d.edge
                            Rectangle {
                                width: 4
                                height: 8
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: -5
                                color: d.dark ? "#120c0c" : "#6a4a4a"
                            }
                            Text {
                                anchors.centerIn: parent
                                text: "FUEL"
                                rotation: -90
                                color: d.muted
                                font.family: d.fontFamily
                                font.pixelSize: Math.max(10, Math.round(d.wheelR * 0.4))
                                font.weight: Font.Bold
                            }
                        }
                    }

                    Rectangle {
                        width: d.pickW * 0.94
                        height: 3
                        radius: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        color: d.rail
                        opacity: 0.75
                    }
                }
            }
        }
    }
}
