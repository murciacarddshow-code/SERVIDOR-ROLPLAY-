@echo off
title Sincronizar Cambios de mi Companero desde GitHub
color 0b
echo ========================================================
echo        SINCRONIZAR CAMBIOS DESDE GITHUB (PULL)
echo ========================================================
echo.

set "GIT_CMD=%~dp0tools\git\cmd\git.exe"

echo Descargando las ultimas actualizaciones de tu companero...
"%GIT_CMD%" pull

echo.
echo ========================================================
echo   Servidor actualizado al ultimo estado de GitHub!
echo ========================================================
pause
