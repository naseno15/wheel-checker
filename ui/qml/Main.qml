import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    // Desktop landscape window � free resize within the work area.
    width: Math.min(1180, Screen.desktopAvailableWidth - 48)
    height: Math.min(740, Screen.desktopAvailableHeight - 48)
    minimumWidth: 960
    minimumHeight: 600
    maximumWidth: Screen.desktopAvailableWidth
    maximumHeight: Screen.desktopAvailableHeight
    // C++ main() centers on the cursor's screen work area, then show()s.
    visible: false
    title: root.tr("app_title")
    color: bg0.color
    flags: Qt.Window

    // Fonts are loaded in C++ (Bridge) and set via QGuiApplication::setFont.
    // Do not FontLoader the Thai face again � it can register a second name and miss.
    FontLoader { id: mi; source: bridge.iconFontUrl }

    readonly property string uiFont: bridge.thaiFontFamily
    // maroon railway palette (matches State Railway emblem)
    readonly property color ink: bridge.dark ? "#f5ecec" : "#1a1212"
    readonly property color muted: bridge.dark ? "#b8a0a0" : "#6a4a4a"
    readonly property color accent: bridge.dark ? "#c45c5c" : "#7a1a1e"
    property int i18nTick: 0
    function tr(k) { return (root.i18nTick, bridge.t(k)) }
    Connections {
        target: bridge
        function onLangChanged() { root.i18nTick++ }
        function onUnitChanged() { root.i18nTick++ }
    }

    function cardTone(tone) {
        if (tone === "ok") return bridge.dark ? "#1a3d2e" : "#cfe8da"
        if (tone === "warn") return bridge.dark ? "#3d3218" : "#f3e2b8"
        if (tone === "bad") return bridge.dark ? "#3d201c" : "#f0d0cb"
        return bridge.dark ? "#2a1c1c" : "#f0e4e4"
    }
    function toneInk(tone) {
        if (tone === "ok") return bridge.dark ? "#3ecf8e" : "#1f7a4d"
        if (tone === "warn") return bridge.dark ? "#f0b429" : "#b86a00"
        if (tone === "bad") return bridge.dark ? "#ff6b5a" : "#b42318"
        return root.muted
    }

    Item {
        id: stage
        anchors.fill: parent

    Rectangle {
        id: bg0
        anchors.fill: parent
        property color c0: bridge.dark ? "#0a0808" : "#e8dcdc"
        property color c1: bridge.dark ? "#1a1010" : "#d4c0c0"
        property color c2: bridge.dark ? "#120c0c" : "#f0e6e6"
        color: c0
        Behavior on c0 { ColorAnimation { duration: 280; easing.type: Easing.OutCubic } }
        Behavior on c1 { ColorAnimation { duration: 280; easing.type: Easing.OutCubic } }
        Behavior on c2 { ColorAnimation { duration: 280; easing.type: Easing.OutCubic } }
        gradient: Gradient {
            orientation: Gradient.ForwardDiagonal
            GradientStop { position: 0.0; color: bg0.c0 }
            GradientStop { position: 0.55; color: bg0.c1 }
            GradientStop { position: 1.0; color: bg0.c2 }
        }
    }
    Rectangle {
        width: parent.width * 0.85
        height: parent.height * 0.5
        x: -width * 0.25
        y: -height * 0.3
        radius: width
        color: bridge.dark ? Qt.rgba(0.55, 0.15, 0.16, 0.18) : Qt.rgba(1, 1, 1, 0.35)
        Behavior on color { ColorAnimation { duration: 280 } }
    }
    Rectangle {
        width: parent.width * 0.7
        height: parent.height * 0.4
        anchors.right: parent.right
        anchors.rightMargin: -width * 0.35
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -height * 0.2
        radius: width
        color: bridge.dark ? Qt.rgba(0.4, 0.1, 0.12, 0.12) : Qt.rgba(0.5, 0.15, 0.18, 0.1)
        Behavior on color { ColorAnimation { duration: 280 } }
    }

    Item {
        id: shell
        anchors.fill: parent
        anchors.margins: 14

        Row {
            id: headerRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 8
            height: 44
            Column {
                width: parent.width - themeSeg.width - 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text {
                    text: bridge.locoNumber.length ? bridge.sessionTitle : root.tr("app_title")
                    color: root.ink
                    font.family: bridge.thaiFontFamily
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: bridge.locoNumber.length ? bridge.fleetHeadline : root.tr("app_sub")
                    color: root.muted
                    font.family: bridge.thaiFontFamily
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    width: parent.width
                }
            }
            Rectangle {
                id: themeSeg
                width: 84
                height: 38
                anchors.verticalCenter: parent.verticalCenter
                radius: 19
                color: bridge.dark ? Qt.rgba(20 / 255, 12 / 255, 12 / 255, 0.7) : Qt.rgba(255, 255, 255, 0.55)
                border.width: 1
                border.color: bridge.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(255, 255, 255, 0.7)
                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    Item {
                        width: 34
                        height: 30
                        Rectangle {
                            anchors.fill: parent
                            radius: 15
                            visible: !bridge.dark
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#a83236" }
                                GradientStop { position: 1.0; color: "#6d191e" }
                            }
                        }
                        IconLabel {
                            anchors.centerIn: parent
                            name: "light_mode"
                            font.pixelSize: 18
                            color: !bridge.dark ? "#ffffff" : root.muted
                        }
                        TapHandler { onTapped: bridge.dark = false }
                    }
                    Item {
                        width: 34
                        height: 30
                        Rectangle {
                            anchors.fill: parent
                            radius: 15
                            visible: bridge.dark
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#a83236" }
                                GradientStop { position: 1.0; color: "#6d191e" }
                            }
                        }
                        IconLabel {
                            anchors.centerIn: parent
                            name: "dark_mode"
                            font.pixelSize: 18
                            color: bridge.dark ? "#ffffff" : root.muted
                        }
                        TapHandler { onTapped: bridge.dark = true }
                    }
                }
            }
        }

        // Left sidebar � desktop nav (replaces phone bottom tab bar)
        Rectangle {
            id: sideNav
            anchors.left: parent.left
            anchors.top: headerRow.bottom
            anchors.topMargin: 10
            anchors.bottom: parent.bottom
            width: 172
            radius: 16
            color: bridge.dark ? Qt.rgba(12 / 255, 8 / 255, 8 / 255, 0.55) : Qt.rgba(255, 255, 255, 0.45)
            border.color: bridge.dark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(255, 255, 255, 0.65)
            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6
                Repeater {
                    model: [
                        { page: "home", icon: "home", key: "home" },
                        { page: "entry", icon: "edit", key: "entry" },
                        { page: "history", icon: "history", key: "history" },
                        { page: "result", icon: "fact_check", key: "result" },
                        { page: "settings", icon: "settings", key: "settings" }
                    ]
                    delegate: Item {
                        required property var modelData
                        width: parent.width
                        height: 48
                        Rectangle {
                            anchors.fill: parent
                            radius: 12
                            opacity: bridge.page === modelData.page
                                     || (modelData.page === "entry" && (bridge.page === "fleet" || bridge.page === "loco" || bridge.page === "guide" || bridge.page === "save"))
                                     ? 1 : 0
                            color: bridge.dark ? "#3a2020" : "#f5ecec"
                            Behavior on opacity { NumberAnimation { duration: 140 } }
                        }
                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            spacing: 10
                            IconLabel {
                                name: modelData.icon
                                font.pixelSize: 22
                                color: bridge.page === modelData.page ? root.accent : root.muted
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.tr(modelData.key)
                                color: bridge.page === modelData.page ? root.ink : root.muted
                                font.family: bridge.thaiFontFamily
                                font.pixelSize: 14
                                font.weight: Font.Medium
                            }
                        }
                        TapHandler {
                            onTapped: {
                                if (modelData.page === "entry")
                                    bridge.goEntryNav()
                                else
                                    bridge.page = modelData.page
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: glass
            anchors.left: sideNav.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.top: headerRow.bottom
            anchors.topMargin: 10
            anchors.bottom: parent.bottom
            radius: 18
            color: bridge.dark ? Qt.rgba(28 / 255, 18 / 255, 18 / 255, 0.55) : Qt.rgba(255, 255, 255, 0.42)
            border.color: bridge.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(255, 255, 255, 0.65)
            clip: true
            Behavior on color { ColorAnimation { duration: 280 } }

            property real pageOpacity: 1
            property real pageY: 0

            Connections {
                target: bridge
                function onPageChanged() {
                    glass.pageOpacity = 0
                    glass.pageY = 10
                    pageIn.start()
                }
            }
            SequentialAnimation {
                id: pageIn
                PauseAnimation { duration: 20 }
                ParallelAnimation {
                    NumberAnimation { target: glass; property: "pageOpacity"; to: 1; duration: 180; easing.type: Easing.OutCubic }
                    NumberAnimation { target: glass; property: "pageY"; to: 0; duration: 200; easing.type: Easing.OutCubic }
                }
            }

            StackLayout {
                id: stack
                anchors.fill: parent
                anchors.margins: 14
                opacity: glass.pageOpacity
                y: glass.pageY
                currentIndex: bridge.page === "fleet" ? 1
                            : bridge.page === "loco" ? 2
                            : bridge.page === "entry" ? 3
                            : bridge.page === "result" ? 4
                            : bridge.page === "guide" ? 5
                            : bridge.page === "save" ? 6
                            : bridge.page === "settings" ? 7
                            : bridge.page === "history" ? 8
                            : 0

                // HOME � 2-column menu grid
                Item {
                    Column {
                        id: homeCol
                        anchors.fill: parent
                        spacing: 12

                        Rectangle {
                            width: parent.width
                            height: 88
                            radius: 18
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: bridge.dark ? "#6d191e" : "#8b2428" }
                                GradientStop { position: 1.0; color: bridge.dark ? "#3a0e10" : "#5c1418" }
                            }
                            border.width: 1
                            border.color: bridge.dark ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(255, 255, 255, 0.28)
                            Row {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 14
                                Rectangle {
                                    width: 52
                                    height: 52
                                    radius: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: Qt.rgba(1, 1, 1, 0.14)
                                    IconLabel {
                                        anchors.centerIn: parent
                                        name: "directions_railway"
                                        font.pixelSize: 28
                                        color: "#ffffff"
                                    }
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4
                                    width: parent.width - 66
                                    Text {
                                        text: root.tr("choose_task")
                                        color: "#ffffff"
                                        font.family: bridge.thaiFontFamily
                                        font.pixelSize: 20
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        width: parent.width
                                        wrapMode: Text.WordWrap
                                        text: root.tr("home_hint")
                                        color: Qt.rgba(1, 1, 1, 0.85)
                                        font.family: bridge.thaiFontFamily
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }

                        Grid {
                            id: homeGrid
                            width: parent.width
                            height: parent.height - 100
                            columns: 2
                            columnSpacing: 12
                            rowSpacing: 12
                            Repeater {
                                model: [
                                    { action: "wizard", icon: "edit", titleKey: "enter_wheels", subKey: "enter_sub", accent: true },
                                    { action: "history", icon: "history", titleKey: "history", subKey: "history_sub", accent: false },
                                    { action: "result", icon: "fact_check", titleKey: "result", subKey: "result_sub", accent: false },
                                    { action: "guide", icon: "menu_book", titleKey: "guide", subKey: "guide_sub", accent: false }
                                ]
                                delegate: Item {
                                    required property var modelData
                                    width: (homeGrid.width - homeGrid.columnSpacing) / 2
                                    height: (homeGrid.height - homeGrid.rowSpacing) / 2
                                    RaiseButton {
                                        anchors.fill: parent
                                        accent: modelData.accent
                                        label: ""
                                        onClicked: {
                                            if (modelData.action === "wizard")
                                                bridge.startWizard()
                                            else
                                                bridge.page = modelData.action
                                        }
                                    }
                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 12
                                        enabled: false
                                        Rectangle {
                                            width: 48
                                            height: 48
                                            radius: 14
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: modelData.accent
                                                   ? Qt.rgba(255, 255, 255, 0.18)
                                                   : (bridge.dark ? "#3a2020" : "#f0d8d8")
                                            IconLabel {
                                                anchors.centerIn: parent
                                                name: modelData.icon
                                                font.pixelSize: 24
                                                color: modelData.accent ? "#ffffff" : root.accent
                                            }
                                        }
                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 4
                                            width: parent.width - 60
                                            Text {
                                                width: parent.width
                                                text: root.tr(modelData.titleKey)
                                                color: modelData.accent ? "#ffffff" : root.ink
                                                font.family: bridge.thaiFontFamily
                                                font.pixelSize: 16
                                                font.weight: Font.DemiBold
                                                elide: Text.ElideRight
                                            }
                                            Text {
                                                width: parent.width
                                                wrapMode: Text.WordWrap
                                                maximumLineCount: 2
                                                elide: Text.ElideRight
                                                text: root.tr(modelData.subKey)
                                                color: modelData.accent ? Qt.rgba(1, 1, 1, 0.88) : root.muted
                                                font.family: bridge.thaiFontFamily
                                                font.pixelSize: 12
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }


                // FLEET pick � one tap selects + opens loco number page
                Item {
                    Column {
                        anchors.fill: parent
                        spacing: 8
                        Text { text: root.tr("pick_fleet"); color: root.ink; font.family: bridge.thaiFontFamily; font.pixelSize: 16; font.weight: Font.DemiBold }
                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: root.tr("pick_fleet_hint")
                            color: root.muted
                            font.family: bridge.thaiFontFamily
                            font.pixelSize: 12
                        }
                        Item {
                            width: parent.width
                            height: parent.height - 48
                            Grid {
                                id: fleetGrid
                                anchors.fill: parent
                                columns: 3
                                columnSpacing: 10
                                rowSpacing: 10
                                Repeater {
                                    model: bridge.fleetOptions
                                    delegate: Item {
                                        required property var modelData
                                        width: (fleetGrid.width - fleetGrid.columnSpacing * 2) / 3
                                        height: (fleetGrid.height - fleetGrid.rowSpacing) / 2
                                        RaiseButton {
                                            anchors.fill: parent
                                            accent: true
                                            label: ""
                                            onClicked: {
                                                bridge.fleetCode = modelData.code
                                                bridge.confirmFleet()
                                            }
                                        }
                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 10
                                            enabled: false
                                            Image {
                                                width: Math.min(64, parent.height - 8)
                                                height: width
                                                anchors.verticalCenter: parent.verticalCenter
                                                source: modelData.icon
                                                fillMode: Image.PreserveAspectFit
                                                smooth: true
                                                mipmap: true
                                            }
                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 3
                                                width: parent.width - 74
                                                Text {
                                                    width: parent.width
                                                    text: modelData.title
                                                    elide: Text.ElideRight
                                                    color: "#ffffff"
                                                    font.family: bridge.thaiFontFamily
                                                    font.pixelSize: 18
                                                    font.weight: Font.DemiBold
                                                }
                                                Text {
                                                    width: parent.width
                                                    text: modelData.code
                                                    color: Qt.rgba(1, 1, 1, 0.85)
                                                    font.family: bridge.thaiFontFamily
                                                    font.pixelSize: 12
                                                    font.weight: Font.Medium
                                                }
                                                Text {
                                                    width: parent.width
                                                    text: modelData.sub
                                                    elide: Text.ElideRight
                                                    color: Qt.rgba(1, 1, 1, 0.75)
                                                    font.family: bridge.thaiFontFamily
                                                    font.pixelSize: 11
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // LOCO number � sticky Next commits field first
                Item {
                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: locoBar.top
                        anchors.bottomMargin: 12
                        spacing: 12
                        Text { text: root.tr("pick_loco"); color: root.ink; font.family: bridge.thaiFontFamily; font.pixelSize: 16; font.weight: Font.DemiBold }
                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: bridge.fleetHeadline
                            color: root.accent
                            font.family: bridge.thaiFontFamily
                            font.pixelSize: 22
                            font.weight: Font.DemiBold
                        }
                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: bridge.locoRangeHint
                            color: root.ink
                            font.family: bridge.thaiFontFamily
                            font.pixelSize: 14
                            font.weight: Font.Medium
                        }
                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: root.tr("pick_loco_hint")
                            color: root.muted
                            font.family: bridge.thaiFontFamily
                            font.pixelSize: 12
                        }
                        SunkField {
                            id: wizardLoco
                            width: parent.width
                            label: root.tr("loco_no")
                            value: bridge.locoNumber
                            unit: ""
                            tone: bridge.locoCheckTone === "ok" ? "ok"
                                  : (bridge.locoCheckTone === "bad" ? "bad"
                                  : (bridge.locoCheckTone === "warn" ? "warn" : "empty"))
                            onEdited: bridge.locoNumber = text
                            Component.onCompleted: Qt.callLater(function() { wizardLoco.focusInput() })
                        }
                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: bridge.saveHint.length > 0 ? bridge.saveHint : bridge.locoCheckMessage
                            color: (bridge.saveHint.length > 0 || bridge.locoCheckTone === "bad")
                                   ? root.toneInk(bridge.locoCheckTone === "empty" ? "bad" : bridge.locoCheckTone)
                                   : root.toneInk(bridge.locoCheckTone)
                            font.family: bridge.thaiFontFamily
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }
                    }
                    Row {
                        id: locoBar
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        spacing: 10
                        RaiseButton {
                            width: (parent.width - 10) / 2
                            height: bridge.largeControls ? 56 : 50
                            label: root.tr("back")
                            iconName: "arrow_back"
                            onClicked: bridge.page = "fleet"
                        }
                        RaiseButton {
                            width: (parent.width - 10) / 2
                            height: bridge.largeControls ? 56 : 50
                            label: root.tr("next")
                            iconName: "chevron_right"
                            accent: true
                            onClicked: {
                                // Push typed text first � don't rely on blur/commit race.
                                bridge.locoNumber = wizardLoco.inputText
                                bridge.confirmLoco()
                            }
                        }
                    }
                }

                // ENTRY � desktop: diagram + all 4 pairs visible, no scroll
                Item {
                    id: entryPage
                    property var f: bridge.currentFields()
                    property var tones: bridge.currentFieldTones()
                    property var hints: bridge.fieldLimitHints()
                    function refresh() {
                        f = bridge.currentFields()
                        tones = bridge.currentFieldTones()
                        hints = bridge.fieldLimitHints()
                    }
                    Connections {
                        target: bridge
                        function onFieldsChanged() { entryPage.refresh() }
                        function onResultsChanged() { entryPage.refresh() }
                        function onUnitChanged() { entryPage.refresh() }
                        function onWheelChanged() { entryPage.refresh() }
                        function onFleetChanged() { entryPage.refresh() }
                        function onLangChanged() { entryPage.refresh() }
                        function onSessionChanged() { entryPage.refresh() }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: entryBar.top
                        anchors.bottomMargin: 8
                        spacing: 8

                        Row {
                            width: parent.width
                            spacing: 14
                            height: Math.min(148, parent.height * 0.28)

                            Column {
                                width: parent.width * 0.42
                                spacing: 4
                                Text {
                                    width: parent.width
                                    text: bridge.fleetHeadline
                                    elide: Text.ElideRight
                                    color: root.accent
                                    font.family: bridge.thaiFontFamily
                                    font.pixelSize: 15
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    width: parent.width
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                    text: root.tr("entry_hint")
                                    color: root.muted
                                    font.family: bridge.thaiFontFamily
                                    font.pixelSize: 12
                                }
                                SideDiagram {
                                    width: parent.width
                                    ink: root.ink
                                    muted: root.muted
                                    accent: root.accent
                                    dark: bridge.dark
                                    fontFamily: bridge.thaiFontFamily
                                    fleetLabel: bridge.fleetHeadline
                                    locoNumber: bridge.locoNumber
                                    wheel: bridge.wheel
                                    largeControls: false
                                    onWheelPicked: (wi) => { bridge.wheel = wi }
                                }
                            }

                            Column {
                                width: parent.width * 0.58 - 14
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 6
                                Text {
                                    width: parent.width
                                    text: root.tr("diagram_hint")
                                    wrapMode: Text.WordWrap
                                    color: root.muted
                                    font.family: bridge.thaiFontFamily
                                    font.pixelSize: 12
                                }
                            }
                        }

                        // 2�2 field grid � all metrics visible at once
                        Grid {
                            id: fieldsGrid
                            width: parent.width
                            height: parent.height - 156
                            columns: 2
                            columnSpacing: 12
                            rowSpacing: 8

                            component PairBlock: Item {
                                property string titleKey
                                property string rKey
                                property string lKey
                                property string rVal
                                property string lVal
                                property string rTone
                                property string lTone
                                property string limitHint
                                width: (fieldsGrid.width - fieldsGrid.columnSpacing) / 2
                                height: (fieldsGrid.height - fieldsGrid.rowSpacing) / 2

                                Column {
                                    anchors.fill: parent
                                    spacing: 4
                                    Text {
                                        text: titleKey === "tyre" ? bridge.tyreLabel : root.tr(titleKey)
                                        color: root.ink
                                        font.family: bridge.thaiFontFamily
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                    }
                                    Rectangle {
                                        width: parent.width
                                        height: 22
                                        radius: 7
                                        color: bridge.dark ? "#2a1818" : "#f5e8e8"
                                        border.width: 1
                                        border.color: bridge.dark ? Qt.rgba(196, 92, 92, 0.4) : Qt.rgba(122, 26, 30, 0.3)
                                        Text {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            text: limitHint
                                            elide: Text.ElideRight
                                            color: bridge.dark ? "#e09090" : "#5c1418"
                                            font.family: bridge.thaiFontFamily
                                            font.pixelSize: 11
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                    Row {
                                        width: parent.width
                                        spacing: 8
                                        height: parent.height - 48
                                        SunkField {
                                            width: (parent.width - 8) / 2
                                            height: parent.height
                                            label: root.tr("right")
                                            value: rVal
                                            tone: rTone
                                            onEdited: (text, wheel) => bridge.setField(rKey, text, wheel)
                                        }
                                        SunkField {
                                            width: (parent.width - 8) / 2
                                            height: parent.height
                                            label: root.tr("left")
                                            value: lVal
                                            tone: lTone
                                            onEdited: (text, wheel) => bridge.setField(lKey, text, wheel)
                                        }
                                    }
                                }
                            }

                            PairBlock {
                                titleKey: "tyre"; rKey: "rTyre"; lKey: "lTyre"
                                rVal: entryPage.f.rTyre || ""; lVal: entryPage.f.lTyre || ""
                                rTone: entryPage.tones.rTyre || "empty"; lTone: entryPage.tones.lTyre || "empty"
                                limitHint: entryPage.hints.tyre || ""
                            }
                            PairBlock {
                                titleKey: "tread"; rKey: "rTread"; lKey: "lTread"
                                rVal: entryPage.f.rTread || ""; lVal: entryPage.f.lTread || ""
                                rTone: entryPage.tones.rTread || "empty"; lTone: entryPage.tones.lTread || "empty"
                                limitHint: entryPage.hints.tread || ""
                            }
                            PairBlock {
                                titleKey: "flange"; rKey: "rFlange"; lKey: "lFlange"
                                rVal: entryPage.f.rFlange || ""; lVal: entryPage.f.lFlange || ""
                                rTone: entryPage.tones.rFlange || "empty"; lTone: entryPage.tones.lFlange || "empty"
                                limitHint: entryPage.hints.flange || ""
                            }
                            PairBlock {
                                titleKey: "root"; rKey: "rRoot"; lKey: "lRoot"
                                rVal: entryPage.f.rRoot || ""; lVal: entryPage.f.lRoot || ""
                                rTone: entryPage.tones.rRoot || "empty"; lTone: entryPage.tones.lRoot || "empty"
                                limitHint: entryPage.hints.root || ""
                            }
                        }
                    }

                    Item {
                        id: entryBar
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: bridge.largeControls ? 50 : 44
                        RaiseButton {
                            anchors.left: parent.left
                            width: 148
                            height: parent.height
                            label: root.tr("clear_wheel")
                            iconName: "clear"
                            onClicked: bridge.clearCurrentWheel()
                        }
                        Row {
                            anchors.right: parent.right
                            spacing: 10
                            height: parent.height
                            RaiseButton {
                                width: 150
                                height: parent.height
                                label: root.tr("see_result")
                                iconName: "fact_check"
                                onClicked: bridge.page = "result"
                            }
                            RaiseButton {
                                width: 180
                                height: parent.height
                                label: bridge.wheel >= 5 ? root.tr("see_result") : root.tr("next_axle")
                                iconName: bridge.wheel >= 5 ? "fact_check" : "chevron_right"
                                accent: true
                                onClicked: {
                                    if (bridge.wheel < 5)
                                        bridge.wheel = bridge.wheel + 1
                                    else
                                        bridge.page = "result"
                                }
                            }
                        }
                    }
                }

                // RESULT � raised category backdrops + L/R cards, filter by status
                Item {
                    id: resultRoot
                    property string statusFilter: "all"  // all | ok | warn | bad
                    property int resultTick: 0
                    Connections {
                        target: bridge
                        function onResultsChanged() { resultRoot.resultTick++ }
                        function onLangChanged() { resultRoot.resultTick++ }
                    }
                    function toneCount(tone) {
                        var n = 0
                        var rows = bridge.resultRows
                        for (var i = 0; i < rows.length; ++i) {
                            if (rows[i].tone === tone) n++
                        }
                        return n
                    }
                    function rowsFor(group) {
                        var _ = resultTick
                        var out = []
                        var rows = bridge.resultRows
                        for (var i = 0; i < rows.length; ++i) {
                            var g = rows[i].group || ""
                            if (group === "other") {
                                if (g.length) continue
                            } else if (g !== group) {
                                continue
                            }
                            if (statusFilter !== "all" && rows[i].tone !== statusFilter)
                                continue
                            out.push(rows[i])
                        }
                        return out
                    }

                    Flickable {
                        id: resultFlick
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: resultBar.top
                        anchors.bottomMargin: 8
                        contentHeight: resultCol.height + 12
                        clip: true
                        // Desktop: no scroll when everything fits the viewport
                        interactive: contentHeight > height + 1
                        boundsBehavior: Flickable.StopAtBounds
                        Column {
                            id: resultCol
                            width: resultFlick.width
                            spacing: 14

                            Rectangle {
                                width: parent.width
                                height: 72
                                radius: 16
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: bridge.dark ? "#6d191e" : "#8b2428" }
                                    GradientStop { position: 1.0; color: bridge.dark ? "#3a0e10" : "#5c1418" }
                                }
                                Column {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.margins: 16
                                    spacing: 2
                                    Text {
                                        text: bridge.fleetHeadline
                                        color: Qt.rgba(1, 1, 1, 0.85)
                                        font.family: bridge.thaiFontFamily
                                        font.pixelSize: 14
                                    }
                                    Text {
                                        text: bridge.locoNumber.length ? bridge.locoNumber : "�"
                                        color: "#ffffff"
                                        font.family: bridge.thaiFontFamily
                                        font.pixelSize: 28
                                        font.weight: Font.Bold
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 70
                                radius: 16
                                color: root.cardTone(bridge.worstTone)
                                border.width: 2
                                border.color: root.toneInk(bridge.worstTone)
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 12
                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: 20
                                        color: root.toneInk(bridge.worstTone)
                                        anchors.verticalCenter: parent.verticalCenter
                                        IconLabel {
                                            anchors.centerIn: parent
                                            name: bridge.worstTone === "bad" ? "error" : (bridge.worstTone === "warn" ? "warning" : "check")
                                            color: "#ffffff"
                                            font.pixelSize: 22
                                        }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        Text {
                                            text: root.tr("overall")
                                            color: root.muted
                                            font.family: bridge.thaiFontFamily
                                            font.pixelSize: 12
                                        }
                                        Text {
                                            text: bridge.worstLabel
                                            color: root.toneInk(bridge.worstTone)
                                            font.family: bridge.thaiFontFamily
                                            font.pixelSize: 22
                                            font.weight: Font.Bold
                                        }
                                    }
                                }
                            }

                            // Status filter (????????)
                            Column {
                                width: parent.width
                                spacing: 6
                                Text {
                                    text: root.tr("filter_by_status")
                                    color: root.muted
                                    font.family: bridge.thaiFontFamily
                                    font.pixelSize: 12
                                }
                                Row {
                                    width: parent.width
                                    spacing: 6
                                    Repeater {
                                        model: [
                                            { id: "all", labelKey: "filter_all", tone: "empty" },
                                            { id: "ok", labelKey: "status_ok", tone: "ok" },
                                            { id: "warn", labelKey: "status_shop", tone: "warn" },
                                            { id: "bad", labelKey: "status_scrap", tone: "bad" }
                                        ]
                                        RaiseButton {
                                            required property var modelData
                                            width: (parent.width - 18) / 4
                                            height: 40
                                            label: root.tr(modelData.labelKey)
                                            accent: resultRoot.statusFilter === modelData.id
                                            onClicked: resultRoot.statusFilter = modelData.id
                                        }
                                    }
                                }
                            }

                            // Raised type panel + 2-col cards
                            component ResultPanel: Item {
                                id: panel
                                property string groupKey
                                property string titleKey
                                property var panelRows: resultRoot.rowsFor(groupKey)
                                width: resultCol.width
                                height: visible ? panelBody.height + 10 : 0
                                visible: panelRows.length > 0

                                // Soft drop shadow under backdrop
                                Repeater {
                                    model: 4
                                    Rectangle {
                                        required property int index
                                        anchors.fill: panelBody
                                        anchors.topMargin: 3 + index
                                        anchors.bottomMargin: -(4 - index)
                                        anchors.leftMargin: 1
                                        anchors.rightMargin: 1
                                        radius: 20
                                        z: -1
                                        color: bridge.dark ? "#000000" : "#6a4a4a"
                                        opacity: 0.16 - index * 0.03
                                    }
                                }

                                Rectangle {
                                    id: panelBody
                                    width: parent.width
                                    height: panelInner.height + 28
                                    radius: 20
                                    gradient: Gradient {
                                        GradientStop {
                                            position: 0.0
                                            color: bridge.dark ? "#2a1c1c" : "#f5ecec"
                                        }
                                        GradientStop {
                                            position: 1.0
                                            color: bridge.dark ? "#1c1212" : "#e8d8d8"
                                        }
                                    }
                                    border.width: 1
                                    border.color: bridge.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(255, 255, 255, 0.85)

                                    Column {
                                        id: panelInner
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.margins: 14
                                        spacing: 12

                                        Text {
                                            width: parent.width
                                            text: root.tr(panel.titleKey)
                                            color: root.ink
                                            font.family: bridge.thaiFontFamily
                                            font.pixelSize: 17
                                            font.weight: Font.Bold
                                        }

                                        Grid {
                                            id: cardGrid
                                            width: parent.width
                                            columns: 2
                                            columnSpacing: 10
                                            rowSpacing: 10
                                            Repeater {
                                                model: panel.panelRows
                                                delegate: Item {
                                                    required property var modelData
                                                    width: (cardGrid.width - cardGrid.columnSpacing) / 2
                                                    height: 118

                                                    Repeater {
                                                        model: 3
                                                        Rectangle {
                                                            required property int index
                                                            anchors.fill: cardFace
                                                            anchors.topMargin: 2 + index
                                                            anchors.bottomMargin: -(3 - index)
                                                            radius: 14
                                                            z: -1
                                                            color: bridge.dark ? "#000000" : "#6a4a4a"
                                                            opacity: 0.18 - index * 0.04
                                                        }
                                                    }

                                                    Rectangle {
                                                        id: cardFace
                                                        anchors.fill: parent
                                                        radius: 14
                                                        gradient: Gradient {
                                                            GradientStop {
                                                                position: 0.0
                                                                color: bridge.dark ? "#3a2424" : "#ffffff"
                                                            }
                                                            GradientStop {
                                                                position: 1.0
                                                                color: root.cardTone(modelData.tone)
                                                            }
                                                        }
                                                        border.width: 1
                                                        border.color: bridge.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(255, 255, 255, 0.9)

                                                        Rectangle {
                                                            anchors.left: parent.left
                                                            anchors.top: parent.top
                                                            anchors.bottom: parent.bottom
                                                            anchors.margins: 5
                                                            width: 5
                                                            radius: 3
                                                            color: root.toneInk(modelData.tone)
                                                        }

                                                        Column {
                                                            anchors.fill: parent
                                                            anchors.leftMargin: 16
                                                            anchors.rightMargin: 10
                                                            anchors.topMargin: 10
                                                            anchors.bottomMargin: 10
                                                            spacing: 4

                                                            Text {
                                                                width: parent.width
                                                                text: modelData.title
                                                                elide: Text.ElideRight
                                                                color: root.ink
                                                                font.family: bridge.thaiFontFamily
                                                                font.pixelSize: 15
                                                                font.weight: Font.Bold
                                                            }
                                                            Text {
                                                                width: parent.width
                                                                text: modelData.detail
                                                                wrapMode: Text.WordWrap
                                                                maximumLineCount: 2
                                                                elide: Text.ElideRight
                                                                color: root.muted
                                                                font.family: bridge.thaiFontFamily
                                                                font.pixelSize: 12
                                                            }
                                                            Item { width: 1; height: 2 }
                                                            Rectangle {
                                                                width: statusLab.implicitWidth + 16
                                                                height: 28
                                                                radius: 14
                                                                color: root.toneInk(modelData.tone)
                                                                Text {
                                                                    id: statusLab
                                                                    anchors.centerIn: parent
                                                                    text: modelData.status
                                                                    color: "#ffffff"
                                                                    font.family: bridge.thaiFontFamily
                                                                    font.pixelSize: 13
                                                                    font.weight: Font.Bold
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            ResultPanel { groupKey: "axle"; titleKey: "grp_axle" }
                            ResultPanel { groupKey: "bogie"; titleKey: "grp_bogie" }
                            ResultPanel { groupKey: "loco"; titleKey: "grp_loco" }
                            ResultPanel { groupKey: "wear"; titleKey: "grp_wear" }
                            ResultPanel { groupKey: "other"; titleKey: "summary" }
                        }
                    }

                    Row {
                        id: resultBar
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        spacing: 8
                        RaiseButton {
                            width: (parent.width - 16) / 3
                            height: bridge.largeControls ? 52 : 46
                            label: root.tr("back_entry")
                            iconName: "edit"
                            onClicked: bridge.page = "entry"
                        }
                        RaiseButton {
                            width: (parent.width - 16) / 3
                            height: bridge.largeControls ? 52 : 46
                            label: root.tr("guide")
                            iconName: "menu_book"
                            onClicked: bridge.page = "guide"
                        }
                        RaiseButton {
                            width: (parent.width - 16) / 3
                            height: bridge.largeControls ? 52 : 46
                            label: root.tr("save_result")
                            iconName: "save"
                            accent: true
                            onClicked: bridge.page = "save"
                        }
                    }
                }

                // GUIDE tabs + raised cards
                Item {
                    id: guideRoot
                    property string guideTab: "diff"
                    Column {
                        anchors.fill: parent
                        spacing: 10
                        Text {
                            text: root.tr("guide_title")
                            color: root.ink
                            font.family: bridge.thaiFontFamily
                            font.pixelSize: 18
                            font.weight: Font.DemiBold
                        }
                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: root.tr("guide_pick_fleet") + "  �  " + bridge.guideFleetName + " (" + bridge.guideFleetCode + ")"
                            color: root.muted
                            font.family: bridge.thaiFontFamily
                            font.pixelSize: 12
                        }
                        Flow {
                            id: guideFleetFlow
                            width: parent.width
                            spacing: 6
                            Repeater {
                                model: bridge.fleetOptions
                                RaiseButton {
                                    required property var modelData
                                    width: (guideFleetFlow.width - 12) / 3
                                    height: 36
                                    label: modelData.code
                                    accent: bridge.guideFleetCode === modelData.code
                                    onClicked: bridge.guideFleetCode = modelData.code
                                }
                            }
                        }
                        Row {
                            id: guideTabs
                            width: parent.width
                            spacing: 6
                            Repeater {
                                model: [
                                    { tab: "diff", key: "badge_diff" },
                                    { tab: "scrap", key: "badge_scrap" },
                                    { tab: "wear", key: "badge_wear" }
                                ]
                                RaiseButton {
                                    required property var modelData
                                    width: (guideTabs.width - 12) / 3
                                    label: root.tr(modelData.key)
                                    accent: guideRoot.guideTab === modelData.tab
                                    onClicked: guideRoot.guideTab = modelData.tab
                                }
                            }
                        }
                        Flickable {
                            width: parent.width
                            height: parent.height - 168
                            clip: true
                            contentHeight: guideCardsCol.height + 12
                            interactive: contentHeight > height + 1
                            boundsBehavior: Flickable.StopAtBounds
                            Column {
                                id: guideCardsCol
                                width: parent.width
                                spacing: 12
                                Repeater {
                                    model: bridge.guideCards
                                    delegate: Item {
                                        required property var modelData
                                        width: guideCardsCol.width
                                        height: visible ? cardBody.height + 8 : 0
                                        visible: modelData.cat === guideRoot.guideTab
                                        // raised floating card
                                        Repeater {
                                            model: 3
                                            Rectangle {
                                                required property int index
                                                anchors.fill: cardBody
                                                anchors.topMargin: 2 + index
                                                anchors.bottomMargin: -(3 - index)
                                                radius: 16
                                                z: -1
                                                color: bridge.dark ? "#000000" : "#6a4a4a"
                                                opacity: 0.14 - index * 0.03
                                            }
                                        }
                                        Rectangle {
                                            id: cardBody
                                            width: parent.width
                                            height: cardInner.height + 28
                                            radius: 16
                                            gradient: Gradient {
                                                GradientStop { position: 0.0; color: bridge.dark ? "#3a2424" : "#ffffff" }
                                                GradientStop { position: 1.0; color: root.cardTone(modelData.tone) }
                                            }
                                            border.width: 1
                                            border.color: bridge.dark ? Qt.rgba(1,1,1,0.12) : Qt.rgba(255,255,255,0.8)
                                            Column {
                                                id: cardInner
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                anchors.top: parent.top
                                                anchors.margins: 14
                                                spacing: 8
                                                Rectangle {
                                                    width: badgeTxt.implicitWidth + 16
                                                    height: 24
                                                    radius: 8
                                                    color: bridge.dark ? Qt.rgba(0,0,0,0.28) : Qt.rgba(255,255,255,0.7)
                                                    Text {
                                                        id: badgeTxt
                                                        anchors.centerIn: parent
                                                        text: modelData.badge
                                                        color: root.toneInk(modelData.tone)
                                                        font.family: bridge.thaiFontFamily
                                                        font.pixelSize: 11
                                                        font.weight: Font.DemiBold
                                                    }
                                                }
                                                Text {
                                                    width: parent.width
                                                    text: modelData.title
                                                    color: root.ink
                                                    font.family: bridge.thaiFontFamily
                                                    font.pixelSize: 15
                                                    font.weight: Font.DemiBold
                                                }
                                                Text {
                                                    width: parent.width
                                                    text: modelData.value
                                                    color: root.toneInk(modelData.tone)
                                                    font.family: bridge.thaiFontFamily
                                                    font.pixelSize: 22
                                                    font.weight: Font.DemiBold
                                                }
                                                Text {
                                                    width: parent.width
                                                    text: modelData.note
                                                    wrapMode: Text.WordWrap
                                                    color: root.muted
                                                    font.family: bridge.thaiFontFamily
                                                    font.pixelSize: 12
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // SAVE loco number
                Flickable {
                    contentHeight: saveCol.height + 20
                    clip: true
                    interactive: contentHeight > height + 1
                    boundsBehavior: Flickable.StopAtBounds
                    Column {
                        id: saveCol
                        width: stack.width - 28
                        spacing: 12
                        Text { text: root.tr("save_page"); color: root.ink; font.family: bridge.thaiFontFamily; font.pixelSize: 15; font.weight: Font.DemiBold }
                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: root.tr("save_page_hint")
                            color: root.muted
                            font.family: bridge.thaiFontFamily
                            font.pixelSize: 12
                        }
                        Rectangle {
                            width: parent.width
                            height: 48
                            radius: 12
                            color: root.cardTone(bridge.worstTone)
                            Text {
                                anchors.centerIn: parent
                                text: root.tr("overall") + " - " + bridge.worstLabel
                                color: root.ink
                                font.family: bridge.thaiFontFamily
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                            }
                        }
                        Text { text: root.tr("loco_no"); color: root.muted; font.family: bridge.thaiFontFamily; font.pixelSize: 12 }
                        SunkField {
                            id: saveLocoField
                            width: parent.width
                            label: root.tr("loco_ph")
                            value: bridge.locoNumber
                            unit: ""
                            onEdited: bridge.locoNumber = text
                        }
                        RaiseButton {
                            width: parent.width
                            label: root.tr("confirm_save")
                            iconName: "save"
                            accent: true
                            onClicked: {
                                bridge.locoNumber = saveLocoField.inputText
                                bridge.saveCurrent()
                                bridge.page = "result"
                            }
                        }
                        RaiseButton {
                            width: parent.width
                            label: root.tr("skip_auto")
                            iconName: "history"
                            onClicked: {
                                bridge.locoNumber = ""
                                bridge.saveCurrent()
                                bridge.page = "result"
                            }
                        }
                        RaiseButton {
                            width: parent.width
                            label: root.tr("back_entry")
                            iconName: "edit"
                            onClicked: bridge.page = "result"
                        }
                        Text {
                            visible: bridge.saveHint.length > 0
                            text: bridge.saveHint
                            color: root.accent
                            font.family: bridge.thaiFontFamily
                            font.pixelSize: 12
                        }
                    }
                }

                // SETTINGS
                Flickable {
                    contentHeight: setCol.height + 20
                    clip: true
                    interactive: contentHeight > height + 1
                    boundsBehavior: Flickable.StopAtBounds
                    Column {
                        id: setCol
                        width: stack.width - 28
                        spacing: 14
                        Text { text: root.tr("settings_title"); color: root.ink; font.family: bridge.thaiFontFamily; font.pixelSize: 15; font.weight: Font.DemiBold }
                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: root.tr("settings_hint")
                            color: root.muted
                            font.family: bridge.thaiFontFamily
                            font.pixelSize: 12
                        }

                        component SettingRow: Row {
                            property string titleKey
                            property string hintKey
                            width: setCol.width
                            spacing: 10
                            Column {
                                width: parent.width - 140
                                Text { text: root.tr(titleKey); color: root.ink; font.family: bridge.thaiFontFamily; font.pixelSize: 14; font.weight: Font.Medium }
                                Text { text: root.tr(hintKey); color: root.muted; font.family: bridge.thaiFontFamily; font.pixelSize: 12; width: parent.width; wrapMode: Text.WordWrap }
                            }
                        }

                        SettingRow {
                            titleKey: "theme"
                            hintKey: "theme_hint"
                            Row {
                                spacing: 6
                                RaiseButton { width: 56; label: root.tr("light"); accent: !bridge.dark; onClicked: bridge.dark = false }
                                RaiseButton { width: 56; label: root.tr("dark"); accent: bridge.dark; onClicked: bridge.dark = true }
                            }
                        }
                        SettingRow {
                            titleKey: "unit"
                            hintKey: "unit_hint"
                            Row {
                                spacing: 6
                                RaiseButton { width: 56; label: root.tr("mm"); accent: !bridge.inches; onClicked: bridge.inches = false }
                                RaiseButton { width: 56; label: root.tr("inch"); accent: bridge.inches; onClicked: bridge.inches = true }
                            }
                        }
                        SettingRow {
                            titleKey: "language"
                            hintKey: "lang_hint"
                            Row {
                                spacing: 6
                                RaiseButton { width: 56; label: "TH"; accent: bridge.lang === "th"; onClicked: bridge.lang = "th" }
                                RaiseButton { width: 56; label: "EN"; accent: bridge.lang === "en"; onClicked: bridge.lang = "en" }
                            }
                        }
                        SettingRow {
                            titleKey: "btn_size"
                            hintKey: "btn_hint"
                            Row {
                                spacing: 6
                                RaiseButton { width: 56; label: root.tr("normal"); accent: !bridge.largeControls; onClicked: bridge.largeControls = false }
                                RaiseButton { width: 56; label: root.tr("large"); accent: bridge.largeControls; onClicked: bridge.largeControls = true }
                            }
                        }
                        RaiseButton { label: root.tr("clear_all"); iconName: "clear"; onClicked: bridge.clearAll() }
                        Text {
                            text: (bridge.fontReady ? "OK " : "FAIL ") + bridge.thaiFontFamily
                            color: root.muted
                            font.family: bridge.thaiFontFamily
                            font.pixelSize: 12
                        }
                    }
                }

                // HISTORY � tap a loco ? open its stats directly
                Item {
                    id: historyRoot
                    property int histTick: 0
                    Connections {
                        target: bridge
                        function onHistoryChanged() { historyRoot.histTick++ }
                        function onSavedChanged() { historyRoot.histTick++ }
                        function onLangChanged() { historyRoot.histTick++ }
                    }

                    Column {
                        anchors.fill: parent
                        spacing: 10

                        Text {
                            text: root.tr("history_title")
                            color: root.ink
                            font.family: bridge.thaiFontFamily
                            font.pixelSize: 18
                            font.weight: Font.DemiBold
                        }
                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: root.tr("history_hint")
                            color: root.muted
                            font.family: bridge.thaiFontFamily
                            font.pixelSize: 12
                        }

                        Row {
                            width: parent.width
                            spacing: 8
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.tr("sort_by")
                                color: root.muted
                                font.family: bridge.thaiFontFamily
                                font.pixelSize: 12
                            }
                            Repeater {
                                model: [
                                    { id: "modified", key: "sort_modified" },
                                    { id: "created", key: "sort_created" },
                                    { id: "loco", key: "sort_loco" }
                                ]
                                RaiseButton {
                                    required property var modelData
                                    width: 120
                                    height: 36
                                    label: root.tr(modelData.key)
                                    accent: bridge.historySort === modelData.id
                                    onClicked: bridge.historySort = modelData.id
                                }
                            }
                        }

                        Item {
                            width: parent.width
                            height: parent.height - 100

                            Text {
                                anchors.centerIn: parent
                                visible: bridge.historyRows.length === 0
                                text: root.tr("no_saved")
                                color: root.muted
                                font.family: bridge.thaiFontFamily
                                font.pixelSize: 14
                            }

                            Flickable {
                                anchors.fill: parent
                                clip: true
                                visible: bridge.historyRows.length > 0
                                contentHeight: histCol.height + 8
                                interactive: contentHeight > height + 1
                                boundsBehavior: Flickable.StopAtBounds

                                Column {
                                    id: histCol
                                    width: parent.width
                                    spacing: 8
                                    // force rebind when sort/saved changes
                                    property var rows: (historyRoot.histTick, bridge.historyRows)

                                    Repeater {
                                        model: histCol.rows
                                        delegate: Item {
                                            required property var modelData
                                            width: histCol.width
                                            height: 78

                                            RaiseButton {
                                                anchors.fill: parent
                                                anchors.rightMargin: 72
                                                accent: false
                                                label: ""
                                                onClicked: bridge.loadRecord(modelData.index)
                                            }
                                            Row {
                                                anchors.fill: parent
                                                anchors.rightMargin: 72
                                                anchors.margins: 12
                                                spacing: 12
                                                enabled: false
                                                Rectangle {
                                                    width: 54
                                                    height: 54
                                                    radius: 14
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    color: root.cardTone(modelData.tone || "empty")
                                                    border.width: 1
                                                    border.color: root.toneInk(modelData.tone || "empty")
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.fleet || "�"
                                                        color: root.toneInk(modelData.tone || "empty")
                                                        font.family: bridge.thaiFontFamily
                                                        font.pixelSize: 12
                                                        font.weight: Font.Bold
                                                    }
                                                }
                                                Column {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    spacing: 2
                                                    width: parent.width - 66
                                                    Text {
                                                        width: parent.width
                                                        text: modelData.loco || "�"
                                                        color: root.ink
                                                        font.family: bridge.thaiFontFamily
                                                        font.pixelSize: 20
                                                        font.weight: Font.Bold
                                                        elide: Text.ElideRight
                                                    }
                                                    Text {
                                                        width: parent.width
                                                        text: root.tr("created_at") + " " + (modelData.createdLabel || "�")
                                                              + "   �   "
                                                              + root.tr("modified_at") + " " + (modelData.modifiedLabel || "�")
                                                        color: root.muted
                                                        font.family: bridge.thaiFontFamily
                                                        font.pixelSize: 11
                                                        elide: Text.ElideRight
                                                    }
                                                    Text {
                                                        width: parent.width
                                                        text: (modelData.worst || "�") + "  �  " + root.tr("open_stats")
                                                        color: root.accent
                                                        font.family: bridge.thaiFontFamily
                                                        font.pixelSize: 12
                                                        font.weight: Font.Medium
                                                        elide: Text.ElideRight
                                                    }
                                                }
                                            }
                                            RaiseButton {
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 64
                                                height: 48
                                                label: root.tr("delete_rec")
                                                iconName: "delete"
                                                onClicked: bridge.deleteRecord(modelData.index)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    } // stage
}
