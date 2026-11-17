-- Q.2.D. Inscripciones a cursadas -> insc_cursada.csv
-- 
-- Resultado: 24.479 filas.
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
       cm.elemento                     AS materia,
       ic.fecha_inscripcion::date      AS fecha,
       vp.anio_academico::int          AS anio_academico,
       vp.periodos_lectivo_tipo_nombre AS tipo_periodo,
       vp.periodo_generico_nombre      AS periodo
FROM poblacion p
JOIN negocio.sga_insc_cursada ic     ON ic.alumno = p.alumno
JOIN negocio.sga_planes_versiones pv ON pv.plan_version = ic.plan_version
JOIN negocio.sga_comisiones cm       ON cm.comision = ic.comision
JOIN negocio.vw_periodos_lectivos vp ON vp.periodo_lectivo = cm.periodo_lectivo
WHERE pv.plan = 28
  AND ic.estado = 'A'
  AND ic.fecha_inscripcion < DATE '2026-04-01';
