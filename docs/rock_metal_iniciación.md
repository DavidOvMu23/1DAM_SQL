# BASE DE DATOS ROCK & HEAVY METAL - 100 EJERCICIOS DE INICIACIÓN

> Usa el script `sql/rock_metal_db.sql` para crear y poblar la base `rock_metal_db` antes de trabajar los ejercicios. Ejecuta `USE rock_metal_db;` en tu sesión.
> Este documento está maquetado como el avanzado: incluye esquema, datos de ejemplo y 100 ejercicios con consulta SQL de ejemplo, de fácil a intermedio.
> No usa LIMIT: los Top-N se resuelven con subconsultas (COUNT/DISTINCT) o comparaciones con ALL, aceptando empates en el último puesto.

## 🎸 ESQUEMA DE LA BASE DE DATOS ROCK_METAL

```sql
-- Información de bandas
BANDA(cod_banda, nombre, pais, anio_formacion, genero, activa)
    CP: {cod_banda}
    VNN: {nombre}

-- Información de músicos
MUSICO(dni, nombre, apellidos, fecha_nacimiento, pais_origen, instrumento_principal)
    CP: {dni}
    VNN: {nombre, apellidos}

-- Álbumes de las bandas
ALBUM(cod_album, titulo, anio_lanzamiento, tipo, cod_banda, duracion_total, ventas)
    CP: {cod_album}
    CAj: {cod_banda} → BANDA

-- Canciones de los álbumes
CANCION(cod_cancion, titulo, duracion, cod_album, es_single, letra_explicita)
    CP: {cod_cancion}
    CAj: {cod_album} → ALBUM

-- Discográficas
DISCOGRAFICA(cod_disco, nombre, pais, anio_fundacion, generos_especializados)
    CP: {cod_disco}
    VNN: {nombre}

-- Contratos entre bandas y discográficas
CONTRATO(cod_banda, cod_disco, fecha_inicio, fecha_fin, tipo_contrato, valor_contrato)
    CP: {cod_banda, cod_disco, fecha_inicio}
    CAj: {cod_banda} → BANDA
    CAj: {cod_disco} → DISCOGRAFICA

-- Integrantes de las bandas (histórico)
INTEGRA(dni, cod_banda, fecha_entrada, fecha_salida, instrumento, es_fundador)
    CP: {dni, cod_banda, fecha_entrada}
    CAj: {dni} → MUSICO
    CAj: {cod_banda} → BANDA

-- Festivales de música
FESTIVAL(cod_festival, nombre, pais, fecha_inicio, fecha_fin, capacidad_maxima, generos)
    CP: {cod_festival}

-- Actuaciones en festivales
ACTUACION(cod_banda, cod_festival, fecha_actuacion, duracion_show, orden_actuacion, cachet)
    CP: {cod_banda, cod_festival, fecha_actuacion}
    CAj: {cod_banda} → BANDA
    CAj: {cod_festival} → FESTIVAL

-- Giras de las bandas
GIRA(cod_gira, nombre, cod_banda, fecha_inicio, fecha_fin, numero_conciertos, recaudacion_total)
    CP: {cod_gira}
    CAj: {cod_banda} → BANDA

-- Premios musicales
PREMIO(cod_premio, nombre, anio, categoria, pais_premio, valor_premio, cod_banda, cod_album, cod_cancion)
    CP: {cod_premio}
    CAj: {cod_banda} → BANDA
    CAj: {cod_album} → ALBUM
    CAj: {cod_cancion} → CANCION

-- Críticas de álbumes
CRITICA(cod_critica, medio_comunicacion, puntuacion, cod_album, fecha_critica, critico, pais_critico)
    CP: {cod_critica}
    CAj: {cod_album} → ALBUM

-- Colaboraciones entre músicos
COLABORACION(dni_musico1, dni_musico2, cod_cancion, tipo_colaboracion)
    CP: {dni_musico1, dni_musico2, cod_cancion}
    CAj: {dni_musico1} → MUSICO
    CAj: {dni_musico2} → MUSICO
    CAj: {cod_cancion} → CANCION
```

### Datos de ejemplo
- Metallica (Estados Unidos, 1981, Thrash Metal)
- Iron Maiden (Reino Unido, 1975, Heavy Metal)
- Black Sabbath (Reino Unido, 1968, Heavy Metal)
- Megadeth (Estados Unidos, 1983, Thrash Metal)
- AC/DC (Australia, 1973, Hard Rock)

---

## 🎯 100 EJERCICIOS DE INICIACIÓN

### EJERCICIOS 1–10: SELECT BÁSICOS

#### EJERCICIO 1 (★)
Listar todas las bandas mostrando nombre.
```sql
SELECT nombre
FROM banda;
```

