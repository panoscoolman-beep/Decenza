pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Decenza

// Recipe gallery home (the "recipeGallery" layout widget in centerMiddle switches IdlePage to
// it): every recipe as a coloured tile with generated cover art, and beside it the selected
// recipe's profile curve, dose/yield controls and the brew action. Selecting and starting go
// through the same MainController path as the Recipes pill (activateRecipe, then
// startSelectedRecipeShotWhenApplied), so the gallery never has its own idea of what is armed.
Item {
    id: root

    // Same gate as IdlePage.canStartOperations: with an active GHC the machine's own button
    // starts the shot and on-screen starts are refused.
    readonly property bool canStartOperations: DE1Device.isHeadless || DE1Device.simulationMode

    property var recipes: []
    readonly property var selectedRecipe: {
        for (var i = 0; i < recipes.length; ++i)
            if (recipes[i].id === MainController.selectedRecipeId)
                return recipes[i]
        return null
    }

    // The selected recipe's profile, read once per selection (a discrete user action).
    property var selectedProfile: null
    function refreshSelectedProfile() {
        if (!selectedRecipe || !selectedRecipe.profileTitle) {
            selectedProfile = null
            return
        }
        var filename = ProfileManager.findProfileByTitle(selectedRecipe.profileTitle)
        selectedProfile = filename ? ProfileManager.getProfileByFilename(filename) : null
    }
    onSelectedRecipeChanged: refreshSelectedProfile()

    readonly property var selectedArt: selectedRecipe
        ? Theme.recipeArtPalette[panelArt.motif] : Theme.recipeArtPalette.cup

    function yieldLabel(recipe: var): string {
        var dose = recipe.doseG || 0
        var y = 0
        if (recipe.yieldMode === "ratio")
            y = dose * (recipe.yieldValue || 0)
        else if (recipe.yieldMode === "absolute")
            y = recipe.yieldValue || 0
        if (dose > 0 && y > 0)
            return dose.toFixed(0) + " → " + y.toFixed(0) + " g"
        return dose > 0 ? dose.toFixed(0) + " g" : ""
    }

    function selectRecipe(recipe: var) {
        if (recipe.id !== MainController.selectedRecipeId)
            MainController.activateRecipe(recipe.id)
    }

    function tryStart() {
        if (!root.selectedRecipe || !root.canStartOperations)
            return
        if (!MachineState.isReady) {
            WebDebugLogger.warn("Recipes", "RecipeGallery", ["start blocked: machine not ready — recipe=" + root.selectedRecipe.id
                        + " phase=" + MachineState.phase].map(String).join(" "))
            if (typeof AccessibilityManager !== "undefined" && AccessibilityManager !== null && AccessibilityManager.enabled)
                AccessibilityManager.announce(TranslationManager.translate("machine.notReady", "Machine is not ready"))
            return
        }
        WebDebugLogger.info("Recipes", "RecipeGallery", ["requesting start — recipe=" + root.selectedRecipe.id].map(String).join(" "))
        MainController.startSelectedRecipeShotWhenApplied()
    }

    // Quick yield/dose tweaks arm the same session overrides as Brew Settings OK.
    readonly property double currentDose: Settings.dye.dyeBeanWeight > 0 ? Settings.dye.dyeBeanWeight : 18
    readonly property double currentYield: ProfileManager.targetWeight
    function applyOverrides(dose: double, value: double, mode: string) {
        var temperature = Settings.brew.hasTemperatureOverride ? Settings.brew.temperatureOverride
                                                               : ProfileManager.profileTargetTemperature
        ProfileManager.activateBrewWithOverrides(dose, value, mode, temperature, Settings.dye.dyeGrinderSetting)
    }

    Component.onCompleted: MainController.recipeStorage.requestInventory()

    Connections {
        target: MainController.recipeStorage
        function onInventoryReady(recipes) { root.recipes = recipes }
        function onRecipesChanged() { MainController.recipeStorage.requestInventory() }
    }

    GramsEditorPopup {
        id: gramsEditor
        accentColor: root.selectedArt.base
        recipeName: root.selectedRecipe ? root.selectedRecipe.name : ""
    }

    RowLayout {
        anchors.fill: parent
        spacing: Theme.spacingMedium

        // ---------------- Tiles ----------------
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacingSmall

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSmall

                Text {
                    Layout.fillWidth: true
                    text: TranslationManager.translate("recipeGallery.title", "Recipes")
                    font: Theme.subtitleFont
                    color: Theme.textColor
                    Accessible.role: Accessible.Heading
                    Accessible.name: text
                }

                AccessibleButton {
                    id: allProfilesButton
                    Layout.preferredHeight: Theme.touchTargetMin
                    leftPadding: Theme.spacingMedium
                    rightPadding: Theme.spacingMedium
                    text: TranslationManager.translate("recipeGallery.allProfiles", "All profiles")
                    accessibleName: TranslationManager.translate("recipeGallery.allProfilesAccessible", "Browse all profiles")
                    icon.source: "qrc:/icons/search.svg"
                    subtle: true
                    onClicked: AppShell.profileSelectorRequested()
                }

                AccessibleButton {
                    Layout.preferredHeight: Theme.touchTargetMin
                    leftPadding: Theme.spacingMedium
                    rightPadding: Theme.spacingMedium
                    text: TranslationManager.translate("recipeGallery.manage", "Manage")
                    accessibleName: TranslationManager.translate("recipeGallery.manageAccessible", "Manage recipes")
                    subtle: true
                    onClicked: AppShell.recipesRequested()
                }
            }

            Flickable {
                id: tileFlick
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: width
                contentHeight: tileGrid.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                visible: root.recipes.length > 0

                GridLayout {
                    id: tileGrid
                    width: parent.width
                    columns: 4
                    columnSpacing: Theme.spacingSmall
                    rowSpacing: Theme.spacingSmall

                    Repeater {
                        model: root.recipes

                        Rectangle {
                            id: tile
                            required property var modelData
                            readonly property bool selected: modelData.id === MainController.selectedRecipeId

                            Layout.fillWidth: true
                            // Two rows fit without scrolling; more recipes scroll.
                            Layout.preferredHeight: Math.max(Theme.scaled(150),
                                                             (tileFlick.height - tileGrid.rowSpacing) / 2)
                            radius: Theme.cardRadius
                            color: tileArt.baseColor
                            border.width: tile.selected ? Theme.scaled(3) : 0
                            border.color: Theme.textColor
                            clip: true

                            RecipeArt {
                                id: tileArt
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: tileLabel.top
                                anchors.margins: Theme.scaled(10)
                                profileTitle: tile.modelData.profileTitle || ""
                                recipeName: tile.modelData.name || ""
                                drinkType: tile.modelData.drinkType || ""
                            }

                            Rectangle {
                                id: tileLabel
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.margins: tile.border.width
                                height: tileLabelColumn.implicitHeight + Theme.scaled(16)
                                color: Theme.recipeArtLabelBandColor
                                bottomLeftRadius: tile.radius - tile.border.width
                                bottomRightRadius: tile.radius - tile.border.width

                                Column {
                                    id: tileLabelColumn
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: Theme.scaled(10)
                                    anchors.rightMargin: Theme.scaled(10)
                                    spacing: Theme.scaled(2)

                                    Text {
                                        width: parent.width
                                        text: tile.modelData.name || ""
                                        font.family: Theme.labelFont.family
                                        font.pixelSize: Theme.scaled(15)
                                        font.bold: true
                                        lineHeight: 0.9
                                        color: Theme.recipeArtLabelColor
                                        elide: Text.ElideRight
                                        maximumLineCount: 2
                                        wrapMode: Text.Wrap
                                    }
                                    Text {
                                        width: parent.width
                                        text: root.yieldLabel(tile.modelData)
                                        visible: text.length > 0
                                        font: Theme.captionFont
                                        color: Theme.recipeArtLabelSecondaryColor
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            AccessibleMouseArea {
                                anchors.fill: parent
                                accessibleName: (tile.modelData.name || "") + (tile.selected
                                    ? ", " + TranslationManager.translate("recipeGallery.selected", "selected") : "")
                                accessibleChecked: tile.selected
                                supportLongPress: true
                                onAccessibleClicked: root.selectRecipe(tile.modelData)
                                onAccessibleLongPressed: AppShell.recipeWizardRequested("edit", { editRecipeId: tile.modelData.id })
                            }
                        }
                    }
                }
            }

            // Empty state
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: root.recipes.length === 0
                spacing: Theme.spacingMedium

                Item { Layout.fillHeight: true }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: TranslationManager.translate("recipeGallery.empty", "No recipes yet")
                    font: Theme.subtitleFont
                    color: Theme.textSecondaryColor
                }
                AccessibleButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: TranslationManager.translate("recipeGallery.create", "Create a recipe")
                    accessibleName: text
                    primary: true
                    onClicked: AppShell.recipeWizardRequested("create", {})
                }
                Item { Layout.fillHeight: true }
            }
        }

        // ---------------- Selected recipe panel ----------------
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: Math.min(Theme.scaled(380), root.width * 0.4)
            radius: Theme.cardRadius * 1.5
            color: Theme.surfaceColor

            // Nothing selected yet
            Text {
                anchors.centerIn: parent
                width: parent.width - Theme.scaled(40)
                visible: !root.selectedRecipe
                text: TranslationManager.translate("recipeGallery.pickOne", "Tap a recipe to get it ready")
                font: Theme.bodyFont
                color: Theme.textSecondaryColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingMedium
                spacing: Theme.spacingSmall
                visible: root.selectedRecipe !== null

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSmall

                    Rectangle {
                        Layout.preferredWidth: Theme.scaled(48)
                        Layout.preferredHeight: Theme.scaled(48)
                        radius: Theme.buttonRadius
                        color: root.selectedArt.base
                        RecipeArt {
                            id: panelArt
                            anchors.fill: parent
                            anchors.margins: Theme.scaled(4)
                            profileTitle: root.selectedRecipe ? (root.selectedRecipe.profileTitle || "") : ""
                            recipeName: root.selectedRecipe ? (root.selectedRecipe.name || "") : ""
                            drinkType: root.selectedRecipe ? (root.selectedRecipe.drinkType || "") : ""
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text {
                            Layout.fillWidth: true
                            text: root.selectedRecipe ? root.selectedRecipe.name : ""
                            font: Theme.subtitleFont
                            color: Theme.textColor
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: {
                                if (!root.selectedRecipe) return ""
                                var parts = [root.selectedRecipe.profileTitle || ""]
                                if (root.selectedProfile && root.selectedProfile.espresso_temperature)
                                    parts.push((root.selectedProfile.espresso_temperature
                                                + (root.selectedRecipe.tempOffsetC || 0)).toFixed(1) + "°C")
                                return parts.filter(function(p) { return p.length > 0 }).join(" · ")
                            }
                            font: Theme.captionFont
                            color: Theme.textSecondaryColor
                            elide: Text.ElideRight
                        }
                    }
                }

                // The recipe profile's own target curves (pressure / flow / temperature).
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: Theme.scaled(90)
                    radius: Theme.cardRadius
                    color: Theme.backgroundColor

                    ProfileGraph {
                        anchors.fill: parent
                        anchors.margins: Theme.scaled(4)
                        frames: root.selectedProfile && root.selectedProfile.steps ? root.selectedProfile.steps : []
                        selectedFrameIndex: -1
                        targetWeight: root.selectedProfile ? (root.selectedProfile.target_weight || 0) : 0
                        targetVolume: root.selectedProfile ? (root.selectedProfile.target_volume || 0) : 0
                    }
                }

                // Dose / yield
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSmall

                    Repeater {
                        model: [
                            { key: "in", label: TranslationManager.translate("recipeGallery.in", "In") },
                            { key: "out", label: TranslationManager.translate("recipeGallery.out", "Out") }
                        ]

                        Rectangle {
                            id: valueCard
                            required property var modelData
                            readonly property bool isIn: modelData.key === "in"
                            readonly property double value: isIn ? root.currentDose : root.currentYield

                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.scaled(74)
                            radius: Theme.cardRadius
                            color: Theme.backgroundColor

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.scaled(6)
                                spacing: Theme.scaled(2)

                                StyledIconButton {
                                    text: "−"
                                    accessibleName: valueCard.isIn
                                        ? TranslationManager.translate("gramsEditor.lessDose", "Less coffee, 0.5 grams")
                                        : TranslationManager.translate("gramsEditor.lessYield", "Less yield, 1 gram")
                                    onClicked: valueCard.isIn
                                        ? root.applyOverrides(Math.max(5, root.currentDose - 0.5),
                                                              ProfileManager.brewByRatioActive ? ProfileManager.brewByRatio : root.currentYield,
                                                              ProfileManager.brewByRatioActive ? "ratio" : "absolute")
                                        : root.applyOverrides(root.currentDose, Math.max(10, root.currentYield - 1), "absolute")
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: valueCard.modelData.label
                                        font: Theme.captionFont
                                        color: Theme.textSecondaryColor
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: valueCard.value.toFixed(1) + " g"
                                        font.family: Theme.valueFont.family
                                        font.pixelSize: Theme.scaled(22)
                                        font.bold: true
                                        color: Theme.textColor
                                    }
                                }

                                StyledIconButton {
                                    text: "+"
                                    accessibleName: valueCard.isIn
                                        ? TranslationManager.translate("gramsEditor.moreDose", "More coffee, 0.5 grams")
                                        : TranslationManager.translate("gramsEditor.moreYield", "More yield, 1 gram")
                                    onClicked: valueCard.isIn
                                        ? root.applyOverrides(Math.min(30, root.currentDose + 0.5),
                                                              ProfileManager.brewByRatioActive ? ProfileManager.brewByRatio : root.currentYield,
                                                              ProfileManager.brewByRatioActive ? "ratio" : "absolute")
                                        : root.applyOverrides(root.currentDose, Math.min(200, root.currentYield + 1), "absolute")
                                }
                            }

                            // Tapping the number (not the ±) opens the big editor.
                            AccessibleMouseArea {
                                anchors.centerIn: parent
                                width: parent.width - Theme.scaled(110)
                                height: parent.height
                                accessibleName: valueCard.modelData.label + " " + valueCard.value.toFixed(1)
                                    + " " + TranslationManager.translate("recipeGallery.grams", "grams")
                                    + ", " + TranslationManager.translate("recipeGallery.openEditor", "opens the large editor")
                                onAccessibleClicked: gramsEditor.openFor(valueCard.modelData.key)
                            }
                        }
                    }
                }

                // Ratio presets
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSmall

                    Repeater {
                        model: [2, 2.5, 3]

                        AccessibleButton {
                            id: ratioButton
                            required property var modelData
                            readonly property bool selected: ProfileManager.brewByRatioActive
                                && Math.abs(ProfileManager.brewByRatio - modelData) < 0.001
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1  // equal thirds regardless of label width
                            Layout.preferredHeight: Theme.touchTargetMin
                            text: "1:" + modelData
                            accessibleName: TranslationManager.translate("gramsEditor.presetRatio", "Ratio one to %1").arg(modelData)
                            onClicked: root.applyOverrides(root.currentDose, modelData, "ratio")
                            background: Rectangle {
                                radius: Theme.buttonRadius
                                color: ratioButton.selected ? Theme.textColor : "transparent"
                                border.width: ratioButton.selected ? 0 : 1
                                border.color: Theme.borderColor
                            }
                            contentItem: Text {
                                text: ratioButton.text
                                font.family: Theme.bodyFont.family
                                font.pixelSize: Theme.bodyFont.pixelSize
                                font.bold: true
                                color: ratioButton.selected ? Theme.backgroundColor : Theme.textColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                // Brew — on-screen when the app may start shots, otherwise a pointer to the GHC.
                AccessibleButton {
                    id: brewButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.scaled(60)
                    enabled: root.canStartOperations
                    // Escaped here because contentItem renders it as StyledText (emoji → <img>).
                    text: Theme.escapeHtml(root.canStartOperations
                        ? TranslationManager.translate("recipeGallery.brew", "Brew")
                        : TranslationManager.translate("recipeGallery.pressOnMachine", "Press ☕ on the machine"))
                    accessibleName: root.canStartOperations
                        ? TranslationManager.translate("recipeGallery.brew", "Brew")
                        : TranslationManager.translate("recipeGallery.pressOnMachineAccessible", "Press the espresso button on the machine")
                    onClicked: root.tryStart()
                    background: Rectangle {
                        radius: Theme.cardRadius
                        color: brewButton.down ? Qt.darker(root.selectedArt.base, 1.2) : root.selectedArt.base
                        opacity: root.canStartOperations ? 1.0 : 0.85
                    }
                    contentItem: Text {
                        text: Theme.replaceEmojiWithImg(brewButton.text, Theme.subtitleFont.pixelSize)
                        textFormat: Text.StyledText
                        font.family: Theme.subtitleFont.family
                        font.pixelSize: Theme.subtitleFont.pixelSize
                        font.bold: true
                        color: Theme.recipeArtOnBaseColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                // Gallery mode hides the centre zones that normally carry these.
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSmall

                    AccessibleButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.touchTargetMin
                        text: TranslationManager.translate("recipeGallery.steam", "Steam")
                        accessibleName: text
                        icon.source: "qrc:/icons/steam.svg"
                        subtle: true
                        onClicked: AppShell.steamRequested()
                    }
                    AccessibleButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.touchTargetMin
                        text: TranslationManager.translate("recipeGallery.hotWater", "Hot water")
                        accessibleName: text
                        icon.source: "qrc:/icons/water.svg"
                        subtle: true
                        onClicked: AppShell.hotWaterRequested()
                    }
                }
            }
        }
    }
}
