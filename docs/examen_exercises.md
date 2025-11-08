# EXAMEN EXTENSO DE SQL - Casos Complicados y Técnicas Avanzadas

Este repositorio quedó organizado en torno a dos grandes bloques prácticos:

- **Rock & Metal** (`sql/rock_metal_db.sql` + `docs/rock_metal_schema.md` + `docs/rock_metal_exercises.md`): base de datos enorme con vistas, triggers y 100 ejercicios avanzados.
- **Bases del examen** (`sql/exam_databases.sql`): script maestro que crea y rellena las bases de datos clásicas del examen (ciclismo, segunda mano, música, biblioteca y baloncesto) con decenas de registros dummy en cada tabla.

## Guía rápida de uso
- Ejecuta cualquier script con `mysql -u <usuario> -p < script.sql`.
- Repite sin miedo: todos los scripts limpian objetos anteriores (`DROP ... IF EXISTS`) y restauran datos consistentes de prueba.
- Consulta la carpeta `docs/` para conocer qué resuelve cada archivo y cómo están pensados los ejercicios.
- Cuando necesites practicar consultas difíciles, comienza cargando la BD correspondiente y después sigue los ejercicios de este `README` o de `docs/rock_metal_exercises.md`.

### Cobertura de datos dummy (`sql/exam_databases.sql`)
- Ciclismo: 20 equipos, 100 ciclistas, 30 etapas, 90 puertos y 150 asignaciones de maillots listas para practicar NOT EXISTS, HAVING, etc.
- Segunda mano: 18 concesionarios, 108 vendedores y 216 coches para practicar `JOIN`, `GROUP BY` y subconsultas de negocio.
- Música: 19 grupos, 38 discos, más de 100 canciones y plantillas completas de artistas/clubes para CTEs de cobertura.
- Biblioteca: 16 autores, 30 libros, 50 obras y 35 lectores con préstamos múltiples para casos de división relacional.
- Baloncesto: 15 equipos, más de 100 jugadores, 35 partidos y estadísticas recientes para ejercicios con ventanas y agregaciones.

## ENUNCIADO Y CHULETA DE ESTUDIO

### 📚 **ESQUEMAS DE BASES DE DATOS**

#### 🚴 **Base de Datos CICLISMO**
```sql
EQUIPO(nomeq, director)
CICLISTA(dorsal, nombre, edad, nomeq)
ETAPA(netapa, km, salida, llegada, dorsal)
PUERTO(nompuerto, altura, pendiente, categoria, netapa, dorsal)
MAILLOT(codigo, tipo, premio, color)
LLEVAR(codigo, netapa, dorsal)
```

#### 🚗 **Base de Datos SEGUNDA MANO**
```sql
CONCESIONARIO(codi_con, nom, ciudad, director)
VENDEDOR(dni, nom, tlf, ventas, codi_con)
COCHE(matricula, marca, modelo, color, kms, precio, codi_con)
```

#### 🎵 **Base de Datos MÚSICA**
```sql
COMPANYIA(cod, nombre, dir, fax, tfno)
DISCO(cod, nombre, fecha, cod_comp, cod_gru)
GRUPO(cod, nombre, fecha, pais)
ARTISTA(dni, nombre)
CLUB(cod, nombre, sede, num, cod_gru)
CANCION(cod, titulo, duracion)
ESTA(cod, can)
PERTENECE(dni, cod, funcion)
```

#### 📚 **Base de Datos BIBLIOTECA**
```sql
AUTOR(autor_id, nombre, nacionalidad)
LIBRO(id_lib, titulo, año, varias_obras)
TEMA(tematica, descripcion)
OBRA(cod_ob, titulo, tematica)
AMIGO(num, nombre, telefono)
PRESTAMO(num, id_lib)
ESTA_EN(cod_ob, id_lib)
ESCRIBIR(cod_ob, autor_id)
```

---

## 🔥 **CASOS CRÍTICOS: NOT EXISTS vs NOT IN**

### ⚠️ **REGLA DE ORO:**
- **NOT IN**: Se rompe con valores NULL (devuelve UNKNOWN)
- **NOT EXISTS**: Funciona correctamente con NULL
- **LEFT JOIN + IS NULL**: Alternativa robusta

---

## 🎯 **CASOS LEFT JOIN ESENCIALES**

### 🔍 **Cuándo usar LEFT JOIN:**
1. **Incluir registros sin coincidencias** (ej: equipos sin ciclistas)
2. **Contar elementos que pueden ser cero**
3. **Evitar perder datos en agregaciones**

---

## 📝 **EXAMEN PRÁCTICO - 30 EJERCICIOS**

### **EJERCICIO 1 - DIVISIÓN RELACIONAL (★★★★★)**
**Obtener el nombre de los ciclistas que han ganado todos los puertos de una etapa y además han ganado esa misma etapa.**

```sql
SELECT c.nombre
FROM ciclista c 
INNER JOIN etapa e ON c.dorsal = e.dorsal
INNER JOIN puerto p ON e.netapa = p.netapa AND c.dorsal = p.dorsal
GROUP BY c.nombre, e.netapa
HAVING COUNT(DISTINCT p.nompuerto) = (
    SELECT COUNT(*)
    FROM puerto p2
    WHERE p2.netapa = e.netapa
);
```

---

### **EJERCICIO 2 - NOT EXISTS COMPLEJO (★★★★★)**
**Obtener el nombre de los equipos tal que sus ciclistas SOLO hayan ganado puertos de 1ª categoría.**

```sql
SELECT DISTINCT e.nomeq
FROM equipo e INNER JOIN ciclista c ON e.nomeq = c.nomeq
WHERE NOT EXISTS (
    SELECT 1
    FROM ciclista c2 INNER JOIN puerto p ON c2.dorsal = p.dorsal
    WHERE c2.nomeq = e.nomeq AND p.categoria != 1
);
```

---

### **EJERCICIO 3 - RANKING SIN LIMIT (★★★★)**
**Obtener el décimo club con mayor número de fans (debe haber solo 9 por encima de él).**

```sql
SELECT c.nombre, c.num
FROM club c
WHERE 9 = (
    SELECT COUNT(*)
    FROM club c2
    WHERE c.num < c2.num
);
```

---

### **EJERCICIO 4 - LEFT JOIN + HAVING (★★★★)**
**Obtener el nombre de los ciclistas que han ganado más de un puerto, indicando cuántos han ganado.**

```sql
SELECT c.nombre, COUNT(p.nompuerto)
FROM ciclista c LEFT JOIN puerto p ON c.dorsal = p.dorsal
GROUP BY c.dorsal
HAVING COUNT(p.nompuerto) > 1;
```

---

### **EJERCICIO 5 - NOT EXISTS CON MÚLTIPLES CONDICIONES (★★★★)**
**Obtener el nombre de las compañías discográficas que solo han trabajado con grupos españoles.**

```sql
SELECT DISTINCT c.nombre
FROM companyia c INNER JOIN disco d ON c.cod = d.cod_comp
WHERE NOT EXISTS (
    SELECT 1
    FROM companyia c2 INNER JOIN disco d2 ON c2.cod = d2.cod_comp
    INNER JOIN grupo g ON g.cod = d2.cod_gru
    WHERE c2.cod = c.cod AND g.pais != "España"
);
```

---

### **EJERCICIO 6 - TODOS vs ALGUNOS (★★★★★)**
**Obtener el nombre de los amigos que han leído todas las obras del autor 'RUKI'.**

```sql
SELECT a.nombre
FROM amigo a INNER JOIN prestamo p ON a.num = p.num
INNER JOIN esta_en ee ON p.id_lib = ee.id_lib
INNER JOIN escribir e ON e.cod_ob = ee.cod_ob
WHERE e.autor_id = "RUKI"
GROUP BY a.num
HAVING COUNT(DISTINCT e.cod_ob) = (
    SELECT COUNT(*)
    FROM escribir e2
    WHERE e2.autor_id = "RUKI"
);
```

---

### **EJERCICIO 7 - MÁXIMO CON >= ALL (★★★★)**
**¿Cuál es la compañía discográfica que más canciones ha grabado?**

