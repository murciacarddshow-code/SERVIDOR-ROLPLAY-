@echo off
title Subir Cambios a GitHub
color 0a
echo ========================================================
echo         SUBIR MIS CAMBIOS AL REPOSITORIO GITHUB
echo ========================================================
echo.

set "GIT_CMD=%~dp0tools\git\cmd\git.exe"

set /p COMMIT_MSG="Describe brevemente que has cambiado o anadido: "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=Actualizacion de recursos y sistemas

echo.
echo [1/3] Detectando archivos modificados y nuevos...
"%GIT_CMD%" add .

echo [2/3] Guardando version local...
"%GIT_CMD%" commit -m "%COMMIT_MSG%"

echo [3/3] Subiendo cambios a GitHub...
"%GIT_CMD%" push

echo.
echo ========================================================
echo   Cambios subidos a GitHub con exito!
echo ========================================================
pause
