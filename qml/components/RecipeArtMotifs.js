// Vector motifs for RecipeArt.qml, in a 100x100 box. Each part names a colour ROLE
// (a key of the motif's Theme.recipeArtPalette entry, or "" for none) rather than a colour.
.pragma library

var motifs = {
    rings: [
        { d: "M12.0 56.0 a38.0 38.0 0 1 0 76.0 0 a38.0 38.0 0 1 0 -76.0 0 Z", fill: "", stroke: "ink", width: 3.2, opacity: 0.25 },
        { d: "M20.0 56.0 a30.0 30.0 0 1 0 60.0 0 a30.0 30.0 0 1 0 -60.0 0 Z", fill: "", stroke: "ink", width: 3.2, opacity: 0.45 },
        { d: "M28.0 56.0 a22.0 22.0 0 1 0 44.0 0 a22.0 22.0 0 1 0 -44.0 0 Z", fill: "", stroke: "ink", width: 3.2, opacity: 0.7 },
        { d: "M37.0 56.0 a13.0 13.0 0 1 0 26.0 0 a13.0 13.0 0 1 0 -26.0 0 Z", fill: "light", stroke: "", width: 0, opacity: 1 },
        { d: "M44.0 56.0 a6.0 6.0 0 1 0 12.0 0 a6.0 6.0 0 1 0 -12.0 0 Z", fill: "ink", stroke: "", width: 0, opacity: 1 },
        { d: "M72.0 20.0 a6.0 6.0 0 1 0 12.0 0 a6.0 6.0 0 1 0 -12.0 0 Z", fill: "light", stroke: "", width: 0, opacity: 1 }
    ],
    hills: [
        { d: "M0 70 C 20 52 36 52 52 66 S 84 78 100 60 L100 100 L0 100 Z", fill: "mid", stroke: "", width: 0, opacity: 1 },
        { d: "M0 82 C 22 68 40 70 58 80 S 86 88 100 76 L100 100 L0 100 Z", fill: "ink", stroke: "", width: 0, opacity: 1 },
        { d: "M34 22 h22 a4 4 0 0 1 4 4 v22 a4 4 0 0 1 -4 4 h-22 a4 4 0 0 1 -4 -4 v-22 a4 4 0 0 1 4 -4 Z", fill: "light", stroke: "", width: 0, opacity: 1 },
        { d: "M65.0 30.0 a7.0 7.0 0 1 0 14.0 0 a7.0 7.0 0 1 0 -14.0 0 Z", fill: "ink", stroke: "", width: 0, opacity: 1 }
    ],
    bolt: [
        { d: "M14 34 H40 M8 48 H36 M18 62 H40", fill: "", stroke: "light", width: 4, opacity: 0.9 },
        { d: "M60 12 L40 54 H56 L46 90 L80 42 H63 L74 12 Z", fill: "ink", stroke: "", width: 0, opacity: 1 },
        { d: "M76.0 78.0 a6.0 6.0 0 1 0 12.0 0 a6.0 6.0 0 1 0 -12.0 0 Z", fill: "light", stroke: "", width: 0, opacity: 1 }
    ],
    flower: [
        { d: "M35.0 35.0 a15.0 15.0 0 1 0 30.0 0 a15.0 15.0 0 1 0 -30.0 0 Z", fill: "light", stroke: "", width: 0, opacity: 0.95 },
        { d: "M51.2 46.7 a15.0 15.0 0 1 0 30.0 0 a15.0 15.0 0 1 0 -30.0 0 Z", fill: "light", stroke: "", width: 0, opacity: 0.95 },
        { d: "M45.0 65.8 a15.0 15.0 0 1 0 30.0 0 a15.0 15.0 0 1 0 -30.0 0 Z", fill: "light", stroke: "", width: 0, opacity: 0.95 },
        { d: "M25.0 65.8 a15.0 15.0 0 1 0 30.0 0 a15.0 15.0 0 1 0 -30.0 0 Z", fill: "light", stroke: "", width: 0, opacity: 0.95 },
        { d: "M18.8 46.7 a15.0 15.0 0 1 0 30.0 0 a15.0 15.0 0 1 0 -30.0 0 Z", fill: "light", stroke: "", width: 0, opacity: 0.95 },
        { d: "M39.0 52.0 a11.0 11.0 0 1 0 22.0 0 a11.0 11.0 0 1 0 -22.0 0 Z", fill: "ink", stroke: "", width: 0, opacity: 1 },
        { d: "M50 74 C 50 84 46 92 40 98", fill: "", stroke: "ink", width: 3.5, opacity: 1 }
    ],
    cup: [
        { d: "M24 50 H70 V62 C70 78 60 86 47 86 C34 86 24 78 24 62 Z", fill: "ink", stroke: "", width: 0, opacity: 1 },
        { d: "M70 56 H76 C84 56 84 70 76 70 H70", fill: "", stroke: "ink", width: 4, opacity: 1 },
        { d: "M16 90 H78", fill: "", stroke: "ink", width: 4, opacity: 1 },
        { d: "M38 40 C 34 34 42 30 38 22 M52 40 C 48 34 56 30 52 22", fill: "", stroke: "light", width: 3.5, opacity: 1 }
    ],
    sun: [
        { d: "M26.0 58.0 L16.0 58.0 M29.2 46.0 L20.6 41.0 M38.0 37.2 L33.0 28.6 M50.0 34.0 L50.0 24.0 M62.0 37.2 L67.0 28.6 M70.8 46.0 L79.4 41.0 M74.0 58.0 L84.0 58.0", fill: "", stroke: "ink", width: 3.5, opacity: 1 },
        { d: "M30 58 a20 20 0 0 1 40 0 Z", fill: "light", stroke: "", width: 0, opacity: 1 },
        { d: "M8 70 H92 M20 80 H80 M34 90 H66", fill: "", stroke: "ink", width: 3.5, opacity: 1 }
    ],
    glass: [
        { d: "M34 14 H66 L62 90 H38 Z", fill: "light", stroke: "", width: 0, opacity: 1 },
        { d: "M36.2 44 H63.8 L62 90 H38 Z", fill: "ink", stroke: "", width: 0, opacity: 1 },
        { d: "M36.8 52 H63.2", fill: "", stroke: "mid", width: 2.5, opacity: 1 },
        { d: "M71.0 24.0 a5.0 5.0 0 1 0 10.0 0 a5.0 5.0 0 1 0 -10.0 0 Z", fill: "ink", stroke: "", width: 0, opacity: 1 }
    ],
    leaf: [
        { d: "M22 78 C 22 40 48 18 82 18 C 82 52 60 78 22 78 Z", fill: "light", stroke: "", width: 0, opacity: 1 },
        { d: "M22 78 C 40 60 56 44 72 30", fill: "", stroke: "ink", width: 3.5, opacity: 1 },
        { d: "M44 58 L 44 44 M56 46 L 58 34", fill: "", stroke: "ink", width: 3, opacity: 0.7 }
    ]
}

