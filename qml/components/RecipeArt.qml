import QtQuick
import QtQuick.Shapes
import Decenza
import "RecipeArtMotifs.js" as Motifs

// Cover art for a recipe tile: a vector motif chosen from what the recipe brews, drawn in that
// motif's Theme.recipeArtPalette colours. Purely decorative — the tile carries the name.
Item {
    id: root

    property string profileTitle: ""
    property string recipeName: ""
    property string drinkType: ""

    readonly property string motif: Motifs.motifFor(profileTitle, recipeName, drinkType)
    readonly property var artColors: Theme.recipeArtPalette[motif]
    readonly property color baseColor: artColors.base

    Accessible.ignored: true

    Item {
        width: 100
        height: 100
        anchors.centerIn: parent
        scale: Math.min(root.width, root.height) / 100

        Repeater {
            model: Motifs.motifs[root.motif]

            Shape {
                id: part
                required property var modelData
                anchors.fill: parent
                opacity: part.modelData.opacity
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    fillColor: part.modelData.fill ? root.artColors[part.modelData.fill] : "transparent"
                    strokeColor: part.modelData.stroke ? root.artColors[part.modelData.stroke] : "transparent"
                    strokeWidth: part.modelData.stroke ? part.modelData.width : -1
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin
                    PathSvg { path: part.modelData.d }
                }
            }
        }
    }
}
