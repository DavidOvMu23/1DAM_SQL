# BASE DE DATOS ROCK & HEAVY METAL - 100 EJERCICIOS AVANZADOS

## 🎸 **ESQUEMA DE LA BASE DE DATOS ROCK_METAL**

### **TABLAS PRINCIPALES**

```sql
-- Información de bandas
BANDA(cod_banda, nombre, pais, año_formacion, genero, activa)
    CP: {cod_banda}
    VNN: {nombre}

-- Información de músicos
MUSICO(dni, nombre, apellidos, fecha_nacimiento, pais_origen, instrumento_principal)
    CP: {dni}
    VNN: {nombre, apellidos}

-- Álbumes de las bandas
ALBUM(cod_album, titulo, año_lanzamiento, tipo, cod_banda, duracion_total, ventas)
    CP: {cod_album}
    CAj: {cod_banda} → BANDA

-- Canciones de los álbumes
CANCION(cod_cancion, titulo, duracion, cod_album, es_single, letra_explicita)
    CP: {cod_cancion}
    CAj: {cod_album} → ALBUM

-- Discográficas
DISCOGRAFICA(cod_disco, nombre, pais, año_fundacion, generos_especializados)
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
PREMIO(cod_premio, nombre, año, categoria, cod_banda, cod_album, cod_cancion)
    CP: {cod_premio}
    CAj: {cod_banda} → BANDA
    CAj: {cod_album} → ALBUM
    CAj: {cod_cancion} → CANCION

-- Críticas de álbumes
CRITICA(cod_critica, medio_comunicacion, puntuacion, cod_album, fecha_critica, critico)
    CP: {cod_critica}
    CAj: {cod_album} → ALBUM

-- Colaboraciones entre músicos
COLABORACION(dni_musico1, dni_musico2, cod_cancion, tipo_colaboracion)
    CP: {dni_musico1, dni_musico2, cod_cancion}
    CAj: {dni_musico1} → MUSICO
    CAj: {dni_musico2} → MUSICO
    CAj: {cod_cancion} → CANCION
```

### **DATOS DE EJEMPLO**

#### **BANDAS:**
- Metallica (USA, 1981, Thrash Metal)
- Iron Maiden (UK, 1975, Heavy Metal)
- Black Sabbath (UK, 1968, Heavy Metal)
- Megadeth (USA, 1983, Thrash Metal)
- AC/DC (Australia, 1973, Hard Rock)
- Deep Purple (UK, 1968, Hard Rock)
- Judas Priest (UK, 1969, Heavy Metal)
- Slayer (USA, 1981, Thrash Metal)
- Motorhead (UK, 1975, Speed Metal)
- Rainbow (UK, 1975, Hard Rock)

#### **GÉNEROS INCLUIDOS:**
Heavy Metal, Thrash Metal, Speed Metal, Power Metal, Progressive Metal, Hard Rock, Doom Metal, Black Metal, Death Metal

---

## 🎯 **100 EJERCICIOS AVANZADOS**

### **EJERCICIOS 1-10: DIVISIÓN RELACIONAL Y NOT EXISTS**

#### **EJERCICIO 1 (★★★★★)**
**Obtener el nombre de las bandas que han tocado en todos los festivales celebrados en Europa.**

```sql
SELECT b.nombre
FROM banda b
WHERE NOT EXISTS (
    SELECT 1
    FROM festival f
    WHERE f.pais IN ('España', 'Francia', 'Alemania', 'Italia', 'Reino Unido', 'Holanda', 'Bélgica', 'Suecia', 'Noruega', 'Finlandia')
    AND NOT EXISTS (
        SELECT 1
        FROM actuacion a
        WHERE a.cod_banda = b.cod_banda
        AND a.cod_festival = f.cod_festival
    )
);
```

#### **EJERCICIO 2 (★★★★★)**
**Obtener el nombre de los músicos que han estado en todas las bandas de thrash metal que se formaron antes de 1985.**

```sql
SELECT m.nombre, m.apellidos
FROM musico m
WHERE NOT EXISTS (
    SELECT 1
    FROM banda b
    WHERE b.genero = 'Thrash Metal' 
    AND b.año_formacion < 1985
    AND NOT EXISTS (
        SELECT 1
        FROM integra i
        WHERE i.dni = m.dni
        AND i.cod_banda = b.cod_banda
    )
);
```

#### **EJERCICIO 3 (★★★★★)**
**Obtener el nombre de las discográficas que han contratado a todas las bandas británicas de heavy metal.**

```sql
SELECT d.nombre
FROM discografica d
WHERE NOT EXISTS (
    SELECT 1
    FROM banda b
    WHERE b.pais = 'Reino Unido' 
    AND b.genero = 'Heavy Metal'
    AND NOT EXISTS (
        SELECT 1
        FROM contrato c
        WHERE c.cod_disco = d.cod_disco
        AND c.cod_banda = b.cod_banda
    )
);
```

#### **EJERCICIO 4 (★★★★★)**
**Obtener el nombre de las bandas que solo han tocado en festivales de metal (no de rock).**

```sql
SELECT b.nombre
FROM banda b
WHERE EXISTS (
    SELECT 1
    FROM actuacion a
    WHERE a.cod_banda = b.cod_banda
)
AND NOT EXISTS (
    SELECT 1
    FROM actuacion a INNER JOIN festival f ON a.cod_festival = f.cod_festival
    WHERE a.cod_banda = b.cod_banda
    AND f.generos NOT LIKE '%Metal%'
);
```

#### **EJERCICIO 5 (★★★★★)**
**Obtener el nombre de los músicos que han colaborado con todos los miembros actuales de Metallica.**

```sql
SELECT m.nombre, m.apellidos
FROM musico m
WHERE NOT EXISTS (
    SELECT 1
    FROM integra i INNER JOIN banda b ON i.cod_banda = b.cod_banda
    WHERE b.nombre = 'Metallica'
    AND i.fecha_salida IS NULL
    AND NOT EXISTS (
        SELECT 1
        FROM colaboracion col
        WHERE (col.dni_musico1 = m.dni AND col.dni_musico2 = i.dni)
        OR (col.dni_musico2 = m.dni AND col.dni_musico1 = i.dni)
    )
);
```

#### **EJERCICIO 6 (★★★★★)**
**Obtener el nombre de las bandas que han lanzado álbumes en todos los tipos existentes (estudio, en vivo, compilación).**

```sql
SELECT b.nombre
FROM banda b
WHERE NOT EXISTS (
    SELECT DISTINCT tipo
    FROM album
    WHERE tipo NOT IN (
        SELECT a.tipo
        FROM album a
        WHERE a.cod_banda = b.cod_banda
    )
);
```

#### **EJERCICIO 7 (★★★★★)**
**Obtener el nombre de los festivales donde han tocado todas las bandas ganadoras de premios Grammy.**

```sql
SELECT f.nombre
FROM festival f
WHERE NOT EXISTS (
    SELECT DISTINCT p.cod_banda
    FROM premio p
    WHERE p.categoria = 'Grammy'
    AND NOT EXISTS (
        SELECT 1
        FROM actuacion a
        WHERE a.cod_festival = f.cod_festival
        AND a.cod_banda = p.cod_banda
    )
);
```

#### **EJERCICIO 8 (★★★★★)**
**Obtener el nombre de las bandas que solo han tenido músicos de su mismo país de origen.**

```sql
SELECT b.nombre
FROM banda b
WHERE NOT EXISTS (
    SELECT 1
    FROM integra i INNER JOIN musico m ON i.dni = m.dni
    WHERE i.cod_banda = b.cod_banda
    AND m.pais_origen != b.pais
);
```

#### **EJERCICIO 9 (★★★★★)**
**Obtener el nombre de los críticos que han reseñado todos los álbumes de Iron Maiden.**

```sql
SELECT c.critico
FROM critica c
WHERE NOT EXISTS (
    SELECT 1
    FROM album a INNER JOIN banda b ON a.cod_banda = b.cod_banda
    WHERE b.nombre = 'Iron Maiden'
    AND NOT EXISTS (
        SELECT 1
        FROM critica c2
        WHERE c2.critico = c.critico
        AND c2.cod_album = a.cod_album
    )
);
```

#### **EJERCICIO 10 (★★★★★)**
**Obtener el nombre de las bandas que han tocado en todos los países donde tienen contratos discográficos.**

```sql
SELECT b.nombre
FROM banda b
WHERE NOT EXISTS (
    SELECT DISTINCT d.pais
    FROM contrato c INNER JOIN discografica d ON c.cod_disco = d.cod_disco
    WHERE c.cod_banda = b.cod_banda
    AND NOT EXISTS (
        SELECT 1
        FROM actuacion act INNER JOIN festival f ON act.cod_festival = f.cod_festival
        WHERE act.cod_banda = b.cod_banda
        AND f.pais = d.pais
    )
);
```

### **EJERCICIOS 11-20: LEFT JOIN Y CASOS COMPLEJOS**

#### **EJERCICIO 11 (★★★★)**
**Obtener el nombre de todas las bandas y el número de premios que han ganado (incluyendo las que no han ganado ninguno).**

```sql
SELECT b.nombre, COUNT(p.cod_premio)
FROM banda b LEFT JOIN premio p ON b.cod_banda = p.cod_banda
GROUP BY b.cod_banda;
```

#### **EJERCICIO 12 (★★★★)**
**Obtener el nombre de todos los músicos y el número de colaboraciones en las que han participado (incluyendo los que no han colaborado).**

