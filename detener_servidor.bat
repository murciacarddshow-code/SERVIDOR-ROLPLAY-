@echo off
title Detener Servidor FiveM y Base de Datos
color 0c

echo ===============================================================================
echo                 DETENIENDO SERVIDOR FIVEM Y BASE DE DATOS
echo ===============================================================================
echo.

echo [1/2] Cerrando FXServer...
taskkill /f /im FXServer.exe >nul 2>&1

echo [2/2] Deteniendo MariaDB y servicios de base de datos...
taskkill /f /im mysqld.exe >nul 2>&1
taskkill /f /im mariadbd.exe >nul 2>&1

timeout /t 1 /nobreak >nul

echo.
echo ===============================================================================
echo  [OK] Todos los servicios (FXServer y MariaDB) se han detenido con exito.
echo  Los puertos 30120, 40120 y 3306 estan completamente liberados.
echo ===============================================================================
echo.
ping 127.0.0.1 -n 3 >nul

