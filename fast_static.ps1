# Single static exe -> build-static\wheel_limits_cpp.exe
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$qt = "C:\Users\Naito\QtStatic"
if (-not (Test-Path (Join-Path $qt "lib\cmake\Qt6\Qt6Config.cmake"))) {
    throw "QtStatic not found at $qt"
}
$env:PATH = "C:\Users\Naito\Qt\Tools\mingw1310_64\bin;C:\Users\Naito\AppData\Roaming\Python\Python312\Scripts;" + $env:PATH
$cmake = "C:\Users\Naito\AppData\Roaming\Python\Python312\site-packages\cmake\data\bin\cmake.exe"
$build = Join-Path $root "build-static"
$ccache = "C:/Users/Naito/AppData/Local/Microsoft/WinGet/Packages/Ccache.Ccache_Microsoft.Winget.Source_8wekyb3d8bbwe/ccache-4.14.1-windows-x86_64/ccache.exe"
if (-not (Test-Path (Join-Path $build "build.ninja"))) {
    $cfg = @(
        "-S", $root, "-B", $build, "-G", "Ninja",
        "-DCMAKE_BUILD_TYPE=Release",
        "-DCMAKE_PREFIX_PATH=$qt",
        "-DWHEEL_STATIC=ON"
    )
    if (Test-Path $ccache) { $cfg += "-DCMAKE_CXX_COMPILER_LAUNCHER=$ccache" }
    & $cmake @cfg
}
& $cmake --build $build --target wheel_limits_cpp --parallel $env:NUMBER_OF_PROCESSORS
$exe = Join-Path $build "wheel_limits_cpp.exe"
if (-not (Test-Path $exe)) { throw "static build missing: $exe" }
$sizeMb = [math]::Round((Get-Item $exe).Length / 1MB, 1)
Write-Host ("static ok: {0} ({1} MB)" -f $exe, $sizeMb)
Write-Host ("run: {0}" -f $exe)