// Picks a motif from what the recipe brews. Keyword first, so the same profile always gets the
// same picture; anything unrecognised falls back to a stable hash of the recipe name.
function motifFor(profileTitle, recipeName, drinkType) {
    var t = ((profileTitle || "") + " " + (recipeName || "")).toLowerCase()
    if ((drinkType || "").indexOf("tea") === 0 || t.indexOf("tea") >= 0) return "leaf"
    if (t.indexOf("turbo") >= 0) return "bolt"
    if (t.indexOf("bloom") >= 0) return "flower"
    if (t.indexOf("allong") >= 0 || t.indexOf("filter") >= 0) return "glass"
    if (t.indexOf("gentle") >= 0 || t.indexOf("sweet") >= 0 || t.indexOf("lever") >= 0) return "hills"
    if (t.indexOf("adaptive") >= 0) return "rings"
    if (t.indexOf("flow") >= 0) return "sun"
    if (t.indexOf("default") >= 0 || t.indexOf("classic") >= 0) return "cup"
    var fallback = ["rings", "hills", "bolt", "flower", "cup", "sun", "glass"]
    var h = 0
    var s = recipeName || profileTitle || ""
    for (var i = 0; i < s.length; ++i)
        h = (h * 31 + s.charCodeAt(i)) % 1000003
    return fallback[h % fallback.length]
}
