@echo off
title Conectar Servidor con GitHub
color 0b
echo ========================================================
echo        VINCULAR SERVIDOR CON TU REPOSITORIO GITHUB
echo ========================================================
echo.
echo 1. Crea un repositorio VACIO y PRIVADO en https://github.com/new
echo    (IMPORTANTE: No marques "Add README", ni .gitignore, ni licencia).
echo.
echo 2. Copia la URL HTTPS de tu repositorio de GitHub.
echo    Ejemplo: https://github.com/tu-usuario/spain-rol.git
echo.
set /p REPO_URL="Pega aqui la URL de tu repositorio: "

if "%REPO_URL%"=="" (
    echo No has introducido ninguna URL. Operacion cancelada.
    pause
    exit /b
)

set "GIT_CMD=%~dp0tools\git\cmd\git.exe"

echo.
echo [1/2] Configurando origen remoto...
"%GIT_CMD%" remote remove origin >nul 2>&1
"%GIT_CMD%" remote add origin %REPO_URL%

echo.
echo [2/2] Subiendo el servidor a la rama 'main' de GitHub...
echo (Si es la primera vez, se te abrira una ventana para iniciar sesion en GitHub).
"%GIT_CMD%" push -u origin main

echo.
echo ========================================================
echo   Vinculacion completada!
echo ========================================================
pause
