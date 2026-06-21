# 🔮 FokusEra — Standalone Focus Frame System for WoW Classic Era

![FokusEra v1.2.2 Interface Preview](FokusEra/images/fokusera1.png)

Welcome to the official repository for **FokusEra (v1.2.2)**, a high-performance, 100% standalone unit frame addon engineered exclusively for **World of Warcraft: Classic Era (Patch 1.15.x)**.

FokusEra operates entirely on its own visual engine, providing a clean, slate-dark aesthetic without bulky interface overhauls or reliance on external libraries. It bridges the game's background metrics with keyboard action bar macros and provides a dedicated, layout-synchronized **FocusTarget** frame featuring realtime health, mirrored portrait rendering, and intelligent dispel scanning.

---

## 🚀 Core Features at a Glance

*   **Symmetrical Dual-Frame Design** — Synchronized primary Focus and mirrored **FocusTarget** windows built on an identical 48-pixel height axis for structural alignment.
*   **Mirrored 3D Portraits** — Primary focus renders portraits on the left, while the target frame mirrors it perfectly to the right with automated, responsive face zooming.
*   **Intelligent Class Dispel Highlights** — Frame borders dynamically illuminate based on active dispel priorities automated for your specific healer class (e.g., Priests prioritize Magic ➡️ Disease, Shamans prioritize Poison ➡️ Disease).
*   **Built-in Click-to-Cast Spellbar** — Cast spells dynamically using a row of 5 secure, custom-assigned icons hovering directly above the primary health bar profile.
*   **Raid Icon Target Overlays** — Real-time index mapping rendering lucky stars, moons, or skulls onto the portrait windows.
*   **Combat Lockdown Shielding** — Advanced memory protections that actively freeze layout adjustments mid-encounter to eliminate Blizzard `ADDON_ACTION_BLOCKED` system graphic exceptions.

---

## ⌨️ Quick Start Guide

*   `/fokus` — Assigns your current friendly target to the framework.
*   `/fokusspell [Spell Name]` — Binds an icon automatically to the next free layout slot (e.g., `/fokusspell Flash Heal`).
*   `Alt + Left-Click + Drag` — Repositions either frame layout freely across your viewport.

---

## 🗂️ Getting Started & Installation

The complete source code, installation check-lists, developer macros, and technical module scripts are located inside the main addon directory block.

👉 **[Click here to view the Addon Directory and Technical Installation Guide](Interface/AddOns/fokusera/)**

---

## 📝 Release History
For a full breakdown of the transition from the early single-file prototypes into the modern multi-module framework, please check the historical archive:

👉 **[Click here to view the Project Changelog Ledger](Interface/AddOns/fokusera/CHANGELOG.md)**
