# FokusEra (Z-Perl Focus Bridge)
### User Documentation & Guide — Version 1.0.0

**FokusEra** is a lightweight, high-performance, and combat-safe addon designed specifically for **World of Warcraft Classic Era (Patch 1.15.8)**. It bridges the structural gap of the missing native `/focus` engine by simulating a fully functional, highly responsive Focus Frame that matches the classic **Z-Perl / X-Perl** visual aesthetic. 

Engineered explicitly for group and raid environments, FokusEra integrates seamlessly with click-casting layouts like **Clique** and your custom healing or dispelling macros without causing UI errors or frame taints during intense encounters.

---

## ⚡ Key Features

*   **Z-Perl Visual Aesthetic:** Features the iconic rectangular dark-gradient layout, complete with fluidly updating values for Health and Power bars.
*   **Authentic Color Profile:** Health bars stay fixed in classic Z-Perl dark green, while player names are dynamically colored to match their respective class (e.g., White for Priest, Light Blue for Mage).
*   **3D Character Portrait:** Automatically renders a real-time 3D model of your focus target.
*   **Smart Group Re-shuffling:** Tracks your focus target dynamically via their distinct `UnitGUID`. If raid assists or group leaders move your focus target across different groups mid-encounter, FokusEra seamlessly maps them across `raid1-40` or `party1-4` tokens without losing track.
*   **Clique & Macro Native Compatibility:** Acts as a secure unit button wrapper. Your custom Clique configurations (including complex `Shift` and `Ctrl` modifiers) and click-to-cast configurations map flawlessly onto the frame.
*   **Character-Specific Layout Profile:** Features an interactive control panel directly on the frame. Locking the frame color-codes the control anchor and permanently retains the frame coordinates locally per character.
*   **Raid-Wide Version Checker:** Built-in hidden addon communication channel allowing network telegrams to audit configurations and version synchronization across an entire raid team without echoing your own interface.
*   **Dynamic Metadata Syncing:** The addon automatically extracts its active version string directly from the `.toc` file, making updates seamless.

---

## 🛠️ Chat Commands & Hotkeys

FokusEra uses a localized, uniform prefix structure to ensure all commands are easy to remember and completely isolated from protected engine keywords.

### Core Console Commands
*   **`/fokus`** — Sets the target frame to your currently selected friendly player (or yourself). Must be used out of combat.
*   **`/clearfokus`** — Completely drops the tracked unit, purges secure attributes, and cleanly hides the UI shell.
*   **`/fokusreset`** — Instantly centers the frame onto the lower-third boundary of your screen. If no focus is active, it spawns a temporary "Sandbox Test Profile" with your own 3D portrait so you can easily view and adjust the new placement.
*   **`/fokusversion`** — Broadcasts an unsecure data network telegram to your entire party or raid group. It prints your current installation locally and loops responses from any raid member running FokusEra.
*   **`/fokushelp`** — Prints a clean, color-coordinated in-game command and shortcut overview directly into your local chat frame.

### Mouse Shortcuts
*   **`Alt + Left-Click + Drag`** — Allows free-hand dragging and positioning of the frame anywhere across your user interface (only functional when the lock toggle is set to Open/Yellow and you are out of combat).

---

## 🎛️ Interactive Frame Controls

Two distinct miniature visual anchors reside at the top-right corner of the FocusFrame, allowing manual control without console entry:

1.  **The Gold/Red Gear Wheel (Tandhjul):** Controls layout configuration locks.
    *   🟡 **Gold/Yellow:** The frame is **Unlocked**. You can hold `Alt` and drag the frame to a new position.
    *   🔴 **Red:** The frame is **Locked**. It is completely anchored to its positions to prevent accidental dragging during chaotic raid movement. *This state is automatically saved across logouts and interface reloads.*
2.  **The Red 'X' Button (Clear Button):** Acts as a hardware trigger for `/clearfokus`. Clicking this immediately purges the active target and conceals the frame interface.

---

## 📋 Comprehensive Macro Integration

Because FokusEra internally keeps your target up-to-date within a secure framework, you can write powerful companion macros for your keyboard action bars using the matching **`FokusEra_`** namespace.

### 1. Smart "Alive & In Range" Emergency Casting
Perfect for casting heavy heals (*Flash Heal*, *Holy Light*) or instant purges (*Cleanse*, *Dispel Magic*) directly onto your focus without abandoning your current enemy or boss target. This macro uses `UnitInRange` to run a 40-yard validation check and filters out deceased party members:

```macro
/run local t=FokusEra_CurrentToken; if t and UnitExists(t) and not UnitIsDeadOrGhost(t) and UnitInRange(t) then CastSpellByName("Flash Heal", t) else UIErrorsFrame:AddMessage("Focus Dead or Out of Range!", 1, 0, 0) PlaySound(846) end
```
*Note: Replace `"Flash Heal"` with your specific class spell name exactly as it appears in your spellbook.*

### 2. Snap-Targeting Utility
If you need to rapidly cycle your primary target pointer onto your focus unit regardless of team sizing configurations, copy this short string:

```macro
/run local t=FokusEra_CurrentToken; if t and UnitExists(t) then TargetUnit(t) end
```