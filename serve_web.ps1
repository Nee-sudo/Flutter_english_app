# Build (if needed) and serve the Flutter web app from build/web.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not (Test-Path 'build\web\main.dart.js')) {
  Write-Host 'Building Flutter web app (first time may take a few minutes)...'
  flutter build web --no-wasm-dry-run
}

Copy-Item 'web\manifest.json' 'build\web\manifest.json' -Force
if (Test-Path 'web\index.html') {
  Copy-Item 'web\index.html' 'build\web\index.html' -Force
}

Write-Host ''
Write-Host 'Serving at http://localhost:8080'
Write-Host 'Press Ctrl+C to stop.'
Write-Host ''

Set-Location build\web
python -m http.server 8080
