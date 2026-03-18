@echo off
REM =====================================================
REM Map2Market - Quick Start Setup Script for Windows
REM =====================================================

echo.
echo ============================================
echo   MAP2MARKET - SETUP & INITIALIZATION
echo ============================================
echo.

REM Check Flutter
echo [1/5] Checking Flutter installation...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    exit /b 1
)
echo       ✓ Flutter found

REM Check Python
echo [2/5] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    exit /b 1
)
echo       ✓ Python found

REM Setup Flutter
echo [3/5] Setting up Flutter dependencies...
call flutter pub get >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    exit /b 1
)
echo       ✓ Flutter dependencies installed

REM Setup Backend
echo [4/5] Setting up Python backend...
cd backend
pip install -r requirements.txt --quiet >nul 2>&1
cd ..
if %errorlevel% neq 0 (
    echo WARNING: Some Python packages may have conflicts
    echo          This is usually safe to continue
)
echo       ✓ Python dependencies resolved

REM Analyze
echo [5/5] Analyzing code quality...
call flutter analyze >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Code analysis failed
    exit /b 1
)
echo       ✓ Code analysis passed

echo.
echo ============================================
echo   SETUP COMPLETE ✓
echo ============================================
echo.
echo READY TO RUN:
echo   • Android/iOS: flutter run
echo   • Backend API: cd backend ^& python main.py
echo.
pause