```sql
SELECT m.nombre, m.apellidos, COUNT(col.dni_musico1) + COUNT(col2.dni_musico2) as total_colaboraciones
FROM musico m 
LEFT JOIN colaboracion col ON m.dni = col.dni_musico1
LEFT JOIN colaboracion col2 ON m.dni = col2.dni_musico2 AND col2.dni_musico1 != m.dni
GROUP BY m.dni;
```

#### **EJERCICIO 13 (★★★★)**
**Obtener el nombre de todas las discográficas y la recaudación total de las giras de sus bandas contratadas (incluyendo las que no tienen bandas).**

```sql
SELECT d.nombre, COALESCE(SUM(g.recaudacion_total), 0) as recaudacion_total
FROM discografica d 
LEFT JOIN contrato c ON d.cod_disco = c.cod_disco
LEFT JOIN gira g ON c.cod_banda = g.cod_banda
GROUP BY d.cod_disco;
```

#### **EJERCICIO 14 (★★★★)**
**Obtener el nombre de todos los festivales y el número de bandas de thrash metal que han actuado (incluyendo los que no han tenido ninguna).**

```sql
SELECT f.nombre, COUNT(CASE WHEN b.genero = 'Thrash Metal' THEN 1 END) as bandas_thrash
FROM festival f 
LEFT JOIN actuacion a ON f.cod_festival = a.cod_festival
LEFT JOIN banda b ON a.cod_banda = b.cod_banda
GROUP BY f.cod_festival;
```

#### **EJERCICIO 15 (★★★★)**
**Obtener el nombre de todas las bandas y la puntuación media de sus álbumes (incluyendo las que no tienen críticas).**

```sql
SELECT b.nombre, AVG(cr.puntuacion) as puntuacion_media
FROM banda b 
LEFT JOIN album al ON b.cod_banda = al.cod_banda
LEFT JOIN critica cr ON al.cod_album = cr.cod_album
GROUP BY b.cod_banda;
```

#### **EJERCICIO 16 (★★★★)**
**Obtener el nombre de todos los álbumes y el número de colaboraciones especiales que contienen (incluyendo los que no tienen).**

```sql
SELECT al.titulo, COUNT(col.cod_cancion) as colaboraciones_especiales
FROM album al 
LEFT JOIN cancion ca ON al.cod_album = ca.cod_album
LEFT JOIN colaboracion col ON ca.cod_cancion = col.cod_cancion AND col.tipo_colaboracion = 'especial'
GROUP BY al.cod_album;
```

#### **EJERCICIO 17 (★★★★)**
**Obtener el nombre de todas las bandas y el número de países diferentes donde han tocado (incluyendo las que no han tocado).**

```sql
SELECT b.nombre, COUNT(DISTINCT f.pais) as paises_actuacion
FROM banda b 
LEFT JOIN actuacion a ON b.cod_banda = a.cod_banda
LEFT JOIN festival f ON a.cod_festival = f.cod_festival
GROUP BY b.cod_banda;
```

#### **EJERCICIO 18 (★★★★)**
**Obtener el nombre de todos los músicos y el número de instrumentos diferentes que han tocado en bandas (incluyendo los que no han estado en bandas).**

```sql
SELECT m.nombre, m.apellidos, COUNT(DISTINCT i.instrumento) as instrumentos_diferentes
FROM musico m 
LEFT JOIN integra i ON m.dni = i.dni
GROUP BY m.dni;
```

#### **EJERCICIO 19 (★★★★)**
**Obtener el nombre de todas las bandas y el valor total de sus contratos activos (incluyendo las que no tienen contratos).**

```sql
SELECT b.nombre, COALESCE(SUM(c.valor_contrato), 0) as valor_total_contratos
FROM banda b 
LEFT JOIN contrato c ON b.cod_banda = c.cod_banda AND c.fecha_fin > CURRENT_DATE
GROUP BY b.cod_banda;
```

#### **EJERCICIO 20 (★★★★)**
**Obtener el nombre de todas las canciones y si son singles o no (incluyendo información del álbum).**

```sql
SELECT ca.titulo, al.titulo as album, 
       CASE WHEN ca.es_single = 1 THEN 'Sí' ELSE 'No' END as es_single,
       b.nombre as banda
FROM cancion ca 
LEFT JOIN album al ON ca.cod_album = al.cod_album
LEFT JOIN banda b ON al.cod_banda = b.cod_banda;
```

### **EJERCICIOS 21-30: RANKING Y COMPARACIONES SIN LIMIT**

#### **EJERCICIO 21 (★★★★★)**
**Obtener las 5 bandas con más álbumes lanzados (sin usar LIMIT).**

```sql
SELECT b.nombre, COUNT(a.cod_album) as num_albums
FROM banda b INNER JOIN album a ON b.cod_banda = a.cod_banda
GROUP BY b.cod_banda
HAVING COUNT(a.cod_album) >= ALL (
    SELECT COUNT(a2.cod_album)
    FROM album a2
    GROUP BY a2.cod_banda
    ORDER BY COUNT(a2.cod_album) DESC
    OFFSET 4 ROWS
    FETCH NEXT 1 ROWS ONLY
) OR 5 > (
    SELECT COUNT(DISTINCT COUNT(a3.cod_album))
    FROM album a3
    GROUP BY a3.cod_banda
    HAVING COUNT(a3.cod_album) > COUNT(a.cod_album)
);
```

#### **EJERCICIO 22 (★★★★★)**
**Obtener el tercer festival con mayor capacidad máxima.**

```sql
SELECT f.nombre, f.capacidad_maxima
FROM festival f
WHERE 2 = (
    SELECT COUNT(*)
    FROM festival f2
    WHERE f2.capacidad_maxima > f.capacidad_maxima
);
```

#### **EJERCICIO 23 (★★★★★)**
**Obtener las bandas que están entre los puestos 6 y 10 en número de premios ganados.**

```sql
SELECT b.nombre, COUNT(p.cod_premio) as num_premios
FROM banda b INNER JOIN premio p ON b.cod_banda = p.cod_banda
GROUP BY b.cod_banda
HAVING (
    SELECT COUNT(DISTINCT COUNT(p2.cod_premio))
    FROM premio p2
    GROUP BY p2.cod_banda
    HAVING COUNT(p2.cod_premio) > COUNT(p.cod_premio)
) BETWEEN 5 AND 9;
```

#### **EJERCICIO 24 (★★★★★)**
**Obtener el segundo músico más veterano de cada banda (el que lleva más tiempo después del más veterano).**

```sql
SELECT b.nombre, m.nombre, m.apellidos, i.fecha_entrada
FROM banda b 
INNER JOIN integra i ON b.cod_banda = i.cod_banda
INNER JOIN musico m ON i.dni = m.dni
WHERE 1 = (
    SELECT COUNT(*)
    FROM integra i2
    WHERE i2.cod_banda = b.cod_banda
    AND i2.fecha_entrada < i.fecha_entrada
    AND i2.fecha_salida IS NULL
)
AND i.fecha_salida IS NULL;
```

#### **EJERCICIO 25 (★★★★★)**
**Obtener las 3 colaboraciones más recientes de cada tipo.**

```sql
SELECT col.tipo_colaboracion, ca.titulo, m1.nombre as musico1, m2.nombre as musico2
FROM colaboracion col 
INNER JOIN cancion ca ON col.cod_cancion = ca.cod_cancion
INNER JOIN musico m1 ON col.dni_musico1 = m1.dni
INNER JOIN musico m2 ON col.dni_musico2 = m2.dni
INNER JOIN album al ON ca.cod_album = al.cod_album
WHERE 3 > (
    SELECT COUNT(*)
    FROM colaboracion col2 
    INNER JOIN cancion ca2 ON col2.cod_cancion = ca2.cod_cancion
    INNER JOIN album al2 ON ca2.cod_album = al2.cod_album
    WHERE col2.tipo_colaboracion = col.tipo_colaboracion
    AND al2.año_lanzamiento > al.año_lanzamiento
);
```

#### **EJERCICIO 26 (★★★★★)**
**Obtener el álbum con la segunda mejor puntuación media de críticas de cada banda.**

```sql
SELECT b.nombre, al.titulo, AVG(cr.puntuacion) as puntuacion_media
FROM banda b 
INNER JOIN album al ON b.cod_banda = al.cod_banda
INNER JOIN critica cr ON al.cod_album = cr.cod_album
GROUP BY b.cod_banda, al.cod_album
HAVING 1 = (
    SELECT COUNT(DISTINCT AVG(cr2.puntuacion))
    FROM album al2 
    INNER JOIN critica cr2 ON al2.cod_album = cr2.cod_album
    WHERE al2.cod_banda = b.cod_banda
    GROUP BY al2.cod_album
    HAVING AVG(cr2.puntuacion) > AVG(cr.puntuacion)
);
```

#### **EJERCICIO 27 (★★★★★)**
**Obtener los 3 géneros musicales más populares por número de bandas.**

```sql
SELECT b.genero, COUNT(*) as num_bandas
FROM banda b
GROUP BY b.genero
HAVING 3 > (
    SELECT COUNT(DISTINCT COUNT(*))
    FROM banda b2
    GROUP BY b2.genero
    HAVING COUNT(*) > COUNT(b.cod_banda)
);
```

#### **EJERCICIO 28 (★★★★★)**
**Obtener el segundo festival más caro (por cachet promedio) de cada país.**

