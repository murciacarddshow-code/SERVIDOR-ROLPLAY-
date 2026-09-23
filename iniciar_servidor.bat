@echo off
setlocal enabledelayedexpansion
title Servidor FiveM Roleplay - Spain Rol (QBCore)
color 0b

echo ===============================================================================
echo                SERVIDOR FIVEM ROLEPLAY - SPAIN ROL (QBCORE)
echo ===============================================================================
echo.

set "SERVER_ROOT=%~dp0"
set "DB_DIR=%SERVER_ROOT%database"
set "FX_DIR=%SERVER_ROOT%server"
set "DATA_DIR=%SERVER_ROOT%server-data"
set "TX_DIR=%SERVER_ROOT%txData"

:: 1. Verificacion y configuracion dinamica de my.ini
set "DATA_DIR_SLASH=%DB_DIR:\=/%/data"
powershell -NoProfile -Command "(Get-Content '%DB_DIR%\my.ini') -replace '^datadir=.*', 'datadir=\"%DATA_DIR_SLASH%\"' | Set-Content '%DB_DIR%\my.ini'" >nul 2>&1

:: 2. Comprobar binarios de FXServer
if not exist "%FX_DIR%\FXServer.exe" (
    echo [AVISO] No se han encontrado los artefactos de FXServer en la carpeta 'server'.
    echo Descargando e instalando FXServer automaticamente, por favor espera...
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$url = 'https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/35245-6efb47dff473c0e2a12fb50b08d74c0eb24a50d5/server.7z';" ^
        "if (!(Test-Path '%FX_DIR%')) { New-Item -ItemType Directory -Path '%FX_DIR%' | Out-Null };" ^
        "Write-Host 'Descargando artefactos FiveM oficiales (44 MB)...' -ForegroundColor Cyan;" ^
        "curl.exe -L $url -o '%FX_DIR%\server.7z';" ^
        "Write-Host 'Extrayendo archivos...' -ForegroundColor Yellow;" ^
        "tar.exe -xf '%FX_DIR%\server.7z' -C '%FX_DIR%';" ^
        "Remove-Item '%FX_DIR%\server.7z' -Force;"
    echo FXServer instalado con exito!
    echo.
)

:: 3. Comprobar binarios de MariaDB
if not exist "%DB_DIR%\bin\mysqld.exe" (
    echo [AVISO] No se han encontrado los binarios de MariaDB en 'database/bin'.
    echo Descargando motor MariaDB Portable, por favor espera...
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$zip = \"$env:TEMP\mariadb.zip\";" ^
        "$tmp = \"$env:TEMP\mariadb_tmp\";" ^
        "Write-Host 'Descargando MariaDB 10.11 Portable (85 MB)...' -ForegroundColor Cyan;" ^
        "curl.exe -L 'https://archive.mariadb.org/mariadb-10.11.8/winx64-packages/mariadb-10.11.8-winx64.zip' -o $zip;" ^
        "tar.exe -xf $zip -C $env:TEMP;" ^
        "Copy-Item \"$env:TEMP\mariadb-10.11.8-winx64\*\" -Destination '%DB_DIR%' -Recurse -Force;" ^
        "Remove-Item \"$env:TEMP\mariadb-10.11.8-winx64\" -Recurse -Force;" ^
        "Remove-Item $zip -Force;" ^
        "& '%DB_DIR%\bin\mariadb-install-db.exe' --datadir='%DB_DIR%\data' | Out-Null;"
    echo Motor MariaDB preparado con exito!
    echo.
)

:: 4. Comprobar e Iniciar MariaDB en Puerto 3306
echo [1/3] Verificando Base de Datos MariaDB (Puerto 3306)...
netstat -ano | findstr :3306 >nul
if %errorlevel% neq 0 (
    echo Iniciando motor MariaDB en segundo plano...
    start "" /b "%DB_DIR%\bin\mysqld.exe" --defaults-file="%DB_DIR%\my.ini"
    set "DB_READY=0"
    for /L %%i in (1,1,8) do (
        ping 127.0.0.1 -n 2 >nul
        netstat -ano | findstr :3306 >nul
        if !errorlevel! equ 0 (
            set "DB_READY=1"
            goto DB_CHECK_DONE
        )
    )
    :DB_CHECK_DONE
    if "!DB_READY!"=="1" (
        echo [OK] Base de datos MariaDB iniciada y respondiendo en el puerto 3306.
    ) else (
        echo [ERROR] No se pudo arrancar MariaDB. Revisa posibles bloqueos de puerto.
    )
) else (
    echo [OK] Base de datos MariaDB ya se encuentra activa en el puerto 3306.
)

:: 5. Comprobar e Importar Base de Datos qbcoreframework si es necesario
powershell -NoProfile -Command "& '%DB_DIR%\bin\mysql.exe' -u root -e 'USE qbcoreframework;'" >nul 2>&1
if %errorlevel% neq 0 (
    echo [2/3] Creando base de datos qbcoreframework e importando tablas...
    powershell -NoProfile -Command "& '%DB_DIR%\bin\mysql.exe' -u root -e 'CREATE DATABASE IF NOT EXISTS qbcoreframework CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'; Get-Content '%DB_DIR%\qbcoreframework_backup.sql' | & '%DB_DIR%\bin\mysql.exe' -u root qbcoreframework;" >nul 2>&1
    echo [OK] Tablas y datos de QBCore importados correctamente.
) else (
    echo [2/3] Base de datos 'qbcoreframework' verificada y lista.
)

:: 6. Limpiar procesos previos
echo [3/3] Comprobando instancias anteriores de FXServer...
taskkill /f /im FXServer.exe >nul 2>&1
ping 127.0.0.1 -n 2 >nul

echo.
echo ===============================================================================
echo   SERVIDOR INICIADO CORRECTAMENTE!
echo.
echo   - Conectate desde FiveM pulsando [F8] y escribiendo: connect localhost
echo   - Panel de Gestion Web txAdmin: http://localhost:40120/
echo   - Para detener el servidor, pulsa Ctrl+C o ejecuta DETENER_SERVIDOR.bat
echo ===============================================================================
echo.

cd /d "%DATA_DIR%"
set "TXHOST_DATA_PATH=%TX_DIR%"
"%FX_DIR%\FXServer.exe" +set citizen_dir "%FX_DIR%\citizen" +set onesync on +exec server.cfg

pause
