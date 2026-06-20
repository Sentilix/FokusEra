# 📝 FokusEra Changelog

All notable changes to the **FokusEra** addon architecture will be documented in this registry file.

---

## — 2026-06-21

This release introduces an advanced, zero-library Click-to-Cast Action Bar module built directly onto the primary focus layout frame architecture, combined with automated data-parsing modules.

### 🏗️ Extended Modular Clean-up
*   **Granular File Splitting** — Expanded the file structure to 5 specialized modules to comply with strict repository boundaries and lightweight memory profiles:
    *   `fokusspellbar.lua` — Draws the backdrop template frames and formats icon texture layouts.
    *   `fokusspellcmd.lua` — Isolated the complex backend scanning mechanics for processing the `/fokusspell` console inputs.
*   **Global Comment Standardization** — Purged all regional language fragments and notes across all source modules, establishing a uniform, 100% technical English documentation style inside the file architectures.

### ✨ Added Features & Symmetrical Balancing
*   **Secure Action Button Row** — Embedded 5 horizontal `SecureActionButtonTemplate` slots hovering 14 pixels above the primary health bar profile for safe, latency-free in-combat spell execution.
*   **Intelligent Auto-Vacancy Scanner** — Upgraded `/fokusspell` console command logic. Typing `/fokusspell [Spell Name]` without an integer slot mapping automatically scans arrays from index 1 to 5 to claim the first vacant cell.
*   **Strict Spell Validation Engine** — Integrated real-time client verification. Entering an invalid or misspelled spell string forces an instant operation block and prints a clear warning feedback line without altering saved character variables.
*   **Numeric Database Fallback** — Programmed the database layer to automatically look up and store raw numeric `SpellID` keys instead of volatile string text, bypassing localized graphic loading glitches.
*   **Slate-Dark Silhouette Outlines** — Redesigned icon boundaries to use a solid black (1-pixel) backdrop frame layer, blending action triggers natively with the standalone backdrop panels.
*   **Unified Layout Reset** — Bound action slot allocations to the central system flush. Executing `/fokusreset` now purges active spell registries (`FokusEra_Spells = {}`) alongside screen coordinates.

---

## — 2026-06-20

### Added
*   Complete core codebase refactor moving from a monolithic build to an isolated multi-file framework (`init`, `ui`, `core`, `chat`).
*   Blizzard internal table namespace injection (`...`) passing parameters safely across modules to stop file-clashing.
*   Dedicated, synchronized **FocusTarget** window tracking units targeted by your active focus player.
*   Horizontal dragging frame resizing grabber allowing customized width stretch values.
*   "Align to Grid" mathematical pixel rounding mechanics paired with a magnetic vertical snap utility.

### Fixed
*   Case-sensitivity bugs, stripping out all volatile `C`-references to fully secure the clean **K** architecture (`FokusFrame`).
*   Automatic memory de-allocation routing loops on character group dissolution events.
*   Transitioned layout configurations to use the modern Classic Era API function wrapper `SetResizeBounds`.

---

## — 2026-06-06

### Added
*   Initial functional monolithic single-file prototype build (`fokusera.lua`).
*   Core background heartbeat update loop scanning units 10 times a second.
*   Basic 3D character portrait window matching slate-dark solid backing aesthetics.
*   Clique click-cast bridging and basic slash triggers (`/fokus`, `/clearfokus`, `/fokusreset`).
*   Character-locked WTF configuration variables for basic padlock positioning retention.
