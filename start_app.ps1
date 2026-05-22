# Start the Flutter web app. Run from project root (backend optional; coupon works offline).
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

flutter pub get
Write-Host 'Launching Flutter web app (Chrome)...'
# Use localhost backend, or run `vercel dev` and use --dart-define=API_BASE_URL=/api
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5000/api
