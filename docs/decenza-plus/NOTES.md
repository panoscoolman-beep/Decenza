# Decenza+ — working notes

Fork of [Kulitorum/Decenza](https://github.com/Kulitorum/Decenza) for Panos' DE1PRO
(Teclast M50 Mini tablet, Acaia Lunar, Weber EG-1 / Femobook A64 / Acaia Orbit SSP MP).
Branch: `claude/recipe-gallery-home`.

## What this fork changes

- **Recipe gallery home** — `recipeGallery` layout widget (Utility). In `centerMiddle` it
  switches the idle page to coloured recipe tiles (`RecipeGallery.qml`, `RecipeArt.qml`,
  `RecipeArtMotifs.js`) with the selected recipe's profile graph, In/Out steppers, ratio
  presets and a full-screen grams editor (`GramsEditorPopup.qml`). The shot page is untouched.
- **Installs beside the official app** — CI sets application id
  `io.github.kulitorum.decenza_de1.plus`, label `Decenza+`, and points the in-app updater at
  this fork's releases (`DECENZA_UPDATE_REPO`). Official/local builds are unchanged.
- **CI** — keystore secret is whitespace-tolerant and verified before the compile.

## Releasing

Run *Android APK Build* (workflow_dispatch) on the branch with `upload_to_release: true`.
It uploads `Decenza_<version>.apk` to release `v<version>` and stamps `Build: N`
(`versioncode.txt × 1000 + run number`), which the in-app updater compares.
Secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD` (alias `de1-key`).

## Related

- Design mockups: https://claude.ai/artifact/SuBbVpsgTn45ADrtPqR5kg
- Coffee stock page: https://claude.ai/artifact/AhskAm2qXvrQryZk9XESxG
- Decenza MCP is reached over Tailscale; a fresh Decenza+ install joins as a new node.
