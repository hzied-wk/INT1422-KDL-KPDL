@echo off
echo 🚀 Starting OLAP Web Interface...
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js is not installed. Please install Node.js first.
    exit /b 1
)

echo ✅ Node.js version:
node --version
echo.

REM Start backend server
echo 🔧 Starting Backend Server (port 5000)...
start "OLAP Backend" cmd /k "cd server && npm start"

REM Wait for backend to start
timeout /t 3 /nobreak

REM Start frontend
echo 🎨 Starting Frontend (port 3000)...
cd client
start "OLAP Frontend" cmd /k "npm start"

echo.
echo ✅ Application is starting...
echo Backend: http://localhost:5000
echo Frontend: http://localhost:3000
echo.
pause
