@echo off
title Servidor FiveM Roleplay - Spain Rol / QBCore
color 0b
echo ========================================================
echo        SERVIDOR FIVEM ROLEPLAY - SPAIN ROL (QBCore)
echo ========================================================
echo.

set "SERVER_ROOT=%~dp0"
set "DB_DIR=%SERVER_ROOT%database"
set "FX_DIR=%SERVER_ROOT%server"
set "DATA_DIR=%SERVER_ROOT%server-data"

echo [1/2] Verificando Base de Datos MariaDB (Puerto 3306)...
netstat -ano | findstr :3306 >nul
if %errorlevel% neq 0 (
    echo Iniciando MariaDB en segundo plano...
    start "" /b "%DB_DIR%\bin\mysqld.exe" --defaults-file="%DB_DIR%\my.ini"
    timeout /t 3 /nobreak >nul
) else (
    echo Base de Datos MariaDB ya activa en el puerto 3306.
)

echo [2/2] Preparando e Iniciando Servidor FiveM con Spain Rol...
taskkill /f /im FXServer.exe >nul 2>&1
timeout /t 1 /nobreak >nul
echo ========================================================
echo Conectate desde FiveM con F8 -> connect localhost
echo Panel txAdmin disponible en http://localhost:40120/
echo Presiona Ctrl+C para apagar.
echo ========================================================
echo.

cd /d "%DATA_DIR%"
"%FX_DIR%\FXServer.exe" +set citizen_dir "%FX_DIR%\citizen" +exec server.cfg

pause
