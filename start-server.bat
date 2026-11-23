@echo off
cd /d "%~dp0server"
call .venv\Scripts\activate.bat
echo.
echo Your IPv4 address (use it in the app's Settings):
ipconfig | findstr /i "IPv4"
echo.
echo Starting the Aether server. Close this window to stop it.
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
pause
