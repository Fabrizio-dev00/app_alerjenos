param(
    [string]$Device = ""
)

$ErrorActionPreference = "Stop"
$app = Split-Path -Parent $PSScriptRoot
$adb = Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe"
$package = "dev.fabrizio.allergen_scanner"
$remote = "/sdcard/Android/data/$package/files/labels"
$adbTarget = @()
$flutterTarget = @()
if ($Device -ne "") {
    $adbTarget = @("-s", $Device)
    $flutterTarget = @("-d", $Device)
}

Write-Host "Subiendo etiquetas a $remote"
& $adb @adbTarget shell mkdir -p "$remote/images"
& $adb @adbTarget push (Join-Path $app "test_labels\labels.json") "$remote/labels.json" | Out-Null
Get-ChildItem (Join-Path $app "test_labels\images") -File | ForEach-Object {
    & $adb @adbTarget push $_.FullName "$remote/images/$($_.Name)" | Out-Null
}

Push-Location $app
try {
    flutter test integration_test/label_benchmark_test.dart @flutterTarget
} finally {
    Pop-Location
}

& $adb @adbTarget pull "$remote/report.json" (Join-Path $app "test_labels\report.json") | Out-Null
Write-Host "Reporte guardado en test_labels\report.json"
