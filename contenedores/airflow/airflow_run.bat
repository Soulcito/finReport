@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

:: ================================
:: CONFIGURACIÓN
:: ================================
set "IMAGE_NAME=airflow-3.1.0"
set "CONTAINER_NAME=airflow"
set "PORT_HOST=8181"
set "SERVER_HOST=localhost"
set "NETWORK_NAME=finreport-net"

:: Directorios locales para persistencia de Airflow
set "DAGS_DIR=%cd%\dags"
set "LOGS_DIR=%cd%\logs"
set "PLUGINS_DIR=%cd%\plugins"

:: Directorios locales para finReport
set "FINREPORT_DIR=%cd%\finReport"
set "INTERFACE=%FINREPORT_DIR%\interface"
set "REPORTS=%FINREPORT_DIR%\reports"
set "LOGS_FINREPORT=%FINREPORT_DIR%\logs"
set "MANTENEDORES=%FINREPORT_DIR%\mantenedores"

:: ================================
:: CREAR DIRECTORIOS SI NO EXISTEN
:: ================================
if not exist "%DAGS_DIR%" mkdir "%DAGS_DIR%"
if not exist "%LOGS_DIR%" mkdir "%LOGS_DIR%"
if not exist "%PLUGINS_DIR%" mkdir "%PLUGINS_DIR%"
if not exist "%FINREPORT_DIR%" mkdir "%FINREPORT_DIR%"
if not exist "%INTERFACE%" mkdir "%INTERFACE%"
if not exist "%REPORTS%" mkdir "%REPORTS%"
if not exist "%LOGS_FINREPORT%" mkdir "%LOGS_FINREPORT%"
if not exist "%MANTENEDORES%" mkdir "%MANTENEDORES%"

:: ================================
:: MOVER CONTENIDO DE /mantenedores → /finReport/mantenedores
:: ================================
if exist "%cd%\mantenedores" (
    echo Moviendo contenido desde carpeta raiz "mantenedores" a "%MANTENEDORES%"
    xcopy "%cd%\mantenedores\*" "%MANTENEDORES%\" /E /Y >nul
    echo Limpiando carpeta raiz "mantenedores"...
    rmdir /S /Q "%cd%\mantenedores"
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
    docker run -d --name %CONTAINER_NAME% ^
      --network %NETWORK_NAME% ^
      -p %PORT_HOST%:8080 ^
      -v "%DAGS_DIR%:/opt/airflow/dags" ^
      -v "%LOGS_DIR%:/opt/airflow/logs" ^
      -v "%PLUGINS_DIR%:/opt/airflow/plugins" ^
      -v "%INTERFACE%:/opt/airflow/finReport/interface" ^
      -v "%REPORTS%:/opt/airflow/finReport/reports" ^
      -v "%LOGS_FINREPORT%:/opt/airflow/finReport/logs" ^
      -v "%MANTENEDORES%:/opt/airflow/finReport/mantenedores" ^
      %IMAGE_NAME%
)

echo.
echo Esperando a que Airflow inicialice...
timeout /t 10 >nul

echo.
echo ================================
echo Airflow disponible en: http://%SERVER_HOST%:%PORT_HOST%
echo ================================
echo.
echo Para ver las credenciales automáticas generadas por Airflow:
echo    docker logs %CONTAINER_NAME% ^| find "user"
echo.
echo (El usuario admin se crea automáticamente por airflow standalone)
pause
