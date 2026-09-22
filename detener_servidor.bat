@echo off
title Detener Servidor FiveM y Base de Datos
color 0c
echo ========================================================
echo        DETENIENDO SERVIDOR FIVEM Y BASE DE DATOS
echo ========================================================
echo.

echo Deteniendo FXServer...
taskkill /f /im FXServer.exe >nul 2>&1

echo Deteniendo MariaDB...
taskkill /f /im mysqld.exe >nul 2>&1
taskkill /f /im mariadbd.exe >nul 2>&1

echo.
echo Todo se ha detenido correctamente.
timeout /t 3
