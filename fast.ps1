# Incremental app build — DLL Qt, not static.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$env:PATH = "C:\Users\Naito\Qt\bin;C:\Users\Naito\Qt\Tools\mingw1310_64\bin;C:\Users\Naito\AppData\Roaming\Python\Python312\Scripts;" + $env:PATH
$cmake = "C:\Users\Naito\AppData\Roaming\Python\Python312\site-packages\cmake\data\bin\cmake.exe"
$build = Join-Path $root "build"
$ccache = "C:/Users/Naito/AppData/Local/Microsoft/WinGet/Packages/Ccache.Ccache_Microsoft.Winget.Source_8wekyb3d8bbwe/ccache-4.14.1-windows-x86_64/ccache.exe"
if (-not (Test-Path (Join-Path $build "build.ninja"))) {
    $args = @("-S", $root, "-B", $build, "-G", "Ninja", "-DCMAKE_BUILD_TYPE=Release", "-DCMAKE_PREFIX_PATH=C:\Users\Naito\Qt")
    if (Test-Path $ccache) { $args += "-DCMAKE_CXX_COMPILER_LAUNCHER=$ccache" }
    & $cmake @args
}
& $cmake --build $build --target wheel_limits_cpp --parallel $env:NUMBER_OF_PROCESSORS
& $cmake --build $build --target check_calc --parallel $env:NUMBER_OF_PROCESSORS
& $cmake --build $build --target check_font --parallel $env:NUMBER_OF_PROCESSORS
& (Join-Path $build "check_calc.exe")
& (Join-Path $build "check_font.exe")
if (-not (Test-Path (Join-Path $build "Qt6Core.dll"))) {
    & "C:\Users\Naito\Qt\bin\windeployqt.exe" --release --compiler-runtime --qmldir (Join-Path $root "ui\qml") (Join-Path $build "wheel_limits_cpp.exe")
}
Write-Host "run: $(Join-Path $build 'wheel_limits_cpp.exe')"