#### EJERCICIO 2 (★)
Listar nombre y país de todas las bandas.
```sql
SELECT nombre, pais
FROM banda;
```

#### EJERCICIO 3 (★)
Listar las bandas activas (activa = TRUE).
```sql
SELECT nombre
FROM banda
WHERE activa = TRUE;
```

#### EJERCICIO 4 (★)
Bandas formadas antes de 1980.
```sql
SELECT nombre, anio_formacion
FROM banda
WHERE anio_formacion < 1980;
```

#### EJERCICIO 5 (★)
Contar cuántas bandas hay en total.
```sql
SELECT COUNT(*) AS total_bandas
FROM banda;
```

#### EJERCICIO 6 (★)
Países distintos de las bandas.
```sql
SELECT DISTINCT pais
FROM banda
ORDER BY pais;
```

#### EJERCICIO 7 (★)
Nombres y apellidos de todos los músicos.
```sql
SELECT nombre, apellidos
FROM musico;
```

#### EJERCICIO 8 (★)
Músicos nacidos después de 1960.
```sql
SELECT nombre, apellidos, fecha_nacimiento
FROM musico
WHERE fecha_nacimiento > '1960-12-31';
```

#### EJERCICIO 9 (★)
Músicos cuyo instrumento principal sea Guitarra.
```sql
SELECT nombre, apellidos
FROM musico
WHERE instrumento_principal = 'Guitarra';
```

#### EJERCICIO 10 (★)
Músicos cuyo país de origen sea Estados Unidos.
```sql
SELECT nombre, apellidos
FROM musico
WHERE pais_origen = 'Estados Unidos';
```

### EJERCICIOS 11–20: ORDER BY y DISTINCT (sin LIMIT)

#### EJERCICIO 11 (★)
Bandas ordenadas por nombre ascendente.
```sql
SELECT nombre
FROM banda
ORDER BY nombre ASC;
```

#### EJERCICIO 12 (★)
Bandas ordenadas por año de formación descendente.
```sql
SELECT nombre, anio_formacion
FROM banda
ORDER BY anio_formacion DESC;
```

#### EJERCICIO 13 (★)
Las 5 bandas más antiguas (sin LIMIT; permite empates en el 5º puesto).
```sql
SELECT b1.nombre, b1.anio_formacion
FROM banda b1
WHERE (
  SELECT COUNT(*)
  FROM banda b2
  WHERE b2.anio_formacion < b1.anio_formacion
) < 5
ORDER BY b1.anio_formacion ASC, b1.nombre;
```

#### EJERCICIO 14 (★)
Las 5 bandas más recientes (sin LIMIT; permite empates en el 5º puesto).
```sql
SELECT b1.nombre, b1.anio_formacion
FROM banda b1
WHERE (
  SELECT COUNT(*)
  FROM banda b2
  WHERE b2.anio_formacion > b1.anio_formacion
) < 5
ORDER BY b1.anio_formacion DESC, b1.nombre;
```

#### EJERCICIO 15 (★)
Músicos ordenados por apellidos y luego por nombre.
```sql
SELECT nombre, apellidos
FROM musico
ORDER BY apellidos ASC, nombre ASC;
```

#### EJERCICIO 16 (★)
Países distintos de músicos, ordenados alfabéticamente.
```sql
SELECT DISTINCT pais_origen
FROM musico
ORDER BY pais_origen;
```

#### EJERCICIO 17 (★)
Primeros 10 álbumes por año de lanzamiento (sin LIMIT; permite empates en el 10º puesto).
```sql
SELECT a1.titulo, a1.anio_lanzamiento
FROM album a1
WHERE (
  SELECT COUNT(*)
  FROM album a2
  WHERE a2.anio_lanzamiento < a1.anio_lanzamiento
) < 10
ORDER BY a1.anio_lanzamiento ASC, a1.titulo;
```

#### EJERCICIO 18 (★)
Álbumes de Estudio ordenados por ventas descendente.
```sql
SELECT titulo, ventas
FROM album
WHERE tipo = 'Estudio'
ORDER BY ventas DESC;
```

#### EJERCICIO 19 (★)
Canciones ordenadas por duración descendente.
```sql
SELECT titulo, duracion
FROM cancion
ORDER BY duracion DESC;
```

#### EJERCICIO 20 (★)
Las 10 canciones más cortas (sin LIMIT; permite empates en el 10º puesto).
```sql
SELECT c1.titulo, c1.duracion
FROM cancion c1
WHERE (
  SELECT COUNT(*)
  FROM cancion c2
  WHERE c2.duracion < c1.duracion
) < 10
ORDER BY c1.duracion ASC, c1.titulo;
```

### EJERCICIOS 21–30: LIKE, IN, BETWEEN, NULL

