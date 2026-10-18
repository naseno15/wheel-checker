# Build

## Dynamic (DLL Qt)

```powershell
powershell -File .\fast.ps1
```

Requires `C:\Users\Naito\Qt`.

## Static one-exe

```powershell
powershell -File .\fast_static.ps1
```

Requires `C:\Users\Naito\QtStatic`. Flag: `-DWHEEL_STATIC=ON`.
