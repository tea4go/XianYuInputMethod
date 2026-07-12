@echo off

if "%1"=="--skip-build" (
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0deploy.ps1" --skip-build
) else (
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0deploy.ps1"
)
pause