#### EJERCICIO 21 (★)
Bandas cuyo nombre empiece por 'M'.
```sql
SELECT nombre
FROM banda
WHERE nombre LIKE 'M%';
```

#### EJERCICIO 22 (★)
Bandas de Thrash o Heavy Metal.
```sql
SELECT nombre
FROM banda
WHERE genero IN ('Thrash Metal', 'Heavy Metal');
```

#### EJERCICIO 23 (★)
Bandas formadas entre 1970 y 1985.
```sql
SELECT nombre, anio_formacion
FROM banda
WHERE anio_formacion BETWEEN 1970 AND 1985;
```

#### EJERCICIO 24 (★)
Músicos cuyo apellido contenga 'son'.
```sql
SELECT nombre, apellidos
FROM musico
WHERE apellidos LIKE '%son%';
```

#### EJERCICIO 25 (★)
Músicos con fecha de nacimiento desconocida.
```sql
SELECT nombre, apellidos
FROM musico
WHERE fecha_nacimiento IS NULL;
```

#### EJERCICIO 26 (★)
Músicos cuyo instrumento esté en una lista dada.
```sql
SELECT nombre, apellidos, instrumento_principal
FROM musico
WHERE instrumento_principal IN ('Guitarra', 'Bajo', 'Batería');
```

#### EJERCICIO 27 (★)
Festivales en España, Alemania o Suecia.
```sql
SELECT nombre, pais
FROM festival
WHERE pais IN ('España', 'Alemania', 'Suecia');
```

#### EJERCICIO 28 (★)
Festivales con capacidad mayor a 50.000.
```sql
SELECT nombre, capacidad_maxima
FROM festival
WHERE capacidad_maxima > 50000;
```

#### EJERCICIO 29 (★)
Contratos con valor igual o superior a 1.000.000.
```sql
SELECT cod_banda, cod_disco, valor_contrato
FROM contrato
WHERE valor_contrato >= 1000000;
```

#### EJERCICIO 30 (★)
Actuaciones con caché entre 10.000 y 50.000.
```sql
SELECT cod_banda, cod_festival, cachet
FROM actuacion
WHERE cachet BETWEEN 10000 AND 50000;
```

### EJERCICIOS 31–40: JOINs BÁSICOS

#### EJERCICIO 31 (★)
Álbumes con su banda.
```sql
SELECT a.titulo AS album, b.nombre AS banda
FROM album a
JOIN banda b ON a.cod_banda = b.cod_banda;
```

#### EJERCICIO 32 (★)
Canciones con su álbum.
```sql
SELECT c.titulo AS cancion, a.titulo AS album
FROM cancion c
JOIN album a ON c.cod_album = a.cod_album;
```

#### EJERCICIO 33 (★)
Actuaciones con nombre de banda y fecha.
```sql
SELECT b.nombre, a.fecha_actuacion
FROM actuacion a
JOIN banda b ON a.cod_banda = b.cod_banda;
```

#### EJERCICIO 34 (★)
Giras con nombre de banda.
```sql
SELECT g.nombre AS gira, b.nombre AS banda
FROM gira g
JOIN banda b ON g.cod_banda = b.cod_banda;
```

#### EJERCICIO 35 (★)
Críticas con título de álbum y puntuación.
```sql
SELECT a.titulo AS album, c.puntuacion
FROM critica c
JOIN album a ON c.cod_album = a.cod_album;
```

#### EJERCICIO 36 (★)
Premios asociados a banda.
```sql
SELECT p.nombre AS premio, b.nombre AS banda
FROM premio p
JOIN banda b ON p.cod_banda = b.cod_banda;
```

#### EJERCICIO 37 (★)
Contratos con nombre de banda y discográfica.
```sql
SELECT b.nombre AS banda, d.nombre AS discografica
FROM contrato c
JOIN banda b ON c.cod_banda = b.cod_banda
JOIN discografica d ON c.cod_disco = d.cod_disco;
```

#### EJERCICIO 38 (★)
Integrantes: músico y banda.
```sql
SELECT m.nombre, m.apellidos, b.nombre AS banda
FROM integra i
JOIN musico m ON i.dni = m.dni
JOIN banda b ON i.cod_banda = b.cod_banda;
```

#### EJERCICIO 39 (★)
Canciones de 'Metallica'.
```sql
SELECT c.titulo
FROM cancion c
JOIN album a ON c.cod_album = a.cod_album
JOIN banda b ON a.cod_banda = b.cod_banda
WHERE b.nombre = 'Metallica';
```

#### EJERCICIO 40 (★)
Álbumes de bandas del Reino Unido.
```sql
SELECT a.titulo, b.nombre AS banda
FROM album a
JOIN banda b ON a.cod_banda = b.cod_banda
WHERE b.pais = 'Reino Unido';
```

### EJERCICIOS 41–50: JOINs + FILTROS