```sql
SELECT f.pais, f.nombre, AVG(a.cachet) as cachet_promedio
FROM festival f 
INNER JOIN actuacion a ON f.cod_festival = a.cod_festival
GROUP BY f.cod_festival
HAVING 1 = (
    SELECT COUNT(DISTINCT AVG(a2.cachet))
    FROM festival f2 
    INNER JOIN actuacion a2 ON f2.cod_festival = a2.cod_festival
    WHERE f2.pais = f.pais
    GROUP BY f2.cod_festival
    HAVING AVG(a2.cachet) > AVG(a.cachet)
);
```

#### **EJERCICIO 29 (★★★★★)**
**Obtener las bandas que ocupan del puesto 4 al 7 en ventas totales de álbumes.**

```sql
SELECT b.nombre, SUM(al.ventas) as ventas_totales
FROM banda b INNER JOIN album al ON b.cod_banda = al.cod_banda
GROUP BY b.cod_banda
HAVING (
    SELECT COUNT(DISTINCT SUM(al2.ventas))
    FROM album al2
    GROUP BY al2.cod_banda
    HAVING SUM(al2.ventas) > SUM(al.ventas)
) BETWEEN 3 AND 6;
```

#### **EJERCICIO 30 (★★★★★)**
**Obtener el músico más joven de cada instrumento principal.**

```sql
SELECT m.instrumento_principal, m.nombre, m.apellidos, m.fecha_nacimiento
FROM musico m
WHERE m.fecha_nacimiento = (
    SELECT MAX(m2.fecha_nacimiento)
    FROM musico m2
    WHERE m2.instrumento_principal = m.instrumento_principal
);
```

### **EJERCICIOS 31-40: SUBCONSULTAS CORRELACIONADAS COMPLEJAS**

#### **EJERCICIO 31 (★★★★★)**
**Obtener el nombre de las bandas cuyo álbum más vendido supera las ventas promedio de todos los álbumes de su género.**

```sql
SELECT b.nombre
FROM banda b
WHERE (
    SELECT MAX(al.ventas)
    FROM album al
    WHERE al.cod_banda = b.cod_banda
) > (
    SELECT AVG(al2.ventas)
    FROM album al2 INNER JOIN banda b2 ON al2.cod_banda = b2.cod_banda
    WHERE b2.genero = b.genero
);
```

#### **EJERCICIO 32 (★★★★★)**
**Obtener el nombre de los músicos que han estado en más bandas que el promedio de su país de origen.**

```sql
SELECT m.nombre, m.apellidos
FROM musico m
WHERE (
    SELECT COUNT(DISTINCT i.cod_banda)
    FROM integra i
    WHERE i.dni = m.dni
) > (
    SELECT AVG(bandas_por_musico)
    FROM (
        SELECT COUNT(DISTINCT i2.cod_banda) as bandas_por_musico
        FROM musico m2 INNER JOIN integra i2 ON m2.dni = i2.dni
        WHERE m2.pais_origen = m.pais_origen
        GROUP BY m2.dni
    ) subquery
);
```

#### **EJERCICIO 33 (★★★★★)**
**Obtener el nombre de las discográficas que tienen contratos con bandas cuya recaudación total en giras supera el doble del valor de sus contratos.**

```sql
SELECT DISTINCT d.nombre
FROM discografica d
WHERE EXISTS (
    SELECT 1
    FROM contrato c INNER JOIN gira g ON c.cod_banda = g.cod_banda
    WHERE c.cod_disco = d.cod_disco
    AND g.recaudacion_total > (
        SELECT 2 * SUM(c2.valor_contrato)
        FROM contrato c2
        WHERE c2.cod_banda = c.cod_banda
        AND c2.cod_disco = d.cod_disco
    )
);
```

#### **EJERCICIO 34 (★★★★★)**
**Obtener el nombre de las bandas que han lanzado más álbumes en una década que Metallica en toda su carrera.**

```sql
SELECT b.nombre
FROM banda b
WHERE EXISTS (
    SELECT 1
    FROM (SELECT FLOOR(año_lanzamiento/10)*10 as decada FROM album WHERE cod_banda = b.cod_banda) decades
    GROUP BY decades.decada
    HAVING COUNT(*) > (
        SELECT COUNT(*)
        FROM album al INNER JOIN banda b2 ON al.cod_banda = b2.cod_banda
        WHERE b2.nombre = 'Metallica'
    )
);
```

#### **EJERCICIO 35 (★★★★★)**
**Obtener el nombre de los festivales donde el cachet promedio de las bandas headliners es mayor que el cachet promedio de todas las actuaciones.**

```sql
SELECT f.nombre
FROM festival f
WHERE (
    SELECT AVG(a.cachet)
    FROM actuacion a
    WHERE a.cod_festival = f.cod_festival
    AND a.orden_actuacion = 1
) > (
    SELECT AVG(a2.cachet)
    FROM actuacion a2
    WHERE a2.cod_festival = f.cod_festival
);
```

#### **EJERCICIO 36 (★★★★★)**
**Obtener el nombre de las bandas que tienen más singles exitosos que la media de singles por banda de su mismo género.**

```sql
SELECT b.nombre
FROM banda b
WHERE (
    SELECT COUNT(*)
    FROM album al INNER JOIN cancion ca ON al.cod_album = ca.cod_album
    WHERE al.cod_banda = b.cod_banda
    AND ca.es_single = 1
) > (
    SELECT AVG(singles_count)
    FROM (
        SELECT COUNT(*) as singles_count
        FROM banda b2 
        INNER JOIN album al2 ON b2.cod_banda = al2.cod_banda
        INNER JOIN cancion ca2 ON al2.cod_album = ca2.cod_album
        WHERE b2.genero = b.genero
        AND ca2.es_single = 1
        GROUP BY b2.cod_banda
    ) subquery
);
```

#### **EJERCICIO 37 (★★★★★)**
**Obtener el nombre de los músicos cuya carrera profesional (tiempo en bandas) es superior al 80% de la carrera de la banda más longeva en la que han participado.**

```sql
SELECT m.nombre, m.apellidos
FROM musico m
WHERE (
    SELECT SUM(
        CASE 
            WHEN i.fecha_salida IS NULL THEN YEAR(CURRENT_DATE) - YEAR(i.fecha_entrada)
            ELSE YEAR(i.fecha_salida) - YEAR(i.fecha_entrada)
        END
    )
    FROM integra i
    WHERE i.dni = m.dni
) > 0.8 * (
    SELECT MAX(YEAR(CURRENT_DATE) - b.año_formacion)
    FROM banda b INNER JOIN integra i2 ON b.cod_banda = i2.cod_banda
    WHERE i2.dni = m.dni
);
```

#### **EJERCICIO 38 (★★★★★)**
**Obtener el nombre de las canciones que duran más que el promedio de duración de las canciones de álbumes del mismo tipo.**

```sql
SELECT ca.titulo
FROM cancion ca INNER JOIN album al ON ca.cod_album = al.cod_album
WHERE ca.duracion > (
    SELECT AVG(ca2.duracion)
    FROM cancion ca2 INNER JOIN album al2 ON ca2.cod_album = al2.cod_album
    WHERE al2.tipo = al.tipo
);
```

#### **EJERCICIO 39 (★★★★★)**
**Obtener el nombre de las bandas cuyo número de integrantes actuales es mayor que el número promedio de integrantes de las bandas de su mismo país.**

```sql
SELECT b.nombre
FROM banda b
WHERE (
    SELECT COUNT(*)
    FROM integra i
    WHERE i.cod_banda = b.cod_banda
    AND i.fecha_salida IS NULL
) > (
    SELECT AVG(integrantes_actuales)
    FROM (
        SELECT COUNT(*) as integrantes_actuales
        FROM banda b2 INNER JOIN integra i2 ON b2.cod_banda = i2.cod_banda
        WHERE b2.pais = b.pais
        AND i2.fecha_salida IS NULL
        GROUP BY b2.cod_banda
    ) subquery
);
```

#### **EJERCICIO 40 (★★★★★)**
**Obtener el nombre de las giras que han recaudado más que el valor total de todos los premios ganados por esa banda.**

```sql
SELECT g.nombre
FROM gira g
WHERE g.recaudacion_total > (
    SELECT COALESCE(SUM(p.valor_premio), 0)
    FROM premio p
    WHERE p.cod_banda = g.cod_banda
);
```

### **EJERCICIOS 41-50: HAVING Y AGREGACIONES COMPLEJAS**

#### **EJERCICIO 41 (★★★★)**
**Obtener el nombre de las bandas que tienen más álbumes en vivo que álbumes de estudio.**

```sql
SELECT b.nombre
FROM banda b INNER JOIN album al ON b.cod_banda = al.cod_banda
GROUP BY b.cod_banda
HAVING SUM(CASE WHEN al.tipo = 'En vivo' THEN 1 ELSE 0 END) > 
       SUM(CASE WHEN al.tipo = 'Estudio' THEN 1 ELSE 0 END);
```

#### **EJERCICIO 42 (★★★★)**
**Obtener el nombre de los festivales que han tenido más bandas de thrash metal que de cualquier otro género.**

```sql
SELECT f.nombre
FROM festival f 
INNER JOIN actuacion a ON f.cod_festival = a.cod_festival
INNER JOIN banda b ON a.cod_banda = b.cod_banda
GROUP BY f.cod_festival
HAVING SUM(CASE WHEN b.genero = 'Thrash Metal' THEN 1 ELSE 0 END) > 
       SUM(CASE WHEN b.genero != 'Thrash Metal' THEN 1 ELSE 0 END);
```

