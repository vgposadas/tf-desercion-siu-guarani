-- Q.2.F. Materias del plan 2004 -> materias.csv
-- Criterios: Catálogo, sin datos personales.
-- Resultado: 310 filas.
-- Reemplazar CLAVE_SECRETA (y NOMBRE_SEDE_* en q2_a) antes de ejecutar. Ver README.
SET search_path TO negocio, public;

SELECT DISTINCT elemento AS materia, codigo, nombre
FROM negocio.vw_elementos_plan
WHERE plan = 28
ORDER BY codigo;
