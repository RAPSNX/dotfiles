# Implementation Plan: Noctalia Mode (Submap), Screenshot Annotations & German Layout Fix

## Background & Objective
Using `MOD5` (`AltGr`) and `Alt` bindings for Noctalia shortcuts directly conflicted with the German keyboard layout (e.g. `EurKEY` / `de`), blocking characters like **`ß`** (`AltGr + S`), **`ä`**, **`ö`**, and **`ü`**.

This plan outlines:
1. Creating a dedicated **Noctalia Mode (submap)** in Hyprland triggered by `Super + N`.
2. Freeing `AltGr` / `MOD5` completely for keyboard typing.
3. Adding screenshot annotation capabilities using `satty`, `grim`, and `slurp`.
4. Providing on-screen mode feedback when entering submaps.

---

## Key Files & Scope
- **`modules/home/desktops/hyprland/keybinds.nix`**: Define the `noctalia` submap and mode notifications in Hyprland.
- **`modules/home/programs/default.nix`**: Add `satty`, `grim`, and `slurp` packages.
- **`docs/reference/hyprland.md`**: Update Hyprland reference documentation with the new submap and keybinds.
- **`docs/reference/noctalia.md`**: Update Noctalia reference documentation.

---

## Detailed Implementation

### 1. Dedicated Noctalia Mode Submap (`Super + N`)
Pressing **`Super + N`** enters the `noctalia` submap with the following single-key actions (each executing its action and resetting the submap):

| Key | Action | Command |
| :--- | :--- | :--- |
| **`n`** | Notifications / Control Center | `noctalia msg panel-toggle control-center notifications` |
| **`m`** | System Monitor | `noctalia msg panel-toggle control-center monitor` |
| **`c`** | Calendar | `noctalia msg panel-toggle control-center calendar` |
| **`s`** | Region Screenshot | `noctalia msg screenshot-region` |
| **`S`** (*Shift+S*) | Fullscreen Screenshot | `noctalia msg screenshot-fullscreen` |
| **`a`** | Annotated Screenshot | `grim -g "$(slurp)" - \| satty --filename -` |
| **`Esc`** / **`Enter`** | Exit Mode | `submap, reset` |

### 2. Retained Global Shortcuts (Direct Access)
- **`Super + E`**: Application launcher (`noctalia msg panel-toggle launcher`)
- **`Super + P`**: Session / Power menu (`noctalia msg panel-toggle session`)
- **`Super + .`**: Emoji picker (`noctalia msg panel-toggle launcher "/emo "`)

### 3. Cleanup & Fix German Layout (`AltGr` / `MOD5`)
- Remove conflicting shortcuts:
  - `MOD5 + C` (was calendar)
  - `MOD5 + S` (was system monitor)
  - `MOD5 + V` and `Alt + V` (was clipboard)
- Restores full native support for German characters (`ä`, `ö`, `ü`, `ß`).

### 4. Mode Feedback & Which-Key Indications
Display transient on-screen banners when entering submaps:
- **`Super + R` (Resize Mode)**:
  - Banner: `MODE: RESIZE — [H/J/K/L] Resize  [Shift+H/J/K/L] Fine  [Esc/Enter] Exit`
- **`Super + G` (Window Mode)**:
  - Banner: `MODE: WINDOWS — [Q/W/E/R] Move to WS  [B] Toggle Firefox  [Esc/Enter] Exit`
- **`Super + N` (Noctalia Mode)**:
  - Banner: `MODE: NOCTALIA — [n] Notifications  [m] Monitor  [c] Calendar  [s] Region  [S] Full  [a] Annotate`

### 5. Packages to Add
Add the following utilities to `modules/home/programs/default.nix`:
- `satty` (interactive screenshot annotation with arrows, text, boxes, blur, crop)
- `grim` (Wayland screen grabber)
- `slurp` (Wayland region selector)

---

## Verification & Testing
1. **Flake Evaluation**:
   - `nix eval .#homeConfigurations."rap@zion".activationPackage.drvPath`
   - `nix eval .#homeConfigurations."nix@firefly".activationPackage.drvPath`
2. **Lint & Quality**:
   - `statix check . && deadnix . && nix fmt`
3. **Behavioral Test**:
   - Press `Super + N` &rarr; verify mode banner displays.
   - Press `n`, `m`, `c`, `s`, `S`, or `a` &rarr; verify corresponding action triggers and submap resets.
   - Type `AltGr + S` &rarr; verify `ß` is typed without triggering any Hyprland shortcuts.
