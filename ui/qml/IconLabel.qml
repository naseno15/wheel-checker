import QtQuick

Text {
    property string name: ""
    text: bridge.glyph(name)
    font.family: mi.name.length > 0 ? mi.name : bridge.iconFont
    font.pixelSize: 22
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    FontLoader { id: mi; source: bridge.iconFontUrl }
}
