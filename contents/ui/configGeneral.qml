/**
 * Spatium - GNOME-like virtual desktops switcher for Plasma 6
 * SPDX-FileCopyrightText: 2024 Sakib Reza
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root
    
    property alias cfg_dotSizeCustom: dotSizeSpin.value
    property alias cfg_activeSizeW: activeWidthSpin.value
    property alias cfg_activeSizeH: activeHeightSpin.value
    property alias cfg_desktopWrapOn: wrapCheck.checked
    property alias cfg_middleButtonCommand: middleCommand.text
    property alias cfg_customColorsEnabled: customColorsCheck.checked
    property alias cfg_activeColor: activeColorField.text
    property alias cfg_inactiveColor: inactiveColorField.text
    property alias cfg_animationDuration: animationSpin.value
    property alias cfg_canAddDesktops: addDesktopsCheck.checked
    property alias cfg_spacingFactor: spacingSpin.realValue

    Kirigami.Heading {
        Kirigami.FormData.isSection: true
        text: i18n("Appearance")
    }

    QQC2.SpinBox {
        id: dotSizeSpin
        Kirigami.FormData.label: i18n("Dot Size (px):")
        from: 2; to: 32
    }

    QQC2.SpinBox {
        id: spacingSpin
        Kirigami.FormData.label: i18n("Spacing Factor:")
        from: 5; to: 30; stepSize: 1
        property real realValue: value / 10.0
        textFromValue: (value, locale) => Number(value / 10.0).toLocaleString(locale, 'f', 1)
        valueFromText: (text, locale) => Math.round(Number.fromLocaleString(locale, text) * 10)
    }

    QQC2.SpinBox {
        id: activeWidthSpin
        Kirigami.FormData.label: i18n("Active Width (px):")
        from: 8; to: 64
    }

    QQC2.SpinBox {
        id: activeHeightSpin
        Kirigami.FormData.label: i18n("Active Height (px):")
        from: 2; to: 64
    }

    Kirigami.Heading {
        Kirigami.FormData.isSection: true
        text: i18n("Colors")
    }

    QQC2.CheckBox {
        id: customColorsCheck
        Kirigami.FormData.label: i18n("Custom Colors:")
        text: i18n("Use custom hex colors")
    }

    QQC2.TextField {
        id: activeColorField
        Kirigami.FormData.label: i18n("Active Color (Hex):")
        placeholderText: "#3daee9"
        visible: customColorsCheck.checked
        Layout.fillWidth: true
    }

    QQC2.TextField {
        id: inactiveColorField
        Kirigami.FormData.label: i18n("Inactive Color (Hex):")
        placeholderText: "#ffffff"
        visible: customColorsCheck.checked
        Layout.fillWidth: true
    }

    Kirigami.Heading {
        Kirigami.FormData.isSection: true
        text: i18n("Behavior")
    }

    QQC2.CheckBox {
        id: wrapCheck
        Kirigami.FormData.label: i18n("Scrolling:")
        text: i18n("Wrap around desktops")
    }

    QQC2.SpinBox {
        id: animationSpin
        Kirigami.FormData.label: i18n("Animation (ms):")
        from: 0; to: 1000; stepSize: 50
    }

    QQC2.TextField {
        id: middleCommand
        Kirigami.FormData.label: i18n("Middle Click Command:")
        placeholderText: "e.g. krunner"
        Layout.fillWidth: true
    }

    QQC2.CheckBox {
        id: addDesktopsCheck
        Kirigami.FormData.label: i18n("Desktop Management:")
        text: i18n("Allow adding/removing via context menu")
    }
}