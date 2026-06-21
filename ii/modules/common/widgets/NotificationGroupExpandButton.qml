import qs.services
import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts

RippleButton { // Expand button
    id: root
    required property int count
    required property bool expanded
    property real fontSize: Appearance?.font.pixelSize.small ?? 12
    implicitHeight: fontSize + 4 * 2
    implicitWidth: Math.max(contentItem.implicitWidth + 5 * 2, 30)
    Layout.alignment: Qt.AlignVCenter
    Layout.fillHeight: false

    buttonRadius: 0
    buttonRadiusPressed: 0
    colBackground: "#252525"
    colBackgroundHover: "#303030"
    colRipple: "#3a3a3a"
    borderWidth: 1
    borderColor: "#363636"

    contentItem: Item {
        anchors.centerIn: parent
        implicitWidth: contentRow.implicitWidth
        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: 4
            StyledText {
                Layout.leftMargin: 4
                visible: root.count > 1
                text: root.count
                font.pixelSize: root.fontSize
                font.family: Appearance.font.family.monospace
            }
            StyledText {
                text: root.expanded ? "▲" : "▼"
                font.pixelSize: root.fontSize
                font.family: Appearance.font.family.monospace
                color: Appearance.colors.colOnLayer2
            }
        }
    }
}