#### EJERCICIO 41 (★)
Álbumes de Estudio de bandas de Estados Unidos.
```sql
SELECT a.titulo, b.nombre
FROM album a
JOIN banda b ON a.cod_banda = b.cod_banda
WHERE a.tipo = 'Estudio' AND b.pais = 'Estados Unidos';
```

#### EJERCICIO 42 (★)
Canciones de álbumes lanzados antes de 1990.
```sql
SELECT c.titulo, a.anio_lanzamiento
FROM cancion c
JOIN album a ON c.cod_album = a.cod_album
WHERE a.anio_lanzamiento < 1990;
```

#### EJERCICIO 43 (★)
Bandas con actuaciones en España.
```sql
SELECT DISTINCT b.nombre
FROM actuacion a
JOIN festival f ON a.cod_festival = f.cod_festival
JOIN banda b ON a.cod_banda = b.cod_banda
WHERE f.pais = 'España';
```

#### EJERCICIO 44 (★)
Festivales en los que tocó Iron Maiden.
```sql
SELECT DISTINCT f.nombre
FROM actuacion a
JOIN festival f ON a.cod_festival = f.cod_festival
JOIN banda b ON a.cod_banda = b.cod_banda
WHERE b.nombre = 'Iron Maiden';
```

#### EJERCICIO 45 (★)
Músicos que han estado en Metallica.
```sql
SELECT DISTINCT m.nombre, m.apellidos
FROM integra i
JOIN banda b ON i.cod_banda = b.cod_banda
JOIN musico m ON i.dni = m.dni
WHERE b.nombre = 'Metallica';
```

#### EJERCICIO 46 (★)
Contratos vigentes en 1990.
```sql
SELECT b.nombre AS banda, d.nombre AS discografica, c.fecha_inicio, c.fecha_fin
FROM contrato c
JOIN banda b ON c.cod_banda = b.cod_banda
JOIN discografica d ON c.cod_disco = d.cod_disco
WHERE c.fecha_inicio <= '1990-12-31'
  AND (c.fecha_fin IS NULL OR c.fecha_fin >= '1990-01-01');
```

#### EJERCICIO 47 (★)
Bandas sin actuaciones.
```sql
SELECT b.nombre
FROM banda b
LEFT JOIN actuacion a ON a.cod_banda = b.cod_banda
WHERE a.cod_banda IS NULL;
```

#### EJERCICIO 48 (★)
Bandas sin contratos con discográficas.
```sql
SELECT b.nombre
FROM banda b
LEFT JOIN contrato c ON c.cod_banda = b.cod_banda
WHERE c.cod_banda IS NULL;
```

#### EJERCICIO 49 (★)
Bandas con al menos un premio.
```sql
SELECT DISTINCT b.nombre
FROM premio p
JOIN banda b ON p.cod_banda = b.cod_banda;
```

#### EJERCICIO 50 (★)
Bandas sin premios.
```sql
SELECT b.nombre
FROM banda b
LEFT JOIN premio p ON p.cod_banda = b.cod_banda
WHERE p.cod_banda IS NULL;
```

### EJERCICIOS 51–60: AGREGACIONES Y GROUP BY

#### EJERCICIO 51 (★★)
Número de álbumes por banda.
```sql
SELECT b.nombre, COUNT(*) AS num_albums
FROM album a
JOIN banda b ON a.cod_banda = b.cod_banda
GROUP BY b.cod_banda, b.nombre
ORDER BY num_albums DESC;
```

#### EJERCICIO 52 (★★)
Número de canciones por álbum.
```sql
SELECT a.titulo, COUNT(*) AS num_canciones
FROM cancion c
JOIN album a ON c.cod_album = a.cod_album
GROUP BY a.cod_album, a.titulo
ORDER BY num_canciones DESC;
```

#### EJERCICIO 53 (★★)
Duración total de canciones por álbum.
```sql
SELECT a.titulo, SUM(c.duracion) AS duracion_total
FROM cancion c
JOIN album a ON c.cod_album = a.cod_album
GROUP BY a.cod_album, a.titulo;
```

#### EJERCICIO 54 (★★)
Número de músicos por país.
```sql
SELECT pais_origen, COUNT(*) AS num_musicos
FROM musico
GROUP BY pais_origen
ORDER BY num_musicos DESC;
```

#### EJERCICIO 55 (★★)
Ventas totales por banda.
```sql
SELECT b.nombre, SUM(a.ventas) AS ventas_totales
FROM album a
JOIN banda b ON a.cod_banda = b.cod_banda
GROUP BY b.cod_banda, b.nombre
ORDER BY ventas_totales DESC;
```

