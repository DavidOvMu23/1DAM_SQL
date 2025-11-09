# 1º DAM — SQL (IES L'ESTACIÓ)

Repositorio de materiales y scripts de SQL para el nivel de 1º de DAM del IES L'ESTACIÓ. Aquí tienes los scripts que usamos en clase, un bloque de ejercicios de examen y un itinerario Rock & Metal con iniciación y avanzado para progresar de forma gradual.

¿Qué hay aquí, en dos bloques?
- Examen (bases clásicas usadas en clase): datasets como Ciclismo y Segunda Mano, pensados para practicar lo que cae en examen: JOIN, GROUP BY, HAVING, subconsultas, NOT EXISTS, comparaciones con ALL/ANY, ranking sin LIMIT, etc.
- Rock & Metal (itinerario en dos niveles):
  - Iniciación: 100 ejercicios graduales sin usar LIMIT, para dominar SELECT, filtros, JOINs, agregaciones/HAVING, subconsultas básicas, anti-joins y top-N sin LIMIT.
  - Avanzado: 100 ejercicios avanzados (división relacional, NOT EXISTS, comparaciones ALL/ANY, anti-joins complejos, rankings sin LIMIT y casos de negocio exigentes).

## Estructura del repositorio

- `sql/`
  - `sql/exam_databases.sql`: Script maestro con bases de datos de práctica para exámenes. Crea y rellena, al menos:
    - CICLISMO: tablas `equipo`, `ciclista`, `etapa`, `puerto`, `maillot`, `llevar` con muchos registros de prueba.
    - SEGUNDA MANO: tablas `concesionario`, `vendedor`, `coche` con un dataset amplio para ejercicios de negocio.
  - `sql/rock_metal_db.sql`: Script completo de la base de datos Rock & Metal. Define tablas principales (`banda`, `musico`, `discografica`, `festival`, `album`, `cancion`, `contrato`, `integra`, `actuacion`, `gira`, `premio`, `critica`, `colaboracion`), índices, checks, claves foráneas y datos de ejemplo.

- `docs/`
  - `docs/examen_exercises.md`: Colección extensa de ejercicios basados en las BDs de examen (Ciclismo, Segunda Mano y más). Incluye guía rápida, enunciados y soluciones modelo para temas como NOT EXISTS, LEFT JOIN, ranking sin LIMIT, división relacional y comparaciones con ALL/ANY.
  - `docs/rock_metal_iniciación.md`: 100 ejercicios de iniciación para la BD Rock & Metal, ordenados de fácil a intermedio, sin usar LIMIT (top‑N con subconsultas/ALL). Pensado para prepararte al avanzado.
  - `docs/rock_metal_avanzado.md`: 100 ejercicios avanzados para la BD Rock & Metal, con esquema resumido y consultas de práctica (división relacional, NOT EXISTS, LEFT/ANTI JOIN, rankings sin LIMIT, comparaciones con ALL/ANY, agregaciones, etc.).

## Cómo usar los scripts

- Requisitos: MySQL o MariaDB con soporte InnoDB y `utf8mb4`.
- Ejecución (CLI):
  - Cargar BDs de examen: `mysql -u <usuario> -p < sql/exam_databases.sql`
  - Cargar Rock & Metal: `mysql -u <usuario> -p < sql/rock_metal_db.sql`
- Los scripts eliminan y recrean objetos cuando es necesario, por lo que puedes relanzarlos para restablecer los datos de prueba.

## Ruta de estudio recomendada

1) Si estás preparando examen: carga `sql/exam_databases.sql` y trabaja `docs/examen_exercises.md` (NOT EXISTS vs NOT IN, LEFT/ANTI JOIN, HAVING, ranking sin LIMIT).
2) Itinerario Rock & Metal:
   - Primero `docs/rock_metal_iniciación.md` (100 ejercicios graduales, sin LIMIT).
   - Después `docs/rock_metal_avanzado.md` (100 ejercicios avanzados).
3) Carga la BD Rock & Metal con `sql/rock_metal_db.sql` antes de esos ejercicios.
4) Repite los scripts cuando necesites un entorno limpio (restablecen datos dummy consistentes).

## Objetivo didáctico

- Practicar SQL a nivel 1º DAM mediante bases de datos pobladas y ejercicios graduados.
- Entrenar consultas con `JOIN`, `GROUP BY`, `HAVING`, subconsultas correlacionadas, `NOT EXISTS` vs `NOT IN`, comparaciones con `ALL/ANY`, y técnicas de ranking sin `LIMIT`.

## Notas

- Este repositorio refleja el nivel de SQL de 1º de DAM del IES L'ESTACIÓ.
- En los ejercicios Rock & Metal no se usa `LIMIT` para Top‑N: se emplean alternativas con subconsultas, `ALL/ANY` y conteos, aceptando empates en el último puesto.
- Todo el contenido inventariado arriba corresponde a los archivos presentes en esta repo en las carpetas `sql/` y `docs/`. En `docs/` verás ejercicios que también cubren otros esquemas clásicos que usamos en clase (p.ej. Música, Biblioteca o Baloncesto).