#### **EJERCICIO 43 (★★★★)**
**Obtener el nombre de las discográficas cuyo valor promedio de contratos supera los 100,000 y tienen al menos 5 bandas contratadas.**

```sql
SELECT d.nombre
FROM discografica d INNER JOIN contrato c ON d.cod_disco = c.cod_disco
GROUP BY d.cod_disco
HAVING AVG(c.valor_contrato) > 100000
AND COUNT(DISTINCT c.cod_banda) >= 5;
```

#### **EJERCICIO 44 (★★★★)**
**Obtener el nombre de las bandas que han tocado en más de 3 países diferentes y cuyo cachet promedio supera los 50,000.**

```sql
SELECT b.nombre
FROM banda b 
INNER JOIN actuacion a ON b.cod_banda = a.cod_banda
INNER JOIN festival f ON a.cod_festival = f.cod_festival
GROUP BY b.cod_banda
HAVING COUNT(DISTINCT f.pais) > 3
AND AVG(a.cachet) > 50000;
```

#### **EJERCICIO 45 (★★★★)**
**Obtener el género musical que tiene la mayor duración promedio de álbumes y al menos 10 álbumes.**

```sql
SELECT b.genero, AVG(al.duracion_total) as duracion_promedio
FROM banda b INNER JOIN album al ON b.cod_banda = al.cod_banda
GROUP BY b.genero
HAVING COUNT(al.cod_album) >= 10
AND AVG(al.duracion_total) >= ALL (
    SELECT AVG(al2.duracion_total)
    FROM banda b2 INNER JOIN album al2 ON b2.cod_banda = al2.cod_banda
    GROUP BY b2.genero
    HAVING COUNT(al2.cod_album) >= 10
);
```

#### **EJERCICIO 46 (★★★★)**
**Obtener el nombre de los músicos que han tocado más de 2 instrumentos diferentes en bandas y han estado en al menos 3 bandas.**

```sql
SELECT m.nombre, m.apellidos
FROM musico m INNER JOIN integra i ON m.dni = i.dni
GROUP BY m.dni
HAVING COUNT(DISTINCT i.instrumento) > 2
AND COUNT(DISTINCT i.cod_banda) >= 3;
```

#### **EJERCICIO 47 (★★★★)**
**Obtener el nombre de las bandas cuyas ventas totales superan los 5 millones y tienen al menos un álbum con puntuación promedio superior a 8.5.**

```sql
SELECT b.nombre
FROM banda b 
INNER JOIN album al ON b.cod_banda = al.cod_banda
LEFT JOIN critica cr ON al.cod_album = cr.cod_album
GROUP BY b.cod_banda
HAVING SUM(al.ventas) > 5000000
AND MAX(
    CASE 
        WHEN cr.cod_album IS NOT NULL THEN 
            (SELECT AVG(cr2.puntuacion) FROM critica cr2 WHERE cr2.cod_album = al.cod_album)
        ELSE 0 
    END
) > 8.5;
```

#### **EJERCICIO 48 (★★★★)**
**Obtener el país que tiene más festivales de metal y cuya capacidad promedio supera las 50,000 personas.**

```sql
SELECT f.pais, COUNT(*) as num_festivales, AVG(f.capacidad_maxima) as capacidad_promedio
FROM festival f
WHERE f.generos LIKE '%Metal%'
GROUP BY f.pais
HAVING AVG(f.capacidad_maxima) > 50000
AND COUNT(*) >= ALL (
    SELECT COUNT(*)
    FROM festival f2
    WHERE f2.generos LIKE '%Metal%'
    GROUP BY f2.pais
    HAVING AVG(f2.capacidad_maxima) > 50000
);
```

#### **EJERCICIO 49 (★★★★)**
**Obtener el nombre de las bandas que han tenido más cambios de formación (entradas y salidas) que años de existencia.**

```sql
SELECT b.nombre
FROM banda b INNER JOIN integra i ON b.cod_banda = i.cod_banda
GROUP BY b.cod_banda
HAVING COUNT(*) > (YEAR(CURRENT_DATE) - b.año_formacion);
```

#### **EJERCICIO 50 (★★★★)**
**Obtener el nombre de los críticos que han dado puntuaciones más altas que el promedio en al menos 5 álbumes.**

```sql
SELECT cr.critico
FROM critica cr
WHERE cr.puntuacion > (
    SELECT AVG(cr2.puntuacion)
    FROM critica cr2
    WHERE cr2.cod_album = cr.cod_album
)
GROUP BY cr.critico
HAVING COUNT(*) >= 5;
```

### **EJERCICIOS 51-60: OPERACIONES DML (INSERT, UPDATE, DELETE)**

#### **EJERCICIO 51 (★★★)**
**Insertar una nueva banda de black metal noruega formada en 2020.**

```sql
INSERT INTO banda (cod_banda, nombre, pais, año_formacion, genero, activa)
VALUES ('BND150', 'Eternal Darkness', 'Noruega', 2020, 'Black Metal', 1);
```

#### **EJERCICIO 52 (★★★)**
**Insertar un nuevo músico guitarrista español nacido en 1995.**

```sql
INSERT INTO musico (dni, nombre, apellidos, fecha_nacimiento, pais_origen, instrumento_principal)
VALUES ('12345678X', 'Carlos', 'Fernández García', '1995-07-15', 'España', 'Guitarra');
```

#### **EJERCICIO 53 (★★★)**
**Incrementar un 20% el cachet de todas las actuaciones en festivales europeos.**

```sql
UPDATE actuacion a
INNER JOIN festival f ON a.cod_festival = f.cod_festival
SET a.cachet = a.cachet * 1.20
WHERE f.pais IN ('España', 'Francia', 'Alemania', 'Italia', 'Reino Unido', 'Holanda', 'Bélgica', 'Suecia', 'Noruega', 'Finlandia');
```

#### **EJERCICIO 54 (★★★)**
**Reducir un 15% el valor de todos los contratos de bandas que no han tocado en vivo en los últimos 2 años.**

```sql
UPDATE contrato c
SET c.valor_contrato = c.valor_contrato * 0.85
WHERE c.cod_banda NOT IN (
    SELECT DISTINCT a.cod_banda
    FROM actuacion a INNER JOIN festival f ON a.cod_festival = f.cod_festival
    WHERE f.fecha_inicio >= DATE_SUB(CURRENT_DATE, INTERVAL 2 YEAR)
);
```

#### **EJERCICIO 55 (★★★)**
**Aumentar un 25% las ventas de todos los álbumes que han ganado premios Grammy.**

```sql
UPDATE album al
SET al.ventas = al.ventas * 1.25
WHERE al.cod_album IN (
    SELECT p.cod_album
    FROM premio p
    WHERE p.categoria = 'Grammy'
    AND p.cod_album IS NOT NULL
);
```

#### **EJERCICIO 56 (★★★)**
**Insertar un nuevo álbum de estudio para la banda Metallica lanzado en 2024.**

```sql
INSERT INTO album (cod_album, titulo, año_lanzamiento, tipo, cod_banda, duracion_total, ventas)
VALUES ('ALB500', '72 Seasons Deluxe', 2024, 'Estudio', 
        (SELECT cod_banda FROM banda WHERE nombre = 'Metallica'), 
        4500, 0);
```

#### **EJERCICIO 57 (★★★)**
**Incrementar un 10% la duración de todas las canciones de álbumes en vivo.**

```sql
UPDATE cancion ca
INNER JOIN album al ON ca.cod_album = al.cod_album
SET ca.duracion = ca.duracion * 1.10
WHERE al.tipo = 'En vivo';
```

#### **EJERCICIO 58 (★★★)**
**Aumentar un 30% la capacidad máxima de todos los festivales que han tenido más de 10 bandas actuando.**

```sql
UPDATE festival f
SET f.capacidad_maxima = f.capacidad_maxima * 1.30
WHERE f.cod_festival IN (
    SELECT a.cod_festival
    FROM actuacion a
    GROUP BY a.cod_festival
    HAVING COUNT(DISTINCT a.cod_banda) > 10
);
```

#### **EJERCICIO 59 (★★★)**
**Insertar una nueva colaboración entre dos guitarristas en una canción específica.**

```sql
INSERT INTO colaboracion (dni_musico1, dni_musico2, cod_cancion, tipo_colaboracion)
VALUES (
    (SELECT dni FROM musico WHERE nombre = 'James' AND apellidos = 'Hetfield'),
    (SELECT dni FROM musico WHERE nombre = 'Dave' AND apellidos = 'Mustaine'),
    'CAN1001',
    'Duelo de guitarras'
);
```

#### **EJERCICIO 60 (★★★★)**
**Actualizar la fecha de salida de todos los músicos que han estado más de 15 años en la misma banda sin salir.**

```sql
UPDATE integra i
SET i.fecha_salida = CURRENT_DATE
WHERE i.fecha_salida IS NULL
AND YEAR(CURRENT_DATE) - YEAR(i.fecha_entrada) > 15
AND i.cod_banda IN (
    SELECT b.cod_banda
    FROM banda b
    WHERE b.activa = 0
);
```

### **EJERCICIOS 61-70: CASOS MIXTOS AVANZADOS**

#### **EJERCICIO 61 (★★★★★)**
**Obtener el nombre de las bandas que han mantenido la misma formación (sin cambios) por más tiempo que Metallica.**

