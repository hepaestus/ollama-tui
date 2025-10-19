@echo off
REM Ollama TUI Startup Script for Windows
REM This script sets up the environment and runs the necessary components

setlocal EnableDelayedExpansion

echo ================================
echo Ollama TUI Startup Script
echo ================================
echo.

REM Check Python installation
echo [INFO] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found. Please install Python 3.8 or higher.
    pause
    exit /b 1
)
echo [INFO] Python found

REM Check if Ollama is running
echo [INFO] Checking Ollama service...
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARN] Ollama not running. Please start Ollama manually.
    echo Run: ollama serve
    pause
)

REM Create virtual environment if it doesn't exist
if not exist ".venv" (
    echo [INFO] Creating virtual environment...
    python -m venv .venv
)

REM Activate virtual environment
echo [INFO] Activating virtual environment...
call .venv\Scripts\activate.bat

REM Install dependencies
echo [INFO] Installing dependencies...
if exist "requirements.txt" (
    pip install -r requirements.txt
) else (
    pip install flask textual ollama werkzeug jinja2 markupsafe itsdangerous click python-dotenv
)

REM Show menu
:menu
echo.
echo ================================
echo Ollama TUI Startup Menu
echo ================================
echo Please select an option:
echo.
echo 1) Run Terminal UI (TUI)
echo 2) Run Web Interface
echo 3) Run Both Interfaces
echo 4) Run diagnostic tests
echo 5) Exit
echo.
set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" goto run_tui
if "%choice%"=="2" goto run_web
if "%choice%"=="3" goto run_both
if "%choice%"=="4" goto run_tests
if "%choice%"=="5" goto exit
echo Invalid option. Please choose 1-5.
goto menu

:run_tui
echo [INFO] Starting Terminal User Interface...
python tui.py
goto exit

:run_web
echo [INFO] Starting Web Interface...
echo Access the web interface at: http://localhost:5000
python app.py
goto exit

:run_both
echo [INFO] Starting both interfaces...
echo Web interface: http://localhost:5000
start python app.py
echo Starting TUI...
python tui.py
goto exit

:run_tests
echo [INFO] Running diagnostic tests...
if exist "test_debug.py" (
    python test_debug.py
) else (
    echo test_debug.py not found
)
pause
goto menu

:exit
echo [INFO] Goodbye!
pause