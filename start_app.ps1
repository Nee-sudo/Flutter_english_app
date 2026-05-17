# Start the Flutter web app. Run from project root (backend optional; coupon works offline).
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

flutter pub get
Write-Host 'Launching Flutter web app (Chrome)...'
flutter run -d chrome --web-port=8080
