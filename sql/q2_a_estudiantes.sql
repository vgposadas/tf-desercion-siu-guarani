-- Q.2.A. Estudiantes -> estudiantes.csv
-- Criterios: Población: carrera 19, sedes 2 y 3, cohortes 2015-2023, situación 1 (pendiente) o 2 (aceptada), con al menos una actividad. Sede de ingreso: la de la inscripción, salvo cambio a la Sede Central el mismo año del ingreso o antes (corrección de carga). Egreso: certificado 22, no anulado, anterior al corte.
-- Resultado: 1.987 filas.
-- Reemplazar CLAVE_SECRETA (y NOMBRE_SEDE_* en q2_a) antes de ejecutar. Ver README.
SET search_path TO negocio, public;

WITH poblacion AS (
  SELECT a.alumno, pa.anio_academico::int AS cohorte,
         pa.ubicacion AS ubicacion_inscripcion, pa.situacion_asp
  FROM negocio.sga_propuestas_aspira pa
  JOIN negocio.sga_alumnos a
       ON a.persona = pa.persona AND a.propuesta = pa.propuesta
  WHERE pa.propuesta = 19
    AND pa.ubicacion IN (2, 3)
    AND pa.anio_academico BETWEEN 2015 AND 2023
    AND pa.situacion_asp IN (1, 2)
    AND (   EXISTS (SELECT 1 FROM negocio.sga_insc_cursada ic
                    WHERE ic.alumno = a.alumno AND ic.estado = 'A')
         OR EXISTS (SELECT 1 FROM negocio.sga_insc_examen ie
                    WHERE ie.alumno = a.alumno AND ie.estado = 'A')
         OR EXISTS (SELECT 1 FROM negocio.vw_hist_academica h
                    WHERE h.alumno = a.alumno))
)
SELECT md5('CLAVE_SECRETA' || p.alumno::text) AS id_est,
       p.cohorte,
       CASE
         WHEN p.ubicacion_inscripcion = 2 THEN 'NOMBRE_SEDE_CENTRAL'
         WHEN EXISTS (SELECT 1 FROM negocio.sga_alumnos_hist_ubicacion hu
                      WHERE hu.alumno = p.alumno
                        AND hu.ubicacion = 2
                        AND EXTRACT(YEAR FROM hu.fecha) <= p.cohorte)
              THEN 'NOMBRE_SEDE_CENTRAL'
         ELSE 'NOMBRE_SEDE_INTERIOR'
       END AS sede_ingreso,
       CASE p.situacion_asp WHEN 1 THEN 'pendiente' ELSE 'aceptada' END
         AS situacion_inscripcion,
       (SELECT MIN(co.fecha_egreso)
        FROM negocio.sga_certificados_otorg co
        WHERE co.alumno = p.alumno
          AND co.certificado = 22
          AND (co.anulado IS NULL OR co.anulado = 0)
          AND co.fecha_egreso <= DATE '2026-03-31') AS fecha_egreso
FROM poblacion p;
