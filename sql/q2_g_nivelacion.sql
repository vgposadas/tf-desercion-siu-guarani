-- Q.2.G. Curso de nivelación -> nivelacion.csv
-- Criterios: Resultados del Curso de Nivelación (propuesta 59) de las personas de la población. El curso tiene su propio registro de alumno, por eso se vincula por persona; el código id_est se calcula igual que en A (con el alumno de Ingeniería Agronómica) para que coincida.
-- Resultado: 1.614 filas.
-- Reemplazar CLAVE_SECRETA (y NOMBRE_SEDE_* en q2_a) antes de ejecutar. Ver README.
SET search_path TO negocio, public;

WITH poblacion AS (
  SELECT a.alumno, pa.persona
  FROM negocio.sga_propuestas_aspira pa
  JOIN negocio.sga_alumnos a
       ON a.persona = pa.persona AND a.propuesta = pa.propuesta
  WHERE pa.propuesta = 19
    AND pa.ubicacion IN (2, 3)
    AND pa.anio_academico BETWEEN 2015 AND 2023
    AND pa.situacion_asp IN (1, 2)
)
SELECT md5('CLAVE_SECRETA' || p.alumno::text) AS id_est,
       h.elemento               AS materia,
       h.actividad_nombre       AS materia_nombre,
       h.anio_academico::int    AS anio_academico,
       h.fecha,
       h.tipo,
       h.resultado,
       h.nota
FROM poblacion p
JOIN negocio.vw_hist_academica h     ON h.persona = p.persona
JOIN negocio.sga_planes_versiones pv ON pv.plan_version = h.plan_version
JOIN negocio.sga_planes pl           ON pl.plan = pv.plan
WHERE pl.propuesta = 59
  AND h.fecha <= DATE '2026-03-31';
