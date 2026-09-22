@echo off
title Importador de Base de Datos - Spain Rol QBCore
color 0a
echo ========================================================
echo       IMPORTADOR DE BASE DE DATOS - SPAIN ROL
echo ========================================================
echo.
echo Importando estructura y datos de qbcoreframework...
"%~dp0bin\mysql.exe" --defaults-file="%~dp0my.ini" -u root -e "CREATE DATABASE IF NOT EXISTS qbcoreframework CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
"%~dp0bin\mysql.exe" --defaults-file="%~dp0my.ini" -u root qbcoreframework < "%~dp0qbcoreframework_dump.sql"
echo.
echo ========================================================
echo   Base de datos importada y sincronizada con exito!
echo ========================================================
timeout /t 3
