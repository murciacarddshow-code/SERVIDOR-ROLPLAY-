@echo off
setlocal enabledelayedexpansion
title Sincronizador Automatico a GitHub - Spain Rol
color 0a

echo ===============================================================================
echo            SUBIDA AUTOMATICA DE CAMBIOS A GITHUB (COMPANEROS)
echo ===============================================================================
echo.

set "GIT_CMD="
where git >nul 2>&1
if %errorlevel% equ 0 (
    set "GIT_CMD=git"
) else (
    for /d %%D in ("%LOCALAPPDATA%\GitHubDesktop\app-*") do (
        if exist "%%D\resources\app\git\cmd\git.exe" set "GIT_CMD=%%D\resources\app\git\cmd\git.exe"
    )
)

if not defined GIT_CMD (
    echo [ERROR] No se ha localizado la instalacion de Git o GitHub Desktop.
    pause
    exit /b 1
)

echo [1/3] Descargando cambios previos de tus companeros (Pull con AutoStash)...
"%GIT_CMD%" pull origin main --autostash
echo.

echo [2/3] Preparando y registrando todos los cambios locales...
"%GIT_CMD%" add .
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set FECHA=%%a-%%b-%%c
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set HORA=%%a:%%b
"%GIT_CMD%" commit -m "sync: actualizacion automatica de equipo (!FECHA! !HORA!)"
echo.

echo [3/3] Subiendo todo a GitHub (Push)...
"%GIT_CMD%" push origin main

echo.
echo ===============================================================================
echo   [OK] Todos tus cambios ya estan en GitHub con exito!
echo   Tus companeros ya los tienen disponibles en sus PCs al abrir el servidor.
echo ===============================================================================
echo.
timeout /t 5
