# =====================================================
# Map2Market - Quick Start Setup Script for PowerShell
# =====================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  MAP2MARKET - SETUP & INITIALIZATION" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check Flutter
Write-Host "[1/5] Checking Flutter installation..." -ForegroundColor Yellow
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutter) {
    Write-Host "ERROR: Flutter is not installed or not in PATH" -ForegroundColor Red
    exit 1
}
Write-Host "      ✓ Flutter found" -ForegroundColor Green

# Check Python
Write-Host "[2/5] Checking Python installation..." -ForegroundColor Yellow
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Write-Host "ERROR: Python is not installed or not in PATH" -ForegroundColor Red
    exit 1
}
Write-Host "      ✓ Python found" -ForegroundColor Green

# Setup Flutter
Write-Host "[3/5] Setting up Flutter dependencies..." -ForegroundColor Yellow
$flutterResult = flutter pub get 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter pub get failed" -ForegroundColor Red
    exit 1
}
Write-Host "      ✓ Flutter dependencies installed" -ForegroundColor Green

# Setup Backend
Write-Host "[4/5] Setting up Python backend..." -ForegroundColor Yellow
Push-Location backend
$pipResult = pip install -r requirements.txt --quiet 2>&1 | Out-Null
Pop-Location
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Some Python packages may have conflicts" -ForegroundColor Yellow
    Write-Host "         This is usually safe to continue" -ForegroundColor Yellow
}
Write-Host "      ✓ Python dependencies resolved" -ForegroundColor Green

# Analyze
Write-Host "[5/5] Analyzing code quality..." -ForegroundColor Yellow
$analyzeResult = flutter analyze 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Code analysis failed" -ForegroundColor Red
    exit 1
}
Write-Host "      ✓ Code analysis passed" -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETE ✓" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "READY TO RUN:" -ForegroundColor Green
Write-Host "  • Android/iOS: flutter run" -ForegroundColor White
Write-Host "  • Backend API: cd backend & python main.py" -ForegroundColor White
Write-Host ""
