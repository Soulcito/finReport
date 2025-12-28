<h1 align="center">📜 finReport</h1>

<h3 align="center">Proyecto Open Source para reporteria regulatoria</h3>

<br />

<p align="center">
  <a href="https://opensource.org/license/apache-2-0">
    <img src="https://img.shields.io/badge/License-Apache 2.0-orange.svg?style=flat-square" />
  </a>
  &nbsp;
</p>

<br />

## ⭐ Que es finReport?

finReport es la culminación de más de 20 años de experiencia trabajando en banca, abarcando distintas áreas como el análisis, la revisión, el desarrollo y la gestión de procesos financieros y tecnológicos.

Durante muchos años existió la inquietud (el bicho), de construir algo propio. Sin embargo, la normativa bancaria, por su nivel de madurez, complejidad y extensión, hacía difícil encontrar un punto de partida claro y abordable.

Ese punto de partida apareció cuando la CMF lanzó [REDEC](https://www.cmfchile.cl/portal/principal/613/w3-propertyvalue-48621.html), un Manual de Sistema de Información orientado a Entidades Financieras. Este proyecto lo empece como un desafio propio hace un poco mas de dos meses (Inicios de Octubre) con mucho analisis antes de empezar a tirar lineas de codigo. Es un sistema pensado mas en el usuario final en donde la parametrizacion no sea un dolor de cabeza y entregue mas visibilidad de que es lo que hace el sistema.

## ✨ Caracteristicas

- Proyecto OpenSource bajo licencia Apache 2.0
- Sistemas bases usados para crear finReport tambien OpenSource (Apache Airflow y PostgreSQL)
- Lenguaje python y PL/pgSQL

## ✨ Pre requisitos

Tener docker instalado

- [Instalacion en windows](https://docs.docker.com/desktop/setup/install/windows-install/)
- [Instalacion en mac](https://docs.docker.com/desktop/setup/install/mac-install/)
- [Instalacion en linux](https://docs.docker.com/desktop/setup/install/linux/)

## ✨ Instalacion

1. [Primero debes bajar el proyecto](https://github.com/Soulcito/finReport/archive/refs/heads/main.zip)
2. Dentro de la carpeta contenedores estan los sistemas de Airflow y Postgres, copialos a un directorio donde lo vas a instalar
3. Dentro de la carpeta airflow hay dos ejecutables
   airflow_run.bat: Si estas usando windows
   airflow_run.sh: En el caso que estes usando linux
   Ejecutar como administrador, si estas en linux recordar dar permisos de ejecucion al bash.
4. Dentro de la carpeta finReport se debe crear el archivo postgres.env, dentro de este se colocan el nombre de la base de datos, el usuario y password, adjunto ejemplo:

<p align="center">
  <img src="imagenes\image.png" alt="alt text" width="400">
</p>

5. Luego ejecutar:
   run_postgres.bat: Si estas en windows
   run_postgres.sh: Si estas usando Linux
   Ejecutar como administrador, si estas en linux recordar dar persmisos de ejecucion al bash.

## 🚀 Comienzo rapido

- Una ves instalado los dos sistemas deberias poder acceder a la aplicacion de airflow, accediendo en un browser a http://localhost:8181/auth/login
<p align="center">
  <img src="imagenes\image-1.png" alt="alt text" width="400">
</p>

- El usuario admin lo crea airflow por defecto, para poder obtener la contraseña, si estas en windows, habre un cmd y ejecuta el siguiente comando

```
      docker logs airflow | find "user"
```

En linux sobre la terminal

```
      docker logs airflow | grep "user"
```

- Una vez ingresado con las credenciales podras ver el proceso "orquestador_redec" y ejecutarlo con el boton "Trigger"

<br><br>

<p align="center">
  <img src="imagenes\image-2.png" alt="alt text" width="900">
</p>
<br><br>

## ✨ Consideraciones para el modulo de generador de archivos

EL sistema maneja mantenedores a traves de excel, existen tablas internas para realizar conversiones de datos de la institucion a datos solicitados por REDEC, los datos que estan en los mantenedores son datos de default, ver documentacion de interfaces [aqui](https://github.com/Soulcito/finReport/blob/main/Analisis/Interfaces/interfaces.xlsx)

Todo lo que es reporte sale en formato TXT y en excel, los log salen en excel para mejor el analisis del usuario, todo esto queda dentro de la carpeta airflow/finReport

### Ejemplo de interfaces:<br><br>

<p align="center">
  <img src="imagenes\image-3.png" alt="alt text" width="700">
</p>

### Ejemplo de logs:<br><br>

<p align="center">
  <img src="imagenes\image-4.png" alt="alt text" width="700">
</p>

### Ejemplo de mantenedores:<br><br>

<p align="center">
  <img src="imagenes\image-5.png" alt="alt text" width="700">
</p>

### Ejemplo de reportes:<br><br>

<p align="center">
  <img src="imagenes\image-6.png" alt="alt text" width="700">
</p>
<br><br>

## ✨ Sistema de validacion

El sistema de validacion funciona de la misma manera que el generador de interfaces, posee un directorio en airflow/finReport/validador donde se dejan los archivos a validar

<p align="center">
  <img src="imagenes\image-7.png" alt="alt text" width="700">
</p>

## ✨ Consideraciones para el modulo de validador de reportes

1. Directorio donde se dejan los archivos deben quedar en airflow/finReport/validador

2. Los archivos deben estar con extension .txt

3. Los primeros 5 caracteres del archivo debe contener el nombre del reporte que corresponde en el MSI Redec, por ejemplo RDC01XXXXXXXX.txt | RDC20XXXXXXXX.txt

4. En el directorio airflow/finReport/validador/resultado , quedan los excel con el detalle del archivo que se valido en la primera hoja, y en la segunda hoja se encuentran todas las validaciones que se realizaron independiente del estado. Por cada ejecucion queda un excel con fecha de proceso y fecha de ejecucion.

<br>
<p align="center">
  <img src="imagenes\image-8.png" alt="alt text" width="700">
</p>
<br>

5. En la seccion de Analisis del proyecto hay un excel "validacion_reportes.xlsx" donde se explica un poco los que se encuentran en la solucion, lo puedes encontrar [aqui](https://github.com/Soulcito/finReport/tree/main/Analisis/validaciones)

## ✨ Consultas y/o sugerencias [aqui](https://github.com/Soulcito/finReport/issues)
