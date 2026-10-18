# พิกัดล้อ (wheel-checker) — continuation handoff

**Last updated:** 2026-10-19 (Asia/Bangkok) — v1.0.1 desktop entry polish

Entry `SideDiagram` scales to the bay (Cab 1 / Cab 2, mid fuel, no bogie plates).
Sunk fields stay compact; titles are large on desktop. Undo/Redo beside theme.
**บันทึก / ดูผล** calls `saveCurrent()` before `page = "result"`.
Window has no max size ceiling — maximize works.

## Canonical location

| Item | Path / URL |
|------|------------|
| Source tree | `c:\trs22\wheel_limits_cpp\` |
| GitHub (private) | https://github.com/naseno15/wheel-checker |
| Product name | **พิกัดล้อ** (`wheel_limits`) |
| Dynamic exe | `build\wheel_limits_cpp.exe` |
| Static exe | `build-static\wheel_limits_cpp.exe` |
| Latest release | **v1.0.1** |

**Do not use** (removed):

- `c:\trs22\als_wheel_cpp\`
- `c:\trs22\srt_wheel_cpp\`

Fleet code `ALS` still means Alstom class 4101–4154 only — not the app name.

## Build

```powershell
cd c:\trs22\wheel_limits_cpp
powershell -File .\fast.ps1
# one-exe:
powershell -File .\fast_static.ps1
```

Needs Qt at `C:\Users\Naito\Qt` (DLL) or `C:\Users\Naito\QtStatic` (static).

## Layout

```text
src/calc.h          multi-fleet limits + loco bands (namespace wheel)
src/bridge.*        QML bridge, i18n, prefs, history, undo/redo
src/main.cpp        Qt Quick entry
ui/qml/Main.qml     home 2-col, wizard, entry, result, guide, settings
ui/qml/SideDiagram.qml   Co-Co axle picker (width-scaled)
ui/qml/SunkField.qml     compact inset wells
assets/fleet/       ALS…QSY icons (class codes)
checks/             check_calc, check_undo, check_font
```

## Prefs

AppData under org `MSTN` / app `wheel_limits` → `wheel_limits.json`.  
Migrates automatically from legacy `als_wheel` / `srt_wheel` if present.

## Recent product notes

- Home: 2-column menu (enter / history / result / guide)
- History: sort by last edited / created / loco number; tap row → result
- Fleet pick: one tap → loco number page
- Theme: maroon railway (not blue); default dark
- Release **v1.0.1** on GitHub

## Continuity rule

Edit only under `wheel_limits_cpp`. Update this file when defaults, paths, or known bugs change.
