@echo off
set "PY_EXE_NAME=Google Policy Uninstaller v2.0.0"
set "SCRIPT_NAME=cleaner.py"
set "TASK_NAME=RunPolicyManager"

if "%~1"=="--scheduled" goto launch_program

schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel%==0 (
    schtasks /run /tn "%TASK_NAME%"
    exit /b
)

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo First-time setup requires admin to create the bypass task...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Creating silent background task...
schtasks /create /tn "%TASK_NAME%" /tr "\"%~f0\" --scheduled" /sc once /sd 01/01/2099 /st 00:00 /rl highest /f

echo ===================================================
echo SETUP COMPLETE!
echo You can now close this window.
echo Run this file again anytime to launch without UAC prompts.
echo ===================================================
timeout /t 3 >nul
exit

:launch_program
set "ENGINE_PATH=%~dp0%PY_EXE_NAME%"

if exist "%~dp0%SCRIPT_NAME%" (
    cd /d "%~dp0"
    set "FULL_PATH=%~dp0%SCRIPT_NAME%"
    goto execute
)

for %%I in ("%~dp0..") do set "PARENT_DIR=%%~fI"
if exist "%PARENT_DIR%\%SCRIPT_NAME%" (
    cd /d "%PARENT_DIR%"
    set "FULL_PATH=%PARENT_DIR%\%SCRIPT_NAME%"
    goto execute
)

echo ===================================================
echo [ERROR] Run installer again.
echo ===================================================
pause
exit

:execute
start "" "%ENGINE_PATH%" "%FULL_PATH%"
exit