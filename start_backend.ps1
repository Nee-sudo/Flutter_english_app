# Start the Node.js API (coupon + analytics). Run from project root.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not (Test-Path 'backend\node_modules')) {
  Write-Host 'Installing backend dependencies...'
  Set-Location backend
  npm install
  Set-Location ..
}

if (-not (Test-Path 'backend\.env')) {
  Copy-Item 'backend\.env.example' 'backend\.env'
  Write-Host 'Created backend\.env from .env.example — set MONGO_URI if you use analytics.'
}

Set-Location backend
Write-Host 'Starting backend on http://localhost:5000'
npm start
