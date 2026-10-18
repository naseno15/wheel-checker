import QtQuick

// HMI-style Co-Co side schematic — body + two bogies + mid tank (TCMS/DDU feel).
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

    readonly property int pad: 12
    readonly property int idW: Math.max(128, Math.min(168, Math.round(width * 0.16)))
    readonly property int scheW: Math.max(280, width - idW - pad * 3)
    readonly property int bodyH: largeControls ? 54 : 48
    readonly property int bogieH: largeControls ? 58 : 52
    readonly property int wheelR: largeControls ? 18 : 16
    readonly property int railY: bodyH + 10 + bogieH - 6
    // Fixed readable height — never squash into a skinny card
    height: pad * 2 + bodyH + 10 + bogieH + 22

    readonly property color panelBg: dark ? "#120c0c" : "#f7efef"
    readonly property color bodyFill: dark ? "#2a1a1a" : "#d8c4c4"
    readonly property color bodyTop: dark ? "#3a2424" : "#e8d8d8"
    readonly property color frame: dark ? "#0a0606" : "#6a4a4a"
    readonly property color glass: dark ? "#1a2836" : "#a8c0d0"
    readonly property color tank: dark ? "#1e1414" : "#9a7878"
    readonly property color rail: dark ? "#4a3030" : "#8a6a6a"
    readonly property color edge: dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(80, 30, 30, 0.2)

    component AxleBtn: Item {
        id: ax
        property int wi: 0
        property bool on: false
        width: d.wheelR * 2 + 8
        height: d.bogieH

        // axle box / journal
        Rectangle {
            width: parent.width - 4
            height: 10
            radius: 2
            anchors.horizontalCenter: parent.horizontalCenter
            y: 4
            color: ax.on ? d.accent : (d.dark ? "#3a2828" : "#c4a8a8")
            border.width: 1
            border.color: d.edge
        }
        // wheel disc
        Rectangle {
            width: d.wheelR * 2
            height: d.wheelR * 2
            radius: d.wheelR
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            color: ax.on ? d.accent : (d.dark ? "#1a1010" : "#ffffff")
            border.width: ax.on ? 2.5 : 1.5
            border.color: ax.on ? "#ffffff" : d.accent
            // hub
            Rectangle {
                width: Math.max(8, d.wheelR * 0.55)
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
                font.pixelSize: Math.max(11, Math.round(d.wheelR * 0.85))
                font.weight: Font.Bold
            }
        }
        // selection halo
        Rectangle {
            visible: ax.on
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            width: d.wheelR * 2 + 10
            height: d.wheelR * 2 + 10
            radius: width / 2
            color: "transparent"
            border.width: 2
            border.color: Qt.rgba(d.accent.r, d.accent.g, d.accent.b, 0.55)
            z: -1
        }
        TapHandler {
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: d.wheelPicked(ax.wi)
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: d.panelBg
        border.width: 1
        border.color: d.edge

        // soft top bevel
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 28
            radius: 14
            gradient: Gradient {
                GradientStop { position: 0.0; color: d.dark ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(1, 1, 1, 0.55) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Row {
            anchors.fill: parent
            anchors.margins: d.pad
            spacing: d.pad

            // —— ID / status plate (HMI left rail) ——
            Rectangle {
                width: d.idW
                height: parent.height
                radius: 10
                color: d.dark ? "#1a1010" : "#ffffff"
                border.width: 1
                border.color: d.edge

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 10
                    spacing: 6
                    Text {
                        width: parent.width
                        text: d.fleetLabel.length ? d.fleetLabel : "—"
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        color: d.muted
                        font.family: d.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Medium
                    }
                    Text {
                        width: parent.width
                        text: d.locoNumber.length ? d.locoNumber : "—"
                        color: d.accent
                        font.family: d.fontFamily
                        font.pixelSize: 28
                        font.weight: Font.Bold
                    }
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: d.edge
                    }
                    Text {
                        width: parent.width
                        text: "Co-Co"
                        color: d.muted
                        font.family: d.fontFamily
                        font.pixelSize: 11
                    }
                    Text {
                        width: parent.width
                        text: (d.wheel < 3 ? "B1" : "B2") + "  ·  Ax " + (d.wheel + 1)
                        color: d.ink
                        font.family: d.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }
                }
            }

            // —— Locomotive schematic ——
            Item {
                id: sche
                width: d.scheW
                height: parent.height

                // rail line
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    y: d.railY
                    height: 3
                    radius: 1
                    color: d.rail
                    opacity: 0.85
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    y: d.railY + 5
                    height: 1
                    color: d.rail
                    opacity: 0.35
                }

                // body assembly
                Item {
                    id: body
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: d.bodyH + 10

                    // left cab nose
                    Canvas {
                        id: noseL
                        width: 36
                        height: d.bodyH
                        anchors.left: parent.left
                        anchors.top: parent.top
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.fillStyle = d.bodyFill
                            ctx.beginPath()
                            ctx.moveTo(width, 0)
                            ctx.lineTo(10, 0)
                            ctx.quadraticCurveTo(0, 0, 0, height * 0.35)
                            ctx.lineTo(0, height)
                            ctx.lineTo(width, height)
                            ctx.closePath()
                            ctx.fill()
                            ctx.strokeStyle = d.edge
                            ctx.lineWidth = 1
                            ctx.stroke()
                            // windshield
                            ctx.fillStyle = d.glass
                            ctx.fillRect(8, 8, 14, height * 0.38)
                        }
                        Connections {
                            target: d
                            function onDarkChanged() { noseL.requestPaint() }
                            function onWidthChanged() { noseL.requestPaint() }
                        }
                        Component.onCompleted: requestPaint()
                    }

                    // long hood / carbody
                    Rectangle {
                        id: hood
                        anchors.left: noseL.right
                        anchors.right: noseR.left
                        anchors.top: parent.top
                        height: d.bodyH
                        radius: 3
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: d.bodyTop }
                            GradientStop { position: 0.45; color: d.bodyFill }
                            GradientStop { position: 1.0; color: d.dark ? "#1a1010" : "#c4a8a8" }
                        }
                        border.width: 1
                        border.color: d.edge

                        // roof strip
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 1
                            height: 5
                            color: d.dark ? "#0c0808" : "#8a6a6a"
                            opacity: 0.55
                        }
                        // window / grille band
                        Row {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 6
                            Repeater {
                                model: 7
                                Rectangle {
                                    width: (hood.width - 20 - 36) / 7
                                    height: Math.max(10, d.bodyH * 0.28)
                                    radius: 2
                                    color: index === 3 ? d.tank : d.glass
                                    opacity: index === 3 ? 0.35 : 0.85
                                    border.width: 1
                                    border.color: d.edge
                                }
                            }
                        }
                        // underframe sill
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 4
                            color: d.frame
                        }
                    }

                    // right cab nose (mirrored)
                    Canvas {
                        id: noseR
                        width: 36
                        height: d.bodyH
                        anchors.right: parent.right
                        anchors.top: parent.top
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.fillStyle = d.bodyFill
                            ctx.beginPath()
                            ctx.moveTo(0, 0)
                            ctx.lineTo(width - 10, 0)
                            ctx.quadraticCurveTo(width, 0, width, height * 0.35)
                            ctx.lineTo(width, height)
                            ctx.lineTo(0, height)
                            ctx.closePath()
                            ctx.fill()
                            ctx.strokeStyle = d.edge
                            ctx.lineWidth = 1
                            ctx.stroke()
                            ctx.fillStyle = d.glass
                            ctx.fillRect(width - 22, 8, 14, height * 0.38)
                        }
                        Connections {
                            target: d
                            function onDarkChanged() { noseR.requestPaint() }
                            function onWidthChanged() { noseR.requestPaint() }
                        }
                        Component.onCompleted: requestPaint()
                    }

                    // coupler stubs
                    Rectangle {
                        width: 8; height: 4; radius: 1
                        anchors.verticalCenter: noseL.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: -2
                        color: d.frame
                    }
                    Rectangle {
                        width: 8; height: 4; radius: 1
                        anchors.verticalCenter: noseR.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: -2
                        color: d.frame
                    }
                }

                // bogies + tank
                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: body.bottom
                    anchors.topMargin: -2
                    height: d.bogieH + 4

                    readonly property real bogieW: Math.min(160, (sche.width - 72) / 2)
                    readonly property real gap: Math.max(40, sche.width - bogieW * 2 - 24)

                    // bogie 1
                    Item {
                        id: bog1
                        width: parent.bogieW
                        height: d.bogieH
                        x: 12
                        y: 0

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: 14
                            radius: 3
                            color: d.dark ? "#241818" : "#b89a9a"
                            border.width: 1
                            border.color: d.edge
                            Text {
                                anchors.centerIn: parent
                                text: "B1"
                                color: d.muted
                                font.family: d.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.Bold
                            }
                        }
                        // sideframe
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            y: 16
                            height: 5
                            radius: 2
                            color: d.frame
                        }
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            spacing: Math.max(4, (bog1.width - (d.wheelR * 2 + 8) * 3) / 2)
                            AxleBtn { wi: 0; on: d.wheel === 0 }
                            AxleBtn { wi: 1; on: d.wheel === 1 }
                            AxleBtn { wi: 2; on: d.wheel === 2 }
                        }
                    }

                    // fuel tank
                    Rectangle {
                        width: Math.min(parent.gap - 8, 72)
                        height: Math.max(28, d.bogieH * 0.62)
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        radius: 6
                        color: d.tank
                        border.width: 1
                        border.color: d.edge
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            width: 3
                            height: 8
                            color: d.frame
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "FUEL"
                            color: d.muted
                            font.family: d.fontFamily
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }
                    }

                    // bogie 2
                    Item {
                        id: bog2
                        width: parent.bogieW
                        height: d.bogieH
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        y: 0

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: 14
                            radius: 3
                            color: d.dark ? "#241818" : "#b89a9a"
                            border.width: 1
                            border.color: d.edge
                            Text {
                                anchors.centerIn: parent
                                text: "B2"
                                color: d.muted
                                font.family: d.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.Bold
                            }
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            y: 16
                            height: 5
                            radius: 2
                            color: d.frame
                        }
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            spacing: Math.max(4, (bog2.width - (d.wheelR * 2 + 8) * 3) / 2)
                            AxleBtn { wi: 3; on: d.wheel === 3 }
                            AxleBtn { wi: 4; on: d.wheel === 4 }
                            AxleBtn { wi: 5; on: d.wheel === 5 }
                        }
                    }
                }
            }
        }
    }
}