```sql
SELECT c.nombre
FROM companyia c INNER JOIN disco d ON c.cod = d.cod_comp
INNER JOIN esta e ON e.cod = d.cod
GROUP BY c.cod
HAVING COUNT(e.can) >= ALL (
    SELECT COUNT(e2.can)
    FROM disco d2 INNER JOIN esta e2 ON e2.cod = d2.cod
    GROUP BY d2.cod_comp
);
```

---

### **EJERCICIO 8 - ETAPAS SIN PUERTOS (★★★★)**
**Obtener el número de etapa y la ciudad de salida de aquellas etapas que no tengan puertos de montaña.**

```sql
SELECT e.netapa, e.salida
FROM etapa e
WHERE NOT EXISTS (
    SELECT 1
    FROM puerto p
    WHERE p.netapa = e.netapa
);
```

---

### **EJERCICIO 9 - TODOS LOS MIEMBROS DE UN GRUPO (★★★★★)**
**Obtener el nombre de los equipos y la edad media de sus ciclistas de aquellos equipos cuya media de edad sea la máxima de todos los equipos.**

```sql
SELECT c.nomeq, AVG(c.edad)
FROM ciclista c
GROUP BY c.nomeq
HAVING AVG(c.edad) >= ALL (
    SELECT AVG(c2.edad)
    FROM ciclista c2
    GROUP BY c2.nomeq
);
```

---

### **EJERCICIO 10 - CONDICIÓN ÚNICA (★★★★★)**
**Obtener el título de la canción de mayor duración si es única.**

```sql
SELECT c.titulo, c.duracion
FROM cancion c
WHERE c.duracion = (SELECT MAX(duracion) FROM cancion)
GROUP BY c.duracion
HAVING COUNT(*) = 1;
```

---

### **EJERCICIO 11 - LEFT JOIN PARA INCLUIR TODOS (★★★★)**
**Obtener el nombre de todos los equipos indicando cuántos ciclistas tiene cada uno (incluyendo los que no tienen ninguno).**

```sql
SELECT e.nomeq, COUNT(c.dorsal)
FROM equipo e LEFT JOIN ciclista c ON e.nomeq = c.nomeq
GROUP BY e.nomeq;
```

---

### **EJERCICIO 12 - AUTORES SIN OBRAS (★★★★)**
**Obtener el nombre de los autores de los que no se tiene ninguna obra.**

```sql
SELECT a.nombre
FROM autor a
WHERE NOT EXISTS (
    SELECT 1
    FROM escribir e
    WHERE e.autor_id = a.autor_id
);
```

---

### **EJERCICIO 13 - MÚLTIPLES CONDICIONES EN HAVING (★★★★)**
**Obtener el nombre de los ciclistas que pertenezcan a un equipo que tenga más de cinco corredores y que hayan ganado alguna etapa, indicando cuántas etapas ha ganado.**

```sql
SELECT c.nombre, COUNT(e.netapa) as etapas_ganadas
FROM ciclista c INNER JOIN etapa e ON c.dorsal = e.dorsal
WHERE c.nomeq IN (
    SELECT c2.nomeq
    FROM ciclista c2
    GROUP BY c2.nomeq
    HAVING COUNT(c2.dorsal) > 5
)
GROUP BY c.dorsal;
```

---

### **EJERCICIO 14 - COMPARACIÓN CON SUBCONSULTA (★★★★)**
**Obtener los nombres de los puertos cuya altura es mayor que la media de altura de los puertos de 2ª categoría.**

```sql
SELECT p.nompuerto
FROM puerto p
WHERE p.altura > (
    SELECT AVG(p2.altura)
    FROM puerto p2
    WHERE p2.categoria = 2
);
```

---

### **EJERCICIO 15 - MÚLTIPLES NIVELES DE AGRUPACIÓN (★★★★★)**
**Obtener el nombre de los artistas que tengan la función de bajo en un único grupo y que además éste tenga más de dos miembros.**

```sql
SELECT a.nombre
FROM artista a INNER JOIN pertenece p ON a.dni = p.dni
WHERE p.funcion = "bajo"
AND p.cod IN (
    SELECT p2.cod
    FROM pertenece p2
    GROUP BY p2.cod
    HAVING COUNT(p2.dni) > 2
)
GROUP BY a.dni
HAVING COUNT(p.cod) = 1;
```

---

### **EJERCICIO 16 - ETAPAS CON CONDICIONES ESPECIALES (★★★★)**
**Obtener el valor del atributo netapa de aquellas etapas tales que todos los puertos que están en ellas tienen más de 700 metros de altura.**

```sql
SELECT e.netapa
FROM etapa e INNER JOIN puerto p ON e.netapa = p.netapa
GROUP BY e.netapa
HAVING MIN(p.altura) > 700;
```

---

### **EJERCICIO 17 - TODOS LOS DE UN TIPO (★★★★★)**
**Obtener el nombre y el director de los equipos tales que todos sus ciclistas son mayores de 26 años.**

```sql
SELECT e.nomeq, e.director
FROM equipo e INNER JOIN ciclista c ON e.nomeq = c.nomeq
GROUP BY e.nomeq
HAVING MIN(c.edad) > 26;
```

---

### **EJERCICIO 18 - SOLO UN TIPO DE CARACTERÍSTICA (★★★★★)**
**Obtener el nombre de los amigos que solo han leído obras de un autor.**

```sql
SELECT a.nombre
FROM amigo a INNER JOIN prestamo p ON a.num = p.num
INNER JOIN esta_en ee ON p.id_lib = ee.id_lib
INNER JOIN escribir e ON ee.cod_ob = e.cod_ob
GROUP BY a.num
HAVING COUNT(DISTINCT e.autor_id) = 1;
```

---

### **EJERCICIO 19 - NACIONALIDADES MENOS FRECUENTES (★★★★)**
**Obtener la nacionalidad (o nacionalidades) menos frecuentes entre los autores.**

```sql
SELECT a.nacionalidad, COUNT(a.autor_id)
FROM autor a
GROUP BY a.nacionalidad
HAVING COUNT(a.autor_id) <= ALL (
    SELECT COUNT(*)
    FROM autor a2
    GROUP BY a2.nacionalidad
);
```

---

### **EJERCICIO 20 - CICLISTA MÁS JOVEN CON CONDICIÓN (★★★★)**
**Obtener el nombre del ciclista más joven que ha ganado al menos una etapa.**

```sql
SELECT c.nombre, c.edad
FROM ciclista c INNER JOIN etapa e ON c.dorsal = e.dorsal
WHERE c.edad = (
    SELECT MIN(c2.edad)
    FROM ciclista c2 INNER JOIN etapa e2 ON c2.dorsal = e2.dorsal
);
```

---

### **EJERCICIO 21 - OBRAS CON MÚLTIPLES AUTORES (★★★★)**
**Obtener el título y el código de las obras que tengan más de un autor.**

```sql
SELECT o.titulo, o.cod_ob
FROM obra o INNER JOIN escribir e ON o.cod_ob = e.cod_ob
GROUP BY o.cod_ob
HAVING COUNT(e.autor_id) > 1;
```

---

### **EJERCICIO 22 - CONCESIONARIO CON MÁS VENTAS (★★★★)**
**Obtener el nombre del concesionario que tenga la mayor suma de ventas de sus vendedores.**

```sql
SELECT c.nom
FROM concesionario c INNER JOIN vendedor v ON c.codi_con = v.codi_con
GROUP BY c.codi_con
HAVING SUM(v.ventas) >= ALL (
    SELECT SUM(v2.ventas)
    FROM vendedor v2
    GROUP BY v2.codi_con
);
```

---

### **EJERCICIO 23 - ARTISTAS EN MÚLTIPLES GRUPOS (★★★★)**
**Obtener el nombre de los artistas que pertenecen a más de un grupo.**

```sql
SELECT a.nombre
FROM artista a INNER JOIN pertenece p ON a.dni = p.dni
GROUP BY a.dni
HAVING COUNT(DISTINCT p.cod) > 1;
```

---

### **EJERCICIO 24 - LIBROS CON TÍTULO Y MÚLTIPLES OBRAS (★★★★)**
**Obtener el título y el identificador de los libros que tengan título y más de dos obras, indicando el número de obras.**

