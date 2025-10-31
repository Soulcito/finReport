@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

:: ==========================================
:: CONFIGURACIÓN
:: ==========================================
set "IMAGE_NAME=finreport"
set "CONTAINER_NAME=finreport"
set "PORT_HOST=25433"
set "SERVER_HOST=localhost"

set "POSTGRES_DB=finreport_db"
set "POSTGRES_USER=finreport_user"
set "POSTGRES_PASSWORD=Finr3p0rt@2025"

set "DATA_DIR=%cd%\pgdata"

:: ==========================================
:: CREAR DIRECTORIOS SI NO EXISTEN
:: ==========================================
if not exist "%DATA_DIR%" (
    echo Creando directorio de datos...
    mkdir "%DATA_DIR%"
)

:: ==========================================
:: VERIFICAR IMAGEN EXISTENTE
:: ==========================================
docker image inspect %IMAGE_NAME% >nul 2>&1
if %errorlevel% equ 0 (
    echo Imagen %IMAGE_NAME% encontrada.
    set /p REBUILD="Desea reconstruir la imagen? (s/n): "
    if /i "%REBUILD%"=="s" (
        echo Eliminando imagen existente...
        docker rmi -f %IMAGE_NAME%
        echo Reconstruyendo imagen...
        docker build -t %IMAGE_NAME% .
    ) else (
        echo Manteniendo imagen existente.
    )
) else (
    echo Imagen no encontrada. Construyendo nueva...
    docker build -t %IMAGE_NAME% .
)

:: ==========================================
:: VERIFICAR SI EXISTE CONTENEDOR
:: ==========================================
for /f "tokens=*" %%i in ('docker ps -a -q -f "name=%CONTAINER_NAME%"') do set CONTAINER_ID=%%i

if defined CONTAINER_ID (
    echo Contenedor %CONTAINER_NAME% encontrado.
    echo Deteniendo y eliminando contenedor previo...
    docker stop %CONTAINER_NAME% >nul 2>&1
    docker rm %CONTAINER_NAME% >nul 2>&1
)

:: ==========================================
:: CREAR CONTENEDOR NUEVO
:: ==========================================
echo ================================
echo   Iniciando contenedor nuevo
echo ================================
docker run -d ^
  --name %CONTAINER_NAME% ^
  -e POSTGRES_DB=%POSTGRES_DB% ^
  -e POSTGRES_USER=%POSTGRES_USER% ^
  -e POSTGRES_PASSWORD=%POSTGRES_PASSWORD% ^
  -p %PORT_HOST%:5432 ^
  -v "%DATA_DIR%:/var/lib/postgresql/data" ^
  %IMAGE_NAME%

if %errorlevel% neq 0 (
    echo Error al iniciar el contenedor.
    pause
    exit /b 1
)

echo ================================
echo Contenedor PostgreSQL listo
echo ================================
docker ps | find "%CONTAINER_NAME%"

endlocal
pause
