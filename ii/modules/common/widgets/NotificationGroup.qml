import qs.services
import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

MouseArea {
    id: root
    property var notificationGroup
    property var notifications: notificationGroup?.notifications ?? []
    property int notificationCount: notifications.length
    property bool multipleNotifications: notificationCount > 1
    property bool expanded: false
    property bool popup: false
    property real padding: 8
    implicitHeight: background.implicitHeight

    property bool isCritical: root.notifications.some(n => n.urgency === NotificationUrgency.Critical.toString())
    property string urgencySymbol: isCritical ? "◆" : "○"
    property color urgencyColor: isCritical ? Appearance.tiling.error : Appearance.tiling.accent

    property real dragConfirmThreshold: 70
    property real dismissOvershoot: 20
    property var qmlParent: root?.parent?.parent
    property var parentDragIndex: qmlParent?.dragIndex
    property var parentDragDistance: qmlParent?.dragDistance
    property var dragIndexDiff: Math.abs(parentDragIndex - index)
    property real xOffset: dragIndexDiff == 0 ? parentDragDistance : 
        Math.abs(parentDragDistance) > dragConfirmThreshold ? 0 :
        dragIndexDiff == 1 ? (parentDragDistance * 0.3) :
        dragIndexDiff == 2 ? (parentDragDistance * 0.1) : 0

    function destroyWithAnimation(left = false) {
        root.qmlParent.resetDrag()
        background.anchors.leftMargin = background.anchors.leftMargin;
        destroyAnimation.left = left;
        destroyAnimation.running = true;
    }

    hoverEnabled: true
    onContainsMouseChanged: {
        if (!root.popup) return;
        if (root.containsMouse) root.notifications.forEach(notif => {
            Notifications.cancelTimeout(notif.notificationId);
        });
        else root.notifications.forEach(notif => {
            Notifications.timeoutNotification(notif.notificationId);
        });
    }

    SequentialAnimation {
        id: destroyAnimation
        property bool left: true
        running: false

        NumberAnimation {
            target: background.anchors
            property: "leftMargin"
            to: (root.width + root.dismissOvershoot) * (destroyAnimation.left ? -1 : 1)
            duration: Appearance.animation.elementMove.duration
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
        onFinished: () => {
            root.notifications.forEach((notif) => {
                Qt.callLater(() => {
                    Notifications.discardNotification(notif.notificationId);
                });
            });
        }
    }

    function toggleExpanded() {
        if (expanded) implicitHeightAnim.enabled = true;
        else implicitHeightAnim.enabled = false;
        root.expanded = !root.expanded;
    }

    DragManager {
        id: dragManager
        anchors.fill: parent
        interactive: !expanded
        automaticallyReset: false
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onPressed: {
            if (mouse.button === Qt.RightButton) 
                root.toggleExpanded();
        }

        onClicked: (mouse) => {
            if (mouse.button === Qt.MiddleButton) 
                root.destroyWithAnimation();
        }

        onDraggingChanged: () => {
            if (dragging) {
                root.qmlParent.dragIndex = root.index ?? root.parent.children.indexOf(root);
            }
        }

        onDragDiffXChanged: () => {
            root.qmlParent.dragDistance = dragDiffX;
        }

        onDragReleased: (diffX, diffY) => {
            if (Math.abs(diffX) > root.dragConfirmThreshold)
                root.destroyWithAnimation(diffX < 0);
            else 
                dragManager.resetDrag();
        }
    }

    Rectangle { // Background of the notification
        id: background
        anchors.left: parent.left
        width: parent.width
        color: popup ? Appearance.tiling.bg : "#1d1d1d"
        radius: 0
        border.width: 1
        border.color: root.isCritical ? Appearance.tiling.borderCritical : Appearance.tiling.border
        anchors.leftMargin: root.xOffset

        Behavior on anchors.leftMargin {
            enabled: !dragManager.dragging
            NumberAnimation {
                duration: Appearance.animation.elementMove.duration
                easing.type: Appearance.animation.elementMove.type
                easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
            }
        }
        
        clip: true
        implicitHeight: root.expanded ? 
            contentCol.implicitHeight + padding * 2 :
            Math.min(80, contentCol.implicitHeight + padding * 2)

        Rectangle { // Left accent bar
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: 3
            color: root.urgencyColor
            opacity: root.expanded || root.containsMouse ? 1 : 0.45
        }

        Behavior on implicitHeight {
            id: implicitHeightAnim
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }

        ColumnLayout {
            id: contentCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: root.padding
            anchors.leftMargin: root.padding + 5
            spacing: 0

            // ─── Top bar: ◆ AppName ──────── 12:34 ───
            Item {
                id: topBar
                Layout.fillWidth: true
                implicitHeight: Math.max(topBarRow.implicitHeight, expandBtn.implicitHeight)

                RowLayout {
                    id: topBarRow
                    anchors.left: parent.left
                    anchors.right: expandBtn.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    StyledText {
                        text: root.urgencySymbol
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.family: Appearance.font.family.monospace
                        color: root.urgencyColor
                    }

                    StyledText {
                        id: appNameText
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        text: (root.multipleNotifications ?
                            notificationGroup?.appName :
                            notificationGroup?.notifications[0]?.summary) || ""
                        font.pixelSize: root.multipleNotifications ?
                            Appearance.font.pixelSize.smaller :
                            Appearance.font.pixelSize.small
                        font.family: Appearance.font.family.monospace
                        color: root.multipleNotifications ?
                            Appearance.colors.colSubtext :
                            Appearance.colors.colOnLayer2
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 16
                        Layout.preferredWidth: 1
                        height: 1
                        color: Appearance.tiling.border
                        opacity: 0.5
                    }

                    StyledText {
                        Layout.rightMargin: 4
                        text: NotificationUtils.getFriendlyNotifTimeString(notificationGroup?.time)
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.family: Appearance.font.family.monospace
                        color: Appearance.colors.colSubtext
                    }
                }

                NotificationGroupExpandButton {
                    id: expandBtn
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    count: root.notificationCount
                    expanded: root.expanded
                    fontSize: Appearance.font.pixelSize.smaller
                    onClicked: { root.toggleExpanded() }
                    altAction: () => { root.toggleExpanded() }

                    StyledToolTip {
                        text: Translation.tr("Tip: right-clicking a group\nalso expands it")
                    }
                }
            }

            // ─── Horizontal separator ───
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                height: 1
                color: Appearance.tiling.border
                opacity: 0.3
            }

            // ─── Notification items ───
            StyledListView {
                id: notificationsColumn
                implicitHeight: contentHeight
                Layout.fillWidth: true
                spacing: expanded ? 5 : 3
                interactive: false
                Behavior on spacing {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
                model: ScriptModel {
                    values: root.expanded ? root.notifications.slice().reverse() : 
                        root.notifications.slice().reverse().slice(0, 2)
                }
                delegate: NotificationItem {
                    required property int index
                    required property var modelData
                    notificationObject: modelData
                    expanded: root.expanded
                    onlyNotification: (root.notificationCount === 1)
                    opacity: (!root.expanded && index == 1 && root.notificationCount > 2) ? 0.5 : 1
                    visible: root.expanded || (index < 2)
                    anchors.left: parent?.left
                    anchors.right: parent?.right
                }
            }
        }
    }
}
