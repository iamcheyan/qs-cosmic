import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

WindowDialog {
    id: root
    backgroundHeight: 480
    backgroundWidth: 360
    anchorPosition: 1

    onVisibleChanged: {
        if (visible) {
            root.forceActiveFocus();
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 16
        spacing: 16

        // Battery icon and percentage
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                text: Battery.isCharging ? "bolt" : (Battery.percentage > 0.9 ? "battery_full" : Battery.percentage > 0.6 ? "battery_5_bar" : Battery.percentage > 0.4 ? "battery_4_bar" : Battery.percentage > 0.2 ? "battery_2_bar" : "battery_1_bar")
                iconSize: 48
                color: (Battery.isLow && !Battery.isCharging) ? Appearance.tiling.error : Appearance.tiling.text
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: `${Math.round(Battery.percentage * 100)}%`
                font.pixelSize: Appearance.font.pixelSize.larger * 1.5
                font.weight: Font.DemiBold
                color: Appearance.tiling.text
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                visible: Battery.available
                text: Battery.isCharging ? Translation.tr("Charging") : (Battery.isPluggedIn ? Translation.tr("Plugged in") : Translation.tr("On battery"))
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.tiling.textDim
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Appearance.tiling.border
        }

        // Battery details
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            // Time info
            RowLayout {
                Layout.fillWidth: true
                visible: {
                    let timeValue = Battery.isCharging ? Battery.timeToFull : Battery.timeToEmpty;
                    let power = Battery.energyRate;
                    return Battery.available && !(Battery.chargeState == 4 || timeValue <= 0 || power <= 0.01);
                }

                MaterialSymbol {
                    text: "schedule"
                    iconSize: Appearance.font.pixelSize.larger
                    color: Appearance.tiling.textDim
                }

                StyledText {
                    text: Battery.isCharging ? Translation.tr("Time to full:") : Translation.tr("Time to empty:")
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.tiling.textDim
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: {
                        function formatTime(seconds) {
                            var h = Math.floor(seconds / 3600);
                            var m = Math.floor((seconds % 3600) / 60);
                            if (h > 0)
                                return `${h}h ${m}m`;
                            else
                                return `${m}m`;
                        }
                        if (Battery.isCharging)
                            return formatTime(Battery.timeToFull);
                        else
                            return formatTime(Battery.timeToEmpty);
                    }
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.DemiBold
                    color: Appearance.tiling.text
                }
            }

            // Power consumption
            RowLayout {
                Layout.fillWidth: true
                visible: Battery.available && Battery.chargeState != 4 && Battery.energyRate > 0.01

                MaterialSymbol {
                    text: "flash_on"
                    iconSize: Appearance.font.pixelSize.larger
                    color: Appearance.tiling.textDim
                }

                StyledText {
                    text: Translation.tr("Power:")
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.tiling.textDim
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: `${Battery.energyRate.toFixed(1)}W`
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.DemiBold
                    color: Appearance.tiling.text
                }
            }

            // Health
            RowLayout {
                Layout.fillWidth: true
                visible: Battery.available && Battery.health > 0

                MaterialSymbol {
                    text: "favorite"
                    iconSize: Appearance.font.pixelSize.larger
                    color: Appearance.tiling.textDim
                }

                StyledText {
                    text: Translation.tr("Health:")
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.tiling.textDim
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: `${Battery.health.toFixed(1)}%`
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.DemiBold
                    color: Appearance.tiling.text
                }
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Appearance.tiling.border
        }

        // Power Profile section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            StyledText {
                text: Translation.tr("Power Profile")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: Appearance.tiling.text
            }

            // Profile buttons
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                // Power Saver
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    radius: Appearance.tiling.dialogRadius
                    color: PowerProfiles.profile === PowerProfile.PowerSaver ? Appearance.tiling.accent : (powerSaverMouse.containsMouse ? Appearance.tiling.bgHover : Appearance.tiling.bg)
                    border.width: Appearance.tiling.borderWidth
                    border.color: PowerProfiles.profile === PowerProfile.PowerSaver ? Appearance.tiling.borderFocus : Appearance.tiling.border

                    MouseArea {
                        id: powerSaverMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PowerProfiles.profile = PowerProfile.PowerSaver
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        MaterialSymbol {
                            text: "energy_savings_leaf"
                            iconSize: Appearance.font.pixelSize.larger
                            color: PowerProfiles.profile === PowerProfile.PowerSaver ? Appearance.tiling.textBright : Appearance.tiling.text
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            StyledText {
                                text: Translation.tr("Power Saver")
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.DemiBold
                                color: PowerProfiles.profile === PowerProfile.PowerSaver ? Appearance.tiling.textBright : Appearance.tiling.text
                            }

                            StyledText {
                                text: Translation.tr("Maximize battery life")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: PowerProfiles.profile === PowerProfile.PowerSaver ? Appearance.tiling.textBright : Appearance.tiling.textDim
                            }
                        }

                        MaterialSymbol {
                            visible: PowerProfiles.profile === PowerProfile.PowerSaver
                            text: "check"
                            iconSize: Appearance.font.pixelSize.larger
                            color: Appearance.tiling.textBright
                        }
                    }
                }

                // Balanced
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    radius: Appearance.tiling.dialogRadius
                    color: PowerProfiles.profile === PowerProfile.Balanced ? Appearance.tiling.accent : (balancedMouse.containsMouse ? Appearance.tiling.bgHover : Appearance.tiling.bg)
                    border.width: Appearance.tiling.borderWidth
                    border.color: PowerProfiles.profile === PowerProfile.Balanced ? Appearance.tiling.borderFocus : Appearance.tiling.border

                    MouseArea {
                        id: balancedMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PowerProfiles.profile = PowerProfile.Balanced
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        MaterialSymbol {
                            text: "airwave"
                            iconSize: Appearance.font.pixelSize.larger
                            color: PowerProfiles.profile === PowerProfile.Balanced ? Appearance.tiling.textBright : Appearance.tiling.text
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            StyledText {
                                text: Translation.tr("Balanced")
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.DemiBold
                                color: PowerProfiles.profile === PowerProfile.Balanced ? Appearance.tiling.textBright : Appearance.tiling.text
                            }

                            StyledText {
                                text: Translation.tr("Balance performance and battery")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: PowerProfiles.profile === PowerProfile.Balanced ? Appearance.tiling.textBright : Appearance.tiling.textDim
                            }
                        }

                        MaterialSymbol {
                            visible: PowerProfiles.profile === PowerProfile.Balanced
                            text: "check"
                            iconSize: Appearance.font.pixelSize.larger
                            color: Appearance.tiling.textBright
                        }
                    }
                }

                // Performance
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    radius: Appearance.tiling.dialogRadius
                    visible: PowerProfiles.hasPerformanceProfile
                    color: PowerProfiles.profile === PowerProfile.Performance ? Appearance.tiling.accent : (performanceMouse.containsMouse ? Appearance.tiling.bgHover : Appearance.tiling.bg)
                    border.width: Appearance.tiling.borderWidth
                    border.color: PowerProfiles.profile === PowerProfile.Performance ? Appearance.tiling.borderFocus : Appearance.tiling.border

                    MouseArea {
                        id: performanceMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PowerProfiles.profile = PowerProfile.Performance
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        MaterialSymbol {
                            text: "local_fire_department"
                            iconSize: Appearance.font.pixelSize.larger
                            color: PowerProfiles.profile === PowerProfile.Performance ? Appearance.tiling.textBright : Appearance.tiling.text
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            StyledText {
                                text: Translation.tr("Performance")
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.DemiBold
                                color: PowerProfiles.profile === PowerProfile.Performance ? Appearance.tiling.textBright : Appearance.tiling.text
                            }

                            StyledText {
                                text: Translation.tr("Prioritize performance")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: PowerProfiles.profile === PowerProfile.Performance ? Appearance.tiling.textBright : Appearance.tiling.textDim
                            }
                        }

                        MaterialSymbol {
                            visible: PowerProfiles.profile === PowerProfile.Performance
                            text: "check"
                            iconSize: Appearance.font.pixelSize.larger
                            color: Appearance.tiling.textBright
                        }
                    }
                }
            }
        }
    }
}
