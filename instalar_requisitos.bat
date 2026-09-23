@echo off
setlocal enabledelayedexpansion
title Instalador y Reparador de Requisitos - Spain Rol
color 0a

echo ===============================================================================
echo            INSTALADOR Y REPARADOR DE ENTORNO - SERVIDOR ROLEPLAY
echo ===============================================================================
echo.

set "SERVER_ROOT=%~dp0"
set "DB_DIR=%SERVER_ROOT%database"
set "FX_DIR=%SERVER_ROOT%server"
set "DATA_DIR=%SERVER_ROOT%server-data"

echo Este asistente revisara y descargara todo lo necesario para ejecutar el servidor:
echo   1. Artefactos oficiales de FXServer (FiveM Windows Server)
echo   2. Motor de Base de Datos MariaDB 10.11 Portable
echo   3. Inicializacion y volcado de tablas QBCore
echo.
pause

:: 1. FXServer
echo.
echo [1/3] Comprobando artefactos de FXServer...
if not exist "%FX_DIR%\FXServer.exe" (
    echo Descargando e instalando FXServer en la carpeta 'server'...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$url = 'https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/35245-6efb47dff473c0e2a12fb50b08d74c0eb24a50d5/server.7z';" ^
        "if (!(Test-Path '%FX_DIR%')) { New-Item -ItemType Directory -Path '%FX_DIR%' | Out-Null };" ^
        "Write-Host 'Descargando paquete FiveM...' -ForegroundColor Cyan;" ^
        "curl.exe -L $url -o '%FX_DIR%\server.7z';" ^
        "Write-Host 'Extrayendo binarios...' -ForegroundColor Yellow;" ^
        "tar.exe -xf '%FX_DIR%\server.7z' -C '%FX_DIR%';" ^
        "Remove-Item '%FX_DIR%\server.7z' -Force;"
    echo [OK] FXServer instalado correctamente!
) else (
    echo [OK] FXServer ya se encuentra instalado.
)

:: 2. MariaDB
echo.
echo [2/3] Comprobando motor de Base de Datos MariaDB...
if not exist "%DB_DIR%\bin\mysqld.exe" (
    echo Descargando MariaDB Portable oficial...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$zip = \"$env:TEMP\mariadb.zip\";" ^
        "$tmp = \"$env:TEMP\mariadb_tmp\";" ^
        "Write-Host 'Descargando MariaDB 10.11...' -ForegroundColor Cyan;" ^
        "curl.exe -L 'https://archive.mariadb.org/mariadb-10.11.8/winx64-packages/mariadb-10.11.8-winx64.zip' -o $zip;" ^
        "Write-Host 'Extrayendo MariaDB...' -ForegroundColor Yellow;" ^
        "tar.exe -xf $zip -C $env:TEMP;" ^
        "Copy-Item \"$env:TEMP\mariadb-10.11.8-winx64\*\" -Destination '%DB_DIR%' -Recurse -Force;" ^
        "Remove-Item \"$env:TEMP\mariadb-10.11.8-winx64\" -Recurse -Force;" ^
        "Remove-Item $zip -Force;"
    echo [OK] Binarios de MariaDB listos!
) else (
    echo [OK] MariaDB ya se encuentra instalado.
)

:: 3. Inicializar data y base de datos
echo.
echo [3/3] Comprobando estructura de datos de QBCore...
set "DATA_DIR_SLASH=%DB_DIR:\=/%/data"
powershell -NoProfile -Command "(Get-Content '%DB_DIR%\my.ini') -replace '^datadir=.*', 'datadir=\"%DATA_DIR_SLASH%\"' | Set-Content '%DB_DIR%\my.ini'" >nul 2>&1

if not exist "%DB_DIR%\data" (
    echo Inicializando directorio de datos de MariaDB...
    "%DB_DIR%\bin\mariadb-install-db.exe" --datadir="%DB_DIR%\data"
)

:: Iniciar temporalmente para importar si es necesario
echo Verificando tablas en MariaDB...
start "" /b "%DB_DIR%\bin\mysqld.exe" --defaults-file="%DB_DIR%\my.ini"
timeout /t 3 /nobreak >nul

powershell -NoProfile -Command "& '%DB_DIR%\bin\mysql.exe' -u root -e 'CREATE DATABASE IF NOT EXISTS qbcoreframework CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'; Get-Content '%DB_DIR%\qbcoreframework_backup.sql' | & '%DB_DIR%\bin\mysql.exe' -u root qbcoreframework;" >nul 2>&1

echo Deteniendo servicio temporal de MariaDB...
taskkill /f /im mysqld.exe >nul 2>&1
taskkill /f /im mariadbd.exe >nul 2>&1

echo.
echo ===============================================================================
echo  [ENHORABUENA] Todos los requisitos y la base de datos estan 100% listos!
echo  Ya puedes iniciar el servidor con 'iniciar_servidor.bat'
echo ===============================================================================
echo.
pause
