@echo off
title Servidor FiveM Roleplay - Spain Rol (Modo txAdmin)
color 0b
echo ========================================================
echo       SERVIDOR FIVEM ROLEPLAY - SPAIN ROL (txAdmin)
echo ========================================================
echo.

set "SERVER_ROOT=%~dp0"
set "DB_DIR=%SERVER_ROOT%database"
set "FX_DIR=%SERVER_ROOT%server"
set "DATA_DIR=%SERVER_ROOT%server-data"
set "TX_DIR=%SERVER_ROOT%txData"

echo [1/3] Verificando Base de Datos MariaDB (Puerto 3306)...
netstat -ano | findstr :3306 >nul
if %errorlevel% neq 0 (
    echo Iniciando MariaDB en segundo plano...
    start "" /b "%DB_DIR%\bin\mysqld.exe" --defaults-file="%DB_DIR%\my.ini"
    timeout /t 3 /nobreak >nul
) else (
    echo Base de Datos MariaDB ya activa en el puerto 3306.
)

echo [2/3] Liberando procesos previos...
taskkill /f /im FXServer.exe >nul 2>&1
timeout /t 1 /nobreak >nul

echo [3/3] Iniciando FXServer con Panel Web txAdmin...
echo ========================================================
echo Panel txAdmin web: http://localhost:40120/
echo Conectate desde FiveM con F8 -> connect localhost
echo Menu dentro del juego -> /tx
echo ========================================================
echo.

set "TXHOST_DATA_PATH=%TX_DIR%"
cd /d "%DATA_DIR%"
"%FX_DIR%\FXServer.exe" +set citizen_dir "%FX_DIR%\citizen" +set txAdminPort 40120
pause
