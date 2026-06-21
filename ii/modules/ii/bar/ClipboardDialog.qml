import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import qs.modules.common.functions
import Quickshell

WindowDialog {
    id: root
    backgroundHeight: itemsPerPage * 23 + 56
    backgroundWidth: 380
    anchorPosition: 1
    anchorMargin: 8

    property int keyboardIndex: 0
    property int currentPage: 0
    property int itemsPerPage: 20
    property var pageEntries: Cliphist.entries.slice(currentPage * itemsPerPage, currentPage * itemsPerPage + itemsPerPage)
    property int totalPages: Math.max(1, Math.ceil(Cliphist.entries.length / itemsPerPage))

    onCurrentPageChanged: pageEntries = Cliphist.entries.slice(currentPage * itemsPerPage, currentPage * itemsPerPage + itemsPerPage)
    onVisibleChanged: {
        if (visible) {
            currentPage = 0;
            keyboardIndex = 0;
            pageEntries = Cliphist.entries.slice(0, itemsPerPage);
            root.forceActiveFocus();
            Cliphist.refresh();
        }
    }

    Connections {
        target: Cliphist
        function onEntriesChanged() {
            pageEntries = Cliphist.entries.slice(currentPage * itemsPerPage, currentPage * itemsPerPage + itemsPerPage);
        }
    }

    function nextPage() {
        if (currentPage < totalPages - 1) {
            currentPage++;
            keyboardIndex = 0;
        }
    }

    function prevPage() {
        if (currentPage > 0) {
            currentPage--;
            keyboardIndex = 0;
        }
    }

    function copySelected() {
        const absIndex = currentPage * itemsPerPage + keyboardIndex;
        if (absIndex >= 0 && absIndex < Cliphist.entries.length) {
            Cliphist.copy(Cliphist.entries[absIndex]);
            root.dismiss();
        }
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Down) {
            event.accepted = true;
            if (pageEntries.length === 0) return;
            keyboardIndex = Math.min(keyboardIndex + 1, pageEntries.length - 1);
        } else if (event.key === Qt.Key_Up) {
            event.accepted = true;
            keyboardIndex = Math.max(keyboardIndex - 1, 0);
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            event.accepted = true;
            copySelected();
        } else if (event.key === Qt.Key_PageDown || event.key === Qt.Key_Right) {
            event.accepted = true;
            nextPage();
        } else if (event.key === Qt.Key_PageUp || event.key === Qt.Key_Left) {
            event.accepted = true;
            prevPage();
        }
    }

    ListView {
        id: clipboardList
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: 2
        Layout.bottomMargin: 2
        Layout.leftMargin: 0
        Layout.rightMargin: 0

        clip: true
        spacing: 0
        boundsBehavior: Flickable.StopAtBounds
        boundsMovement: Flickable.StopAtBounds
        highlightMoveDuration: 0
        interactive: false

        model: ScriptModel {
            values: root.pageEntries
        }

        delegate: ClipboardItem {
            required property string modelData
            required property int index
            entry: modelData
            width: ListView.view.width
            keySelected: root.keyboardIndex === index
            onItemClicked: root.dismiss()
            onHoveredChanged: {
                if (hovered) {
                    root.keyboardIndex = index;
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: (event) => {
                const steps = WheelUtils.getSteps(event.angleDelta.y)
                if (steps === 0) return
                if (steps > 0) {
                    for (let i = 0; i < steps; i++) {
                        if (root.keyboardIndex > 0) {
                            root.keyboardIndex--;
                        } else {
                            root.prevPage();
                            root.keyboardIndex = Math.min(root.pageEntries.length - 1, root.itemsPerPage - 1);
                        }
                    }
                } else {
                    for (let i = 0; i < -steps; i++) {
                        if (root.keyboardIndex < root.pageEntries.length - 1) {
                            root.keyboardIndex++;
                        } else {
                            root.nextPage();
                            root.keyboardIndex = 0;
                        }
                    }
                }
                event.accepted = true;
            }
        }
    }

    WindowDialogSeparator {}

    RowLayout {
        Layout.leftMargin: 8
        Layout.rightMargin: 8
        Layout.topMargin: 4
        Layout.bottomMargin: 4
        spacing: 6

        RippleButton {
            implicitHeight: 28
            implicitWidth: 28
            buttonRadius: 14
            colBackgroundHover: Appearance.tiling.bgHover
            colRipple: Appearance.tiling.bgActive
            onClicked: root.dismiss()
            MaterialSymbol {
                anchors.centerIn: parent
                text: "close"
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.tiling.text
            }
        }

        RippleButton {
            visible: root.totalPages > 1
            implicitHeight: 28
            implicitWidth: 28
            buttonRadius: 14
            colBackgroundHover: Appearance.tiling.bgHover
            colRipple: Appearance.tiling.bgActive
            enabled: root.currentPage > 0
            opacity: enabled ? 1 : 0.3
            onClicked: root.prevPage()
            MaterialSymbol {
                anchors.centerIn: parent
                text: "chevron_left"
                font.pixelSize: Appearance.font.pixelSize.larger
                color: Appearance.tiling.text
            }
        }

        Item { Layout.fillWidth: true }

        StyledText {
            visible: root.totalPages > 1
            text: `${root.currentPage + 1} / ${root.totalPages}`
            color: Appearance.tiling.textDim
            font.pixelSize: Appearance.font.pixelSize.small
        }

        Item { Layout.fillWidth: true }

        RippleButton {
            visible: root.totalPages > 1
            implicitHeight: 28
            implicitWidth: 28
            buttonRadius: 14
            colBackgroundHover: Appearance.tiling.bgHover
            colRipple: Appearance.tiling.bgActive
            enabled: root.currentPage < root.totalPages - 1
            opacity: enabled ? 1 : 0.3
            onClicked: root.nextPage()
            MaterialSymbol {
                anchors.centerIn: parent
                text: "chevron_right"
                font.pixelSize: Appearance.font.pixelSize.larger
                color: Appearance.tiling.text
            }
        }

        RippleButton {
            implicitHeight: 28
            implicitWidth: 28
            buttonRadius: 14
            colBackgroundHover: Appearance.tiling.bgHover
            colRipple: Appearance.tiling.bgActive
            onClicked: {
                Cliphist.wipe();
                root.dismiss();
            }
            MaterialSymbol {
                anchors.centerIn: parent
                text: "delete_sweep"
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.tiling.error
            }
        }
    }
}
