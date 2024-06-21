# Datos de migración en Chile

Proyecto que facilita la obtención y limpieza de datos sobre migración en Chile usando R.

Se procesan dos conjuntos de datos: los registros administrativos de permisos de residencia de extranjeros, y la estimación de personas extranjeras residentes habituales en Chile.


**Registros administrativos de permisos de residencia de extranjeros:**
> base de datos originada a partir de los registros administrativos de permisos de residencia de extranjeros en Chile en el período 2000 al cierre de semestre de cada año. En particular, los datos corresponden a Residencias Temporales y Residencias Definitivas otorgadas, y a solicitudes, otorgamientos y rechazos de Refugio.

**Estimación de personas extranjeras residentes habituales en Chile:**
> El Servicio Nacional de Migraciones (SERMIG) y el Instituto Nacional de Estadísticas (INE), en colaboración con la Policía de Investigaciones de Chile (PDI), el Ministerio de Relaciones Exteriores (MINREL) y el Servicio de Registro Civil e Identificación (SRCI), entregan anualmente una estimación acerca de la cantidad de personas extranjeras residentes habituales en Chile al 31 de diciembre de cada año a nivel nacional, regional y para las comunas con más de 10.000 personas extranjeras residentes estimadas.


![Gráfico de residencias otorgadas a migrantes desde 2010 a 2023 de los 5 países con mayor cantidad de residencias](graficos/residencias_2010_2023.jpg)

**Obtener datos:** El script `obtener_datos.R` descarga los datos originales desde el [sitio oficial del Servicio Nacional de Migraciones]((https://serviciomigraciones.cl/estudios-migratorios/datos-abiertos/) y los descomprime. Estos datos corresponden a: 
- residencias temporales acogidas
- residencias temporales otorgadas
- residencias definitivas acogidas
- residencias definitivas otorgadas
- estimación de extranjeros residentes en Chile 2022

**Procesar datos:** El script `procesar_datos.R` aplica la función `cargar_datos_residencias()` para ir cargando los datos de cada fuente de datos, ya que cada archivo comprimido contiene varios archivos Excel. Al cargarlos, obtiene el conteo de solicitudes por comuna donde se realiza, país de origen de la persona que la realiza, y año. Finalmente, une todos los datos en una sola tabla con 267.909 filas, que se guarda como `residencias_comuna_año.csv`. Adicionalmente, se guarda otra tabla `residencias_comuna_2023.csv`, que solo contiene los datos de 2023 (los más recientes a la fecha), reduciendo el número de filas a 13.088.


## Fuentes

**Residencias temporales y residencias definitivas:** [Servicio Nacional de Migraciones (SERMIG)](https://serviciomigraciones.cl/estudios-migratorios/datos-abiertos/)

**Estimación de extranjeros:** [Servicio Nacional de Migraciones (SERMIG)](https://serviciomigraciones.cl/estudios-migratorios/estimaciones-de-extranjeros/)