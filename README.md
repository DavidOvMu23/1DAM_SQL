# 1º DAM — SQL (IES L'ESTACIÓ)

Repositorio de materiales y scripts de SQL para el nivel de 1º de DAM del IES L'ESTACIÓ. Aquí tienes los scripts que usamos en clase, un bloque de ejercicios de examen y otro bloque de repaso grande (ambientado en bandas de rock/metal) para subir el nivel con consultas avanzadas.

¿Qué hay aquí, en dos bloques?
- Examen (bases clásicas usadas en clase): datasets como Ciclismo y Segunda Mano, pensados para practicar lo que cae en examen: JOIN, GROUP BY, HAVING, subconsultas, NOT EXISTS, comparaciones con ALL/ANY, ranking sin LIMIT, etc.
- Repaso Rock & Metal: una BD grande y realista con 100 ejercicios para consolidar y ampliar lo visto, trabajando integridad referencial, filtros complejos, agregaciones, y casos de negocio.

## Estructura del repositorio

- `sql/`
  - `sql/exam_databases.sql`: Script maestro con bases de datos de práctica para exámenes. Crea y rellena, al menos:
    - CICLISMO: tablas `equipo`, `ciclista`, `etapa`, `puerto`, `maillot`, `llevar` con muchos registros de prueba.
    - SEGUNDA MANO: tablas `concesionario`, `vendedor`, `coche` con un dataset amplio para ejercicios de negocio.
  - `sql/rock_metal_db.sql`: Script completo de la base de datos Rock & Metal. Define tablas principales (`banda`, `musico`, `discografica`, `festival`, `album`, `cancion`, `contrato`, `integra`, `actuacion`, `gira`, `premio`, `critica`, `colaboracion`), índices, checks, claves foráneas y datos de ejemplo.

- `docs/`
  - `docs/examen_exercises.md`: Colección extensa de ejercicios basados en las BDs de examen (Ciclismo, Segunda Mano y más). Incluye guía rápida, enunciados y soluciones modelo para temas como NOT EXISTS, LEFT JOIN, ranking sin LIMIT, división relacional y comparaciones con ALL/ANY.
  - `docs/rock_metal_exercises.md`: 100 ejercicios avanzados para la BD Rock & Metal, con esquema resumido y consultas de práctica (división relacional, NOT EXISTS, LEFT JOIN, rankings, comparaciones, agregaciones, etc.). Perfecto para repasar y reforzar.

## Cómo usar los scripts

- Requisitos: MySQL o MariaDB con soporte InnoDB y `utf8mb4`.
- Ejecución (CLI):
  - Cargar BDs de examen: `mysql -u <usuario> -p < sql/exam_databases.sql`
  - Cargar Rock & Metal: `mysql -u <usuario> -p < sql/rock_metal_db.sql`
- Los scripts eliminan y recrean objetos cuando es necesario, por lo que puedes relanzarlos para restablecer los datos de prueba.

## Ruta de estudio recomendada

1) Si estás preparando examen: carga `sql/exam_databases.sql` y trabaja los enunciados de `docs/examen_exercises.md` en este orden: NOT EXISTS vs NOT IN, LEFT JOIN para incluir “los que no tienen”, HAVING con agregaciones y casos de ranking sin LIMIT.
2) Para afianzar y subir dificultad: carga `sql/rock_metal_db.sql` y resuelve `docs/rock_metal_exercises.md` (100 ejercicios), priorizando división relacional, subconsultas correlacionadas y comparaciones con ALL/ANY.
3) Repite los scripts cuando necesites un entorno limpio (restablecen datos dummy consistentes).

## Objetivo didáctico

- Practicar SQL a nivel 1º DAM mediante bases de datos pobladas y ejercicios graduados.
- Entrenar consultas con `JOIN`, `GROUP BY`, `HAVING`, subconsultas correlacionadas, `NOT EXISTS` vs `NOT IN`, comparaciones con `ALL/ANY`, y técnicas de ranking sin `LIMIT`.

## Notas

- Este repositorio refleja el nivel de SQL de 1º de DAM del IES L'ESTACIÓ.
- Todo el contenido inventariado arriba corresponde a los archivos presentes en esta repo en las carpetas `sql/` y `docs/`. En `docs/` verás ejercicios que también cubren otros esquemas clásicos que usamos en clase (p.ej. Música, Biblioteca o Baloncesto).
