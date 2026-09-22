@echo off
title Sincronizar Cambios de mi Companero desde GitHub
color 0b
echo ========================================================
echo        SINCRONIZAR CAMBIOS DESDE GITHUB (PULL)
echo ========================================================
echo.

set "GIT_CMD=%~dp0tools\git\cmd\git.exe"
if not exist "%GIT_CMD%" (
    where git >nul 2>&1
    if %errorlevel% equ 0 (
        set "GIT_CMD=git"
    ) else (
        for /d %%D in ("%LOCALAPPDATA%\GitHubDesktop\app-*") do (
            if exist "%%D\resources\app\git\cmd\git.exe" set "GIT_CMD=%%D\resources\app\git\cmd\git.exe"
        )
    )
)

echo Descargando las ultimas actualizaciones de tu companero...
"%GIT_CMD%" pull

echo.
echo ========================================================
echo   Servidor actualizado al ultimo estado de GitHub!
echo ========================================================
pause
