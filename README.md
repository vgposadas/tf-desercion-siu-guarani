# Análisis de historias académicas de SIU Guarani mediante minería de datos

Código del Trabajo Final de Grado de Ingeniería en Informática: análisis de la deserción de los ingresantes 2015-2023 a Ingeniería Agronómica con agrupamiento (K-means y Ward) y análisis de supervivencia (Kaplan-Meier, regresión de Cox y Random Survival Forest).

**El repositorio no contiene datos de estudiantes.** Contiene las consultas de extracción, el script de carga y los notebooks, sin resultados. Para reproducir el análisis hace falta acceso autorizado a una copia de la base de datos de SIU Guarani 3.21.3 de la unidad académica.

## Estructura

```
sql/                      Consultas de extracción (Anexo Q.2 de la tesis) y del tablero (Q.3)
scripts/cargar_csv.py     Carga los CSV exportados en el esquema `tesis` de la base de trabajo
notebooks/
  01_exploracion.ipynb    Calidad de los datos (tarea 2)
  02_preparacion.ipynb    Actividad académica, definición de deserción y censura; tablas trayectorias, cursadas y aprobaciones (tarea 3)
  03_indicadores.ipynb    Indicadores del primer año; tabla indicadores (tarea 4)
  04_agrupamiento.ipynb   K-means y Ward; tabla grupos (tarea 5)
  05_supervivencia.ipynb  Kaplan-Meier, Cox, Cox extendido, RSF, evaluación e importancia (tareas 6 y 7)
  06_sensibilidad.ipynb   Análisis de sensibilidad pedidos en la revisión del tutor (solo lectura)
config_local.ejemplo.py   Plantilla para los nombres reales de las sedes (no se publican)
requirements.txt          Versiones de las bibliotecas (Python 3.12)
```

## Flujo de trabajo

1. **Extracción (solo lectura sobre una copia de SIU Guarani).** Ejecutar las consultas `sql/q2_*.sql` y exportar cada resultado a `datos/<nombre>.csv` (el nombre del archivo figura en la primera línea de cada consulta). Antes de ejecutarlas, reemplazar `CLAVE_SECRETA` por la clave de seudonimización, que se guarda fuera del repositorio.
2. **Carga en la base de trabajo.** `python scripts/cargar_csv.py --carpeta datos` crea el esquema `tesis` y carga cada CSV en una tabla del mismo nombre, con un control de la cantidad de filas.
3. **Configuración.** Copiar `config_local.ejemplo.py` como `notebooks/config_local.py` y completar los nombres de las sedes.
4. **Análisis.** Ejecutar los notebooks en orden (01 a 06). Cada uno lee de la base de trabajo y guarda sus tablas en el esquema `tesis`; 06 no modifica la base.
5. **Tablero.** Crear la vista y las tablas de `sql/q3_tablero.txt` y abrir el archivo de Power BI Desktop conectado a la base de trabajo.

```bash
python -m venv .venv
.venv\Scripts\activate          # en Windows; en Linux: source .venv/bin/activate
pip install -r requirements.txt
```

## Seudonimización

Cada estudiante se identifica con un código (`id_est`) calculado a partir del identificador interno y de una clave secreta; no se extraen legajo, documento ni nombre. Las consultas usan `md5('CLAVE_SECRETA' || alumno)`, que es lo que se ejecutó en el trabajo. Para una nueva extracción se recomienda HMAC-SHA-256 (extensión `pgcrypto` de PostgreSQL):

```sql
encode(hmac(p.alumno::text, 'CLAVE_SECRETA', 'sha256'), 'hex') AS id_est
```

Si se cambia la función, hay que cambiarla en **todas** las consultas, para que los códigos sigan uniendo las tablas.

## Reglas principales (detalle en el Capítulo IV de la tesis)

- Fecha de corte: año académico 2025 (incluye los turnos de febrero y marzo de 2026). El tiempo se mide en cuatrimestres.
- Actividad académica: inscripción activa a cursada o examen, o resultado en actas. 06 repite el análisis con la actividad medida solo por resultados.
- Deserción: tres o más cuatrimestres consecutivos sin actividad hasta el corte. Los egresados se censuran en el egreso.
- Grupo del modelo: quienes completaron el primer año (985; 978 con indicadores).
