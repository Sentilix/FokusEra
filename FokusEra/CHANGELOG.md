# 📝 FokusEra Changelog

All notable changes to the **FokusEra** addon architecture will be documented in this registry file.

---
## — 2026-08-08 (version 1.4.0)

### ✨ Added
* Added support for setting focus on NPCs, bosses, and non-group players.
* Added context-aware text header status icons for instant clickability verification.

### 🛑 Removed
* Removed legacy /fokusspell functionality.
* Removed support for Patch 1.15.8.


## — 2026-07-18 (version 1.3.1)

### ✨ Changed
* Updated TOC interface compatibility flags for Patch 1.15.9.


## — 2026-07-04 (version 1.3.0)

### ✨ Added
* Added buffs and debuffs to the Focus window.
* Added combined buffs and debuffs onto a single row for the Focus Target window.
* Added an options menu directly inside Blizzard's Options > Addons interface.
* Added custom secure checkboxes to completely eliminate memory taint.
* Added saved variables to remember aura visibility settings per character.

### 🐛 Fixed
* Fixed a bug where hiding frames during combat would trigger action blocked errors.
* Moved cross-module functions into the private namespace to prevent addon conflicts.

---

## — 2026-06-21 (version 1.2.3)

### 🐛 Fixed
* Fixed a bug where target buffs would erroneously display on the Focus frame by assigning proper metadata unit linkage.

---

## — 2026-06-21 (version 1.2.2)

### ✨ Added
* Added a mirrored 3D portrait to the right side of the Focus Target frame.
* Added an automatic close-up camera zoom on target load events.
* Added an automated startup system that colorizes frame borders based on your class dispel capabilities.
* Added real-time raid target icon overlays onto the corners of both portraits.

### 🐛 Fixed
* Fixed action blocked errors in combat by freezing status bar resizing routines mid-encounter.
* Restricted dispel border highlights exclusively to the primary Focus frame to reduce visual clutter.

---

## — 2026-06-21 (version 1.2.0)

### ✨ Added
* Added 5 secure click-to-cast action slots above the primary health bar.
* Added the `/fokusspell` chat command with automatic slot allocation and spelling validation.
* Added numeric SpellID database tracking to fix localized texture loading glitches.
* Added solid 1-pixel black borders around the active click-to-cast spell buttons.
* Added spell profile clearing to the main layout `/fokusreset` command.

---

## — 2026-06-20 (version 1.1.0)

### ✨ Added
* Refactored monolithic code into clean source files via shared Blizzard namespace tables.
* Added a relative-anchored Focus Target frame tracking your focus target's target.
* Added a horizontal resize handle to customize frame width adjustments.
* Added an align-to-grid system with horizontal magnetic snapping.

### 🐛 Fixed
* Unified case-sensitivity paths to match the strict lowercase folder structure.
* Transitioned deprecated scaling parameters to the modern layout bounding API.

---

## — 2026-06-06 (version 1.0.0)

### ✨ Added
* Initial single-file focus frame prototype build.
* Heartbeat update loop running 10 times a second.
* 3D portrait window with a solid slate-dark backdrop.
* Clique click-cast support and standard slash commands (`/fokus`, `/clearfokus`, `/fokusreset`).
* Character-locked frame positioning persistence via WTF variables.