```sql
SELECT l.titulo, l.id_lib, l.varias_obras
FROM libro l
WHERE l.titulo IS NOT NULL AND l.varias_obras > 2;
```

---

### **EJERCICIO 25 - EDAD MEDIA DE GANADORES (★★★★)**
**Obtener la edad media de los ciclistas que han ganado alguna etapa.**

```sql
SELECT AVG(c.edad)
FROM ciclista c INNER JOIN etapa e ON c.dorsal = e.dorsal;
```

---

### **EJERCICIO 26 - INSERT COMPLEJO (★★★)**
**Añadir un nuevo coche con los siguientes datos:**
- Matrícula: '9876ZXY', Precio: 25000, Código concesionario: 'VAL03'
- Marca: 'TESLA', Modelo: 'MODEL_3', Color: 'BLANCO', Kilómetros: 0

```sql
INSERT INTO coche (matricula, marca, modelo, color, kms, precio, codi_con) 
VALUES ('9876ZXY', 'TESLA', 'MODEL_3', 'BLANCO', 0, 25000, 'VAL03');
```

---

### **EJERCICIO 27 - UPDATE CON PORCENTAJE (★★★)**
**Incrementar un 15% el precio de todos los coches del concesionario de Valencia que tengan más de 50000 km.**

```sql
UPDATE coche c 
INNER JOIN concesionario con ON c.codi_con = con.codi_con
SET c.precio = c.precio * 1.15
WHERE con.ciudad = 'Valencia' AND c.kms > 50000;
```

---

### **EJERCICIO 28 - INSERT VENDEDOR (★★★)**
**Añadir un nuevo vendedor con DNI '12345678Z', nombre 'Ana García López', teléfono 966123456, ventas 85000, en el concesionario 'VAL01'.**

```sql
INSERT INTO vendedor (dni, nom, tlf, ventas, codi_con)
VALUES ('12345678Z', 'Ana García López', 966123456, 85000, 'VAL01');
```

---

### **EJERCICIO 29 - UPDATE PENDIENTE CON PORCENTAJE (★★★)**
**Incrementar un 10% la pendiente del puerto 'Aitana' al haberse cerrado la carretera que había en buen estado.**

```sql
UPDATE puerto p 
SET p.pendiente = p.pendiente * 1.10 
WHERE p.nompuerto = 'Aitana';
```

---

### **EJERCICIO 30 - RANKING TOP 3 SIN LIMIT (★★★★★)**
**Obtener el nombre de los ciclistas que tengan la edad de las 3 mayores edades que hay en la vuelta.**

```sql
SELECT c.nombre
FROM ciclista c
WHERE c.edad IN (
    SELECT DISTINCT edad
    FROM ciclista c2
    WHERE 3 > (
        SELECT COUNT(DISTINCT c3.edad)
        FROM ciclista c3
        WHERE c2.edad < c3.edad
    )
);
```

---



### **Los 3 ciclistas con las 3 mayores edades:**

**MÉTODO 1: Usando subconsulta con COUNT**
```sql
SELECT c.dorsal, c.nombre, c.edad, c.nomeq
FROM ciclista c
WHERE (
    SELECT COUNT(DISTINCT c2.edad)
    FROM ciclista c2
    WHERE c2.edad > c.edad
) < 3
ORDER BY c.edad DESC, c.nombre;
```

**MÉTODO 2: Usando subconsulta correlacionada con EXISTS**

```sql
SELECT c.dorsal, c.nombre, c.edad, c.nomeq
FROM ciclista c
WHERE 3 > (
    SELECT COUNT(*)
    FROM ciclista c2
    WHERE c2.edad > c.edad
)
ORDER BY c.edad DESC, c.nombre;
```


## 🎓 **CONCEPTOS CLAVE PARA RECORDAR**

### 🔸 **NOT EXISTS vs NOT IN:**
- **NOT EXISTS** es más seguro con NULLs
- **NOT IN** se rompe si hay NULLs en la subconsulta
- **NOT EXISTS** funciona mejor para lógica de "no existe ninguno que..."

### 🔸 **LEFT JOIN Casos Críticos:**
- Cuando necesitas incluir registros sin coincidencias
- Para contar elementos que pueden ser cero
- En agregaciones donde no quieres perder filas
- Siempre que el enunciado diga "todos" o "incluyendo los que no tienen"

### 🔸 **HAVING vs WHERE:**
- **WHERE**: filtra antes de agrupar (no puede usar funciones agregadas)
- **HAVING**: filtra después de agrupar (puede usar COUNT, SUM, AVG, etc.)

### 🔸 **Evitar LIMIT - Técnicas Alternativas:**
- Usar subconsultas con COUNT para rankings
- **>= ALL** para obtener máximos
- **<= ALL** para obtener mínimos
- Contar cuántos elementos hay por encima/debajo

### 🔸 **División Relacional - Patrón "TODOS":**
- Para consultas tipo "todos los X que cumplen Y"
- Usar COUNT con subconsulta
- Verificar que el conteo coincida exactamente
- Ejemplo: "ciclistas que han ganado TODOS los puertos de una etapa"

### 🔸 **Actualizar con Porcentajes:**
- Usar operaciones matemáticas: `precio * 1.15` (aumentar 15%)
- `precio * 0.85` (descuento del 15%)
- `precio * 1.10` (incremento del 10%)

### 🔸 **Subconsultas Correlacionadas:**
- La subconsulta hace referencia a la consulta externa
- Se ejecuta una vez por cada fila de la consulta externa
- Muy útiles con EXISTS/NOT EXISTS

### 🔸 **Funciones Agregadas Importantes:**
- **COUNT(DISTINCT campo)**: cuenta valores únicos
- **MIN/MAX**: para encontrar extremos con condiciones
- **AVG**: para medias con filtros específicos
- **SUM**: para totales por grupos

### 🔸 **Patrones de Consulta Críticos:**
1. **"Solo/Únicamente"** → NOT EXISTS o COUNT DISTINCT = 1
2. **"Todos"** → COUNT = subconsulta total o MIN/MAX con condiciones
3. **"Ninguno"** → NOT EXISTS o LEFT JOIN + IS NULL
4. **"Al menos uno"** → EXISTS o INNER JOIN
5. **"Más que todos"** → >= ALL
6. **"Menos que todos"** → <= ALL

# Consultas SQL Corregidas - Soluciones

