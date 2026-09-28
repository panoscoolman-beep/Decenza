pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Templates as T
import Decenza

// Full-screen dose / yield editor opened from the recipe gallery: one big number, big −/+ and
// one-tap ratio or dose presets. Done arms the same session overrides Brew Settings' OK does
// (ProfileManager.activateBrewWithOverrides), keeping the current temperature and grind, so the
// two editors never disagree about what the next shot pours.
T.Popup {
    id: root

    property color accentColor: Theme.primaryColor
    property string recipeName: ""

    // "in" edits the dose, "out" the stop-at weight.
    property string field: "out"
    property double doseValue: 18
    property double yieldValue: 36
    // "absolute" while the yield was set in grams, "ratio" once a ratio preset was tapped — the
    // spec activateBrewWithOverrides takes, so a later dose change keeps the picked ratio.
    property string yieldMode: "absolute"
    property double yieldRatio: 2

    readonly property var ratioPresets: [2, 2.5, 3, 5]
    readonly property var dosePresets: [15, 18, 20, 22]

    function openFor(which: string) {
        field = which
        doseValue = Settings.dye.dyeBeanWeight > 0 ? Settings.dye.dyeBeanWeight : 18
        yieldValue = ProfileManager.targetWeight > 0 ? ProfileManager.targetWeight : doseValue * 2
        yieldMode = ProfileManager.brewByRatioActive ? "ratio" : "absolute"
        yieldRatio = ProfileManager.brewByRatioActive ? ProfileManager.brewByRatio
                                                      : (doseValue > 0 ? yieldValue / doseValue : 2)
        open()
    }

    function round1(v: double): double { return Math.round(v * 10) / 10 }

    function setDose(v: double) {
        doseValue = round1(Math.max(5, Math.min(30, v)))
        if (yieldMode === "ratio")
            yieldValue = round1(doseValue * yieldRatio)
    }

    function setYield(v: double) {
        yieldMode = "absolute"
        yieldValue = round1(Math.max(10, Math.min(200, v)))
    }

    function pickRatio(r: double) {
        yieldMode = "ratio"
        yieldRatio = r
        yieldValue = round1(doseValue * r)
    }

    function step(direction: int) {
        if (field === "in")
            setDose(doseValue + direction * 0.5)
        else
            setYield(yieldValue + direction)
    }

    function apply() {
        var temperature = Settings.brew.hasTemperatureOverride ? Settings.brew.temperatureOverride
                                                               : ProfileManager.profileTargetTemperature
        ProfileManager.activateBrewWithOverrides(
            doseValue,
            yieldMode === "ratio" ? yieldRatio : yieldValue,
            yieldMode,
            temperature,
            Settings.dye.dyeGrinderSetting)
        close()
    }

    readonly property string ratioText: "1:" + (doseValue > 0 ? round1(yieldValue / doseValue) : 0)

    parent: Overlay.overlay
    x: 0
    y: 0
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    modal: true
    focus: true
    closePolicy: T.Popup.CloseOnEscape

    onOpened: {
        if (typeof AccessibilityManager !== "undefined" && AccessibilityManager !== null && AccessibilityManager.enabled)
            AccessibilityManager.announce(fieldLabel.text + " " + valueText.text)
    }

    background: Rectangle { color: Theme.backgroundColor }

    contentItem: ColumnLayout {
        spacing: 0

        // Header: back, recipe, In/Out switch
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.scaled(72)
            Layout.leftMargin: Theme.standardMargin
            Layout.rightMargin: Theme.standardMargin
            spacing: Theme.spacingMedium

            StyledIconButton {
                icon.source: "qrc:/icons/back.svg"
                accessibleName: TranslationManager.translate("gramsEditor.cancel", "Close without changing")
                onClicked: root.close()
            }

            Rectangle {
                Layout.preferredWidth: Theme.scaled(14)
                Layout.preferredHeight: Theme.scaled(14)
                radius: Theme.scaled(5)
                color: root.accentColor
                Accessible.ignored: true
            }

            Text {
                Layout.fillWidth: true
                text: root.recipeName
                font: Theme.subtitleFont
                color: Theme.textColor
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.preferredHeight: Theme.touchTargetMin + Theme.scaled(8)
                Layout.preferredWidth: fieldRow.implicitWidth + Theme.scaled(8)
                radius: Theme.cardRadius
                color: Theme.surfaceColor

                Row {
                    id: fieldRow
                    anchors.centerIn: parent
                    spacing: Theme.scaled(4)

                    Repeater {
                        model: [
                            { key: "in", label: TranslationManager.translate("gramsEditor.doseIn", "Dose in") },
                            { key: "out", label: TranslationManager.translate("gramsEditor.yieldOut", "Yield out") }
                        ]

                        AccessibleButton {
                            id: fieldButton
                            required property var modelData
                            readonly property bool selected: root.field === modelData.key
                            height: Theme.touchTargetMin
                            leftPadding: Theme.spacingMedium
                            rightPadding: Theme.spacingMedium
                            text: modelData.label
                            accessibleName: modelData.label
                            checkable: true
                            checked: selected
                            onClicked: root.field = modelData.key
                            background: Rectangle {
                                radius: Theme.buttonRadius
                                color: fieldButton.selected ? Theme.textColor : "transparent"
                            }
                            contentItem: Text {
                                text: fieldButton.text
                                font.family: Theme.bodyFont.family
                                font.pixelSize: Theme.bodyFont.pixelSize
                                font.bold: true
                                color: fieldButton.selected ? Theme.backgroundColor : Theme.textSecondaryColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }

        // Big value with −/+
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.scaled(40)

            Item { Layout.fillWidth: true }

            AccessibleButton {
                id: minusButton
                Layout.preferredWidth: Theme.scaled(112)
                Layout.preferredHeight: Theme.scaled(112)
                accessibleName: root.field === "in"
                    ? TranslationManager.translate("gramsEditor.lessDose", "Less coffee, 0.5 grams")
                    : TranslationManager.translate("gramsEditor.lessYield", "Less yield, 1 gram")
                autoRepeat: true
                onClicked: root.step(-1)
                background: Rectangle {
                    radius: width / 2
                    color: minusButton.down ? Qt.darker(Theme.surfaceColor, 1.3) : Theme.surfaceColor
                }
                contentItem: Text {
                    text: "−"
                    font.family: Theme.valueFont.family
                    font.pixelSize: Theme.scaled(48)
                    color: Theme.textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ColumnLayout {
                Layout.preferredWidth: Theme.scaled(360)
                spacing: Theme.scaled(4)

                Text {
                    id: fieldLabel
                    Layout.alignment: Qt.AlignHCenter
                    text: root.field === "in"
                        ? TranslationManager.translate("gramsEditor.dose", "Dose")
                        : TranslationManager.translate("gramsEditor.stopAt", "Stop at")
                    font: Theme.bodyFont
                    color: Theme.textSecondaryColor
                }
                Text {
                    id: valueText
                    Layout.alignment: Qt.AlignHCenter
                    text: (root.field === "in" ? root.doseValue : root.yieldValue).toFixed(1) + " g"
                    font.family: Theme.valueFont.family
                    font.pixelSize: Theme.scaled(110)
                    font.bold: true
                    color: Theme.textColor
                    Accessible.role: Accessible.StaticText
                    Accessible.name: text
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.doseValue.toFixed(1) + " g → " + root.yieldValue.toFixed(1) + " g  ·  " + root.ratioText
                    font: Theme.bodyFont
                    color: Theme.textSecondaryColor
                }
            }

            AccessibleButton {
                id: plusButton
                Layout.preferredWidth: Theme.scaled(112)
                Layout.preferredHeight: Theme.scaled(112)
                accessibleName: root.field === "in"
                    ? TranslationManager.translate("gramsEditor.moreDose", "More coffee, 0.5 grams")
                    : TranslationManager.translate("gramsEditor.moreYield", "More yield, 1 gram")
                autoRepeat: true
                onClicked: root.step(1)
                background: Rectangle {
                    radius: width / 2
                    color: plusButton.down ? Qt.darker(root.accentColor, 1.2) : root.accentColor
                }
                contentItem: Text {
                    text: "+"
                    font.family: Theme.valueFont.family
                    font.pixelSize: Theme.scaled(48)
                    color: Theme.recipeArtOnBaseColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Item { Layout.fillWidth: true }
        }

        // Presets + Done
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.standardMargin
            Layout.rightMargin: Theme.standardMargin
            Layout.bottomMargin: Theme.standardMargin
            spacing: Theme.spacingSmall

            Text {
                text: TranslationManager.translate("gramsEditor.quick", "Quick")
                font: Theme.labelFont
                color: Theme.textSecondaryColor
            }

            Repeater {
                model: root.field === "in" ? root.dosePresets : root.ratioPresets

                AccessibleButton {
                    id: presetButton
                    required property var modelData
                    readonly property bool selected: root.field === "in"
                        ? Math.abs(root.doseValue - modelData) < 0.05
                        : (root.yieldMode === "ratio" && Math.abs(root.yieldRatio - modelData) < 0.001)
                    Layout.preferredHeight: Theme.touchTargetLarge
                    Layout.preferredWidth: Theme.scaled(80)
                    text: root.field === "in" ? modelData + " g" : "1:" + modelData
                    accessibleName: root.field === "in"
                        ? TranslationManager.translate("gramsEditor.presetDose", "Dose %1 grams").arg(modelData)
                        : TranslationManager.translate("gramsEditor.presetRatio", "Ratio one to %1").arg(modelData)
                    onClicked: root.field === "in" ? root.setDose(modelData) : root.pickRatio(modelData)
                    background: Rectangle {
                        radius: Theme.cardRadius
                        color: presetButton.selected ? root.accentColor : Theme.surfaceColor
                        border.width: presetButton.selected ? 0 : 1
                        border.color: Theme.borderColor
                    }
                    contentItem: Text {
                        text: presetButton.text
                        font.family: Theme.bodyFont.family
                        font.pixelSize: Theme.bodyFont.pixelSize
                        font.bold: true
                        color: presetButton.selected ? Theme.recipeArtOnBaseColor : Theme.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Item { Layout.fillWidth: true }

            AccessibleButton {
                id: doneButton
                Layout.preferredHeight: Theme.scaled(64)
                Layout.preferredWidth: Theme.scaled(160)
                text: TranslationManager.translate("gramsEditor.done", "Done")
                accessibleName: TranslationManager.translate("gramsEditor.doneAccessible", "Use these grams for the next shot")
                onClicked: root.apply()
                background: Rectangle {
                    radius: Theme.cardRadius
                    color: doneButton.down ? Qt.darker(Theme.textColor, 1.2) : Theme.textColor
                }
                contentItem: Text {
                    text: doneButton.text
                    font.family: Theme.subtitleFont.family
                    font.pixelSize: Theme.subtitleFont.pixelSize
                    font.bold: true
                    color: Theme.backgroundColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