#### EJERCICIO 56 (★★)
Duración media de canciones por álbum.
```sql
SELECT a.titulo, AVG(c.duracion) AS duracion_media
FROM cancion c
JOIN album a ON c.cod_album = a.cod_album
GROUP BY a.cod_album, a.titulo
ORDER BY duracion_media DESC;
```

#### EJERCICIO 57 (★★)
Año de lanzamiento mínimo y máximo por banda.
```sql
SELECT b.nombre,
       MIN(a.anio_lanzamiento) AS anio_min,
       MAX(a.anio_lanzamiento) AS anio_max
FROM album a
JOIN banda b ON a.cod_banda = b.cod_banda
GROUP BY b.cod_banda, b.nombre;
```

#### EJERCICIO 58 (★★)
Número de actuaciones por país del festival.
```sql
SELECT f.pais, COUNT(*) AS num_actuaciones
FROM actuacion a
JOIN festival f ON a.cod_festival = f.cod_festival
GROUP BY f.pais
ORDER BY num_actuaciones DESC;
```

#### EJERCICIO 59 (★★)
Recaudación total de giras por banda.
```sql
SELECT b.nombre, SUM(g.recaudacion_total) AS recaudacion
FROM gira g
JOIN banda b ON g.cod_banda = b.cod_banda
GROUP BY b.cod_banda, b.nombre
ORDER BY recaudacion DESC;
```

#### EJERCICIO 60 (★★)
Número de premios por categoría.
```sql
SELECT categoria, COUNT(*) AS total
FROM premio
GROUP BY categoria
ORDER BY total DESC;
```

### EJERCICIOS 61–70: HAVING Y AGRUPACIONES FILTRADAS

#### EJERCICIO 61 (★★)
Bandas con más de 3 álbumes.
```sql
SELECT b.nombre, COUNT(*) AS num_albums
FROM album a
JOIN banda b ON a.cod_banda = b.cod_banda
GROUP BY b.cod_banda, b.nombre
HAVING COUNT(*) > 3;
```

#### EJERCICIO 62 (★★)
Álbumes con más de 8 canciones.
```sql
SELECT a.titulo, COUNT(*) AS num_canciones
FROM cancion c
JOIN album a ON c.cod_album = a.cod_album
GROUP BY a.cod_album, a.titulo
HAVING COUNT(*) > 8;
```

#### EJERCICIO 63 (★★)
Bandas con ventas totales > 10.000.000.
```sql
SELECT b.nombre, SUM(a.ventas) AS ventas_totales
FROM album a
JOIN banda b ON a.cod_banda = b.cod_banda
GROUP BY b.cod_banda, b.nombre
HAVING SUM(a.ventas) > 10000000;
```

#### EJERCICIO 64 (★★)
Festivales con capacidad > 80.000 y al menos una actuación.
```sql
SELECT f.nombre, f.capacidad_maxima, COUNT(a.cod_banda) AS actuaciones
FROM festival f
JOIN actuacion a ON a.cod_festival = f.cod_festival
WHERE f.capacidad_maxima > 80000
GROUP BY f.cod_festival, f.nombre, f.capacidad_maxima
HAVING COUNT(a.cod_banda) >= 1;
```

#### EJERCICIO 65 (★★)
Bandas con actuaciones en más de 3 países distintos.
```sql
SELECT b.nombre, COUNT(DISTINCT f.pais) AS paises
FROM banda b
JOIN actuacion a ON a.cod_banda = b.cod_banda
JOIN festival f ON a.cod_festival = f.cod_festival
GROUP BY b.cod_banda, b.nombre
HAVING COUNT(DISTINCT f.pais) > 3;
```

#### EJERCICIO 66 (★★)
Músicos que han estado en más de una banda.
```sql
SELECT m.nombre, m.apellidos, COUNT(DISTINCT i.cod_banda) AS bandas
FROM musico m
JOIN integra i ON i.dni = m.dni
GROUP BY m.dni, m.nombre, m.apellidos
HAVING COUNT(DISTINCT i.cod_banda) > 1;
```

#### EJERCICIO 67 (★★)
Bandas cuya media de duración de canciones supera 300 segundos.
```sql
SELECT b.nombre, AVG(c.duracion) AS media_duracion
FROM banda b
JOIN album a ON a.cod_banda = b.cod_banda
JOIN cancion c ON c.cod_album = a.cod_album
GROUP BY b.cod_banda, b.nombre
HAVING AVG(c.duracion) > 300;
```

#### EJERCICIO 68 (★★)
Álbumes con alguna crítica con puntuación ≥ 9.
```sql
SELECT DISTINCT a.titulo
FROM album a
JOIN critica c ON c.cod_album = a.cod_album
WHERE c.puntuacion >= 9;
```

#### EJERCICIO 69 (★★)
Bandas con más de 2 premios.
```sql
SELECT b.nombre, COUNT(*) AS num_premios
FROM premio p
JOIN banda b ON p.cod_banda = b.cod_banda
GROUP BY b.cod_banda, b.nombre
HAVING COUNT(*) > 2;
```