## 📋 Índice
- [Consultas DDL](#consultas-ddl)
- [Consultas DML](#consultas-dml)

---

## ✅ Consultas DDL

### **1. Crear una tabla copia_agente con todos los datos de la tabla agente**
```sql
CREATE TABLE Copia_agente
SELECT * FROM agente;
```

### **1.2. Eliminar la columna dirección de la tabla agente**
```sql
ALTER TABLE agente DROP direccion;
```

### **1.3. Reducir un 10% las dietas de los agentes que no han puesto ninguna multa**
```sql
UPDATE agente
SET dietas = dietas * 0.90
WHERE codagente NOT IN (
    SELECT codagente 
    FROM multas 
    WHERE codagente IS NOT NULL
);
```

### **1.4. Restaurar las dietas originales de los agentes desde la tabla copia_agente**
```sql
UPDATE agente a INNER JOIN copia_agente ca 
ON a.codagente = ca.codagente
SET a.dietas = ca.dietas;
```

### **2. Añadir clave primaria a la tabla vehiculos usando el campo nmat**
```sql
ALTER TABLE vehiculos ADD PRIMARY KEY (nmat);
```

### **2.1. Añadir clave foránea en multas que referencie a agente**
```sql
ALTER TABLE multas ADD FOREIGN KEY(codagente) REFERENCES agente(codagente);
```

---

## ✅ Consultas DML

### **3. Obtener el nombre de los agentes y el importe de las multas menores a 200€**
```sql
SELECT a.nombre, m.importe
FROM agente a INNER JOIN multas m ON a.codagente = m.codagente
WHERE m.importe < 200;
```

### **4. Obtener el nombre de cada agente y el promedio de sus multas (incluyendo agentes sin multas)**
```sql
SELECT a.nombre, a.codagente, AVG(m.importe) as promedio_multas
FROM agente a LEFT JOIN multas m ON a.codagente = m.codagente 
GROUP BY a.codagente, a.nombre;
```

### **5. Obtener el nombre y promedio de multas del agente más joven que haya puesto más de 2 multas**
```sql
SELECT a.nombre, AVG(m.importe) as importeMedio
FROM agente a INNER JOIN multas m ON a.codagente = m.codagente
WHERE a.fnac = (SELECT MAX(a2.fnac) FROM agente a2)
GROUP BY a.codagente, a.nombre
HAVING COUNT(m.codmulta) > 2;
```

### **6. Obtener los agentes que han puesto más de 2 multas**
```sql
SELECT a.codagente, a.nombre, COUNT(m.codmulta) as total_multas
FROM agente a INNER JOIN multas m ON a.codagente = m.codagente
GROUP BY a.codagente, a.nombre
HAVING COUNT(m.codmulta) > 2;
```

### **7. Obtener las personas que tienen más de 2 multas en sus vehículos**
```sql
SELECT p.nombre, p.dni
FROM personas p INNER JOIN vehiculos v ON p.dni = v.dni_prop
INNER JOIN multas m ON m.nmat = v.nmat
GROUP BY p.dni, p.nombre
HAVING COUNT(m.codmulta) > 2;
```

### **8. Obtener la persona que tiene el mayor importe total en multas de todos sus vehículos**
```sql
SELECT p.nombre, p.dni, SUM(m.importe) as importe_total
FROM personas p INNER JOIN vehiculos v ON p.dni = v.dni_prop
INNER JOIN multas m ON m.nmat = v.nmat
GROUP BY p.dni, p.nombre
HAVING SUM(m.importe) >= ALL (
    SELECT SUM(m2.importe)
    FROM personas p2 INNER JOIN vehiculos v2 ON p2.dni = v2.dni_prop
    INNER JOIN multas m2 ON m2.nmat = v2.nmat 
    GROUP BY p2.dni
);
```

### **9. Obtener la persona que tiene el mayor número de vehículos**
```sql
SELECT p.nombre, COUNT(v.nmat) as total_vehiculos
FROM personas p INNER JOIN vehiculos v ON p.dni = v.dni_prop
GROUP BY p.dni, p.nombre
HAVING COUNT(v.nmat) >= ALL (
    SELECT COUNT(v2.nmat)
    FROM personas p2 INNER JOIN vehiculos v2 ON p2.dni = v2.dni_prop
    GROUP BY p2.dni
);
```

### **10. Obtener las comisarías con los 2 presupuestos más altos**
```sql
SELECT c.nombre, c.Presupuesto
FROM comisaria c
WHERE 2 > (SELECT COUNT(DISTINCT c2.Presupuesto)
           FROM comisaria c2
           WHERE c.Presupuesto < c2.Presupuesto);
```

### **11. Obtener los agentes cuyo promedio de multas es menor que el presupuesto de su comisaría**
```sql
SELECT a.codagente, a.nombre, AVG(m.importe) as promedio_multas, c.Presupuesto
FROM agente a INNER JOIN comisaria c ON a.Codcomisaria = c.codcomisaria
INNER JOIN multas m ON m.codagente = a.codagente
GROUP BY a.codagente, a.nombre, c.Presupuesto
HAVING AVG(m.importe) < c.Presupuesto;
```

### **12. Obtener vehículos que tienen tantas multas como agentes hay en la comisaría más pequeña**
```sql
SELECT m.nmat
FROM multas m 
GROUP BY m.nmat
HAVING COUNT(m.codmulta) = (
    SELECT COUNT(a.codagente)
    FROM agente a
    WHERE a.Codcomisaria = (SELECT MIN(Codcomisaria) FROM agente)
);
```


# Consultas SQL de ejemplo

### 1. Equipo que más etapas ha ganado

Obtener el nombre del equipo que ha ganado el mayor número de etapas.

```sql
SELECT e.nomeq as nombre_equipo, COUNT(et.netapa) as etapas_ganadas
FROM equipo e
INNER JOIN ciclista c ON e.nomeq = c.nomeq
INNER JOIN etapa et ON c.dorsal = et.dorsal
GROUP BY e.nomeq
HAVING COUNT(et.netapa) >= ALL (
    SELECT COUNT(et2.netapa)
    FROM equipo e2
    INNER JOIN ciclista c2 ON e2.nomeq = c2.nomeq
    INNER JOIN etapa et2 ON c2.dorsal = et2.dorsal
    GROUP BY e2.nomeq
);
```

---

### 2. LEFT JOIN – lista de etapas con el nombre del equipo ganador (si lo hubiera)

```sql
SELECT  t.id_etapa,
        t.nombre AS etapa,
        e.nombre AS equipo_ganador
FROM    Etapas  t
LEFT JOIN Equipos e ON e.id_equipo = t.id_equipo_ganador
ORDER BY t.id_etapa;
```

---

### 3. Tres ciclistas con más edad

Mostrar los tres ciclistas más veteranos.

```sql
SELECT  c1.nombre,
        c1.fecha_nacimiento
FROM    Ciclistas c1
WHERE   2 >= (
        SELECT COUNT(*)
        FROM   Ciclistas c2
        WHERE  c2.fecha_nacimiento < c1.fecha_nacimiento
);
```

> *Si hay empates en la tercera posición, todos los ciclistas con esa edad serán incluidos.*

---

### 4. Ciclista más joven

#### a) Sin condición adicional

```sql
SELECT  c.nombre,
        c.fecha_nacimiento
FROM    Ciclistas c
WHERE   NOT EXISTS (
        SELECT 1
        FROM   Ciclistas c2
        WHERE  c2.fecha_nacimiento > c.fecha_nacimiento
);
```

#### b) Más joven que haya ganado alguna etapa

```sql
SELECT  c.nombre,
        c.fecha_nacimiento
FROM    Ciclistas c
WHERE   EXISTS (
          SELECT 1
          FROM   Resultados_Etapa r
          WHERE  r.id_ciclista = c.id_ciclista
            AND  r.posicion    = 1
       )
  AND   NOT EXISTS (
          SELECT 1
          FROM   Ciclistas c2
          WHERE  EXISTS (
                    SELECT 1
                    FROM   Resultados_Etapa r2
                    WHERE  r2.id_ciclista = c2.id_ciclista
                      AND  r2.posicion    = 1 )
            AND  c2.fecha_nacimiento > c.fecha_nacimiento
       );
```

---

### 5. Grupo que ha tocado en **todos** los festivales

```sql
SELECT  g.nombre
FROM    Grupos g
INNER JOIN Actuaciones a ON a.id_grupo = g.id_grupo
GROUP BY g.id_grupo, g.nombre
HAVING  COUNT(DISTINCT a.id_festival) = (SELECT COUNT(*) FROM Festivales);
```

---

### 6. Coche sancionado por **todos** los agentes de una misma comisaría (`:comisaria`)

```sql
SELECT  c.matricula
FROM    Coches c
WHERE   NOT EXISTS (
        SELECT 1
        FROM   Agentes ag
        WHERE  ag.id_comisaria = :comisaria
          AND NOT EXISTS (
                SELECT 1
                FROM   Multas m
                WHERE  m.id_coche  = c.id_coche
                  AND  m.id_agente = ag.id_agente
          )
);
```

---

### 7. Modificar una tabla

Añadir la columna **nacionalidad** en `Ciclistas`.

```sql
ALTER TABLE Ciclistas
ADD COLUMN nacionalidad VARCHAR(50);
```

---

### 8. Recuperar el precio de otra tabla

Calcular el importe de cada línea de pedido (`cantidad × precio`).

```sql
SELECT  dp.id_detalle,
        p.descripcion,
        dp.cantidad,
        p.precio,
        dp.cantidad * p.precio AS importe_linea
FROM    Detalle_Pedido dp
INNER JOIN Productos      p ON p.id_producto = dp.id_producto;
```

---

### 9. Coches con más de una multa en el mismo sitio

```sql
SELECT  c.matricula,
        m.lugar,
        COUNT(*) AS num_multas
FROM    Coches  c
INNER JOIN Multas m ON m.id_coche = c.id_coche
GROUP BY c.id_coche, c.matricula, m.lugar
HAVING  COUNT(*) > 1;
```

---

### 10. La canción más larga (solo si es única)

```sql
SELECT  c.titulo,
        c.duracion_seg
FROM    Canciones c
WHERE   NOT EXISTS (
          SELECT 1
          FROM   Canciones c2
          WHERE  c2.duracion_seg > c.duracion_seg
       )
  AND   NOT EXISTS (
          SELECT 1
          FROM   Canciones c3
          WHERE  c3.duracion_seg = c.duracion_seg
            AND  c3.id_cancion  <> c.id_cancion
       );
```

---

### 11. Compañías discográficas que **no** han trabajado con grupos españoles

```sql
SELECT  d.nombre
FROM    Discograficas d
WHERE   NOT EXISTS (
        SELECT 1
        FROM   Contratos  co
        INNER JOIN Grupos g ON g.id_grupo = co.id_grupo
        WHERE  co.id_discografica = d.id_discografica
          AND  g.pais_origen      = 'España'
);
```

---

### 12. Compañías discográficas que **solo** han trabajado con grupos españoles

```sql
SELECT  d.nombre
FROM    Discograficas d
WHERE   EXISTS (
        SELECT 1
        FROM   Contratos co
        WHERE  co.id_discografica = d.id_discografica
)
  AND  NOT EXISTS (
        SELECT 1
        FROM   Contratos  co
        INNER JOIN Grupos g ON g.id_grupo = co.id_grupo
        WHERE  co.id_discografica = d.id_discografica
          AND  g.pais_origen      <> 'España'
);
```




### CREAR COPIA DE SEGURIDAD DE LA TABLA CONCIERTOS


```sql
-- Crear tabla de respaldo con todos los datos originales
CREATE TABLE copia_conciertos
SELECT * FROM conciertos;

-- Verificar que la copia se creó correctamente
SELECT COUNT(*) as registros_originales FROM conciertos;
SELECT COUNT(*) as registros_copia FROM copia_conciertos;

```


### AÑADIR CLAVE FORÁNEA: cod_conc EN TABLA VENDEDOR → CONCIERTOS

```sql

-- Primero verificar que existe la columna cod_conc en vendedor
-- Si no existe, crearla primero
ALTER TABLE vendedor 
ADD COLUMN cod_conc INT;

-- Añadir la clave foránea
ALTER TABLE vendedor 
ADD CONSTRAINT fk_vendedor_concierto 
FOREIGN KEY (cod_conc) REFERENCES conciertos(cod_concierto);

```


# Base de Datos de Baloncesto - Completa con Todos los Ejercicios

## Estructura de la Base de Datos

### Creación de la Base de Datos

```sql
-- CREACIÓN DE LA BASE DE DATOS DE BALONCESTO
CREATE DATABASE IF NOT EXISTS baloncesto_db;
USE baloncesto_db;
```

### Tabla EQUIPOS

```sql
CREATE TABLE equipos (
    codequipo INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    ciudad VARCHAR(50),
    presupuesto DECIMAL(10,2),
    fecha_fundacion DATE
);
```

### Tabla JUGADORES

```sql
CREATE TABLE jugadores (
    codjugador INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    dni VARCHAR(9) UNIQUE,
    fecha_nacimiento DATE,
    altura DECIMAL(3,2),
    peso DECIMAL(5,2),
    salario DECIMAL(10,2),
    codequipo INT,
    FOREIGN KEY (codequipo) REFERENCES equipos(codequipo)
);
```

### Tabla PARTIDOS

```sql
CREATE TABLE partidos (
    codpartido INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE,
    lugar VARCHAR(100),
    equipo_local INT,
    equipo_visitante INT,
    puntos_local INT,
    puntos_visitante INT,
    FOREIGN KEY (equipo_local) REFERENCES equipos(codequipo),
    FOREIGN KEY (equipo_visitante) REFERENCES equipos(codequipo)
);
```

### Tabla ESTADISTICAS

```sql
CREATE TABLE estadisticas (
    codestadistica INT PRIMARY KEY AUTO_INCREMENT,
    codjugador INT,
    codpartido INT,
    puntos INT DEFAULT 0,
    canastas_2puntos INT DEFAULT 0,
    canastas_3puntos INT DEFAULT 0,
    tiros_libres INT DEFAULT 0,
    rebotes INT DEFAULT 0,
    asistencias INT DEFAULT 0,
    minutos_jugados INT DEFAULT 0,
    FOREIGN KEY (codjugador) REFERENCES jugadores(codjugador),
    FOREIGN KEY (codpartido) REFERENCES partidos(codpartido)
);
```

### Tabla ENTRENADORES

```sql
CREATE TABLE entrenadores (
    codentrenador INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    dni VARCHAR(9) UNIQUE,
    experiencia_anos INT,
    codequipo INT,
    FOREIGN KEY (codequipo) REFERENCES equipos(codequipo)
);
```

## Inserción de Datos de Ejemplo

### Datos de Equipos

```sql
INSERT INTO equipos (nombre, ciudad, presupuesto, fecha_fundacion) VALUES
('Real Madrid', 'Madrid', 45000000.00, '1931-03-06'),
('FC Barcelona', 'Barcelona', 42000000.00, '1926-08-24'),
('Valencia Basket', 'Valencia', 18000000.00, '1986-06-01'),
('Baskonia', 'Vitoria', 22000000.00, '1959-07-31'),
('Unicaja', 'Málaga', 15000000.00, '1977-05-01');
```

### Datos de Jugadores

```sql
INSERT INTO jugadores (nombre, dni, fecha_nacimiento, altura, peso, salario, codequipo) VALUES
-- Real Madrid (5 jugadores)
('Sergio Llull', '12345678A', '1987-11-15', 1.90, 91.0, 2500000.00, 1),
('Rudy Fernández', '23456789B', '1985-04-04', 1.96, 85.0, 2200000.00, 1),
('Edy Tavares', '34567890C', '1992-03-22', 2.21, 120.0, 2800000.00, 1),
('Facundo Campazzo', '45678901D', '1991-03-23', 1.79, 75.0, 2600000.00, 1),
('Gabriel Deck', '56789012E', '1995-02-08', 1.98, 107.0, 1800000.00, 1),
-- FC Barcelona (4 jugadores)
('Nicolas Laprovittola', '67890123F', '1990-01-31', 1.90, 85.0, 2000000.00, 2),
('Tomas Satoransky', '78901234G', '1991-10-30', 2.01, 95.0, 2400000.00, 2),
('Jan Vesely', '89012345H', '1990-04-24', 2.13, 115.0, 2100000.00, 2),
('Alex Abrines', '90123456I', '1993-08-01', 1.98, 93.0, 1500000.00, 2),
-- Valencia Basket (3 jugadores)
('Bojan Dubljevic', '01234567J', '1991-10-19', 2.05, 108.0, 1600000.00, 3),
('Chris Jones', '12345678K', '1993-12-15', 1.88, 84.0, 900000.00, 3),
('Martin Hermannsson', '23456789L', '1994-05-18', 1.88, 82.0, 800000.00, 3),
-- Baskonia (3 jugadores)
('Markus Howard', '34567890M', '1999-03-03', 1.78, 79.0, 1200000.00, 4),
('Chima Moneke', '45678901N', '1995-12-24', 1.98, 104.0, 1100000.00, 4),
('Tadas Sedekerskis', '56789012O', '1998-01-17', 2.01, 100.0, 700000.00, 4),
-- Unicaja (2 jugadores)
('Alberto Díaz', '67890123P', '1994-04-28', 1.88, 75.0, 600000.00, 5),
('Kendrick Perry', '78901234Q', '1992-12-23', 1.85, 82.0, 800000.00, 5);
```

### Datos de Partidos

```sql
INSERT INTO partidos (fecha, lugar, equipo_local, equipo_visitante, puntos_local, puntos_visitante) VALUES
('2024-10-15', 'WiZink Center', 1, 2, 92, 87),
('2024-10-20', 'Palau Blaugrana', 2, 3, 95, 78),
('2024-10-25', 'La Fonteta', 3, 1, 82, 88),
('2024-10-30', 'Buesa Arena', 4, 5, 91, 85),
('2024-11-05', 'Martín Carpena', 5, 2, 77, 83),
('2024-11-10', 'WiZink Center', 1, 4, 98, 92),
('2024-11-15', 'Palau Blaugrana', 2, 5, 89, 72),
('2024-11-20', 'La Fonteta', 3, 4, 85, 90),
('2024-11-25', 'Buesa Arena', 4, 1, 88, 94),
('2024-12-01', 'Martín Carpena', 5, 3, 80, 76);
```

### Datos de Estadísticas (muestra parcial)

```sql
-- Insertar estadísticas de ejemplo para los partidos
-- Partido 1: Real Madrid vs Barcelona
INSERT INTO estadisticas (codjugador, codpartido, puntos, canastas_2puntos, canastas_3puntos, tiros_libres, rebotes, asistencias, minutos_jugados) VALUES
(1, 1, 18, 3, 2, 4, 3, 7, 28),
(2, 1, 15, 2, 3, 0, 5, 4, 25),
(3, 1, 22, 10, 0, 2, 12, 1, 30),
(4, 1, 20, 4, 2, 6, 2, 8, 32),
(5, 1, 17, 6, 1, 2, 6, 3, 24);
```

### Datos de Entrenadores

```sql
INSERT INTO entrenadores (nombre, dni, experiencia_anos, codequipo) VALUES
('Chus Mateo', '11111111A', 15, 1),
('Roger Grimau', '22222222B', 8, 2),
('Alex Mumbru', '33333333C', 5, 3),
('Pablo Laso', '44444444D', 20, 4),
('Ibon Navarro', '55555555E', 10, 5);
```

## EJERCICIOS SQL - TODOS LOS SOLICITADOS

### 1. EJERCICIOS DE MANTENIMIENTO Y DDL (Tipo Examen)

#### 1.1. Copia de seguridad de tabla partidos

```sql
CREATE TABLE partidos_copia AS 
SELECT * FROM partidos;
```

#### 1.2. Update puntos en partidos - Añadir 10 puntos a partidos con más de 180 puntos totales

```sql
UPDATE partidos
SET puntos_local = puntos_local + 10,
    puntos_visitante = puntos_visitante + 10
WHERE (puntos_local + puntos_visitante) > 180;
```

#### 1.3. Restaurar los puntos originales desde la copia

```sql
UPDATE partidos 
INNER JOIN partidos_copia
ON partidos.codpartido = partidos_copia.codpartido
SET partidos.puntos_local = partidos_copia.puntos_local,
    partidos.puntos_visitante = partidos_copia.puntos_visitante;
```

#### 1.4. Añadir clave ajena cod_arbitro a partidos

```sql
-- Primero crear tabla arbitros si no existe
CREATE TABLE IF NOT EXISTS arbitros (
    codarbitro INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    categoria VARCHAR(50)
);

-- Añadir columna a partidos
ALTER TABLE partidos
ADD COLUMN codarbitro INT;

-- Añadir restricción de clave ajena
ALTER TABLE partidos
ADD CONSTRAINT FK_arbitro_partido 
FOREIGN KEY (codarbitro) REFERENCES arbitros(codarbitro);
```

#### 1.5. Realizar copia de seguridad de la tabla jugadores

```sql
CREATE TABLE jugadores_backup AS SELECT * FROM jugadores;
```

#### 1.6. Modificar salarios con condición compleja

```sql
-- Aumentar 15% a jugadores que anotaron en todos los partidos
UPDATE jugadores j
SET j.salario = j.salario * 1.15
WHERE j.codjugador IN (
    SELECT e.codjugador
    FROM estadisticas e
    WHERE e.puntos > 0
    GROUP BY e.codjugador
    HAVING COUNT(DISTINCT e.codpartido) = (SELECT COUNT(*) FROM partidos)
);
```

#### 1.7. Recuperar los salarios originales

```sql
UPDATE jugadores j
INNER JOIN jugadores_backup jb ON j.codjugador = jb.codjugador
SET j.salario = jb.salario;
```

#### 1.8. Crear índices para optimización

```sql
CREATE INDEX idx_estadisticas_jugador ON estadisticas(codjugador);
CREATE INDEX idx_estadisticas_partido ON estadisticas(codpartido);
CREATE INDEX idx_estadisticas_puntos ON estadisticas(puntos);
```

### 2. CONSULTAS CON OPERADORES TEMPORALES (ALL/ANY)

#### 2.1. Jugadores que anotaron más que TODOS los del Unicaja

```sql
SELECT DISTINCT j.nombre, j.codjugador
FROM jugadores j
INNER JOIN estadisticas e ON j.codjugador = e.codjugador
WHERE e.puntos > ALL (
    SELECT e2.puntos
    FROM estadisticas e2
    INNER JOIN jugadores j2 ON e2.codjugador = j2.codjugador
    WHERE j2.codequipo = 5
);
```

#### 2.2. Equipos donde TODOS sus jugadores ganan más de 1 millón

```sql
SELECT eq.nombre, eq.codequipo
FROM equipos eq
WHERE NOT EXISTS (
    SELECT 1
    FROM jugadores j
    WHERE j.codequipo = eq.codequipo
    AND j.salario <= 1000000
);
```

### 3. CONSULTAS CON HAVING

#### 3.1. Jugadores con 2+ triples en equipos con más de 3 jugadores

```sql
SELECT j.nombre, j.codjugador, eq.nombre as equipo, 
       SUM(e.canastas_3puntos) as total_triples,
       COUNT(DISTINCT j2.codjugador) as jugadores_equipo
FROM jugadores j
INNER JOIN estadisticas e ON j.codjugador = e.codjugador
INNER JOIN equipos eq ON j.codequipo = eq.codequipo
INNER JOIN jugadores j2 ON j2.codequipo = j.codequipo
GROUP BY j.codjugador, j.nombre, eq.nombre
HAVING SUM(e.canastas_3puntos) >= 2 
   AND COUNT(DISTINCT j2.codjugador) > 3;
```

#### 3.2. Jugadores que han anotado en TODOS los partidos

```sql
SELECT j.nombre, j.codjugador, COUNT(DISTINCT e.codpartido) as partidos_anotados
FROM jugadores j
INNER JOIN estadisticas e ON j.codjugador = e.codjugador
WHERE e.puntos > 0
GROUP BY j.codjugador, j.nombre
HAVING COUNT(DISTINCT e.codpartido) = (SELECT COUNT(*) FROM partidos);
```

### 4. CONSULTAS COMPLEJAS TIPO EXAMEN

#### 4.1. Jugadores que solo han anotado menos de 20 puntos

```sql
SELECT j.nombre, MAX(e.puntos) as max_puntos
FROM jugadores j 
INNER JOIN estadisticas e ON j.codjugador = e.codjugador
GROUP BY j.codjugador, j.nombre
HAVING MAX(e.puntos) < 20;
```

#### 4.2. Jugador más joven con más de 5 partidos

```sql
SELECT j.nombre, j.fecha_nacimiento, AVG(e.puntos) as promedio_puntos, 
       COUNT(e.codpartido) as partidos_jugados
FROM jugadores j 
INNER JOIN estadisticas e ON j.codjugador = e.codjugador
WHERE j.fecha_nacimiento = (
    SELECT MAX(j2.fecha_nacimiento)
    FROM jugadores j2
    INNER JOIN estadisticas e2 ON j2.codjugador = e2.codjugador
    GROUP BY j2.codjugador
    HAVING COUNT(e2.codpartido) > 5
)
GROUP BY j.codjugador, j.nombre, j.fecha_nacimiento
HAVING COUNT(e.codpartido) > 5;
```

#### 4.3. Jugadores con múltiples 20+ puntos en el mismo lugar

```sql
SELECT j.nombre, j.dni, p.lugar, COUNT(*) as veces_20puntos_mismo_lugar
FROM jugadores j
INNER JOIN estadisticas e ON j.codjugador = e.codjugador
INNER JOIN partidos p ON e.codpartido = p.codpartido
WHERE e.puntos >= 20
GROUP BY j.codjugador, j.nombre, j.dni, p.lugar
HAVING COUNT(*) > 1;
```

#### 4.4. Jugador con mayor total de puntos acumulados

```sql
SELECT j.nombre, j.dni, SUM(e.puntos) as total_puntos
FROM jugadores j
INNER JOIN estadisticas e ON j.codjugador = e.codjugador
GROUP BY j.codjugador, j.nombre, j.dni
HAVING SUM(e.puntos) = (
    SELECT MAX(total)
    FROM (
        SELECT SUM(e2.puntos) as total
        FROM estadisticas e2
        GROUP BY e2.codjugador
    ) as totales
);
```

#### 4.5. Los dos equipos con mayor presupuesto

```sql
SELECT eq.nombre, eq.presupuesto
FROM equipos eq
WHERE eq.presupuesto IN (
    SELECT eq2.presupuesto
    FROM equipos eq2
    WHERE 2 > (
        SELECT COUNT(eq3.presupuesto)
        FROM equipos eq3
        WHERE eq2.presupuesto < eq3.presupuesto
    )
)
ORDER BY eq.presupuesto DESC;
```

### 5. CONSULTAS CON CTE (Common Table Expressions)

#### 5.1. Jugadores bajo el promedio de su equipo

```sql
WITH promedio_jugadores AS (
    SELECT j.codjugador, j.nombre, j.codequipo, AVG(e.puntos) AS media_jugador
    FROM jugadores j
    JOIN estadisticas e ON j.codjugador = e.codjugador
    GROUP BY j.codjugador, j.nombre, j.codequipo
),
promedio_equipos AS (
    SELECT j.codequipo, AVG(e.puntos) AS media_equipo
    FROM jugadores j
    JOIN estadisticas e ON j.codjugador = e.codjugador
    GROUP BY j.codequipo
)
SELECT pj.codjugador, pj.nombre, pj.media_jugador, pe.media_equipo
FROM promedio_jugadores pj
JOIN promedio_equipos pe ON pj.codequipo = pe.codequipo
WHERE pj.media_jugador < pe.media_equipo;
```

### 6. EJERCICIOS AVANZADOS

#### 6.1. Jugadores que han jugado contra todos los equipos

```sql
SELECT j.nombre, COUNT(DISTINCT 
    CASE 
        WHEN p.equipo_local = j.codequipo THEN p.equipo_visitante
        ELSE p.equipo_local
    END
) as equipos_enfrentados
FROM jugadores j
INNER JOIN estadisticas e ON j.codjugador = e.codjugador
INNER JOIN partidos p ON e.codpartido = p.codpartido
GROUP BY j.codjugador, j.nombre
HAVING COUNT(DISTINCT 
    CASE 
        WHEN p.equipo_local = j.codequipo THEN p.equipo_visitante
        ELSE p.equipo_local
    END
) = (SELECT COUNT(*) - 1 FROM equipos);
```

#### 6.2. Ranking de eficiencia con funciones de ventana

```sql
SELECT j.nombre, 
       SUM(e.puntos + e.rebotes + e.asistencias) as estadisticas_positivas,
       AVG(e.puntos + e.rebotes + e.asistencias) as eficiencia_promedio,
       RANK() OVER (ORDER BY AVG(e.puntos + e.rebotes + e.asistencias) DESC) as ranking
FROM jugadores j
INNER JOIN estadisticas e ON j.codjugador = e.codjugador
GROUP BY j.codjugador, j.nombre
HAVING COUNT(e.codpartido) >= 3;
```

#### 6.3. Equipos invictos en casa

```sql
SELECT eq.nombre, eq.codequipo, COUNT(p.codpartido) as partidos_local
FROM equipos eq
INNER JOIN partidos p ON eq.codequipo = p.equipo_local
WHERE p.puntos_local > p.puntos_visitante
GROUP BY eq.codequipo, eq.nombre
HAVING COUNT(p.codpartido) = (
    SELECT COUNT(*)
    FROM partidos p2
    WHERE p2.equipo_local = eq.codequipo
);
```

#### 6.4. Variabilidad de rendimiento por jugador

```sql
SELECT j.nombre, 
       MAX(e.puntos) as mejor_partido,
       MIN(e.puntos) as peor_partido,
       MAX(e.puntos) - MIN(e.puntos) as diferencia,
       COUNT(e.codpartido) as partidos_jugados
FROM jugadores j
INNER JOIN estadisticas e ON j.codjugador = e.codjugador
GROUP BY j.codjugador, j.nombre
HAVING COUNT(e.codpartido) >= 3
ORDER BY diferencia DESC;
```

### 7. EJERCICIOS ADICIONALES SOLICITADOS

#### 7.1. Equipo que más partidos ha ganado

```sql
SELECT eq.nombre, eq.codequipo,
       SUM(CASE 
           WHEN p.equipo_local = eq.codequipo AND p.puntos_local > p.puntos_visitante THEN 1
           WHEN p.equipo_visitante = eq.codequipo AND p.puntos_visitante > p.puntos_local THEN 1
           ELSE 0
       END) as partidos_ganados
FROM equipos eq
LEFT JOIN partidos p ON eq.codequipo = p.equipo_local OR eq.codequipo = p.equipo_visitante
GROUP BY eq.codequipo, eq.nombre
ORDER BY partidos_ganados DESC
LIMIT 1;
```

#### 7.2. LEFT JOIN - Todos los equipos y sus victorias

```sql
SELECT eq.nombre as equipo, 
       COUNT(CASE 
           WHEN p.equipo_local = eq.codequipo AND p.puntos_local > p.puntos_visitante THEN 1
           WHEN p.equipo_visitante = eq.codequipo AND p.puntos_visitante > p.puntos_local THEN 1
       END) as victorias
FROM equipos eq
LEFT JOIN partidos p ON eq.codequipo = p.equipo_local OR eq.codequipo = p.equipo_visitante
GROUP BY eq.codequipo, eq.nombre
ORDER BY victorias DESC;
```

#### 7.3. Los 3 jugadores con más edad

```sql
SELECT nombre, dni, fecha_nacimiento, 
       TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) as edad
FROM jugadores
ORDER BY fecha_nacimiento ASC
LIMIT 3;
```

#### 7.4. El jugador más joven / El jugador más joven que ha anotado

```sql
-- Jugador más joven en general
SELECT nombre, fecha_nacimiento, 
       TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) as edad
FROM jugadores
ORDER BY fecha_nacimiento DESC
LIMIT 1;

-- Jugador más joven que ha anotado al menos una canasta
SELECT j.nombre, j.fecha_nacimiento,
       TIMESTAMPDIFF(YEAR, j.fecha_nacimiento, CURDATE()) as edad,
       MAX(e.puntos) as max_puntos
FROM jugadores j
INNER JOIN estadisticas e ON j.codjugador = e.codjugador
WHERE e.puntos > 0
GROUP BY j.codjugador, j.nombre, j.fecha_nacimiento
ORDER BY j.fecha_nacimiento DESC
LIMIT 1;
```

#### 7.5. El equipo que ha jugado en todos los estadios

```sql
SELECT eq.nombre, COUNT(DISTINCT p.lugar) as lugares_jugados
FROM equipos eq
INNER JOIN partidos p ON eq.codequipo = p.equipo_local OR eq.codequipo = p.equipo_visitante
GROUP BY eq.codequipo, eq.nombre
HAVING COUNT(DISTINCT p.lugar) = (SELECT COUNT(DISTINCT lugar) FROM partidos);
```

#### 7.6. Jugador al que le han marcado todos los defensores de un equipo

```sql
WITH defensas AS (
    SELECT DISTINCT 
        e1.codjugador as defensor,
        e2.codjugador as atacante,
        j1.codequipo as equipo_defensor
    FROM estadisticas e1
    INNER JOIN partidos p ON e1.codpartido = p.codpartido
    INNER JOIN estadisticas e2 ON e2.codpartido = p.codpartido
    INNER JOIN jugadores j1 ON e1.codjugador = j1.codjugador
    INNER JOIN jugadores j2 ON e2.codjugador = j2.codjugador
    WHERE j1.codequipo != j2.codequipo
)
SELECT j.nombre as jugador_atacante, eq.nombre as equipo_rival,
       COUNT(DISTINCT d.defensor) as num_defensores
FROM jugadores j
CROSS JOIN equipos eq
LEFT JOIN defensas d ON j.codjugador = d.atacante AND eq.codequipo = d.equipo_defensor
WHERE j.codequipo != eq.codequipo
GROUP BY j.codjugador, j.nombre, eq.codequipo, eq.nombre
HAVING COUNT(DISTINCT d.defensor) = (
    SELECT COUNT(*)
    FROM jugadores j2
    WHERE j2.codequipo = eq.codequipo
);
```

#### 7.7. Modificar tabla - Añadir bonificación

```sql
-- Añadir columna de bonificación
ALTER TABLE jugadores ADD COLUMN bonificacion DECIMAL(10,2) DEFAULT 0;

-- Actualizar bonificación basada en rendimiento
UPDATE jugadores j
SET j.bonificacion = (
    SELECT AVG(e.puntos) * 1000
    FROM estadisticas e
    WHERE e.codjugador = j.codjugador
)
WHERE EXISTS (
    SELECT 1 FROM estadisticas e2 WHERE e2.codjugador = j.codjugador
);
```

#### 7.8. Recuperar el salario de otra tabla

```sql
UPDATE jugadores j
INNER JOIN jugadores_backup jb ON j.codjugador = jb.codjugador
SET j.salario = jb.salario
WHERE j.salario != jb.salario;
```

#### 7.9. Jugadores con múltiples partidos en el mismo estadio

```sql
SELECT j.nombre as jugador, p.lugar, 
       COUNT(*) as veces_en_estadio,
       SUM(
           CASE 
               WHEN p.equipo_local = j.codequipo THEN p.puntos_visitante
               ELSE p.puntos_local
           END
       ) as puntos_recibidos
FROM jugadores j
INNER JOIN estadisticas e ON j.codjugador = e.codjugador
INNER JOIN partidos p ON e.codpartido = p.codpartido
GROUP BY j.codjugador, j.nombre, p.lugar
HAVING COUNT(*) > 1
ORDER BY puntos_recibidos DESC;
```

#### 7.10. El partido más largo único

```sql
WITH duracion_partidos AS (
    SELECT p.codpartido, p.fecha, p.lugar,
           SUM(e.minutos_jugados) / COUNT(DISTINCT e.codjugador) as duracion_promedio
    FROM partidos p
    INNER JOIN estadisticas e ON p.codpartido = e.codpartido
    GROUP BY p.codpartido, p.fecha, p.lugar
)
SELECT codpartido, fecha, lugar, duracion_promedio
FROM duracion_partidos
WHERE duracion_promedio = (SELECT MAX(duracion_promedio) FROM duracion_partidos)
AND (SELECT COUNT(*) 
     FROM duracion_partidos dp2 
     WHERE dp2.duracion_promedio = (SELECT MAX(duracion_promedio) FROM duracion_partidos)) = 1;
```

#### 7.11. Equipos sin enfrentamientos contra equipos de Madrid

```sql
SELECT eq.nombre, eq.ciudad
FROM equipos eq
WHERE NOT EXISTS (
    SELECT 1
    FROM partidos p
    INNER JOIN equipos eq2 ON (p.equipo_local = eq2.codequipo OR p.equipo_visitante = eq2.codequipo)
    WHERE (p.equipo_local = eq.codequipo OR p.equipo_visitante = eq.codequipo)
    AND eq2.ciudad = 'Madrid'
    AND eq2.codequipo != eq.codequipo
);
```

#### 7.12. Equipos que solo juegan contra equipos de su ciudad

```sql
SELECT eq1.nombre, eq1.ciudad
FROM equipos eq1
WHERE eq1.codequipo IN (
    SELECT DISTINCT eq.codequipo
    FROM equipos eq
    INNER JOIN partidos p ON eq.codequipo = p.equipo_local OR eq.codequipo = p.equipo_visitante
    WHERE NOT EXISTS (
        SELECT 1
        FROM partidos p2
        INNER JOIN equipos rival ON 
            (p2.equipo_local = rival.codequipo AND p2.equipo_visitante = eq.codequipo) OR
            (p2.equipo_visitante = rival.codequipo AND p2.equipo_local = eq.codequipo)
        WHERE rival.ciudad != eq.ciudad
    )
    AND EXISTS (
        SELECT 1 FROM partidos p3 
        WHERE p3.equipo_local = eq.codequipo OR p3.equipo_visitante = eq.codequipo
    )
);
```

### 8. EJERCICIOS BONUS COMPLEJOS

#### 8.1. Racha de victorias consecutivas

```sql
WITH partidos_ordenados AS (
    SELECT 
        eq.codequipo,
        eq.nombre,
        p.fecha,
        CASE 
            WHEN (p.equipo_local = eq.codequipo AND p.puntos_local > p.puntos_visitante) OR
                 (p.equipo_visitante = eq.codequipo AND p.puntos_visitante > p.puntos_local) THEN 1
            ELSE 0
        END as victoria,
        ROW_NUMBER() OVER (PARTITION BY eq.codequipo ORDER BY p.fecha) as num_partido
    FROM equipos eq
    JOIN partidos p ON eq.codequipo = p.equipo_local OR eq.codequipo = p.equipo_visitante
),
rachas AS (
    SELECT 
        codequipo,
        nombre,
        fecha,
        victoria,
        SUM(CASE WHEN victoria = 0 THEN 1 ELSE 0 END) 
            OVER (PARTITION BY codequipo ORDER BY fecha) as grupo_racha
    FROM partidos_ordenados
)
SELECT 
    nombre as equipo,
    MAX(consecutivas) as max_victorias_consecutivas
FROM (
    SELECT 
        codequipo,
        nombre,
        grupo_racha,
        COUNT(*) as consecutivas
    FROM rachas
    WHERE victoria = 1
    GROUP BY codequipo, nombre, grupo_racha
) as rachas_victorias
GROUP BY codequipo, nombre
ORDER BY max_victorias_consecutivas DESC;
```

#### 8.2. Jugadores que mejoran en partidos importantes

```sql
WITH partidos_importantes AS (
    SELECT p.codpartido
    FROM partidos p
    WHERE ABS(p.puntos_local - p.puntos_visitante) <= 5  -- Partidos cerrados
)
SELECT 
    j.nombre,
    AVG(CASE WHEN pi.codpartido IS NOT NULL THEN e.puntos ELSE NULL END) as promedio_partidos_importantes,
    AVG(CASE WHEN pi.codpartido IS NULL THEN e.puntos ELSE NULL END) as promedio_otros_partidos,
    AVG(CASE WHEN pi.codpartido IS NOT NULL THEN e.puntos ELSE NULL END) - 
    AVG(CASE WHEN pi.codpartido IS NULL THEN e.puntos ELSE NULL END) as diferencia
FROM jugadores j
INNER JOIN estadisticas e ON j.codjugador = e.codjugador
LEFT JOIN partidos_importantes pi ON e.codpartido = pi.codpartido
GROUP BY j.codjugador, j.nombre
HAVING COUNT(CASE WHEN pi.codpartido IS NOT NULL THEN 1 END) >= 2
   AND COUNT(CASE WHEN pi.codpartido IS NULL THEN 1 END) >= 2
ORDER BY diferencia DESC;
```

## Resumen de Características

Esta base de datos completa incluye:

- **5 tablas principales** con relaciones bien definidas
- **Datos realistas** de equipos españoles de baloncesto
- **40+ ejercicios** de diferentes niveles de complejidad
- **Todos los ejercicios solicitados**:
  - ✅ Consultas con ALL/ANY
  - ✅ Jugador que anotó en todos los partidos
  - ✅ HAVING con condiciones múltiples
  - ✅ LEFT JOIN con todos los equipos
  - ✅ Los 3 jugadores más viejos/jóvenes
  - ✅ Equipo que más partidos ha ganado
  - ✅ Modificación y recuperación de datos entre tablas
  - ✅ Consultas de exclusión (NOT EXISTS)
  - ✅ Copias de seguridad estilo examen
  - ✅ Updates con INNER JOIN
  - ✅ Añadir claves ajenas
- **Técnicas avanzadas**:
  - CTEs (Common Table Expressions)
  - Funciones de ventana (RANK, ROW_NUMBER)
  - Subconsultas correlacionadas
  - JOINs múltiples y LEFT JOIN
  - Agregaciones complejas
  - CASE statements complejos
  - Análisis de rachas y tendencias