```sql
SELECT b.nombre
FROM banda b
WHERE (
    SELECT MIN(CASE 
        WHEN i.fecha_salida IS NULL THEN YEAR(CURRENT_DATE) - YEAR(i.fecha_entrada)
        ELSE YEAR(i.fecha_salida) - YEAR(i.fecha_entrada)
    END)
    FROM integra i
    WHERE i.cod_banda = b.cod_banda
) > (
    SELECT MIN(CASE 
        WHEN i2.fecha_salida IS NULL THEN YEAR(CURRENT_DATE) - YEAR(i2.fecha_entrada)
        ELSE YEAR(i2.fecha_salida) - YEAR(i2.fecha_entrada)
    END)
    FROM integra i2 INNER JOIN banda b2 ON i2.cod_banda = b2.cod_banda
    WHERE b2.nombre = 'Metallica'
);
```

#### **EJERCICIO 62 (★★★★★)**
**Obtener el nombre de los festivales que solo han tenido bandas ganadoras de premios.**

```sql
SELECT f.nombre
FROM festival f
WHERE NOT EXISTS (
    SELECT 1
    FROM actuacion a
    WHERE a.cod_festival = f.cod_festival
    AND a.cod_banda NOT IN (
        SELECT DISTINCT p.cod_banda
        FROM premio p
        WHERE p.cod_banda IS NOT NULL
    )
);
```

#### **EJERCICIO 63 (★★★★★)**
**Obtener el nombre de las bandas cuyo álbum menos vendido tiene más ventas que el álbum más vendido de bandas de su mismo género formadas después.**

```sql
SELECT b.nombre
FROM banda b
WHERE (
    SELECT MIN(al.ventas)
    FROM album al
    WHERE al.cod_banda = b.cod_banda
) > (
    SELECT MAX(al2.ventas)
    FROM album al2 INNER JOIN banda b2 ON al2.cod_banda = b2.cod_banda
    WHERE b2.genero = b.genero
    AND b2.año_formacion > b.año_formacion
);
```

#### **EJERCICIO 64 (★★★★★)**
**Obtener el nombre de los músicos que han colaborado con más bandas diferentes que miembros han tenido en total.**

```sql
SELECT m.nombre, m.apellidos
FROM musico m
WHERE (
    SELECT COUNT(DISTINCT b.cod_banda)
    FROM colaboracion col 
    INNER JOIN cancion ca ON col.cod_cancion = ca.cod_cancion
    INNER JOIN album al ON ca.cod_album = al.cod_album
    INNER JOIN banda b ON al.cod_banda = b.cod_banda
    WHERE col.dni_musico1 = m.dni OR col.dni_musico2 = m.dni
) > (
    SELECT COUNT(DISTINCT i.cod_banda)
    FROM integra i
    WHERE i.dni = m.dni
);
```

#### **EJERCICIO 65 (★★★★★)**
**Obtener el nombre de las discográficas que han contratado bandas de todos los géneros que especializan.**

```sql
SELECT d.nombre
FROM discografica d
WHERE NOT EXISTS (
    SELECT 1
    FROM (
        SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.generos_especializados, ',', numbers.n), ',', -1)) as genero
        FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) numbers
        WHERE CHAR_LENGTH(d.generos_especializados) - CHAR_LENGTH(REPLACE(d.generos_especializados, ',', '')) >= numbers.n - 1
    ) generos_tabla
    WHERE NOT EXISTS (
        SELECT 1
        FROM contrato c INNER JOIN banda b ON c.cod_banda = b.cod_banda
        WHERE c.cod_disco = d.cod_disco
        AND b.genero = generos_tabla.genero
    )
);
```

#### **EJERCICIO 66 (★★★★★)**
**Obtener el nombre de las bandas que han tocado en festivales en todos los países donde tienen fans (medido por ventas de álbumes).**

```sql
SELECT b.nombre
FROM banda b
WHERE NOT EXISTS (
    SELECT DISTINCT f2.pais
    FROM festival f2 INNER JOIN actuacion a2 ON f2.cod_festival = a2.cod_festival
    INNER JOIN album al2 ON a2.cod_banda = al2.cod_banda
    WHERE al2.ventas > 10000  -- Países con ventas significativas
    AND NOT EXISTS (
        SELECT 1
        FROM actuacion a INNER JOIN festival f ON a.cod_festival = f.cod_festival
        WHERE a.cod_banda = b.cod_banda
        AND f.pais = f2.pais
    )
);
```

#### **EJERCICIO 67 (★★★★★)**
**Obtener el nombre de los críticos que han puntuado de forma más consistente (menor desviación estándar) en al menos 10 reseñas.**

```sql
SELECT cr.critico, STDDEV(cr.puntuacion) as desviacion
FROM critica cr
GROUP BY cr.critico
HAVING COUNT(*) >= 10
AND STDDEV(cr.puntuacion) <= ALL (
    SELECT STDDEV(cr2.puntuacion)
    FROM critica cr2
    GROUP BY cr2.critico
    HAVING COUNT(*) >= 10
);
```

#### **EJERCICIO 68 (★★★★★)**
**Obtener el nombre de las bandas que han tenido éxito internacional (han tocado en más de 5 países) pero nunca han ganado un premio en su país de origen.**

```sql
SELECT b.nombre
FROM banda b
WHERE (
    SELECT COUNT(DISTINCT f.pais)
    FROM actuacion a INNER JOIN festival f ON a.cod_festival = f.cod_festival
    WHERE a.cod_banda = b.cod_banda
) > 5
AND NOT EXISTS (
    SELECT 1
    FROM premio p
    WHERE p.cod_banda = b.cod_banda
    AND p.pais_premio = b.pais
);
```

#### **EJERCICIO 69 (★★★★★)**
**Obtener el nombre de las giras que han sido más rentables que todas las giras anteriores de la misma banda.**

```sql
SELECT g.nombre
FROM gira g
WHERE g.recaudacion_total > ALL (
    SELECT g2.recaudacion_total
    FROM gira g2
    WHERE g2.cod_banda = g.cod_banda
    AND g2.fecha_inicio < g.fecha_inicio
);
```

#### **EJERCICIO 70 (★★★★★)**
**Obtener el nombre de las canciones que han sido más colaborativas (más músicos invitados) que cualquier otra canción del mismo álbum.**

```sql
SELECT ca.titulo
FROM cancion ca
WHERE (
    SELECT COUNT(*)
    FROM colaboracion col
    WHERE col.cod_cancion = ca.cod_cancion
) > ALL (
    SELECT COUNT(*)
    FROM cancion ca2 LEFT JOIN colaboracion col2 ON ca2.cod_cancion = col2.cod_cancion
    WHERE ca2.cod_album = ca.cod_album
    AND ca2.cod_cancion != ca.cod_cancion
    GROUP BY ca2.cod_cancion
);
```

### **EJERCICIOS 71-80: ANÁLISIS TEMPORAL Y TENDENCIAS**

#### **EJERCICIO 71 (★★★★★)**
**Obtener el nombre de las bandas cuya productividad (álbumes por año) ha aumentado en la última década comparado con la anterior.**

```sql
SELECT b.nombre
FROM banda b
WHERE (
    SELECT COUNT(*) / 10.0
    FROM album al
    WHERE al.cod_banda = b.cod_banda
    AND al.año_lanzamiento BETWEEN YEAR(CURRENT_DATE) - 10 AND YEAR(CURRENT_DATE)
) > (
    SELECT COUNT(*) / 10.0
    FROM album al2
    WHERE al2.cod_banda = b.cod_banda
    AND al2.año_lanzamiento BETWEEN YEAR(CURRENT_DATE) - 20 AND YEAR(CURRENT_DATE) - 11
);
```

#### **EJERCICIO 72 (★★★★★)**
**Obtener el género musical que ha tenido el mayor crecimiento en número de bandas en los últimos 5 años.**

```sql
SELECT genero, 
       COUNT(CASE WHEN año_formacion >= YEAR(CURRENT_DATE) - 5 THEN 1 END) as bandas_recientes,
       COUNT(CASE WHEN año_formacion < YEAR(CURRENT_DATE) - 5 THEN 1 END) as bandas_anteriores
FROM banda
GROUP BY genero
HAVING COUNT(CASE WHEN año_formacion >= YEAR(CURRENT_DATE) - 5 THEN 1 END) > 
       COUNT(CASE WHEN año_formacion < YEAR(CURRENT_DATE) - 5 THEN 1 END)
ORDER BY (COUNT(CASE WHEN año_formacion >= YEAR(CURRENT_DATE) - 5 THEN 1 END) - 
          COUNT(CASE WHEN año_formacion < YEAR(CURRENT_DATE) - 5 THEN 1 END)) DESC
LIMIT 1;
```

#### **EJERCICIO 73 (★★★★★)**
**Obtener el nombre de las bandas que han mantenido contratos continuos (sin interrupciones) por más de 10 años.**

```sql
SELECT b.nombre
FROM banda b
WHERE EXISTS (
    SELECT 1
    FROM contrato c1
    WHERE c1.cod_banda = b.cod_banda
    AND YEAR(c1.fecha_fin) - YEAR(c1.fecha_inicio) > 10
    AND NOT EXISTS (
        SELECT 1
        FROM contrato c2
        WHERE c2.cod_banda = b.cod_banda
        AND c2.fecha_inicio > c1.fecha_fin
        AND c2.fecha_inicio - c1.fecha_fin > INTERVAL 1 YEAR
    )
);
```

