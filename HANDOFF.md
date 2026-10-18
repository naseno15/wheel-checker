# พิกัดล้อ (wheel-checker) — continuation handoff

**Last updated:** 2026-10-19 (Asia/Bangkok) — HMI Co-Co SideDiagram (full-width)

Entry page uses a full-width TCMS-style loco schematic (`SideDiagram.qml`): cab noses, hood, B1/B2 bogies, mid fuel tank, selectable axle discs. Do not put the diagram in a narrow side column — it looks squashed.

**Last updated:** 2026-10-19 (Asia/Bangkok) — rename + handoff path

## Canonical location

| Item | Path / URL |
|------|------------|
| Source tree | `c:\trs22\wheel_limits_cpp\` |
| GitHub (private) | https://github.com/naseno15/wheel-checker |
| Product name | **พิกัดล้อ** (`wheel_limits`) |
| Dynamic exe | `build\wheel_limits_cpp.exe` |
| Static exe | `build-static\wheel_limits_cpp.exe` |

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
src/bridge.*        QML bridge, i18n, prefs, history sort/rows
src/main.cpp        Qt Quick entry
ui/qml/Main.qml     home 2-col, fleet, entry, result, guide, settings
ui/qml/SideDiagram.qml   Co-Co axle picker
assets/fleet/       ALS…QSY icons (class codes)
checks/             check_calc, check_font
```

## Prefs

AppData under org `MSTN` / app `wheel_limits` → `wheel_limits.json`.  
Migrates automatically from legacy `als_wheel` / `srt_wheel` if present.

## Recent product notes

- Home: 2-column menu (enter / history / result / guide)
- History: sort by last edited / created / loco number; tap row → result (no load dropdown)
- Fleet pick: one tap → loco number page
- Theme: maroon railway (not blue); default dark
- No GitHub Release yet — work tracked under CHANGELOG Unreleased

## Continuity rule

Edit only under `wheel_limits_cpp`. Update this file when defaults, paths, or known bugs change.