#### EJERCICIO 70 (★★)
Bandas formadas antes de 1980 con al menos 3 álbumes.
```sql
SELECT b.nombre, b.anio_formacion, COUNT(a.cod_album) AS num_albums
FROM banda b
JOIN album a ON a.cod_banda = b.cod_banda
WHERE b.anio_formacion < 1980
GROUP BY b.cod_banda, b.nombre, b.anio_formacion
HAVING COUNT(a.cod_album) >= 3;
```

### EJERCICIOS 71–80: SUBCONSULTAS

#### EJERCICIO 71 (★★★)
Álbumes de la banda con mayores ventas totales (sin LIMIT).
```sql
SELECT a.titulo
FROM album a
WHERE a.cod_banda IN (
  SELECT a2.cod_banda
  FROM album a2
  GROUP BY a2.cod_banda
  HAVING SUM(a2.ventas) >= ALL (
    SELECT SUM(a3.ventas)
    FROM album a3
    GROUP BY a3.cod_banda
  )
);
```

#### EJERCICIO 72 (★★★)
Canciones con duración mayor que la media de su álbum.
```sql
SELECT c.titulo, c.duracion
FROM cancion c
WHERE c.duracion > (
    SELECT AVG(c2.duracion)
    FROM cancion c2
    WHERE c2.cod_album = c.cod_album
);
```

#### EJERCICIO 73 (★★★)
Bandas con algún álbum por encima de la venta media global.
```sql
SELECT DISTINCT b.nombre
FROM banda b
JOIN album a ON a.cod_banda = b.cod_banda
WHERE a.ventas > (SELECT AVG(ventas) FROM album);
```

#### EJERCICIO 74 (★★★)
Músicos que han colaborado con Dave Mustaine.
```sql
SELECT DISTINCT m.nombre, m.apellidos
FROM colaboracion col
JOIN musico m
  ON ( (col.dni_musico1 = 'US007' AND m.dni = col.dni_musico2)
    OR (col.dni_musico2 = 'US007' AND m.dni = col.dni_musico1) );
```

#### EJERCICIO 75 (★★★)
Bandas que nunca han actuado en ningún festival.
```sql
SELECT b.nombre
FROM banda b
WHERE NOT EXISTS (
  SELECT 1
  FROM actuacion a
  WHERE a.cod_banda = b.cod_banda
);
```

#### EJERCICIO 76 (★★★)
Bandas con más actuaciones que la media por banda.
```sql
SELECT b.nombre, COUNT(*) AS actuaciones
FROM banda b
JOIN actuacion a ON a.cod_banda = b.cod_banda
GROUP BY b.cod_banda, b.nombre
HAVING COUNT(*) > (
  SELECT AVG(cnt)
  FROM (
    SELECT COUNT(*) AS cnt
    FROM actuacion
    GROUP BY cod_banda
  ) t
);
```

#### EJERCICIO 77 (★★★)
Músicos que no han formado parte de Metallica.
```sql
SELECT m.nombre, m.apellidos
FROM musico m
WHERE NOT EXISTS (
  SELECT 1
  FROM integra i
  JOIN banda b ON i.cod_banda = b.cod_banda
  WHERE b.nombre = 'Metallica'
    AND i.dni = m.dni
);
```

#### EJERCICIO 78 (★★★)
Bandas cuyo primer álbum es anterior a 1980.
```sql
SELECT b.nombre, MIN(a.anio_lanzamiento) AS primer_anio
FROM banda b
JOIN album a ON a.cod_banda = b.cod_banda
GROUP BY b.cod_banda, b.nombre
HAVING MIN(a.anio_lanzamiento) < 1980;
```

#### EJERCICIO 79 (★★★)
Bandas con más canciones que la media por banda.
```sql
SELECT b.nombre, COUNT(c.cod_cancion) AS canciones
FROM banda b
JOIN album a ON a.cod_banda = b.cod_banda
JOIN cancion c ON c.cod_album = a.cod_album
GROUP BY b.cod_banda, b.nombre
HAVING COUNT(c.cod_cancion) > (
  SELECT AVG(cnt)
  FROM (
    SELECT COUNT(*) AS cnt
    FROM banda b2
    JOIN album a2 ON a2.cod_banda = b2.cod_banda
    JOIN cancion c2 ON c2.cod_album = a2.cod_album
    GROUP BY b2.cod_banda
  ) t
);
```

#### EJERCICIO 80 (★★★)
Discográficas con bandas de más de 2 países distintos.
```sql
SELECT d.nombre, COUNT(DISTINCT b.pais) AS paises
FROM contrato c
JOIN discografica d ON c.cod_disco = d.cod_disco
JOIN banda b ON c.cod_banda = b.cod_banda
GROUP BY d.cod_disco, d.nombre
HAVING COUNT(DISTINCT b.pais) > 2;
```