#### **EJERCICIO 74 (★★★★★)**
**Obtener el nombre de los músicos que han tenido carreras más longevas (tiempo total en bandas) que la edad de la banda más antigua.**

```sql
SELECT m.nombre, m.apellidos
FROM musico m
WHERE (
    SELECT SUM(
        CASE 
            WHEN i.fecha_salida IS NULL THEN YEAR(CURRENT_DATE) - YEAR(i.fecha_entrada)
            ELSE YEAR(i.fecha_salida) - YEAR(i.fecha_entrada)
        END
    )
    FROM integra i
    WHERE i.dni = m.dni
) > (
    SELECT YEAR(CURRENT_DATE) - MIN(b.año_formacion)
    FROM banda b
);
```

#### **EJERCICIO 75 (★★★★★)**
**Obtener el nombre de las discográficas cuyos contratos promedio han aumentado de valor en los últimos 3 años.**

```sql
SELECT d.nombre
FROM discografica d
WHERE (
    SELECT AVG(c.valor_contrato)
    FROM contrato c
    WHERE c.cod_disco = d.cod_disco
    AND YEAR(c.fecha_inicio) >= YEAR(CURRENT_DATE) - 3
) > (
    SELECT AVG(c2.valor_contrato)
    FROM contrato c2
    WHERE c2.cod_disco = d.cod_disco
    AND YEAR(c2.fecha_inicio) < YEAR(CURRENT_DATE) - 3
);
```

#### **EJERCICIO 76 (★★★★★)**
**Obtener el nombre de las bandas que han tenido su período más productivo (más álbumes) en sus primeros 5 años de existencia.**

```sql
SELECT b.nombre
FROM banda b
WHERE (
    SELECT COUNT(*)
    FROM album al
    WHERE al.cod_banda = b.cod_banda
    AND al.año_lanzamiento BETWEEN b.año_formacion AND b.año_formacion + 5
) >= ALL (
    SELECT COUNT(*)
    FROM album al2
    WHERE al2.cod_banda = b.cod_banda
    AND al2.año_lanzamiento BETWEEN (b.año_formacion + periodo.inicio) AND (b.año_formacion + periodo.inicio + 5)
    FROM (SELECT 0 AS inicio UNION SELECT 5 UNION SELECT 10 UNION SELECT 15 UNION SELECT 20) periodo
    GROUP BY periodo.inicio
);
```

#### **EJERCICIO 77 (★★★★★)**
**Obtener el nombre de los festivales que han experimentado el mayor crecimiento en asistencia promedio (calculado por capacidad) en los últimos 5 años.**

```sql
SELECT f.nombre
FROM festival f
WHERE (
    SELECT AVG(f2.capacidad_maxima)
    FROM festival f2
    WHERE f2.cod_festival = f.cod_festival
    AND YEAR(f2.fecha_inicio) >= YEAR(CURRENT_DATE) - 5
) > 1.5 * (
    SELECT AVG(f3.capacidad_maxima)
    FROM festival f3
    WHERE f3.cod_festival = f.cod_festival
    AND YEAR(f3.fecha_inicio) < YEAR(CURRENT_DATE) - 5
);
```

#### **EJERCICIO 78 (★★★★★)**
**Obtener el nombre de las bandas que han reducido su actividad de giras (número de conciertos por año) en los últimos 5 años comparado con los 5 anteriores.**

```sql
SELECT b.nombre
FROM banda b
WHERE (
    SELECT AVG(g.numero_conciertos / (YEAR(g.fecha_fin) - YEAR(g.fecha_inicio) + 1))
    FROM gira g
    WHERE g.cod_banda = b.cod_banda
    AND YEAR(g.fecha_inicio) >= YEAR(CURRENT_DATE) - 5
) < (
    SELECT AVG(g2.numero_conciertos / (YEAR(g2.fecha_fin) - YEAR(g2.fecha_inicio) + 1))
    FROM gira g2
    WHERE g2.cod_banda = b.cod_banda
    AND YEAR(g2.fecha_inicio) BETWEEN YEAR(CURRENT_DATE) - 10 AND YEAR(CURRENT_DATE) - 6
);
```

#### **EJERCICIO 79 (★★★★★)**
**Obtener el nombre de los álbumes que han tenido el mayor impacto crítico en su año de lanzamiento (mejor puntuación promedio de su año).**

```sql
SELECT al.titulo, al.año_lanzamiento
FROM album al
WHERE (
    SELECT AVG(cr.puntuacion)
    FROM critica cr
    WHERE cr.cod_album = al.cod_album
) >= ALL (
    SELECT AVG(cr2.puntuacion)
    FROM album al2 INNER JOIN critica cr2 ON al2.cod_album = cr2.cod_album
    WHERE al2.año_lanzamiento = al.año_lanzamiento
    GROUP BY al2.cod_album
);
```

#### **EJERCICIO 80 (★★★★★)**
**Obtener el nombre de las bandas que han sido más influyentes (han inspirado formación de más bandas del mismo género después de su formación) en su género.**

```sql
SELECT b.nombre, b.genero
FROM banda b
WHERE (
    SELECT COUNT(*)
    FROM banda b2
    WHERE b2.genero = b.genero
    AND b2.año_formacion > b.año_formacion
) >= ALL (
    SELECT COUNT(*)
    FROM banda b3 
    INNER JOIN banda b4 ON b3.genero = b4.genero
    WHERE b4.año_formacion > b3.año_formacion
    AND b3.genero = b.genero
    GROUP BY b3.cod_banda
);
```

### **EJERCICIOS 81-90: CASOS ESPECIALES Y EXCEPCIONES**

#### **EJERCICIO 81 (★★★★★)**
**Obtener el nombre de las bandas que han tenido miembros fundadores que han salido y regresado al menos una vez.**

```sql
SELECT b.nombre
FROM banda b
WHERE EXISTS (
    SELECT 1
    FROM integra i1, integra i2
    WHERE i1.cod_banda = b.cod_banda
    AND i2.cod_banda = b.cod_banda
    AND i1.dni = i2.dni
    AND i1.es_fundador = 1
    AND i1.fecha_salida IS NOT NULL
    AND i2.fecha_entrada > i1.fecha_salida
);
```

#### **EJERCICIO 82 (★★★★★)**
**Obtener el nombre de los músicos que han tocado el mismo instrumento en todas las bandas donde han estado pero es diferente a su instrumento principal.**

```sql
SELECT m.nombre, m.apellidos
FROM musico m
WHERE EXISTS (
    SELECT i.instrumento
    FROM integra i
    WHERE i.dni = m.dni
    GROUP BY i.instrumento
    HAVING COUNT(DISTINCT i.cod_banda) = (
        SELECT COUNT(DISTINCT i2.cod_banda)
        FROM integra i2
        WHERE i2.dni = m.dni
    )
    AND i.instrumento != m.instrumento_principal
);
```

#### **EJERCICIO 83 (★★★★★)**
**Obtener el nombre de las bandas que han lanzado un álbum en cada década desde su formación hasta la actualidad.**

```sql
SELECT b.nombre
FROM banda b
WHERE NOT EXISTS (
    SELECT DISTINCT FLOOR(años.año/10)*10 as decada
    FROM (
        SELECT b.año_formacion + (n-1)*10 as año
        FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) numbers
        WHERE b.año_formacion + (n-1)*10 <= YEAR(CURRENT_DATE)
    ) años
    WHERE NOT EXISTS (
        SELECT 1
        FROM album al
        WHERE al.cod_banda = b.cod_banda
        AND FLOOR(al.año_lanzamiento/10)*10 = años.decada
    )
);
```

#### **EJERCICIO 84 (★★★★★)**
**Obtener el nombre de las discográficas que nunca han tenido dos bandas del mismo género bajo contrato simultáneamente.**

```sql
SELECT d.nombre
FROM discografica d
WHERE NOT EXISTS (
    SELECT 1
    FROM contrato c1, contrato c2, banda b1, banda b2
    WHERE c1.cod_disco = d.cod_disco
    AND c2.cod_disco = d.cod_disco
    AND c1.cod_banda = b1.cod_banda
    AND c2.cod_banda = b2.cod_banda
    AND b1.genero = b2.genero
    AND c1.cod_banda != c2.cod_banda
    AND c1.fecha_inicio <= c2.fecha_fin
    AND c2.fecha_inicio <= c1.fecha_fin
);
```

#### **EJERCICIO 85 (★★★★★)**
**Obtener el nombre de los festivales que han tenido al menos una banda de cada género que promocionan.**

```sql
SELECT f.nombre
FROM festival f
WHERE NOT EXISTS (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(f.generos, ',', numbers.n), ',', -1)) as genero
    FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) numbers
    WHERE CHAR_LENGTH(f.generos) - CHAR_LENGTH(REPLACE(f.generos, ',', '')) >= numbers.n - 1
    AND NOT EXISTS (
        SELECT 1
        FROM actuacion a INNER JOIN banda b ON a.cod_banda = b.cod_banda
        WHERE a.cod_festival = f.cod_festival
        AND b.genero = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(f.generos, ',', numbers.n), ',', -1))
    )
);
```

#### **EJERCICIO 86 (★★★★★)**
**Obtener el nombre de las bandas que han mantenido el mismo número de integrantes en todos sus álbumes de estudio.**

