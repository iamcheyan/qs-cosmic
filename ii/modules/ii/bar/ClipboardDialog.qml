import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import qs.modules.common.functions
import Quickshell

WindowDialog {
    id: clipboardDialog
    backgroundHeight: itemsPerPage * 23 + 56
    backgroundWidth: 380
    anchorPosition: 1
    anchorMargin: 8

    property int keyboardIndex: 0
    property int currentPage: 0
    property int itemsPerPage: 20
    property real wheelAccum: 0
    property var pageEntries: Cliphist.entries.slice(currentPage * itemsPerPage, currentPage * itemsPerPage + itemsPerPage)
    property int totalPages: Math.max(1, Math.ceil(Cliphist.entries.length / itemsPerPage))

    onCurrentPageChanged: pageEntries = Cliphist.entries.slice(currentPage * itemsPerPage, currentPage * itemsPerPage + itemsPerPage)
    onVisibleChanged: {
        if (visible) {
            currentPage = 0;
            keyboardIndex = 0;
            pageEntries = Cliphist.entries.slice(0, itemsPerPage);
            clipboardDialog.forceActiveFocus();
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
            clipboardDialog.dismiss();
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
            values: clipboardDialog.pageEntries
        }

        delegate: ClipboardItem {
            required property string modelData
            required property int index
            entry: modelData
            width: ListView.view.width
            keySelected: clipboardDialog.keyboardIndex === index
            onItemClicked: clipboardDialog.dismiss()
            onHoveredChanged: {
                if (hovered) {
                    clipboardDialog.keyboardIndex = index;
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: (event) => {
                const r = WheelUtils.getSteps(event.angleDelta.y, clipboardDialog.wheelAccum)
                clipboardDialog.wheelAccum = r.accum
                const steps = r.steps
                if (steps === 0) return
                if (steps > 0) {
                    for (let i = 0; i < steps; i++) {
                        if (clipboardDialog.keyboardIndex > 0) {
                            clipboardDialog.keyboardIndex--;
                        } else {
                            clipboardDialog.prevPage();
                            clipboardDialog.keyboardIndex = Math.min(clipboardDialog.pageEntries.length - 1, clipboardDialog.itemsPerPage - 1);
                        }
                    }
                } else {
                    for (let i = 0; i < -steps; i++) {
                        if (clipboardDialog.keyboardIndex < clipboardDialog.pageEntries.length - 1) {
                            clipboardDialog.keyboardIndex++;
                        } else {
                            clipboardDialog.nextPage();
                            clipboardDialog.keyboardIndex = 0;
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
            onClicked: clipboardDialog.dismiss()
            MaterialSymbol {
                anchors.centerIn: parent
                text: "close"
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.tiling.text
            }
        }

        RippleButton {
            visible: clipboardDialog.totalPages > 1
            implicitHeight: 28
            implicitWidth: 28
            buttonRadius: 14
            colBackgroundHover: Appearance.tiling.bgHover
            colRipple: Appearance.tiling.bgActive
            enabled: clipboardDialog.currentPage > 0
            opacity: enabled ? 1 : 0.3
            onClicked: clipboardDialog.prevPage()
            MaterialSymbol {
                anchors.centerIn: parent
                text: "chevron_left"
                font.pixelSize: Appearance.font.pixelSize.larger
                color: Appearance.tiling.text
            }
        }

        Item { Layout.fillWidth: true }

        StyledText {
            visible: clipboardDialog.totalPages > 1
            text: `${clipboardDialog.currentPage + 1} / ${clipboardDialog.totalPages}`
            color: Appearance.tiling.textDim
            font.pixelSize: Appearance.font.pixelSize.small
        }

        Item { Layout.fillWidth: true }

        RippleButton {
            visible: clipboardDialog.totalPages > 1
            implicitHeight: 28
            implicitWidth: 28
            buttonRadius: 14
            colBackgroundHover: Appearance.tiling.bgHover
            colRipple: Appearance.tiling.bgActive
            enabled: clipboardDialog.currentPage < clipboardDialog.totalPages - 1
            opacity: enabled ? 1 : 0.3
            onClicked: clipboardDialog.nextPage()
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
                clipboardDialog.dismiss();
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
