@echo off
title Limpiar Cache del Servidor FiveM
color 0e

echo ===============================================================================
echo                     LIMPIEZA DE CACHE - SERVIDOR FIVEM
echo ===============================================================================
echo.

set "SERVER_ROOT=%~dp0"
set "DATA_DIR=%SERVER_ROOT%server-data"
set "TX_DIR=%SERVER_ROOT%txData"

echo [1/3] Comprobando que el servidor no este en marcha...
taskkill /f /im FXServer.exe >nul 2>&1
timeout /t 1 /nobreak >nul

echo [2/3] Eliminando cache de server-data...
if exist "%DATA_DIR%\cache" (
    rmdir /s /q "%DATA_DIR%\cache"
    echo   - Carpeta server-data/cache eliminada.
) else (
    echo   - La carpeta server-data/cache ya estaba limpia.
)

echo [3/3] Eliminando cache de txData...
if exist "%TX_DIR%\default\cache" (
    rmdir /s /q "%TX_DIR%\default\cache"
    echo   - Carpeta txData/default/cache eliminada.
)

echo.
echo ===============================================================================
echo  [OK] Cache limpiada con exito!
echo  Al iniciar el servidor, todos los scripts, vehiculos y texturas cargaran desde cero.
echo ===============================================================================
echo.
ping 127.0.0.1 -n 3 >nul