```sql
SELECT b.nombre
FROM banda b
WHERE 1 = (
    SELECT COUNT(DISTINCT miembros_por_album.num_miembros)
    FROM (
        SELECT al.cod_album, COUNT(DISTINCT i.dni) as num_miembros
        FROM album al 
        INNER JOIN integra i ON al.cod_banda = i.cod_banda
        WHERE al.cod_banda = b.cod_banda
        AND al.tipo = 'Estudio'
        AND i.fecha_entrada <= MAKEDATE(al.año_lanzamiento, 1)
        AND (i.fecha_salida IS NULL OR i.fecha_salida >= MAKEDATE(al.año_lanzamiento, 365))
        GROUP BY al.cod_album
    ) miembros_por_album
);
```

#### **EJERCICIO 87 (★★★★★)**
**Obtener el nombre de los músicos que han estado en bandas que han tocado en festivales en todos los continentes.**

```sql
SELECT m.nombre, m.apellidos
FROM musico m
WHERE NOT EXISTS (
    SELECT continente
    FROM (
        SELECT 'Europa' as continente
        UNION SELECT 'América del Norte'
        UNION SELECT 'América del Sur'
        UNION SELECT 'Asia'
        UNION SELECT 'África'
        UNION SELECT 'Oceanía'
    ) continentes
    WHERE NOT EXISTS (
        SELECT 1
        FROM integra i 
        INNER JOIN actuacion a ON i.cod_banda = a.cod_banda
        INNER JOIN festival f ON a.cod_festival = f.cod_festival
        WHERE i.dni = m.dni
        AND CASE 
            WHEN f.pais IN ('España', 'Francia', 'Alemania', 'Italia', 'Reino Unido') THEN 'Europa'
            WHEN f.pais IN ('Estados Unidos', 'Canadá', 'México') THEN 'América del Norte'
            WHEN f.pais IN ('Brasil', 'Argentina', 'Chile') THEN 'América del Sur'
            WHEN f.pais IN ('Japón', 'China', 'India') THEN 'Asia'
            WHEN f.pais IN ('Sudáfrica', 'Egipto') THEN 'África'
            WHEN f.pais IN ('Australia', 'Nueva Zelanda') THEN 'Oceanía'
        END = continentes.continente
    )
);
```

#### **EJERCICIO 88 (★★★★★)**
**Obtener el nombre de las giras que han visitado más países que álbumes ha lanzado la banda.**

```sql
SELECT g.nombre
FROM gira g
WHERE (
    SELECT COUNT(DISTINCT f.pais)
    FROM actuacion a INNER JOIN festival f ON a.cod_festival = f.cod_festival
    WHERE a.cod_banda = g.cod_banda
    AND a.fecha_actuacion BETWEEN g.fecha_inicio AND g.fecha_fin
) > (
    SELECT COUNT(*)
    FROM album al
    WHERE al.cod_banda = g.cod_banda
);
```

#### **EJERCICIO 89 (★★★★★)**
**Obtener el nombre de las bandas cuyos álbumes han sido reseñados por críticos de más países diferentes que países donde han tocado.**

```sql
SELECT b.nombre
FROM banda b
WHERE (
    SELECT COUNT(DISTINCT cr.pais_critico)
    FROM album al INNER JOIN critica cr ON al.cod_album = cr.cod_album
    WHERE al.cod_banda = b.cod_banda
) > (
    SELECT COUNT(DISTINCT f.pais)
    FROM actuacion a INNER JOIN festival f ON a.cod_festival = f.cod_festival
    WHERE a.cod_banda = b.cod_banda
);
```

#### **EJERCICIO 90 (★★★★★)**
**Obtener el nombre de las discográficas que han contratado bandas que posteriormente han ganado más premios que el número de bandas que tienen contratadas.**

```sql
SELECT d.nombre
FROM discografica d
WHERE EXISTS (
    SELECT 1
    FROM contrato c INNER JOIN banda b ON c.cod_banda = b.cod_banda
    WHERE c.cod_disco = d.cod_disco
    AND (
        SELECT COUNT(*)
        FROM premio p
        WHERE p.cod_banda = b.cod_banda
        AND p.año >= YEAR(c.fecha_inicio)
    ) > (
        SELECT COUNT(DISTINCT c2.cod_banda)
        FROM contrato c2
        WHERE c2.cod_disco = d.cod_disco
    )
);
```

### **EJERCICIOS 91-100: CASOS EXTREMOS Y OPTIMIZACIÓN**

#### **EJERCICIO 91 (★★★★★)**
**Obtener el nombre de las bandas que han tenido la mayor diversidad instrumental (mayor número de instrumentos diferentes tocados por sus miembros históricos).**

```sql
SELECT b.nombre, COUNT(DISTINCT i.instrumento) as diversidad_instrumental
FROM banda b INNER JOIN integra i ON b.cod_banda = i.cod_banda
GROUP BY b.cod_banda
HAVING COUNT(DISTINCT i.instrumento) >= ALL (
    SELECT COUNT(DISTINCT i2.instrumento)
    FROM integra i2
    GROUP BY i2.cod_banda
);
```

#### **EJERCICIO 92 (★★★★★)**
**Obtener el nombre de los músicos que han sido los únicos representantes de su país en bandas internacionales (bandas con miembros de al menos 3 países diferentes).**

```sql
SELECT m.nombre, m.apellidos, m.pais_origen
FROM musico m
WHERE EXISTS (
    SELECT 1
    FROM integra i
    WHERE i.dni = m.dni
    AND (
        SELECT COUNT(DISTINCT m2.pais_origen)
        FROM integra i2 INNER JOIN musico m2 ON i2.dni = m2.dni
        WHERE i2.cod_banda = i.cod_banda
    ) >= 3
    AND NOT EXISTS (
        SELECT 1
        FROM integra i3 INNER JOIN musico m3 ON i3.dni = m3.dni
        WHERE i3.cod_banda = i.cod_banda
        AND m3.pais_origen = m.pais_origen
        AND m3.dni != m.dni
    )
);
```

#### **EJERCICIO 93 (★★★★★)**
**Obtener el nombre de las canciones que han tenido más colaboraciones internacionales (músicos de diferentes países) que la duración de la canción en minutos.**

```sql
SELECT ca.titulo
FROM cancion ca
WHERE (
    SELECT COUNT(DISTINCT m.pais_origen)
    FROM colaboracion col 
    INNER JOIN musico m ON col.dni_musico1 = m.dni OR col.dni_musico2 = m.dni
    WHERE col.cod_cancion = ca.cod_cancion
) > (ca.duracion / 60);
```

#### **EJERCICIO 94 (★★★★★)**
**Obtener el nombre de las bandas que han experimentado la mayor evolución estilística (han tocado en festivales de géneros más diversos que su género original).**

```sql
SELECT b.nombre
FROM banda b
WHERE (
    SELECT COUNT(DISTINCT 
        CASE 
            WHEN f.generos LIKE '%Metal%' THEN 'Metal'
            WHEN f.generos LIKE '%Rock%' THEN 'Rock'
            WHEN f.generos LIKE '%Punk%' THEN 'Punk'
            WHEN f.generos LIKE '%Alternative%' THEN 'Alternative'
            ELSE 'Otros'
        END
    )
    FROM actuacion a INNER JOIN festival f ON a.cod_festival = f.cod_festival
    WHERE a.cod_banda = b.cod_banda
) >= ALL (
    SELECT COUNT(DISTINCT 
        CASE 
            WHEN f2.generos LIKE '%Metal%' THEN 'Metal'
            WHEN f2.generos LIKE '%Rock%' THEN 'Rock'
            WHEN f2.generos LIKE '%Punk%' THEN 'Punk'
            WHEN f2.generos LIKE '%Alternative%' THEN 'Alternative'
            ELSE 'Otros'
        END
    )
    FROM actuacion a2 INNER JOIN festival f2 ON a2.cod_festival = f2.cod_festival
    GROUP BY a2.cod_banda
);
```

#### **EJERCICIO 95 (★★★★★)**
**Obtener el nombre de los festivales que han logrado el mayor equilibrio generacional (diferencia mínima entre la banda más joven y más veterana que han presentado).**

```sql
SELECT f.nombre, 
       MAX(YEAR(CURRENT_DATE) - b.año_formacion) - MIN(YEAR(CURRENT_DATE) - b.año_formacion) as diferencia_generacional
FROM festival f 
INNER JOIN actuacion a ON f.cod_festival = a.cod_festival
INNER JOIN banda b ON a.cod_banda = b.cod_banda
GROUP BY f.cod_festival
HAVING MAX(YEAR(CURRENT_DATE) - b.año_formacion) - MIN(YEAR(CURRENT_DATE) - b.año_formacion) <= ALL (
    SELECT MAX(YEAR(CURRENT_DATE) - b2.año_formacion) - MIN(YEAR(CURRENT_DATE) - b2.año_formacion)
    FROM festival f2 
    INNER JOIN actuacion a2 ON f2.cod_festival = a2.cod_festival
    INNER JOIN banda b2 ON a2.cod_banda = b2.cod_banda
    GROUP BY f2.cod_festival
    HAVING COUNT(DISTINCT a2.cod_banda) >= 5
);
```

#### **EJERCICIO 96 (★★★★★)**
**Obtener el nombre de las bandas que han mantenido la mayor coherencia contractual (han renovado contratos con la misma discográfica más veces que años de existencia).**

