# 📝 FokusEra Changelog

All notable changes to the **FokusEra** addon architecture will be documented in this registry file.

---

## 🚀 — 2026-06-21

This release marks a complete structural refactor, moving from a single monolithic file prototype to a clean, multi-module standalone interface package. It guarantees full uafhængighed from foreign unit frame suites and introduces symmetrical asset tracking.

### 🏗️ Architectural Overhaul (Code Splitting)
*   **Modular Decomposition** — Splitted the original `fokusera.lua` into 4 specialized lightweight components to optimize maintenance:
    *   `fokusinit.lua` — Handles shared namespace setup and client boot variables.
    *   `fokusui.lua` — Constructs all backdrops, borders, resource bars, and sizing handles.
    *   `fokuscore.lua` — Manages the high-speed heartbeat loop and data validations.
    *   `fokuschat.lua` — Maps UI slash commands and internal message networks.
*   **Blizzard Namespace Security** — Implemented the secure internal table payload (`...`) to pass functions across files safely, completely eliminating raw global clutter and preventing `nil value` execution drops.

### ✨ Added Features & Symmetrical Balancing
*   **Dual-Frame Synchronized Setup** — Introduced a dedicated, standalone **FocusTarget** window (`FokusEraTargetFrame`) attached out-of-combat to map targets of your focus player or main tank.
*   **Target Resource Tracking** — Equipped the FocusTarget frame with an internal, responsive power/mana bar that dynamically scans and colorizes based on enemy or ally unit classifications (Mana, Rage, Energy).
*   **Horizontal Resize Engine** — Deployed an interactive drag-grabber button in the bottom-right corner. Healers can now dynamically expand or shrink the frame layout width, while the 3D character portrait scales safely inside a locked, crisp bounding square.
*   **Align to Grid & Magnetic Snap** — Added geometric calculation tools inside the sub-frame drag arrays. Slipped items snip automatically onto integers, and letting go of the target frame near baseline plane constraints triggers a horizontal magnetic alignment snap.

### 🐛 Bug Fixes & API Safety Updates
*   **Case-Sensitivity Cleansing** — Unified all variables, folder configurations, and directory entries to use the true, clean **K** format (`Fokus` instead of `Focus`), shielding the core package from case-sensitive C++ memory skips.
*   **Group Dissolution Purge** — Wired a secure event handler to `GROUP_ROSTER_UPDATE`. If the player leaves a party or cross-server raid group, all `raidX` or `partyX` target hooks are instantly cleared and the frames are concealed automatically.
*   **Modern API Transition** — Swapped out the deprecated `SetMinResize` and `SetMaxResize` Blizzard triggers for the official patch 1.15.x API wrapper `SetResizeBounds`.
*   **Macro Pointer Correction** — Restructured action bar macro instructions to fetch unit paths natively through global frame attribute queries (`FokusEraFrame:GetAttribute("unit")`) due to structural localization inside the private addon namespace.

---

## 🧪 — 2026-06-20

### Added
*   Initial fully functional monolithic single-file prototype build (`fokusera.lua`).
*   Core background heartbeat update loop scanning units 10 times a second.
*   Basic 3D character portrait window matching Z-Perl Slate-Dark solid backing aesthetics.
*   Clique click-cast bridging and basic slash triggers (`/fokus`, `/clearfokus`, `/fokusreset`).
*   Character-locked WTF configuration variables for basic padlock positioning retention.
