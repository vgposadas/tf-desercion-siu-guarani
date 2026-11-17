-- Q.2.H. Equivalencias y aprobaciones por resolución -> equivalencias.csv
-- Criterios: No se consideran actividad ni rendimiento; se usan para la variable «ingresó con equivalencias». No tienen año académico: se ubican por fecha.
-- Resultado: 580 filas.
-- Reemplazar CLAVE_SECRETA (y NOMBRE_SEDE_* en q2_a) antes de ejecutar. Ver README.
SET search_path TO negocio, public;

WITH poblacion AS (
  SELECT a.alumno
  FROM negocio.sga_propuestas_aspira pa
  JOIN negocio.sga_alumnos a
       ON a.persona = pa.persona AND a.propuesta = pa.propuesta
  WHERE pa.propuesta = 19
    AND pa.ubicacion IN (2, 3)
    AND pa.anio_academico BETWEEN 2015 AND 2023
    AND pa.situacion_asp IN (1, 2)
)
SELECT md5('CLAVE_SECRETA' || p.alumno::text) AS id_est,
       h.elemento AS materia,
       h.tipo,
       h.fecha,
       h.resultado
FROM poblacion p
JOIN negocio.vw_hist_academica h     ON h.alumno = p.alumno
JOIN negocio.sga_planes_versiones pv ON pv.plan_version = h.plan_version
WHERE pv.plan = 28
  AND h.tipo IN ('Equivalencia', 'Aprob. por Resolución')
  AND h.fecha <= DATE '2026-03-31';
