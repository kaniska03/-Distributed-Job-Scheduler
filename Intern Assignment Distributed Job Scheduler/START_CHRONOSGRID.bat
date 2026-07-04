@echo off
title ChronosGrid Launcher
echo ============================================
echo   ChronosGrid - one-click local launcher
echo   (runs without Docker: SQLite + Node dev server)
echo ============================================
cd /d "%~dp0chronosgrid"

echo.
echo [1/4] Installing Python dependencies (first run only, ~1 min)...
cd backend
python -m pip install --quiet -r requirements.txt -r requirements-dev.txt
if errorlevel 1 (
  echo Python install failed. Make sure Python is on PATH, then re-run.
  pause
  exit /b 1
)

echo [2/4] Starting API server (with embedded scheduler + demo data)...
start "ChronosGrid API" cmd /k "cd /d %~dp0chronosgrid\backend && python -m uvicorn app.main:app --port 8000"

echo [3/4] Starting a worker...
timeout /t 8 /nobreak >nul
start "ChronosGrid Worker" cmd /k "cd /d %~dp0chronosgrid\backend && python worker_main.py"

echo [4/4] Installing frontend + starting dev server (first run ~2 min)...
cd ..\frontend
call npm install --no-audit --no-fund
start "ChronosGrid Frontend" cmd /k "cd /d %~dp0chronosgrid\frontend && npm run dev"

echo.
echo Waiting for the frontend to come up...
timeout /t 12 /nobreak >nul
start http://localhost:5173

echo.
echo ============================================
echo  ChronosGrid is starting in 3 windows:
echo    API      http://localhost:8000/api/docs
echo    Frontend http://localhost:5173
echo  Login: click "Login as Demo User"
echo  To stop: close the 3 ChronosGrid windows.
echo ============================================
pause
