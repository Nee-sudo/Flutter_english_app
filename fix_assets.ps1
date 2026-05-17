# Fix Flutter asset entries when assets folders/fonts are missing.
# Run from repo root.
# This script checks for existence of assets/images, assets/icons and required font files.
# If missing, it edits pubspec.yaml to remove those asset/font entries.

$ErrorActionPreference = 'Stop'
$root = Get-Location
$pubspec = Join-Path $root 'pubspec.yaml'

if (!(Test-Path $pubspec)) {
  throw "pubspec.yaml not found in $root"
}

$hasImagesDir = Test-Path (Join-Path $root 'assets/images')
$hasIconsDir  = Test-Path (Join-Path $root 'assets/icons')
$hasFontReg   = Test-Path (Join-Path $root 'assets/fonts/Poppins-Regular.ttf')
$hasFontBold  = Test-Path (Join-Path $root 'assets/fonts/Poppins-Bold.ttf')

# Load pubspec
$yaml = Get-Content -Raw -Path $pubspec

# Remove missing assets directories entries
if (-not $hasImagesDir) {
  $yaml = $yaml -replace "(?m)^\s*- assets/images/\s*\r?\n", ""
}
if (-not $hasIconsDir) {
  $yaml = $yaml -replace "(?m)^\s*- assets/icons/\s*\r?\n", ""
}

# Remove fonts entries if missing
if (-not ($hasFontReg -and $hasFontBold)) {
  # Remove entire Poppins fonts block
  $yaml = $yaml -replace "(?ms)^\s*fonts:\s*\n\s*- family: Poppins[\s\S]*?\n\s*flutter:\s*\n","" | Out-Null
  # If previous regex fails, do a safer approach: strip only the fonts: section up to the next top-level key.
  # Fallback: remove the fonts section if it still exists.
  if ($yaml -match "(?ms)^\s*fonts:\s*") {
    $yaml = $yaml -replace "(?ms)^\s*fonts:\s*[\s\S]*?(?=^\s*flutter:|^\w+:)","" 
  }
}

Set-Content -Path $pubspec -Value $yaml
Write-Host "pubspec.yaml updated. ImagesDir=$hasImagesDir IconsDir=$hasIconsDir RegFont=$hasFontReg BoldFont=$hasFontBold"
