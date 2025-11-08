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
set "NETWORK_NAME=finreport-net"

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

echo ================================
echo   Verificando imagen: %IMAGE_NAME%
echo ================================

set "REBUILD_IMAGE=0"

:: Verificar si existe la imagen
docker image inspect %IMAGE_NAME% >nul 2>&1
if %errorlevel% neq 0 (
    echo Imagen no encontrada. Construyendo nueva...
    docker build -t %IMAGE_NAME% .
) else (
    echo La imagen "%IMAGE_NAME%" ya existe.
    set /p recreate="¿Desea reconstruirla desde el Dockerfile y reiniciar el contenedor? (s/N): "
    if /i "!recreate!"=="s" (
        set "REBUILD_IMAGE=1"
    ) else (
        echo Se mantiene la imagen existente.
    )
)

:: ================================
:: SI EL USUARIO QUIERE RECREAR, ELIMINAMOS EL CONTENEDOR
:: ================================
if "%REBUILD_IMAGE%"=="1" (
    echo.
    echo Verificando si existe el contenedor %CONTAINER_NAME%...
    docker ps -a --format "{{.Names}}" | find "%CONTAINER_NAME%" >nul
    if %errorlevel%==0 (
        echo Deteniendo y eliminando contenedor anterior...
        docker stop %CONTAINER_NAME% >nul 2>&1
        docker rm %CONTAINER_NAME% >nul 2>&1
    )
    echo Reconstruyendo imagen...
    docker build -t %IMAGE_NAME% .
)

echo.
echo ================================
echo   Verificando red Docker: %NETWORK_NAME%
echo ================================
docker network inspect %NETWORK_NAME% >nul 2>&1
if %errorlevel% neq 0 (
    echo La red no existe. Creando red %NETWORK_NAME%...
    docker network create %NETWORK_NAME%
    if %errorlevel% equ 0 (
        echo Red %NETWORK_NAME% creada correctamente.
    ) else (
        echo Error al crear la red %NETWORK_NAME%.
        exit /b 1
    )
) else (
    echo Red %NETWORK_NAME% ya existe.
)

echo.
echo ================================
echo   Verificando contenedor: %CONTAINER_NAME%
echo ================================

:: Verificar si el contenedor existe
docker ps -a --format "{{.Names}}" | find "%CONTAINER_NAME%" >nul
if %errorlevel%==0 (
    docker ps --format "{{.Names}}" | find "%CONTAINER_NAME%" >nul
    if %errorlevel%==0 (
        echo El contenedor %CONTAINER_NAME% está corriendo.
        set /p restart="¿Desea reiniciarlo? (s/N): "
        if /i "!restart!"=="s" (
            echo Reiniciando contenedor...
            docker restart %CONTAINER_NAME%
        ) else (
            echo No se reiniciará el contenedor.
        )
    ) else (
        echo El contenedor existe pero está detenido.
        set /p startit="¿Desea iniciarlo? (s/N): "
        if /i "!startit!"=="s" (
            docker start %CONTAINER_NAME%
        ) else (
            echo No se iniciará el contenedor.
        )
    )
) else (
    echo Creando nuevo contenedor con persistencia...
	docker run -d ^
	  --name %CONTAINER_NAME% ^
	  --network %NETWORK_NAME% ^
	  -e POSTGRES_DB=%POSTGRES_DB% ^
	  -e POSTGRES_USER=%POSTGRES_USER% ^
	  -e POSTGRES_PASSWORD=%POSTGRES_PASSWORD% ^
	  -p %PORT_HOST%:5432 ^
	  -v "%DATA_DIR%:/var/lib/postgresql/data" ^
	  %IMAGE_NAME%
)

echo ================================
echo Contenedor PostgreSQL listo
echo ================================
docker ps | find "%CONTAINER_NAME%"

endlocal
pause
