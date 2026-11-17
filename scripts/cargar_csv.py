"""Carga en el esquema `tesis` de la base de trabajo los CSV exportados con las consultas de sql/q2_*.sql.

Reemplaza la importación manual con pgAdmin: cada archivo <nombre>.csv se carga en la tabla tesis.<nombre>
(si la tabla existe, se reemplaza). No modifica SIU Guarani: trabaja solo sobre la base de trabajo local.

Uso:
    python scripts/cargar_csv.py --carpeta datos/ --base tesis_agronomia --usuario postgres
"""
import argparse, getpass, pathlib
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

ESPERADAS = {"estudiantes": 1987, "actas_cursada": 26465, "examenes": 7300, "insc_cursada": 24479,
             "insc_examen": 7428, "materias": 310, "nivelacion": 1614, "equivalencias": 580}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--carpeta", default="datos")
    ap.add_argument("--base", default="tesis_agronomia")
    ap.add_argument("--usuario", default="postgres")
    ap.add_argument("--host", default="localhost")
    ap.add_argument("--sep", default=",")
    a = ap.parse_args()
    engine = create_engine(URL.create("postgresql+psycopg2", username=a.usuario,
                                      password=getpass.getpass("Contraseña de PostgreSQL: "),
                                      host=a.host, port=5432, database=a.base))
    with engine.begin() as con:
        con.execute(text("CREATE SCHEMA IF NOT EXISTS tesis"))
    for f in sorted(pathlib.Path(a.carpeta).glob("*.csv")):
        df = pd.read_csv(f, sep=a.sep, dtype={"id_est": str, "nota": str})
        df.to_sql(f.stem, engine, schema="tesis", if_exists="replace", index=False)
        esperado = ESPERADAS.get(f.stem)
        control = "" if esperado is None else (" (OK)" if len(df) == esperado else f" (ATENCIÓN: se esperaban {esperado})")
        print(f"tesis.{f.stem}: {len(df)} filas{control}")

if __name__ == "__main__":
    main()
