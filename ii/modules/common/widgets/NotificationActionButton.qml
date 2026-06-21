import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services
import QtQuick
import Quickshell.Services.Notifications

Item {
    id: button
    property string buttonText
    property string urgency
    property bool hovered: hoverArea.containsMouse
    property bool pressed: hoverArea.pressed
    signal clicked()

    implicitWidth: label.implicitWidth + 16
    implicitHeight: 24

    Rectangle {
        anchors.fill: parent
        color: button.pressed ? (urgency == NotificationUrgency.Critical ? Appearance.tiling.error : Appearance.tiling.text) :
               button.hovered ? (urgency == NotificationUrgency.Critical ? Appearance.tiling.borderCritical : Appearance.tiling.bgHover) :
               "transparent"
        Behavior on color { ColorAnimation { duration: 80 } }
    }

    StyledText {
        id: label
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        font.family: Appearance.font.family.monospace
        font.pixelSize: Appearance.font.pixelSize.small
        text: button.buttonText
        color: button.pressed ? Appearance.tiling.bg :
               (urgency == NotificationUrgency.Critical) ? Appearance.tiling.error : Appearance.tiling.text
        Behavior on color { ColorAnimation { duration: 80 } }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }
}
