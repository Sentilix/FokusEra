# 📝 FokusEra Changelog

All notable changes to the **FokusEra** addon architecture will be documented in this registry file.

---

## — 2026-06-21 (version 1.2.2)

This release implements advanced tactical raid overlays, an intelligent class-specific debuff prioritization border engine, and comprehensive in-combat error shielding.

### ✨ Added
*   **Smart Debuff Border Highlights** — Frame backdrops dynamically colorize their borders based on the highest weighted threat (Magic = Blue, Curse = Purple, Disease = Brown, Poison = Green) utilizing the new `fokusdispel.lua` engine module.
*   **Automated Class Dispel Audit** — Deployed an automated startup routine mapping out specific debuff weighting metrics based on your chosen class capabilities (Priest: Magic ➡️ Disease, Shaman: Poison ➡️ Disease).
*   **Zero-Nil Fallback Security** — Engineered a hardcoded baseline priority backup map ensuring non-healer classes fallback safely onto standard Blizzard dispels without throwing Lua evaluation crashes.
*   **Raid Target Symbol Overlays** — Integrated real-time texture coordinates tracking active raid marks (Star, Moon, Skull, etc.) and rendering them seamlessly on corresponding corners of both portrait blocks via `fokusraidicons.lua`.

### 🐛 Fixed
*   **Combat Lockdown Shield** — Embedded strict `InCombatLockdown()` interceptor blocks inside `FokusEra_UpdateInternalWidths()`. The addon now actively halts status bar resizing routines mid-encounter, completely mitigating `ADDON_ACTION_BLOCKED` system graphics exceptions.
*   **Visual Ergonomics Filtering** — Confined the dynamic dispel border highlights exclusively to the primary Focus frame canvas, safeguarding the healer's core task field from unnecessary clutter on the Target of Focus layout.

---

## — 2026-06-21 (version 1.2.1)

This release establishes visual layout symmetry with dual 3D model capabilities and hardens party evacuation validation routines.

### ✨ Added
*   **Mirrored 3D Target Portrait** — Upgraded `FokusEraTargetFrame` with an internal 3D `PlayerModel` viewport mirrored symmetrically to the right-hand margin using the isolated `fokustargetui.lua` module.
*   **OnModelLoaded Camera Anchor** — Fixed 3D camera drift by introducing an automated model load event listener, enforcing a high-precision close-up face zoom instantly upon unit allocation.
*   **Intelligent Token Remapping** — Programmed a background redirect inside `fokuscore.lua` that automatically intercepts invisible combinations like `playertarget` when targeting yourself, forcing a direct raw lookup on `player` to prevent black texture voids.

### 🐛 Fixed
*   **Roster Disconnect Evacuation** — Hardened `GROUP_ROSTER_UPDATE` logic. If a tracked focus player leaves your raid or party environment completely, the framework triggers an automatic memory purge and frame concealment sequence.

---

## — 2026-06-21 (version 1.2.0)

This release introduces an advanced Click-to-Cast Action Bar system directly onto the interface layouts.

### ✨ Added
*   **Secure Action Button Row** — Embedded 5 horizontal `SecureActionButtonTemplate` slots hovering over the primary health bar profile for safe in-combat action execution via `fokusspellbar.lua`.
*   **Chat-Driven Configuration UI** — Added the data-parsing module `fokusspellcmd.lua` supporting the `/fokusspell` slot scanning and validation syntax.
*   **Numeric Database Protection** — Auto-resolving and storing raw `SpellID` keys instead of volatile localized string values.
*   **Slate-Dark Silhouettes** — Formatted solid 1-pixel black borders framing active hot-button elements.
*   **Unified Layout Reset** — Bound active spell profile purges (`FokusEra_Spells = {}`) to fire simultaneously during `/fokusreset` cycles.

---

## — 2026-06-20 (version 1.1.0)

This release implements a complete modular architecture refactor for the core addon framework.

### ✨ Added
*   **Granular File Splitting** — Refactored the monolithic prototype into distinct source components (`init`, `ui`, `core`, `chat`) communicating seamlessly via hidden Blizzard namespace parameters (`...`).
*   **Synchronized Sub-Frames** — Introduced the dedicated, relative-anchored **FocusTarget** window tracking units targeted by your active focus player.
*   **Horizontal Stretch Tuning** — Added a layout resizing handle permitting custom layout width expansions.
*   **Align to Grid Math** — Injected geometric calculation tools into drag arrays, rounding layout positioning offsets to clean integers and enabling vertical magnet snapping.

### 🐛 Fixed
*   **Case-Sensitivity Pass** — Unified all directory, structural, and naming references to use the strict lowercase **K** architecture (`fokusera`).
*   **Modern API Transition** — Swapped out deprecated layout scaling parameters for the modern `SetResizeBounds` API.

---

## — 2026-06-06 (version 1.0.0)

### ✨ Added
*   Initial functional monolithic single-file prototype build (`fokusera.lua`).
*   Core background heartbeat update loop scanning units 10 times a second.
*   Basic 3D character portrait window matching slate-dark solid backing aesthetics.
*   Clique click-cast bridging and basic slash triggers (`/fokus`, `/clearfokus`, `/fokusreset`).
*   Character-locked WTF configuration variables for basic paddock positioning retention.