### EJERCICIOS 81–90: UNION Y CONSULTAS COMPUESTAS

#### EJERCICIO 81 (★★)
Músicos que han estado en Metallica o en Slayer.
```sql
SELECT DISTINCT m.nombre, m.apellidos
FROM integra i
JOIN banda b ON i.cod_banda = b.cod_banda
JOIN musico m ON m.dni = i.dni
WHERE b.nombre = 'Metallica'
UNION
SELECT DISTINCT m.nombre, m.apellidos
FROM integra i
JOIN banda b ON i.cod_banda = b.cod_banda
JOIN musico m ON m.dni = i.dni
WHERE b.nombre = 'Slayer';
```

#### EJERCICIO 82 (★★)
Canciones que son single y tienen letra explícita.
```sql
SELECT titulo
FROM cancion
WHERE es_single = TRUE
  AND letra_explicita = TRUE;
```

#### EJERCICIO 83 (★★)
Bandas de Thrash o Heavy de Estados Unidos.
```sql
SELECT nombre
FROM banda
WHERE genero IN ('Thrash Metal', 'Heavy Metal')
  AND pais = 'Estados Unidos';
```

#### EJERCICIO 84 (★★)
Bandas activas con al menos un contrato vigente hoy.
```sql
SELECT DISTINCT b.nombre
FROM banda b
JOIN contrato c ON c.cod_banda = b.cod_banda
WHERE b.activa = TRUE
  AND c.fecha_inicio <= CURRENT_DATE()
  AND (c.fecha_fin IS NULL OR c.fecha_fin >= CURRENT_DATE());
```

#### EJERCICIO 85 (★★★)
Músicos que han colaborado y además coincidieron en alguna banda.
```sql
SELECT DISTINCT m1.nombre AS musico1, m1.apellidos AS ap1,
                m2.nombre AS musico2, m2.apellidos AS ap2
FROM colaboracion col
JOIN integra i1 ON i1.dni = col.dni_musico1
JOIN integra i2 ON i2.dni = col.dni_musico2 AND i2.cod_banda = i1.cod_banda
JOIN musico m1 ON m1.dni = col.dni_musico1
JOIN musico m2 ON m2.dni = col.dni_musico2;
```

#### EJERCICIO 86 (★★)
Bandas con premios a álbumes o a canciones.
```sql
SELECT DISTINCT b.nombre
FROM premio p
JOIN album a ON p.cod_album = a.cod_album
JOIN banda b ON a.cod_banda = b.cod_banda
UNION
SELECT DISTINCT b.nombre
FROM premio p
JOIN cancion c ON p.cod_cancion = c.cod_cancion
JOIN album a ON c.cod_album = a.cod_album
JOIN banda b ON a.cod_banda = b.cod_banda;
```

#### EJERCICIO 87 (★★)
Último álbum por banda (por año de lanzamiento).
```sql
SELECT a1.titulo, a1.cod_banda, a1.anio_lanzamiento
FROM album a1
WHERE a1.anio_lanzamiento = (
  SELECT MAX(a2.anio_lanzamiento)
  FROM album a2
  WHERE a2.cod_banda = a1.cod_banda
);
```

#### EJERCICIO 88 (★★)
Bandas con ventas totales iguales a 0.
```sql
SELECT b.nombre
FROM banda b
LEFT JOIN album a ON a.cod_banda = b.cod_banda
GROUP BY b.cod_banda, b.nombre
HAVING COALESCE(SUM(a.ventas), 0) = 0;
```

#### EJERCICIO 89 (★★)
Bandas con ventas totales entre 1 y 5 millones.
```sql
SELECT b.nombre, SUM(a.ventas) AS ventas
FROM album a
JOIN banda b ON a.cod_banda = b.cod_banda
GROUP BY b.cod_banda, b.nombre
HAVING SUM(a.ventas) BETWEEN 1000000 AND 5000000;
```

#### EJERCICIO 90 (★★)
Canciones con duración por encima de la media global.
```sql
SELECT titulo, duracion
FROM cancion
WHERE duracion > (SELECT AVG(duracion) FROM cancion);
```

### EJERCICIOS 91–100: REPASO INTEGRADOR

#### EJERCICIO 91 (★★★)
Top 5 bandas por ventas totales (sin LIMIT; permite empates en el 5º puesto).
```sql
SELECT b.nombre, SUM(a.ventas) AS ventas
FROM album a
JOIN banda b ON a.cod_banda = b.cod_banda
GROUP BY b.cod_banda, b.nombre
HAVING (
  SELECT COUNT(DISTINCT ventas2)
  FROM (
    SELECT SUM(a2.ventas) AS ventas2
    FROM album a2
    GROUP BY a2.cod_banda
  ) t
  WHERE t.ventas2 > SUM(a.ventas)
) < 5
ORDER BY ventas DESC, b.nombre;
```

