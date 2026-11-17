-- Q.2.E. Inscripciones a exámenes -> insc_examen.csv
-- 
-- Resultado: 7.428 filas.
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
       ie.fecha_inscripcion::date AS fecha
FROM poblacion p
JOIN negocio.sga_insc_examen ie      ON ie.alumno = p.alumno
JOIN negocio.sga_planes_versiones pv ON pv.plan_version = ie.plan_version
WHERE pv.plan = 28
  AND ie.estado = 'A'
  AND ie.fecha_inscripcion < DATE '2026-04-01';
