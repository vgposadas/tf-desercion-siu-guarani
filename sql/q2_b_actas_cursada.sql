-- Q.2.B. Resultados de cursada -> actas_cursada.csv
-- Criterios: Regularidades (origen R) y promociones (origen P), plan 28, registros activos, hasta el corte. resultado: A = regular/aprobado, R = libre/reprobado, U = ausente.
-- Resultado: 26.465 filas.
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
       vp.anio_academico::int          AS anio_academico,
       vp.periodos_lectivo_tipo_nombre AS tipo_periodo,
       vp.periodo_generico_nombre      AS periodo,
       a.origen,
       d.resultado,
       d.nota,
       d.fecha,
       cm.ubicacion                    AS ubicacion_comision
FROM poblacion p
JOIN negocio.sga_actas_detalle d     ON d.alumno = p.alumno
JOIN negocio.sga_actas a             ON a.id_acta = d.id_acta
JOIN negocio.sga_planes_versiones pv ON pv.plan_version = d.plan_version
JOIN negocio.sga_comisiones cm       ON cm.comision = a.comision
JOIN negocio.vw_periodos_lectivos vp ON vp.periodo_lectivo = cm.periodo_lectivo
WHERE pv.plan = 28
  AND a.comision IS NOT NULL
  AND d.estado = 'A'
  AND d.fecha <= DATE '2026-03-31';