#### EJERCICIO 92 (★★★)
Top 5 álbumes por ventas, con su banda (sin LIMIT; permite empates en el 5º puesto).
```sql
SELECT a.titulo, b.nombre AS banda, a.ventas
FROM album a
JOIN banda b ON a.cod_banda = b.cod_banda
WHERE (
  SELECT COUNT(DISTINCT a2.ventas)
  FROM album a2
  WHERE a2.ventas > a.ventas
) < 5
ORDER BY a.ventas DESC, a.titulo;
```

#### EJERCICIO 93 (★★★)
Bandas ordenadas por número de álbumes publicados.
```sql
SELECT b.nombre, COUNT(a.cod_album) AS num_albums
FROM banda b
LEFT JOIN album a ON a.cod_banda = b.cod_banda
GROUP BY b.cod_banda, b.nombre
ORDER BY num_albums DESC, b.nombre ASC;
```

#### EJERCICIO 94 (★★★)
Las 10 canciones más largas con su álbum y banda (sin LIMIT; permite empates en el 10º puesto).
```sql
SELECT c.titulo AS cancion, c.duracion,
       a.titulo AS album, b.nombre AS banda
FROM cancion c
JOIN album a ON c.cod_album = a.cod_album
JOIN banda b ON a.cod_banda = b.cod_banda
WHERE (
  SELECT COUNT(DISTINCT c2.duracion)
  FROM cancion c2
  WHERE c2.duracion > c.duracion
) < 10
ORDER BY c.duracion DESC, c.titulo;
```

#### EJERCICIO 95 (★★★)
Bandas con más de 2 músicos fundadores.
```sql
SELECT b.nombre, SUM(i.es_fundador) AS fundadores
FROM banda b
JOIN integra i ON i.cod_banda = b.cod_banda
GROUP BY b.cod_banda, b.nombre
HAVING SUM(i.es_fundador) > 2;
```

#### EJERCICIO 96 (★★★)
Festivales con mayor número de bandas distintas (top 10 sin LIMIT; permite empates en el 10º puesto).
```sql
SELECT f.nombre, COUNT(DISTINCT a.cod_banda) AS bandas
FROM festival f
JOIN actuacion a ON a.cod_festival = f.cod_festival
GROUP BY f.cod_festival, f.nombre
HAVING (
  SELECT COUNT(DISTINCT x.bandas2)
  FROM (
    SELECT COUNT(DISTINCT a2.cod_banda) AS bandas2
    FROM festival f2
    JOIN actuacion a2 ON a2.cod_festival = f2.cod_festival
    GROUP BY f2.cod_festival
  ) x
  WHERE x.bandas2 > COUNT(DISTINCT a.cod_banda)
) < 10
ORDER BY bandas DESC, f.nombre;
```

#### EJERCICIO 97 (★★★)
Bandas que han tocado en al menos 2 festivales dentro del mismo país.
```sql
SELECT DISTINCT nombre
FROM (
  SELECT b.nombre
  FROM banda b
  JOIN actuacion a ON a.cod_banda = b.cod_banda
  JOIN festival f ON a.cod_festival = f.cod_festival
  GROUP BY b.cod_banda, b.nombre, f.pais
  HAVING COUNT(*) >= 2
 ) t;
```

#### EJERCICIO 98 (★★★)
Bandas con alguna gira de duración superior a 365 días.
```sql
SELECT DISTINCT b.nombre
FROM gira g
JOIN banda b ON g.cod_banda = b.cod_banda
WHERE DATEDIFF(g.fecha_fin, g.fecha_inicio) > 365;
```

#### EJERCICIO 99 (★★★)
Álbumes que no tienen críticas asociadas.
```sql
SELECT a.titulo
FROM album a
LEFT JOIN critica c ON c.cod_album = a.cod_album
WHERE c.cod_album IS NULL;
```

#### EJERCICIO 100 (★★★)
Canciones que no son single y pertenecen a álbumes En vivo.
```sql
SELECT c.titulo
FROM cancion c
JOIN album a ON c.cod_album = a.cod_album
WHERE c.es_single = FALSE
  AND a.tipo = 'En vivo';
```

---

Sugerencias de trabajo
- Ejecuta primero consultas de lectura (SELECT) y deja las de modificación para entornos de prueba.
- Comprueba los nombres de columnas exactamente como están en el script (por ejemplo, `anio_formacion`, no `año_formacion`).
- Si lo necesitas, crea vistas auxiliares o CTEs (MySQL 8+) para simplificar consultas largas.
