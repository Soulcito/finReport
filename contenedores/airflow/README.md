# USO DE MANTENEDORES

## CONSIDERACIONES

<p align="center">
  <img src="imagenes\image.png" alt="alt text" width="700">
</p>

1. Los excel que se encuentran en la carpeta mantenedores no se pueden cambiar de nombre, tampoco el nombre de las hojas, solo se pueden mantener los datos dentro de las hojas.
2. Los procesos de generacion de REDEC siempre actualizan los datos de estos excel, por eso es super importante mantener siempre el mismo nombre, ya que hay tablas internas que se relacionan con estos excel.
3. Es muy importante trabajar todos los datos como texto, es decir, si hay un codigo que se debe poner como 01, asegurar que en el excel la columna este como texto para que considere el 01 y no lo convierta a 1.
4. Hay excel que no se modifican y que son puntos de partida para el sistema, se explicara mas adelante.

<br><br>

## LISTADO DE MANTENEDORES

<br>

### 1. calendario_rdc20.xlsx

Este mantenedor le dice al sistema cuando empezo a regir el RDC20, ya que internamente finReport va haciendo un calculo de las fechas que se deben enviar, es decir, cada dos semanas y de manera mensual, esto es super importante ya que el RDC20 es una variacion de datos entre dos fechas ya sea bimensual y/o mensual, por tal motivo, se necesitaba realizar un calculo de las fechas de envio para poder programar este archivo.

**<span style="color:red">⚠️ ESTE ARCHIVO NO SE MODIFICA </span>**

<br>

### 2. interfaz_manager.xlsx

Este excel contiene la definicion de las interfaces a nivel de sistema, finReport toma esta definicion para poder realizar las transformaciones pertinentes desde la interfaz hacia la base de datos.

**<span style="color:red">⚠️ ESTE ARCHIVO NO SE MODIFICA </span>**

<br>

### 3. operacion_titulo.xlsx

Este excel si se puede modificar, contiene la relacion del concepto "Titulo de la operacion", si la deuda es positiva, negativa, etc .....

La hoja "operacion_titulo" contiene los datos validos de la CMF

**<span style="color:red">⚠️ ESTA HOJA NO SE MODIFICA </span>**

La hoja "operacion_titulo_rel" contiene los datos a relacionar de la institucion con los datos solicitados por la CMF,

**<span style="color:yellow">⚠️ ESTA HOJA SI SE PUEDE MODIFICAR </span>**

Ejemplo:

<p align="center">
  <img src="imagenes\image-1.png" alt="alt text" width="400">
</p>

Como default esta mapeado el mismo codigo de la CMF consigo mismo, es decir, la institucion podria enviar como datos a "relacionar" para etse concepto, los mismos datos solicitados por la CMF, por ese motivo, les recomiendo no eliminar estos default.

Si la institucion posee este concepto en sus sistemas pero con otros datos, es preferible que los envie tal cual y los relacione en este mantenedor, por ejemplo:

- Supongamos que para el concepto deuda positiva la institucion tiene la codificacion 0ABC y 0ABA
- Supongamos que para el concepto deuda negativa la institucion tiene la codificacion 0AAA
- Supongamos que para el concepto deuda positiva y negativa la institucion tiene la codificacion 0BBB
- Supongamos que la institucion tiene otros conceptos que la CMF no ha requerido pero que no cae en las categorias anteriores, por lo cual, iria en el codigo default (4 -> No) que puso la CMF, y estos codigos de la institucion son 0CCC, 0DDD y 0EEE

Por lo tanto, la institucion deberia modificar el excel de esta manera:

<p align="center">
  <img src="imagenes\image-2.png" alt="alt text" width="400">
</p>

<br>

### 4. parametros_generales.xlsx

Este excel es usado como parametria del sistema, en el se encuentran reservados los codigos 1 y 2 que son usados para identificar el codigo de institucion y el codigo de moneda UF respectivamente, el primer codigo es el que da la CMF a cada institucion y el segundo codigo es el codigo de moneda interno que usa la institucion para identificar la moneda UF.

Estos dos valores, deberian ser cambiados por cada institucion.

<p align="center">
  <img src="imagenes\image-3.png" alt="alt text" width="400">
</p>

**<span style="color:yellow">⚠️ ESTE ARCHIVO SI SE PUEDE MODIFICAR </span>**

<br>

### 5. tabla_banco_126.xlsx

Este excel contiene la tabla 126 solicitada por la CMF, las indicaciones para mantenerlo son las mismas que en el punto 3, ver [operacion_titulo.xlsx](#3-operacion_tituloxlsx)

**<span style="color:yellow">⚠️ ESTE ARCHIVO SOLO SE PUEDE MODIFICAR LA HOJA 2</span>**

<br>

### 6. tipo_deudor.xlsx

Este excel contiene la codificacion solicitada por la CMF para representar el deudor directo o indirecto, las indicaciones para mantenerlo son las mismas que en el punto 3, ver [operacion_titulo.xlsx](#3-operacion_tituloxlsx)

**NOTA: Considerar que en la interfaz cartera_operaciones solo se envian las operaciones del deudor directo. EL tema de indirecto se determina por la interfaz cartera_garantias.**

**<span style="color:yellow">⚠️ ESTE ARCHIVO SOLO SE PUEDE MODIFICAR LA HOJA 2</span>**

<br>

### 7. tipo_flujo.xlsx

Este excel contiene la codificacion solicitada por la CMF para representar los tipos de flujos solicitados para el RDC20, las indicaciones para mantenerlo son las mismas que en el punto 3, ver [operacion_titulo.xlsx](#3-operacion_tituloxlsx)

**<span style="color:yellow">⚠️ ESTE ARCHIVO SOLO SE PUEDE MODIFICAR LA HOJA 2</span>**

<br>

### 8. tipo_persona.xlsx

Este excel contiene la codificacion solicitada por la CMF para representar los tipos de personas como natural o juridica, las indicaciones para mantenerlo son las mismas que en el punto 3, ver [operacion_titulo.xlsx](#3-operacion_tituloxlsx)

**<span style="color:yellow">⚠️ ESTE ARCHIVO SOLO SE PUEDE MODIFICAR LA HOJA 2</span>**

<br>

## Recordar, cualquier consulta la pueden hacer por [aqui](https://github.com/Soulcito/finReport/issues)
