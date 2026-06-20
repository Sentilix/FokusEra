# 🔮 FokusEra

A lightweight, high-performance, and completely standalone focus frame structure built exclusively for **World of Warcraft: Classic Era (Patch 1.15.x)**. 

FokusEra operates entirely on its own visual engine, providing a clean, slate-dark aesthetic without bulky interface overhauls. It bridges the game's background metrics with keyboard action bar macros and provides a dedicated, layout-synchronized **FocusTarget** frame featuring realtime health and power resource scanning.

---

## ✨ Features

*   **100% Standalone Integrity** — Operates natively using the Blizzard API without any reliance on or hooks into external unit frame addons.
*   **Dual-Frame Setup** — Includes a primary tracking focus window (with a 3D portrait, level display, class color strings, and health/power tracking) alongside a symmetrical **FocusTarget** tracker for targets of your focus.
*   **Clique & Click-Cast Friendly** — Both the Focus Frame and FocusTarget Frame are built onto `SecureUnitButtonTemplate` architectures, allowing out-of-combat configuration and full direct binding support via mouseover heal engines like Clique.
*   **Smart Token Routing Loop** — Monitors group re-shuffles and raid grid position re-allocations dynamically in the background 10 times a second, preventing the layout from losing tracking data mid-combat.
*   **Independent Alt + Drag Layouts** — Hold `Alt` and drag either frame to construct your ideal viewport configuration. 
*   **Align to Grid & Magnetic Snap** — Slipped sub-frames mathematically round to clean pixel points. Dropping the target frame near horizontal alignment forces an instant magnetic snap onto a perfectly level plane.
*   **Horizontal Stretch Tuning** — Drag the built-in sizing handle in the bottom-right corner to stretch the main frame width dynamically while keeping the 3D portrait size crisp and intact.
*   **Persistent WTF Config File Mapping** — Remembers lock states, layout positions, custom coordinate gaps, and expanded widths across relogs uniquely per character.

---

## ⌨️ Slash Commands Overview

Execute these key strings inside your in-game text frame input:

*   `/fokus` — Assigns your currently active friendly target pointer to the framework (Usable out of combat).
*   `/clearfokus` — De-allocates tracking targets, completely conceals active frame structures, and purges system memory keys.
*   `/fokusreset` — Safely flushes runtime coordinates and database entries, snapping both frames back to default lower-third grid spaces side by side.
*   `/fokusversion` — Audits active raid or party communication channels for checking matching FokusEra client installations.
*   `/fokushelp` — Prints a layout command cheat sheet checklist index directly into your local log pane.

---

## 📋 Comprehensive Macro Integration

Because FokusEra internally keeps your target updated within a secure framework, you can write powerful companion macros for your keyboard action bars by querying the global frame attributes directly.

### 1. Silent "In-Range Check" Cast Engine (With Icon Tooltip)
This companion macro handles range validation metrics silently and tracks cooldown graphics without throwing annoying error texts on your viewport if your focus is out of line-of-sight:

```macro
#showtooltip Power Word: Shield
/run local t=FokusEraFrame:GetAttribute("unit"); if t and UnitExists(t) and not UnitIsDeadOrGhost(t) and UnitInRange(t) then CastSpellByName("Power Word: Shield", t); end
```

### 2. Snap-Targeting Pointer Swap
Cycle your main target selection window instantly onto your designated focus player or tank unit regardless of configuration sizing:

```macro
/run local t=FokusEraFrame:GetAttribute("unit"); if t and UnitExists(t) then TargetUnit(t) end
```

---

## 💽 File Structure Registry

For clean client initialization, your core folder directory path must be named exactly **`fokusera`** inside `World of Warcraft\_classic_era_\Interface\AddOns\`. Ensure your active package includes only the following modules:

1.  **`README.md`** — This structural documentation sheet.
2.  **`fokusera.toc`** — The initialization list that loads variables and modules in sequence.
3.  **`fokusinit.lua`** — Initializes shared namespaces and handles system startup variables.
4.  **`fokusui.lua`** — Establishes secure button canvas structures, fonts, backdrops, and resize motors.
5.  **`fokuscore.lua`** drove the background heartbeat tracking loop, group roster checks, and unit power type updates.
6.  **`fokuschat.lua`** — Binds command keywords and logs data broadcasts on background channels.

---

## 🚀 Post-Installation Verification Checklist

1. Ensure **Clique** is updated to map onto external addons if you want click-casting.
2. Boot into the server environment. Type **`/fokusreset`** to force the layout sandboxes onto your screen.
3. Unlock the yellow wheel icon, adjust your sizing stretch widths, and clamp the padlock down red (Locked) to save profiles safely! (Your system chat frame will confirm authorization with the active version string: **
3. 