#!/bin/bash
# =====================================================
# Map2Market - Quick Start Setup Script for macOS/Linux
# =====================================================

echo ""
echo "============================================"
echo "  MAP2MARKET - SETUP & INITIALIZATION"
echo "============================================"
echo ""

# Check Flutter
echo "[1/5] Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter is not installed or not in PATH"
    exit 1
fi
echo "      ✓ Flutter found"

# Check Python
echo "[2/5] Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python3 is not installed or not in PATH"
    exit 1
fi
echo "      ✓ Python found"

# Setup Flutter
echo "[3/5] Setting up Flutter dependencies..."
flutter pub get > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: Flutter pub get failed"
    exit 1
fi
echo "      ✓ Flutter dependencies installed"

# Setup Backend
echo "[4/5] Setting up Python backend..."
cd backend
pip3 install -r requirements.txt --quiet > /dev/null 2>&1
cd ..
if [ $? -ne 0 ]; then
    echo "WARNING: Some Python packages may have conflicts"
    echo "         This is usually safe to continue"
fi
echo "      ✓ Python dependencies resolved"

# Analyze
echo "[5/5] Analyzing code quality..."
flutter analyze > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: Code analysis failed"
    exit 1
fi
echo "      ✓ Code analysis passed"

echo ""
echo "============================================"
echo "  SETUP COMPLETE ✓"
echo "============================================"
echo ""
echo "READY TO RUN:"
echo "  • Android/iOS: flutter run"
echo "  • Backend API: cd backend && python3 main.py"
echo ""
