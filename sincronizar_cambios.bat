@echo off
setlocal enabledelayedexpansion
title Sincronizador de Cambios GitHub - Spain Rol
color 0b

:MENU
cls
echo ===============================================================================
echo            SINCRONIZADOR DE CAMBIOS CON GITHUB - SERVIDOR ROLEPLAY
echo ===============================================================================
echo.
echo  Repositorio: https://github.com/murciacarddshow-code/SERVIDOR-ROLPLAY-
echo  Rama activa: main
echo.
echo  [1] DESCARGAR ultimos cambios de mis companeros (PULL)
echo  [2] SUBIR mis cambios al servidor de GitHub (ADD + COMMIT + PUSH)
echo  [3] SINCRONIZACION COMPLETA (Descargar primero y luego Subir)
echo  [4] VER ESTADO de archivos modificados (GIT STATUS)
echo  [5] SALIR
echo.
echo ===============================================================================
set /p OPCION="Selecciona una opcion [1-5]: "

if "%OPCION%"=="1" goto PULL
if "%OPCION%"=="2" goto PUSH
if "%OPCION%"=="3" goto SYNC_ALL
if "%OPCION%"=="4" goto STATUS
if "%OPCION%"=="5" goto SALIR
goto MENU

:PULL
echo.
echo ===============================================================================
echo  DESCARGANDO ACTUALIZACIONES DESDE GITHUB (PULL)...
echo ===============================================================================
git pull origin main
echo.
echo  Pulse cualquier tecla para volver al menu...
pause >nul
goto MENU

:PUSH
echo.
echo ===============================================================================
echo  SUBIENDO MIS CAMBIOS A GITHUB (PUSH)...
echo ===============================================================================
echo.
set /p MSG="Describe brevemente lo que has cambiado o anadido: "
if "%MSG%"=="" set MSG=Actualizacion de recursos y configuraciones

echo.
echo [1/3] Preparando archivos modificados...
git add .
echo [2/3] Registrando commit: "%MSG%"...
git commit -m "%MSG%"
echo [3/3] Subiendo cambios a GitHub...
git push origin main
echo.
echo ===============================================================================
echo  [OK] Cambios sincronizados y subidos a GitHub con exito!
echo ===============================================================================
echo.
pause
goto MENU

:SYNC_ALL
echo.
echo ===============================================================================
echo  SINCRONIZACION COMPLETA: DESCARGANDO Y SUBIENDO...
echo ===============================================================================
echo.
echo [Paso 1] Descargando cambios de companeros...
git pull origin main
echo.
echo [Paso 2] Preparando subida de tus cambios...
set /p MSG_ALL="Describe brevemente lo que has cambiado o anadido: "
if "%MSG_ALL%"=="" set MSG_ALL=Sincronizacion de cambios y mejoras

git add .
git commit -m "%MSG_ALL%"
git push origin main
echo.
echo ===============================================================================
echo  [OK] Repositorio completamente sincronizado en ambas direcciones!
echo ===============================================================================
echo.
pause
goto MENU

:STATUS
echo.
echo ===============================================================================
echo  ESTADO ACTUAL DE ARCHIVOS (GIT STATUS):
echo ===============================================================================
git status
echo.
pause
goto MENU

:SALIR
exit
