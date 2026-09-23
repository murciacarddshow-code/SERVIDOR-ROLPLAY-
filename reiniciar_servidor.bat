@echo off
title Reiniciar Servidor FiveM - Spain Rol
color 0e

echo ===============================================================================
echo                 REINICIANDO SERVIDOR FIVEM - SPAIN ROL
echo ===============================================================================
echo.
echo [1/2] Cerrando instancias activas de FXServer...
taskkill /f /im FXServer.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [2/2] Iniciando servidor con txAdmin y MariaDB...
echo.
call "%~dp0iniciar_servidor.bat"