```sql
SELECT b.nombre
FROM banda b
WHERE (
    SELECT COUNT(*)
    FROM contrato c
    WHERE c.cod_banda = b.cod_banda
    GROUP BY c.cod_disco
    ORDER BY COUNT(*) DESC
    LIMIT 1
) > (YEAR(CURRENT_DATE) - b.año_formacion);
```

#### **EJERCICIO 97 (★★★★★)**
**Obtener el nombre de los álbumes que han tenido el mayor impacto comercial relativo (ventas divididas por el número de años desde el lanzamiento mayor que cualquier otro álbum de la banda).**

```sql
SELECT al.titulo
FROM album al
WHERE (al.ventas / (YEAR(CURRENT_DATE) - al.año_lanzamiento + 1)) >= ALL (
    SELECT al2.ventas / (YEAR(CURRENT_DATE) - al2.año_lanzamiento + 1)
    FROM album al2
    WHERE al2.cod_banda = al.cod_banda
    AND al2.cod_album != al.cod_album
);
```

#### **EJERCICIO 98 (★★★★★)**
**Obtener el nombre de las discográficas que han demostrado la mayor lealtad artística (mayor porcentaje de renovaciones de contratos exitosas).**

```sql
SELECT d.nombre, 
       (COUNT(renovaciones.cod_banda) * 100.0 / COUNT(DISTINCT c.cod_banda)) as porcentaje_renovaciones
FROM discografica d 
INNER JOIN contrato c ON d.cod_disco = c.cod_disco
LEFT JOIN (
    SELECT c1.cod_banda, c1.cod_disco
    FROM contrato c1, contrato c2
    WHERE c1.cod_banda = c2.cod_banda
    AND c1.cod_disco = c2.cod_disco
    AND c1.fecha_fin < c2.fecha_inicio
    AND c2.fecha_inicio - c1.fecha_fin <= INTERVAL 1 YEAR
) renovaciones ON c.cod_banda = renovaciones.cod_banda AND c.cod_disco = renovaciones.cod_disco
GROUP BY d.cod_disco
HAVING COUNT(DISTINCT c.cod_banda) >= 5
AND (COUNT(renovaciones.cod_banda) * 100.0 / COUNT(DISTINCT c.cod_banda)) >= ALL (
    SELECT (COUNT(ren2.cod_banda) * 100.0 / COUNT(DISTINCT c3.cod_banda))
    FROM discografica d2 
    INNER JOIN contrato c3 ON d2.cod_disco = c3.cod_disco
    LEFT JOIN (
        SELECT c4.cod_banda, c4.cod_disco
        FROM contrato c4, contrato c5
        WHERE c4.cod_banda = c5.cod_banda
        AND c4.cod_disco = c5.cod_disco
        AND c4.fecha_fin < c5.fecha_inicio
        AND c5.fecha_inicio - c4.fecha_fin <= INTERVAL 1 YEAR
    ) ren2 ON c3.cod_banda = ren2.cod_banda AND c3.cod_disco = ren2.cod_disco
    GROUP BY d2.cod_disco
    HAVING COUNT(DISTINCT c3.cod_banda) >= 5
);
```

#### **EJERCICIO 99 (★★★★★)**
**Obtener el nombre de las bandas que han logrado el mayor equilibrio entre éxito comercial y reconocimiento crítico (correlación positiva entre ventas y puntuaciones).**

```sql
SELECT b.nombre
FROM banda b
WHERE (
    SELECT 
        (COUNT(*) * SUM(al.ventas * cr_avg.puntuacion_media) - SUM(al.ventas) * SUM(cr_avg.puntuacion_media)) /
        SQRT((COUNT(*) * SUM(al.ventas * al.ventas) - SUM(al.ventas) * SUM(al.ventas)) *
             (COUNT(*) * SUM(cr_avg.puntuacion_media * cr_avg.puntuacion_media) - SUM(cr_avg.puntuacion_media) * SUM(cr_avg.puntuacion_media)))
    FROM album al 
    INNER JOIN (
        SELECT cr.cod_album, AVG(cr.puntuacion) as puntuacion_media
        FROM critica cr
        GROUP BY cr.cod_album
    ) cr_avg ON al.cod_album = cr_avg.cod_album
    WHERE al.cod_banda = b.cod_banda
) >= ALL (
    SELECT 
        (COUNT(*) * SUM(al2.ventas * cr_avg2.puntuacion_media) - SUM(al2.ventas) * SUM(cr_avg2.puntuacion_media)) /
        SQRT((COUNT(*) * SUM(al2.ventas * al2.ventas) - SUM(al2.ventas) * SUM(al2.ventas)) *
             (COUNT(*) * SUM(cr_avg2.puntuacion_media * cr_avg2.puntuacion_media) - SUM(cr_avg2.puntuacion_media) * SUM(cr_avg2.puntuacion_media)))
    FROM album al2 
    INNER JOIN (
        SELECT cr2.cod_album, AVG(cr2.puntuacion) as puntuacion_media
        FROM critica cr2
        GROUP BY cr2.cod_album
    ) cr_avg2 ON al2.cod_album = cr_avg2.cod_album
    GROUP BY al2.cod_banda
    HAVING COUNT(*) >= 3
);
```

#### **EJERCICIO 100 (★★★★★)**
**Obtener el nombre del músico que ha tenido la carrera más extraordinaria: ha estado en el mayor número de bandas ganadoras de premios, ha colaborado en más canciones que años de carrera tiene, y ha tocado en festivales de al menos 4 continentes diferentes.**

```sql
SELECT m.nombre, m.apellidos
FROM musico m
WHERE (
    -- Bandas ganadoras de premios
    SELECT COUNT(DISTINCT i.cod_banda)
    FROM integra i INNER JOIN premio p ON i.cod_banda = p.cod_banda
    WHERE i.dni = m.dni
) >= ALL (
    SELECT COUNT(DISTINCT i2.cod_banda)
    FROM integra i2 INNER JOIN premio p2 ON i2.cod_banda = p2.cod_banda
    GROUP BY i2.dni
)
AND (
    -- Más colaboraciones que años de carrera
    SELECT COUNT(*)
    FROM colaboracion col
    WHERE col.dni_musico1 = m.dni OR col.dni_musico2 = m.dni
) > (
    SELECT YEAR(CURRENT_DATE) - MIN(YEAR(i3.fecha_entrada))
    FROM integra i3
    WHERE i3.dni = m.dni
)
AND (
    -- Al menos 4 continentes
    SELECT COUNT(DISTINCT 
        CASE 
            WHEN f.pais IN ('España', 'Francia', 'Alemania', 'Italia', 'Reino Unido') THEN 'Europa'
            WHEN f.pais IN ('Estados Unidos', 'Canadá', 'México') THEN 'América del Norte'
            WHEN f.pais IN ('Brasil', 'Argentina', 'Chile') THEN 'América del Sur'
            WHEN f.pais IN ('Japón', 'China', 'India') THEN 'Asia'
            WHEN f.pais IN ('Sudáfrica', 'Egipto') THEN 'África'
            WHEN f.pais IN ('Australia', 'Nueva Zelanda') THEN 'Oceanía'
        END
    )
    FROM integra i4 
    INNER JOIN actuacion a ON i4.cod_banda = a.cod_banda
    INNER JOIN festival f ON a.cod_festival = f.cod_festival
    WHERE i4.dni = m.dni
) >= 4;
```

---

## 🎓 **CONCEPTOS CLAVE APLICADOS**

### 🔸 **Técnicas Avanzadas Utilizadas:**

1. **División Relacional Compleja**: Ejercicios 1-10
   - Uso de NOT EXISTS anidados
   - Verificación de "todos los elementos"
   - Subconsultas correlacionadas múltiples

2. **LEFT JOIN Estratégico**: Ejercicios 11-20
   - Inclusión de registros sin coincidencias
   - Agregaciones que mantienen todos los elementos
   - Conteos con valores nulos

3. **Rankings sin LIMIT**: Ejercicios 21-30
   - Uso de subconsultas para posiciones específicas
   - Comparaciones con >= ALL y <= ALL
   - Rangos de posiciones

4. **Subconsultas Correlacionadas**: Ejercicios 31-40
   - Referencias cruzadas entre consulta externa e interna
   - Cálculos comparativos complejos
   - Análisis condicionales

5. **HAVING Avanzado**: Ejercicios 41-50
   - Filtros post-agregación
   - Múltiples condiciones de grupo
   - Comparaciones entre agregaciones

6. **DML con Lógica Compleja**: Ejercicios 51-60
   - INSERT con subconsultas
   - UPDATE con porcentajes y condiciones
   - Modificaciones masivas controladas

7. **Análisis Temporal**: Ejercicios 61-80
   - Comparaciones entre períodos
   - Tendencias y evoluciones
   - Cálculos de crecimiento

8. **Casos Especiales**: Ejercicios 81-100
   - Lógica de excepciones
   - Condiciones múltiples complejas
   - Optimizaciones extremas

### 🔸 **Patrones SQL Críticos Dominados:**

- **NOT EXISTS** para negaciones seguras
- **LEFT JOIN** para preservar todos los registros
- **Subconsultas correlacionadas** para comparaciones dinámicas
- **HAVING con agregaciones** para filtros post-grupo
- **Rankings sin LIMIT** usando conteos
- **Análisis temporal** con funciones de fecha
- **División relacional** para consultas "todos"
- **Correlaciones estadísticas** en SQL
- **Optimización de consultas** complejas

¡Con estos 100 ejercicios dominarás SQL avanzado en contextos reales del mundo de la música rock y metal! 🤘🎸
