param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$wasiSdk,

  [Parameter(Mandatory = $true, Position = 1)]
  [string]$binaryen
)
$ErrorActionPreference = "Stop"

$wasiSdk = $wasiSdk.TrimEnd('/', '\')
$binaryen = $binaryen.TrimEnd('/', '\')

$wasiSysroot = Join-Path $wasiSdk "share\wasi-sysroot"
$clang = Join-Path $wasiSdk "bin\clang.exe"
$clangxx = Join-Path $wasiSdk "bin\clang++.exe"

$wasmOpt = Join-Path $binaryen "bin\wasm-opt.exe"
$wasmCtorEval = Join-Path $binaryen "bin\wasm-ctor-eval.exe"

Write-Host ""
Write-Host "wasi_sysroot    $wasiSysroot"
Write-Host "clang           $clang"
Write-Host "clangxx         $clangxx"
Write-Host "wasm_opt        $wasmOpt"
Write-Host "wasm_ctor_eval  $wasmCtorEval"
Write-Host ""

Push-Location $PSScriptRoot
try {
  Set-Location sqlite3.dart
  git apply ..\sqlite3_wasm_build.patch
  git add sqlite3 sqlite3_wasm_build

  Set-Location sqlite3_wasm_build

  $buildDir = ".dart_tool\sqlite3_build"
  $cmakeArgs = @(
    "-Dwasi_sysroot=$wasiSysroot",
    "-Dclang=$clang",
    "-Dclangxx=$clangxx",
    "-Dwasm_opt=$wasmOpt",
    "-Dwasm_ctor_eval=$wasmCtorEval"

    "-DSIMPLE_WITH_JIEBA=ON"
  )
  cmake -S src -B $buildDir @cmakeArgs -DFETCHCONTENT_QUIET=OFF
  cmake --build $buildDir -t output -j
} finally {
  Pop-Location
}
