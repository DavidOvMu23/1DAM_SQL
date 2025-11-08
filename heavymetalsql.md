# BASE DE DATOS ROCK & METAL - CREACIÓN COMPLETA

## 🗄️ **SCRIPT DE CREACIÓN DE LA BASE DE DATOS**

```sql
-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS rock_metal_db;
USE rock_metal_db;

-- Eliminar tablas si existen (orden inverso por dependencias)
DROP TABLE IF EXISTS colaboracion;
DROP TABLE IF EXISTS critica;
DROP TABLE IF EXISTS premio;
DROP TABLE IF EXISTS actuacion;
DROP TABLE IF EXISTS gira;
DROP TABLE IF EXISTS cancion;
DROP TABLE IF EXISTS album;
DROP TABLE IF EXISTS contrato;
DROP TABLE IF EXISTS integra;
DROP TABLE IF EXISTS festival;
DROP TABLE IF EXISTS discografica;
DROP TABLE IF EXISTS musico;
DROP TABLE IF EXISTS banda;

-- Crear las tablas
CREATE TABLE banda (
    cod_banda VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    pais VARCHAR(50) NOT NULL,
    año_formacion INT NOT NULL,
    genero VARCHAR(50) NOT NULL,
    activa BOOLEAN DEFAULT TRUE
);

CREATE TABLE musico (
    dni VARCHAR(15) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    pais_origen VARCHAR(50) NOT NULL,
    instrumento_principal VARCHAR(50) NOT NULL
);

CREATE TABLE discografica (
    cod_disco VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    pais VARCHAR(50) NOT NULL,
    año_fundacion INT NOT NULL,
    generos_especializados TEXT NOT NULL
);

CREATE TABLE festival (
    cod_festival VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    capacidad_maxima INT NOT NULL,
    generos TEXT NOT NULL
);

CREATE TABLE album (
    cod_album VARCHAR(10) PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    año_lanzamiento INT NOT NULL,
    tipo ENUM('Estudio', 'En vivo', 'Compilación', 'EP') NOT NULL,
    cod_banda VARCHAR(10) NOT NULL,
    duracion_total INT NOT NULL, -- en segundos
    ventas BIGINT DEFAULT 0,
    FOREIGN KEY (cod_banda) REFERENCES banda(cod_banda)
);

CREATE TABLE cancion (
    cod_cancion VARCHAR(10) PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    duracion INT NOT NULL, -- en segundos
    cod_album VARCHAR(10) NOT NULL,
    es_single BOOLEAN DEFAULT FALSE,
    letra_explicita BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (cod_album) REFERENCES album(cod_album)
);

CREATE TABLE contrato (
    cod_banda VARCHAR(10),
    cod_disco VARCHAR(10),
    fecha_inicio DATE,
    fecha_fin DATE,
    tipo_contrato VARCHAR(50) NOT NULL,
    valor_contrato DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (cod_banda, cod_disco, fecha_inicio),
    FOREIGN KEY (cod_banda) REFERENCES banda(cod_banda),
    FOREIGN KEY (cod_disco) REFERENCES discografica(cod_disco)
);

CREATE TABLE integra (
    dni VARCHAR(15),
    cod_banda VARCHAR(10),
    fecha_entrada DATE,
    fecha_salida DATE NULL,
    instrumento VARCHAR(50) NOT NULL,
    es_fundador BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (dni, cod_banda, fecha_entrada),
    FOREIGN KEY (dni) REFERENCES musico(dni),
    FOREIGN KEY (cod_banda) REFERENCES banda(cod_banda)
);

CREATE TABLE actuacion (
    cod_banda VARCHAR(10),
    cod_festival VARCHAR(10),
    fecha_actuacion DATE,
    duracion_show INT NOT NULL, -- en minutos
    orden_actuacion INT NOT NULL,
    cachet DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (cod_banda, cod_festival, fecha_actuacion),
    FOREIGN KEY (cod_banda) REFERENCES banda(cod_banda),
    FOREIGN KEY (cod_festival) REFERENCES festival(cod_festival)
);

CREATE TABLE gira (
    cod_gira VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    cod_banda VARCHAR(10) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    numero_conciertos INT NOT NULL,
    recaudacion_total DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (cod_banda) REFERENCES banda(cod_banda)
);

CREATE TABLE premio (
    cod_premio VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    año INT NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    pais_premio VARCHAR(50) NOT NULL,
    valor_premio DECIMAL(10,2) DEFAULT 0,
    cod_banda VARCHAR(10) NULL,
    cod_album VARCHAR(10) NULL,
    cod_cancion VARCHAR(10) NULL,
    FOREIGN KEY (cod_banda) REFERENCES banda(cod_banda),
    FOREIGN KEY (cod_album) REFERENCES album(cod_album),
    FOREIGN KEY (cod_cancion) REFERENCES cancion(cod_cancion)
);

CREATE TABLE critica (
    cod_critica VARCHAR(10) PRIMARY KEY,
    medio_comunicacion VARCHAR(100) NOT NULL,
    puntuacion DECIMAL(3,1) NOT NULL,
    cod_album VARCHAR(10) NOT NULL,
    fecha_critica DATE NOT NULL,
    critico VARCHAR(100) NOT NULL,
    pais_critico VARCHAR(50) NOT NULL,
    FOREIGN KEY (cod_album) REFERENCES album(cod_album)
);

CREATE TABLE colaboracion (
    dni_musico1 VARCHAR(15),
    dni_musico2 VARCHAR(15),
    cod_cancion VARCHAR(10),
    tipo_colaboracion VARCHAR(50) NOT NULL,
    PRIMARY KEY (dni_musico1, dni_musico2, cod_cancion),
    FOREIGN KEY (dni_musico1) REFERENCES musico(dni),
    FOREIGN KEY (dni_musico2) REFERENCES musico(dni),
    FOREIGN KEY (cod_cancion) REFERENCES cancion(cod_cancion)
);
```

## 📊 **INSERCIÓN DE DATOS DE EJEMPLO**

### **BANDAS**
```sql
INSERT INTO banda VALUES
('BND001', 'Metallica', 'Estados Unidos', 1981, 'Thrash Metal', TRUE),
('BND002', 'Iron Maiden', 'Reino Unido', 1975, 'Heavy Metal', TRUE),
('BND003', 'Black Sabbath', 'Reino Unido', 1968, 'Heavy Metal', FALSE),
('BND004', 'Megadeth', 'Estados Unidos', 1983, 'Thrash Metal', TRUE),
('BND005', 'AC/DC', 'Australia', 1973, 'Hard Rock', TRUE),
('BND006', 'Deep Purple', 'Reino Unido', 1968, 'Hard Rock', TRUE),
('BND007', 'Judas Priest', 'Reino Unido', 1969, 'Heavy Metal', TRUE),
('BND008', 'Slayer', 'Estados Unidos', 1981, 'Thrash Metal', FALSE),
('BND009', 'Motörhead', 'Reino Unido', 1975, 'Speed Metal', FALSE),
('BND010', 'Rainbow', 'Reino Unido', 1975, 'Hard Rock', FALSE),
('BND011', 'Dio', 'Estados Unidos', 1982, 'Heavy Metal', FALSE),
('BND012', 'Ozzy Osbourne', 'Reino Unido', 1979, 'Heavy Metal', TRUE),
('BND013', 'Anthrax', 'Estados Unidos', 1981, 'Thrash Metal', TRUE),
('BND014', 'Testament', 'Estados Unidos', 1983, 'Thrash Metal', TRUE),
('BND015', 'Exodus', 'Estados Unidos', 1979, 'Thrash Metal', TRUE),
('BND016', 'Kreator', 'Alemania', 1982, 'Thrash Metal', TRUE),
('BND017', 'Sodom', 'Alemania', 1981, 'Thrash Metal', TRUE),
('BND018', 'Destruction', 'Alemania', 1982, 'Thrash Metal', TRUE),
('BND019', 'Sepultura', 'Brasil', 1984, 'Thrash Metal', TRUE),
('BND020', 'Pantera', 'Estados Unidos', 1981, 'Groove Metal', FALSE),
('BND021', 'Dream Theater', 'Estados Unidos', 1985, 'Progressive Metal', TRUE),
('BND022', 'Queensrÿche', 'Estados Unidos', 1980, 'Progressive Metal', TRUE),
('BND023', 'Fates Warning', 'Estados Unidos', 1982, 'Progressive Metal', TRUE),
('BND024', 'Helloween', 'Alemania', 1984, 'Power Metal', TRUE),
('BND025', 'Gamma Ray', 'Alemania', 1989, 'Power Metal', TRUE);
```

### **MÚSICOS**
```sql
INSERT INTO musico VALUES
-- Metallica
('US001', 'James', 'Hetfield', '1963-08-03', 'Estados Unidos', 'Guitarra'),
('US002', 'Lars', 'Ulrich', '1963-12-26', 'Dinamarca', 'Batería'),
('US003', 'Kirk', 'Hammett', '1962-11-18', 'Estados Unidos', 'Guitarra'),
('US004', 'Robert', 'Trujillo', '1964-10-23', 'Estados Unidos', 'Bajo'),
('US005', 'Cliff', 'Burton', '1962-02-10', 'Estados Unidos', 'Bajo'),
('US006', 'Jason', 'Newsted', '1963-03-04', 'Estados Unidos', 'Bajo'),
('US007', 'Dave', 'Mustaine', '1961-09-13', 'Estados Unidos', 'Guitarra'),

-- Iron Maiden
('UK001', 'Bruce', 'Dickinson', '1958-08-07', 'Reino Unido', 'Voz'),
('UK002', 'Steve', 'Harris', '1956-03-12', 'Reino Unido', 'Bajo'),
('UK003', 'Dave', 'Murray', '1956-12-23', 'Reino Unido', 'Guitarra'),
('UK004', 'Adrian', 'Smith', '1957-02-27', 'Reino Unido', 'Guitarra'),
('UK005', 'Janick', 'Gers', '1957-01-27', 'Reino Unido', 'Guitarra'),
('UK006', 'Nicko', 'McBrain', '1952-06-05', 'Reino Unido', 'Batería'),
('UK007', 'Paul', 'Di Anno', '1958-05-17', 'Reino Unido', 'Voz'),

-- Black Sabbath
('UK008', 'Tony', 'Iommi', '1948-02-19', 'Reino Unido', 'Guitarra'),
('UK009', 'Ozzy', 'Osbourne', '1948-12-03', 'Reino Unido', 'Voz'),
('UK010', 'Geezer', 'Butler', '1949-07-17', 'Reino Unido', 'Bajo'),
('UK011', 'Bill', 'Ward', '1948-05-05', 'Reino Unido', 'Batería'),

-- Megadeth
('US008', 'David', 'Ellefson', '1964-11-12', 'Estados Unidos', 'Bajo'),
('US009', 'Marty', 'Friedman', '1962-12-08', 'Estados Unidos', 'Guitarra'),
('US010', 'Nick', 'Menza', '1964-07-23', 'Estados Unidos', 'Batería'),
('US011', 'Kiko', 'Loureiro', '1972-06-16', 'Brasil', 'Guitarra'),
('US012', 'Dirk', 'Verbeuren', '1975-01-17', 'Bélgica', 'Batería'),

-- AC/DC
('AU001', 'Angus', 'Young', '1955-03-31', 'Australia', 'Guitarra'),
('AU002', 'Malcolm', 'Young', '1953-01-06', 'Australia', 'Guitarra'),
('AU003', 'Brian', 'Johnson', '1947-10-05', 'Reino Unido', 'Voz'),
('AU004', 'Phil', 'Rudd', '1954-05-19', 'Australia', 'Batería'),
('AU005', 'Cliff', 'Williams', '1949-12-14', 'Reino Unido', 'Bajo'),
('AU006', 'Bon', 'Scott', '1946-07-09', 'Australia', 'Voz'),

-- Deep Purple
('UK012', 'Ian', 'Gillan', '1945-08-19', 'Reino Unido', 'Voz'),
('UK013', 'Ritchie', 'Blackmore', '1945-04-14', 'Reino Unido', 'Guitarra'),
('UK014', 'Jon', 'Lord', '1941-06-09', 'Reino Unido', 'Teclado'),
('UK015', 'Roger', 'Glover', '1945-11-30', 'Reino Unido', 'Bajo'),
('UK016', 'Ian', 'Paice', '1948-06-29', 'Reino Unido', 'Batería'),

-- Judas Priest
('UK017', 'Rob', 'Halford', '1951-08-25', 'Reino Unido', 'Voz'),
('UK018', 'Glenn', 'Tipton', '1947-10-25', 'Reino Unido', 'Guitarra'),
('UK019', 'K.K.', 'Downing', '1951-10-27', 'Reino Unido', 'Guitarra'),
('UK020', 'Ian', 'Hill', '1951-01-20', 'Reino Unido', 'Bajo'),
('UK021', 'Scott', 'Travis', '1961-09-06', 'Estados Unidos', 'Batería'),

-- Slayer
('US013', 'Tom', 'Araya', '1961-06-06', 'Chile', 'Bajo'),
('US014', 'Jeff', 'Hanneman', '1964-01-31', 'Estados Unidos', 'Guitarra'),
('US015', 'Kerry', 'King', '1964-06-03', 'Estados Unidos', 'Guitarra'),
('US016', 'Dave', 'Lombardo', '1965-02-16', 'Cuba', 'Batería'),

-- Motörhead
('UK022', 'Lemmy', 'Kilmister', '1945-12-24', 'Reino Unido', 'Bajo'),
('UK023', 'Phil', 'Campbell', '1961-05-07', 'Reino Unido', 'Guitarra'),
('UK024', 'Mikkey', 'Dee', '1963-10-31', 'Suecia', 'Batería'),

-- Más músicos para otras bandas...
('US017', 'Ronnie James', 'Dio', '1942-07-10', 'Estados Unidos', 'Voz'),
('US018', 'Randy', 'Rhoads', '1956-12-06', 'Estados Unidos', 'Guitarra'),
('US019', 'Zakk', 'Wylde', '1967-01-14', 'Estados Unidos', 'Guitarra'),
('US020', 'Scott', 'Ian', '1963-12-31', 'Estados Unidos', 'Guitarra'),
('US021', 'Charlie', 'Benante', '1962-11-27', 'Estados Unidos', 'Batería'),
('GE001', 'Mille', 'Petrozza', '1967-12-18', 'Alemania', 'Guitarra'),
('GE002', 'Kai', 'Hansen', '1963-01-17', 'Alemania', 'Guitarra'),
('BR001', 'Max', 'Cavalera', '1969-08-04', 'Brasil', 'Guitarra'),
('BR002', 'Igor', 'Cavalera', '1970-09-04', 'Brasil', 'Batería'),
('US022', 'Dimebag', 'Darrell', '1966-08-20', 'Estados Unidos', 'Guitarra'),
('US023', 'Vinnie Paul', 'Abbott', '1964-03-11', 'Estados Unidos', 'Batería'),
('US024', 'John', 'Petrucci', '1967-07-12', 'Estados Unidos', 'Guitarra'),
('US025', 'Mike', 'Portnoy', '1967-04-20', 'Estados Unidos', 'Batería');
```

### **DISCOGRÁFICAS**
```sql
INSERT INTO discografica VALUES
('DISC001', 'Elektra Records', 'Estados Unidos', 1950, 'Rock, Metal, Alternative'),
('DISC002', 'EMI Records', 'Reino Unido', 1931, 'Rock, Pop, Metal'),
('DISC003', 'Vertigo Records', 'Reino Unido', 1969, 'Hard Rock, Heavy Metal'),
('DISC004', 'Capitol Records', 'Estados Unidos', 1942, 'Rock, Metal, Pop'),
('DISC005', 'Columbia Records', 'Estados Unidos', 1887, 'Rock, Metal, Pop'),
('DISC006', 'Warner Bros Records', 'Estados Unidos', 1958, 'Rock, Metal, Alternative'),
('DISC007', 'Atlantic Records', 'Estados Unidos', 1947, 'Rock, Metal, R&B'),
('DISC008', 'Def Jam Recordings', 'Estados Unidos', 1984, 'Metal, Hardcore, Hip Hop'),
('DISC009', 'Nuclear Blast', 'Alemania', 1987, 'Heavy Metal, Death Metal, Black Metal'),
('DISC010', 'Century Media', 'Estados Unidos', 1988, 'Death Metal, Black Metal, Hardcore'),
('DISC011', 'Roadrunner Records', 'Holanda', 1980, 'Heavy Metal, Thrash Metal'),
('DISC012', 'Metal Blade Records', 'Estados Unidos', 1982, 'Heavy Metal, Death Metal'),
('DISC013', 'SPV GmbH', 'Alemania', 1984, 'Heavy Metal, Hard Rock'),
('DISC014', 'Sanctuary Records', 'Reino Unido', 1979, 'Heavy Metal, Progressive Rock'),
('DISC015', 'InsideOut Music', 'Alemania', 1993, 'Progressive Metal, Progressive Rock');
```

### **FESTIVALES**
```sql
INSERT INTO festival VALUES
('FEST001', 'Wacken Open Air', 'Alemania', '2023-08-02', '2023-08-05', 85000, 'Heavy Metal, Thrash Metal, Death Metal'),
('FEST002', 'Download Festival', 'Reino Unido', '2023-06-08', '2023-06-11', 111000, 'Metal, Hard Rock, Alternative'),
('FEST003', 'Hellfest', 'Francia', '2023-06-15', '2023-06-25', 180000, 'Metal, Hardcore, Punk'),
('FEST004', 'Bloodstock Open Air', 'Reino Unido', '2023-08-10', '2023-08-13', 20000, 'Heavy Metal, Death Metal'),
('FEST005', 'Sweden Rock Festival', 'Suecia', '2023-06-07', '2023-06-10', 33000, 'Hard Rock, Heavy Metal'),
('FEST006', 'Rock am Ring', 'Alemania', '2023-06-02', '2023-06-04', 85000, 'Rock, Metal, Alternative'),
('FEST007', 'Graspop Metal Meeting', 'Bélgica', '2023-06-15', '2023-06-18', 152000, 'Metal, Hard Rock'),
('FEST008', 'Monsters of Rock', 'Estados Unidos', '2023-05-13', '2023-05-14', 50000, 'Classic Rock, Heavy Metal'),
('FEST009', 'Rock in Rio', 'Brasil', '2022-09-02', '2022-09-11', 700000, 'Rock, Metal, Pop'),
('FEST010', 'Loud Park', 'Japón', '2023-10-14', '2023-10-15', 20000, 'Heavy Metal, Visual Kei'),
('FEST011', 'Copenhell', 'Dinamarca', '2023-06-14', '2023-06-17', 55000, 'Heavy Metal, Black Metal'),
('FEST012', 'Resurrection Fest', 'España', '2023-06-28', '2023-07-01', 85000, 'Metal, Hardcore, Punk'),
('FEST013', 'Masters of Rock', 'República Checa', '2023-07-13', '2023-07-16', 35000, 'Heavy Metal, Hard Rock'),
('FEST014', 'Metaldays', 'Eslovenia', '2023-07-23', '2023-07-29', 12000, 'Extreme Metal, Progressive Metal'),
('FEST015', 'ProgPower USA', 'Estados Unidos', '2023-09-06', '2023-09-09', 1500, 'Progressive Metal, Power Metal');
```

### **ÁLBUMES**
```sql
INSERT INTO album VALUES
-- Metallica
('ALB001', 'Master of Puppets', 1986, 'Estudio', 'BND001', 3279, 6000000),
('ALB002', 'Ride the Lightning', 1984, 'Estudio', 'BND001', 2984, 5000000),
('ALB003', 'Kill Em All', 1983, 'Estudio', 'BND001', 3060, 3000000),
('ALB004', 'Metallica (Black Album)', 1991, 'Estudio', 'BND001', 3858, 31000000),
('ALB005', 'Load', 1996, 'Estudio', 'BND001', 4760, 5000000),
('ALB006', 'S&M', 1999, 'En vivo', 'BND001', 8424, 2500000),

-- Iron Maiden
('ALB007', 'The Number of the Beast', 1982, 'Estudio', 'BND002', 2388, 14000000),
('ALB008', 'Powerslave', 1984, 'Estudio', 'BND002', 3072, 4000000),
('ALB009', 'Piece of Mind', 1983, 'Estudio', 'BND002', 2711, 3500000),
('ALB010', 'Seventh Son of a Seventh Son', 1988, 'Estudio', 'BND002', 2745, 2000000),
('ALB011', 'Live After Death', 1985, 'En vivo', 'BND002', 6120, 2000000),

-- Black Sabbath
('ALB012', 'Paranoid', 1970, 'Estudio', 'BND003', 2558, 4000000),
('ALB013', 'Master of Reality', 1971, 'Estudio', 'BND003', 2073, 2000000),
('ALB014', 'Vol. 4', 1972, 'Estudio', 'BND003', 2532, 1500000),
('ALB015', 'Black Sabbath', 1970, 'Estudio', 'BND003', 2278, 5000000),

-- Megadeth
('ALB016', 'Peace Sells... but Whos Buying?', 1986, 'Estudio', 'BND004', 2175, 2000000),
('ALB017', 'Rust in Peace', 1990, 'Estudio', 'BND004', 2395, 2500000),
('ALB018', 'Countdown to Extinction', 1992, 'Estudio', 'BND004', 3413, 2000000),
('ALB019', 'Dystopia', 2016, 'Estudio', 'BND004', 2700, 500000),

-- AC/DC
('ALB020', 'Back in Black', 1980, 'Estudio', 'BND005', 2534, 50000000),
('ALB021', 'Highway to Hell', 1979, 'Estudio', 'BND005', 2511, 20000000),
('ALB022', 'For Those About to Rock', 1981, 'Estudio', 'BND005', 2405, 4000000),
('ALB023', 'Live at River Plate', 2012, 'En vivo', 'BND005', 9120, 1000000),

-- Deep Purple
('ALB024', 'Machine Head', 1972, 'Estudio', 'BND006', 2294, 3000000),
('ALB025', 'Deep Purple in Rock', 1970, 'Estudio', 'BND006', 2460, 2000000),
('ALB026', 'Made in Japan', 1972, 'En vivo', 'BND006', 4380, 2500000),

-- Judas Priest
('ALB027', 'British Steel', 1980, 'Estudio', 'BND007', 2170, 2000000),
('ALB028', 'Screaming for Vengeance', 1982, 'Estudio', 'BND007', 2290, 1500000),
('ALB029', 'Painkiller', 1990, 'Estudio', 'BND007', 2985, 1000000),

-- Slayer
('ALB030', 'Reign in Blood', 1986, 'Estudio', 'BND008', 1756, 2000000),
('ALB031', 'South of Heaven', 1988, 'Estudio', 'BND008', 2166, 1500000),
('ALB032', 'Seasons in the Abyss', 1990, 'Estudio', 'BND008', 2504, 1200000),

-- Motörhead
('ALB033', 'Ace of Spades', 1980, 'Estudio', 'BND009', 2193, 1500000),
('ALB034', 'Overkill', 1979, 'Estudio', 'BND009', 2387, 1000000),
('ALB035', 'Bomber', 1979, 'Estudio', 'BND009', 2023, 800000),

-- Otros álbumes
('ALB036', 'Holy Diver', 1983, 'Estudio', 'BND011', 2545, 2000000),
('ALB037', 'Blizzard of Ozz', 1980, 'Estudio', 'BND012', 2289, 5000000),
('ALB038', 'Among the Living', 1987, 'Estudio', 'BND013', 3165, 1000000),
('ALB039', 'The Legacy', 1987, 'Estudio', 'BND014', 2280, 500000),
('ALB040', 'Bonded by Blood', 1985, 'Estudio', 'BND015', 2275, 300000);
```

### **CANCIONES**
```sql
INSERT INTO cancion VALUES
-- Master of Puppets
('CAN001', 'Battery', 312, 'ALB001', TRUE, FALSE),
('CAN002', 'Master of Puppets', 515, 'ALB001', TRUE, FALSE),
('CAN003', 'The Thing That Should Not Be', 396, 'ALB001', FALSE, FALSE),
('CAN004', 'Welcome Home (Sanitarium)', 387, 'ALB001', TRUE, FALSE),
('CAN005', 'Disposable Heroes', 496, 'ALB001', FALSE, TRUE),
('CAN006', 'Leper Messiah', 340, 'ALB001', FALSE, FALSE),
('CAN007', 'Orion', 508, 'ALB001', FALSE, FALSE),
('CAN008', 'Damage, Inc.', 329, 'ALB001', FALSE, TRUE),

-- The Number of the Beast
('CAN009', 'Invaders', 203, 'ALB007', FALSE, FALSE),
('CAN010', 'Children of the Damned', 282, 'ALB007', FALSE, FALSE),
('CAN011', 'The Prisoner', 359, 'ALB007', FALSE, FALSE),
('CAN012', 'The Number of the Beast', 290, 'ALB007', TRUE, FALSE),
('CAN013', 'Run to the Hills', 228, 'ALB007', TRUE, FALSE),
('CAN014', 'Gangland', 227, 'ALB007', FALSE, FALSE),
('CAN015', 'Hallowed Be Thy Name', 432, 'ALB007', TRUE, FALSE),

-- Paranoid
('CAN016', 'War Pigs', 466, 'ALB012', FALSE, TRUE),
('CAN017', 'Paranoid', 168, 'ALB012', TRUE, FALSE),
('CAN018', 'Planet Caravan', 263, 'ALB012', FALSE, FALSE),
('CAN019', 'Iron Man', 356, 'ALB012', TRUE, FALSE),
('CAN020', 'Electric Funeral', 289, 'ALB012', FALSE, FALSE),
('CAN021', 'Hand of Doom', 427, 'ALB012', FALSE, TRUE),
('CAN022', 'Rat Salad', 154, 'ALB012', FALSE, FALSE),
('CAN023', 'Fairies Wear Boots', 375, 'ALB012', FALSE, FALSE),

-- Back in Black
('CAN024', 'Hells Bells', 312, 'ALB020', TRUE, FALSE),
('CAN025', 'Shoot to Thrill', 317, 'ALB020', FALSE, FALSE),
('CAN026', 'What Do You Do for Money Honey', 213, 'ALB020', FALSE, FALSE),
('CAN027', 'Given the Dog a Bone', 210, 'ALB020', FALSE, TRUE),
('CAN028', 'Let Me Put My Love into You', 255, 'ALB020', FALSE, TRUE),
('CAN029', 'Back in Black', 255, 'ALB020', TRUE, FALSE),
('CAN030', 'You Shook Me All Night Long', 210, 'ALB020', TRUE, FALSE),
('CAN031', 'Have a Drink on Me', 238, 'ALB020', FALSE, TRUE),
('CAN032', 'Shake a Leg', 244, 'ALB020', FALSE, FALSE),
('CAN033', 'Rock and Roll Aint Noise Pollution', 255, 'ALB020', FALSE, FALSE),

-- Reign in Blood
('CAN034', 'Angel of Death', 286, 'ALB030', TRUE, TRUE),
('CAN035', 'Piece by Piece', 122, 'ALB030', FALSE, TRUE),
('CAN036', 'Necrophobic', 99, 'ALB030', FALSE, TRUE),
('CAN037', 'Altar of Sacrifice', 171, 'ALB030', FALSE, TRUE),
('CAN038', 'Jesus Saves', 176, 'ALB030', FALSE, TRUE),
('CAN039', 'Criminally Insane', 147, 'ALB030', FALSE, TRUE),
('CAN040', 'Reborn', 130, 'ALB030', FALSE, TRUE),
('CAN041', 'Epidemic', 143, 'ALB030', FALSE, TRUE),
('CAN042', 'Postmortem', 205, 'ALB030', FALSE, TRUE),
('CAN043', 'Raining Blood', 217, 'ALB030', TRUE, TRUE),

-- Más canciones para otros álbumes...
('CAN044', 'Ace of Spades', 169, 'ALB033', TRUE, FALSE),
('CAN045', 'Holy Diver', 341, 'ALB036', TRUE, FALSE),
('CAN046', 'Crazy Train', 233, 'ALB037', TRUE, FALSE),
('CAN047', 'Among the Living', 317, 'ALB038', TRUE, FALSE),
('CAN048', 'Over the Wall', 246, 'ALB039', FALSE, FALSE),
('CAN049', 'Bonded by Blood', 202, 'ALB040', TRUE, TRUE),
('CAN050', 'Breaking the Law', 155, 'ALB027', TRUE, FALSE);
```

### **CONTRATOS**
```sql
INSERT INTO contrato VALUES
('BND001', 'DISC001', '1984-01-01', '1991-12-31', 'Exclusivo', 15000000.00),
('BND001', 'DISC001', '1992-01-01', '2000-12-31', 'Exclusivo', 60000000.00),
('BND001', 'DISC006', '2001-01-01', '2012-12-31', 'Exclusivo', 200000000.00),
('BND002', 'DISC002', '1980-01-01', '1995-12-31', 'Exclusivo', 25000000.00),
('BND002', 'DISC014', '1996-01-01', '2025-12-31', 'Exclusivo', 100000000.00),
('BND003', 'DISC003', '1970-01-01', '1975-12-31', 'Exclusivo', 2000000.00),
('BND003', 'DISC006', '1976-01-01', '1983-12-31', 'Exclusivo', 5000000.00),
('BND004', 'DISC004', '1985-01-01', '1992-12-31', 'Exclusivo', 8000000.00),
('BND004', 'DISC011', '1993-01-01', '2002-12-31', 'Exclusivo', 15000000.00),
('BND004', 'DISC009', '2003-01-01', '2025-12-31', 'Exclusivo', 10000000.00),
('BND005', 'DISC007', '1976-01-01', '2025-12-31', 'Exclusivo', 100000000.00),
('BND006', 'DISC003', '1970-01-01', '1984-12-31', 'Exclusivo', 10000000.00),
('BND006', 'DISC002', '1985-01-01', '2025-12-31', 'Exclusivo', 15000000.00),
('BND007', 'DISC005', '1974-01-01', '2025-12-31', 'Exclusivo', 20000000.00),
('BND008', 'DISC008', '1983-01-01', '1998-12-31', 'Exclusivo', 5000000.00),
('BND008', 'DISC009', '1999-01-01', '2019-12-31', 'Exclusivo', 3000000.00),
('BND009', 'DISC003', '1976-01-01', '2015-12-31', 'Exclusivo', 8000000.00),
('BND011', 'DISC006', '1983-01-01', '2010-12-31', 'Exclusivo', 5000000.00),
('BND012', 'DISC008', '1980-01-01', '2025-12-31', 'Exclusivo', 25000000.00),
('BND013', 'DISC009', '1985-01-01', '2025-12-31', 'Exclusivo', 8000000.00),
('BND014', 'DISC007', '1987-01-01', '2025-12-31', 'Exclusivo', 3000000.00);
```

### **INTEGRA (Miembros de bandas)**
```sql
INSERT INTO integra VALUES
-- Metallica
('US001', 'BND001', '1981-10-28', NULL, 'Guitarra', TRUE),
('US002', 'BND001', '1981-10-28', NULL, 'Batería', TRUE),
('US003', 'BND001', '1983-04-01', NULL, 'Guitarra', FALSE),
('US004', 'BND001', '2003-02-24', NULL, 'Bajo', FALSE),
('US005', 'BND001', '1982-10-01', '1986-09-27', 'Bajo', FALSE),
('US006', 'BND001', '1986-10-28', '2001-01-17', 'Bajo', FALSE),
('US007', 'BND001', '1981-10-28', '1983-04-11', 'Guitarra', TRUE),

-- Iron Maiden
('UK001', 'BND002', '1981-02-01', NULL, 'Voz', FALSE),
('UK002', 'BND002', '1975-12-25', NULL, 'Bajo', TRUE),
('UK003', 'BND002', '1976-12-01', NULL, 'Guitarra', FALSE),
('UK004', 'BND002', '1980-01-01', '1990-01-01', 'Guitarra', FALSE),
('UK004', 'BND002', '1999-02-01', NULL, 'Guitarra', FALSE),
('UK005', 'BND002', '1990-01-01', NULL, 'Guitarra', FALSE),
('UK006', 'BND002', '1982-01-01', NULL, 'Batería', FALSE),
('UK007', 'BND002', '1978-05-01', '1981-02-01', 'Voz', FALSE),

-- Black Sabbath
('UK008', 'BND003', '1968-01-01', NULL, 'Guitarra', TRUE),
('UK009', 'BND003', '1968-01-01', '1979-04-01', 'Voz', TRUE),
('UK009', 'BND003', '1997-06-01', '2017-02-04', 'Voz', TRUE),
('UK010', 'BND003', '1968-01-01', NULL, 'Bajo', TRUE),
('UK011', 'BND003', '1968-01-01', '1980-01-01', 'Batería', TRUE),

-- Megadeth
('US007', 'BND004', '1983-05-01', NULL, 'Guitarra', TRUE),
('US008', 'BND004', '1983-11-01', '2002-02-01', 'Bajo', FALSE),
('US008', 'BND004', '2010-02-01', '2021-05-14', 'Bajo', FALSE),
('US009', 'BND004', '1990-02-01', '2000-01-01', 'Guitarra', FALSE),
('US010', 'BND004', '1989-01-01', '1998-07-01', 'Batería', FALSE),
('US011', 'BND004', '2015-04-01', NULL, 'Guitarra', FALSE),
('US012', 'BND004', '2016-07-01', NULL, 'Batería', FALSE),

-- AC/DC
('AU001', 'BND005', '1973-11-01', NULL, 'Guitarra', TRUE),
('AU002', 'BND005', '1973-11-01', '2014-09-01', 'Guitarra', TRUE),
('AU003', 'BND005', '1980-03-01', NULL, 'Voz', FALSE),
('AU004', 'BND005', '1975-01-01', '1983-01-01', 'Batería', FALSE),
('AU004', 'BND005', '1994-09-01', '2015-11-01', 'Batería', FALSE),
('AU005', 'BND005', '1977-06-01', '2016-07-01', 'Bajo', FALSE),
('AU006', 'BND005', '1974-09-01', '1980-02-19', 'Voz', FALSE),

-- Deep Purple
('UK012', 'BND006', '1969-06-01', '1973-06-01', 'Voz', FALSE),
('UK012', 'BND006', '1984-04-01', '1989-01-01', 'Voz', FALSE),
('UK012', 'BND006', '1992-01-01', NULL, 'Voz', FALSE),
('UK013', 'BND006', '1968-04-01', '1975-06-01', 'Guitarra', FALSE),
('UK013', 'BND006', '1984-04-01', '1993-01-01', 'Guitarra', FALSE),
('UK014', 'BND006', '1968-04-01', '2002-07-16', 'Teclado', TRUE),
('UK015', 'BND006', '1969-06-01', NULL, 'Bajo', FALSE),
('UK016', 'BND006', '1968-04-01', NULL, 'Batería', TRUE),

-- Judas Priest
('UK017', 'BND007', '1973-05-01', '1992-05-01', 'Voz', FALSE),
('UK017', 'BND007', '2003-07-01', NULL, 'Voz', FALSE),
('UK018', 'BND007', '1974-01-01', NULL, 'Guitarra', FALSE),
('UK019', 'BND007', '1970-01-01', '2011-04-01', 'Guitarra', FALSE),
('UK020', 'BND007', '1970-01-01', NULL, 'Bajo', TRUE),
('UK021', 'BND007', '1989-08-01', NULL, 'Batería', FALSE),

-- Slayer
('US013', 'BND008', '1981-01-01', NULL, 'Bajo', FALSE),
('US014', 'BND008', '1981-01-01', '2013-05-02', 'Guitarra', TRUE),
('US015', 'BND008', '1981-01-01', NULL, 'Guitarra', TRUE),
('US016', 'BND008', '1981-01-01', '1986-01-01', 'Batería', FALSE),
('US016', 'BND008', '1987-01-01', '1992-01-01', 'Batería', FALSE),
('US016', 'BND008', '2001-01-01', '2013-01-01', 'Batería', FALSE),

-- Motörhead
('UK022', 'BND009', '1975-06-01', '2015-12-28', 'Bajo', TRUE),
('UK023', 'BND009', '1984-05-01', NULL, 'Guitarra', FALSE),
('UK024', 'BND009', '1992-09-01', NULL, 'Batería', FALSE);
```

### **ACTUACIONES EN FESTIVALES**
```sql
INSERT INTO actuacion VALUES
-- Wacken Open Air 2023
('BND001', 'FEST001', '2023-08-04', 120, 1, 500000.00),
('BND002', 'FEST001', '2023-08-03', 110, 1, 400000.00),
('BND004', 'FEST001', '2023-08-03', 90, 3, 200000.00),
('BND007', 'FEST001', '2023-08-04', 100, 2, 150000.00),
('BND016', 'FEST001', '2023-08-02', 80, 4, 100000.00),

-- Download Festival 2023
('BND002', 'FEST002', '2023-06-11', 150, 1, 800000.00),
('BND001', 'FEST002', '2023-06-10', 130, 1, 750000.00),
('BND005', 'FEST002', '2023-06-09', 110, 1, 600000.00),
('BND007', 'FEST002', '2023-06-10', 100, 3, 300000.00),
('BND012', 'FEST002', '2023-06-09', 90, 4, 250000.00),

-- Hellfest 2023
('BND001', 'FEST003', '2023-06-25', 140, 1, 600000.00),
('BND008', 'FEST003', '2023-06-24', 90, 2, 300000.00),
('BND009', 'FEST003', '2023-06-23', 85, 3, 200000.00),
('BND016', 'FEST003', '2023-06-22', 80, 4, 150000.00),
('BND019', 'FEST003', '2023-06-21', 75, 5, 100000.00),

-- Sweden Rock Festival 2023
('BND006', 'FEST005', '2023-06-10', 120, 1, 300000.00),
('BND002', 'FEST005', '2023-06-09', 110, 1, 400000.00),
('BND007', 'FEST005', '2023-06-08', 100, 2, 200000.00),
('BND005', 'FEST005', '2023-06-07', 95, 3, 350000.00),

-- Rock am Ring 2023
('BND001', 'FEST006', '2023-06-04', 135, 1, 700000.00),
('BND004', 'FEST006', '2023-06-03', 100, 2, 300000.00),
('BND013', 'FEST006', '2023-06-02', 85, 4, 150000.00),

-- Graspop Metal Meeting 2023
('BND002', 'FEST007', '2023-06-18', 130, 1, 500000.00),
('BND001', 'FEST007', '2023-06-17', 125, 1, 550000.00),
('BND007', 'FEST007', '2023-06-16', 95, 3, 250000.00),
('BND008', 'FEST007', '2023-06-15', 85, 4, 200000.00),

-- Rock in Rio 2022
('BND002', 'FEST009', '2022-09-11', 140, 1, 800000.00),
('BND001', 'FEST009', '2022-09-08', 130, 1, 750000.00),
('BND019', 'FEST009', '2022-09-04', 90, 3, 200000.00),

-- Copenhell 2023
('BND001', 'FEST011', '2023-06-17', 120, 1, 400000.00),
('BND002', 'FEST011', '2023-06-16', 110, 1, 350000.00),
('BND016', 'FEST011', '2023-06-15', 80, 3, 120000.00),

-- Resurrection Fest 2023
('BND001', 'FEST012', '2023-07-01', 125, 1, 300000.00),
('BND008', 'FEST012', '2023-06-30', 90, 2, 150000.00),
('BND013', 'FEST012', '2023-06-29', 85, 3, 100000.00),

-- ProgPower USA 2023
('BND021', 'FEST015', '2023-09-09', 120, 1, 50000.00),
('BND022', 'FEST015', '2023-09-08', 110, 2, 40000.00),
('BND024', 'FEST015', '2023-09-07', 100, 3, 35000.00);
```

### **GIRAS**
```sql
INSERT INTO gira VALUES
('GIRA001', 'WorldWired Tour', 'BND001', '2016-05-12', '2019-07-25', 168, 415000000.00),
('GIRA002', 'M72 World Tour', 'BND001', '2023-04-27', '2024-09-29', 64, 180000000.00),
('GIRA003', 'Legacy of the Beast Tour', 'BND002', '2018-05-26', '2022-10-29', 117, 95000000.00),
('GIRA004', 'The Book of Souls World Tour', 'BND002', '2016-02-24', '2017-08-05', 98, 85000000.00),
('GIRA005', 'Rock or Bust World Tour', 'BND005', '2015-05-05', '2016-09-20', 79, 220000000.00),
('GIRA006', 'Black Ice World Tour', 'BND005', '2008-10-28', '2010-06-28', 168, 441000000.00),
('GIRA007', 'Dystopia World Tour', 'BND004', '2016-02-20', '2017-12-18', 121, 25000000.00),
('GIRA008', 'Endgame Tour', 'BND004', '2009-09-11', '2012-02-25', 134, 18000000.00),
('GIRA009', 'Firepower World Tour', 'BND007', '2018-03-13', '2019-06-29', 85, 15000000.00),
('GIRA010', 'Redeemer of Souls Tour', 'BND007', '2014-05-13', '2015-12-06', 97, 12000000.00),
('GIRA011', 'The End World Tour', 'BND003', '2016-01-20', '2017-02-04', 81, 50000000.00),
('GIRA012', 'Blizzard of Ozz Tour', 'BND012', '1980-09-12', '1982-11-07', 156, 8000000.00),
('GIRA013', 'No More Tours II', 'BND012', '2018-04-27', '2020-03-07', 98, 95000000.00),
('GIRA014', 'Among the Kings', 'BND013', '2017-02-17', '2018-04-15', 67, 8000000.00),
('GIRA015', 'Brotherhood of the Snake', 'BND014', '2016-10-28', '2018-09-01', 89, 5000000.00);
```

### **PREMIOS**
```sql
INSERT INTO premio VALUES
('PREM001', 'Grammy Award', 2009, 'Best Metal Performance', 'Estados Unidos', 0, 'BND001', 'ALB004', 'CAN002'),
('PREM002', 'Grammy Award', 1992, 'Best Metal Performance', 'Estados Unidos', 0, 'BND001', 'ALB004', NULL),
('PREM003', 'Grammy Award', 1999, 'Best Hard Rock Performance', 'Estados Unidos', 0, 'BND001', 'ALB006', NULL),
('PREM004', 'Grammy Award', 2009, 'Best Recording Package', 'Estados Unidos', 0, 'BND001', NULL, NULL),
('PREM005', 'Rock and Roll Hall of Fame', 2009, 'Induction', 'Estados Unidos', 0, 'BND001', NULL, NULL),
('PREM006', 'Kerrang! Award', 2004, 'Hall of Fame', 'Reino Unido', 0, 'BND002', NULL, NULL),
('PREM007', 'Metal Hammer Golden Gods', 2012, 'Golden God Award', 'Reino Unido', 0, 'BND002', NULL, NULL),
('PREM008', 'Ivor Novello Award', 2002, 'International Achievement', 'Reino Unido', 0, 'BND002', NULL, NULL),
('PREM009', 'Rock and Roll Hall of Fame', 2006, 'Induction', 'Estados Unidos', 0, 'BND003', NULL, NULL),
('PREM010', 'Grammy Award', 1994, 'Best Metal Performance', 'Estados Unidos', 0, 'BND012', NULL, NULL),
('PREM011', 'MTV Video Music Award', 1986, 'Best Heavy Metal Video', 'Estados Unidos', 0, 'BND012', NULL, NULL),
('PREM012', 'Metal Hammer Golden Gods', 2017, 'Lifetime Achievement', 'Reino Unido', 0, 'BND007', NULL, NULL),
('PREM013', 'Revolver Golden Gods', 2010, 'Best Live Band', 'Estados Unidos', 0, 'BND008', NULL, NULL),
('PREM014', 'Kerrang! Award', 1987, 'Best International Live Act', 'Reino Unido', 0, 'BND008', NULL, NULL),
('PREM015', 'Metal Archives Award', 2004, 'Most Influential Band', 'Canadá', 0, 'BND009', NULL, NULL),
('PREM016', 'Loudwire Music Award', 2011, 'Metal Madness Champion', 'Estados Unidos', 0, 'BND004', NULL, NULL),
('PREM017', 'Bandit Rock Award', 2008, 'Best Metal Album', 'Suecia', 0, 'BND002', 'ALB010', NULL),
('PREM018', 'Classic Rock Roll of Honour', 2005, 'Living Legend', 'Reino Unido', 0, 'BND006', NULL, NULL),
('PREM019', 'Download Festival Award', 2019, 'Lifetime Achievement', 'Reino Unido', 0, 'BND005', NULL, NULL),
('PREM020', 'Wacken Metal Battle', 2018, 'Legend Award', 'Alemania', 0, 'BND016', NULL, NULL);
```

### **CRÍTICAS**
```sql
INSERT INTO critica VALUES
-- Master of Puppets
('CRIT001', 'Rolling Stone', 9.2, 'ALB001', '1986-03-15', 'David Fricke', 'Estados Unidos'),
('CRIT002', 'Kerrang!', 9.5, 'ALB001', '1986-03-10', 'Geoff Barton', 'Reino Unido'),
('CRIT003', 'Metal Hammer', 9.8, 'ALB001', '1986-03-20', 'Malcolm Dome', 'Reino Unido'),
('CRIT004', 'AllMusic', 9.0, 'ALB001', '1986-04-01', 'Steve Huey', 'Estados Unidos'),

-- The Number of the Beast
('CRIT005', 'Kerrang!', 9.7, 'ALB007', '1982-03-25', 'Geoff Barton', 'Reino Unido'),
('CRIT006', 'Rolling Stone', 8.8, 'ALB007', '1982-04-02', 'Kurt Loder', 'Estados Unidos'),
('CRIT007', 'Metal Forces', 9.5, 'ALB007', '1982-04-10', 'Bernard Doe', 'Reino Unido'),
('CRIT008', 'Sounds', 9.2, 'ALB007', '1982-03-30', 'Dante Bonutto', 'Reino Unido'),

-- Paranoid
('CRIT009', 'Rolling Stone', 8.5, 'ALB012', '1970-09-25', 'Lester Bangs', 'Estados Unidos'),
('CRIT010', 'NME', 8.8, 'ALB012', '1970-09-30', 'Roy Carr', 'Reino Unido'),
('CRIT011', 'Melody Maker', 9.0, 'ALB012', '1970-09-28', 'Chris Welch', 'Reino Unido'),

-- Back in Black
('CRIT012', 'Rolling Stone', 9.3, 'ALB020', '1980-07-30', 'David Fricke', 'Estados Unidos'),
('CRIT013', 'Kerrang!', 9.6, 'ALB020', '1980-08-05', 'Geoff Barton', 'Reino Unido'),
('CRIT014', 'Sounds', 9.4, 'ALB020', '1980-08-02', 'Pete Makowski', 'Reino Unido'),
('CRIT015', 'Circus', 9.1, 'ALB020', '1980-08-10', 'Jon Young', 'Estados Unidos'),

-- Reign in Blood
('CRIT016', 'Kerrang!', 9.8, 'ALB030', '1986-10-15', 'Malcolm Dome', 'Reino Unido'),
('CRIT017', 'Metal Forces', 9.9, 'ALB030', '1986-10-20', 'Bernard Doe', 'Reino Unido'),
('CRIT018', 'Thrasher', 9.7, 'ALB030', '1986-10-25', 'Brian Slagel', 'Estados Unidos'),
('CRIT019', 'AllMusic', 9.5, 'ALB030', '1986-11-01', 'Steve Huey', 'Estados Unidos'),

-- Más críticas para otros álbumes
('CRIT020', 'Metal Hammer', 8.9, 'ALB016', '1986-11-10', 'Malcolm Dome', 'Reino Unido'),
('CRIT021', 'Revolver', 9.2, 'ALB017', '1990-09-30', 'Jon Wiederhorn', 'Estados Unidos'),
('CRIT022', 'Guitar World', 9.4, 'ALB027', '1980-04-20', 'Brad Tolinski', 'Estados Unidos'),
('CRIT023', 'Classic Rock', 8.7, 'ALB024', '1972-03-30', 'Paul Elliott', 'Reino Unido'),
('CRIT024', 'Metal Archives', 9.0, 'ALB033', '1980-11-10', 'Frank Albrecht', 'Alemania'),
('CRIT025', 'Loudwire', 8.8, 'ALB036', '1983-05-30', 'Chad Bowar', 'Estados Unidos'),
('CRIT026', 'Decibel', 9.3, 'ALB037', '1980-09-25', 'Albert Mudrian', 'Estados Unidos'),
('CRIT027', 'Terrorizer', 8.6, 'ALB038', '1987-04-15', 'Scott Alisoglu', 'Reino Unido'),
('CRIT028', 'Metal Injection', 8.4, 'ALB039', '1987-05-20', 'Frank Godla', 'Estados Unidos'),
('CRIT029', 'Blabbermouth', 8.9, 'ALB040', '1985-07-30', 'Borivoj Krgin', 'Estados Unidos'),
('CRIT030', 'Pitchfork', 7.8, 'ALB004', '1991-08-15', 'Andy OConnor', 'Estados Unidos');
```

### **COLABORACIONES**
```sql
INSERT INTO colaboracion VALUES
-- Colaboraciones especiales
('US007', 'US001', 'CAN002', 'Solo de guitarra invitado'),
('UK009', 'US018', 'CAN046', 'Dúo vocal'),
('US017', 'UK013', 'CAN045', 'Solo de guitarra'),
('US014', 'US015', 'CAN034', 'Composición conjunta'),
('UK022', 'UK023', 'CAN044', 'Arreglo musical'),
('US001', 'US003', 'CAN001', 'Armonías guitarras'),
('UK001', 'UK002', 'CAN012', 'Producción vocal'),
('US013', 'US016', 'CAN043', 'Ritmo base'),
('UK008', 'UK009', 'CAN017', 'Riff principal'),
('AU001', 'AU002', 'CAN029', 'Guitarras gemelas'),
('US002', 'US016', 'CAN002', 'Colaboración rítmica'),
('UK003', 'UK004', 'CAN013', 'Solo dual'),
('US015', 'GE001', 'CAN043', 'Intercambio cultural'),
('BR001', 'US022', 'CAN047', 'Fusión estilos');
INSERT INTO colaboracion VALUES
('UK017', 'UK018', 'CAN050', 'Composición conjunta'),
('US020', 'US021', 'CAN047', 'Producción'),
('UK012', 'UK013', 'CAN024', 'Jam session'),
('US024', 'US025', 'CAN048', 'Experimental'),
('GE002', 'US011', 'CAN049', 'Intercambio técnico'),
('BR002', 'US023', 'CAN047', 'Ritmo percusivo'),
('UK004', 'UK005', 'CAN014', 'Melodías alternas'),
('US003', 'US009', 'CAN004', 'Armonización'),
('UK006', 'AU004', 'CAN030', 'Sección rítmica'),
('US004', 'UK010', 'CAN019', 'Línea de bajo');

-- ÍNDICES PARA OPTIMIZAR CONSULTAS
CREATE INDEX idx_banda_genero ON banda(genero);
CREATE INDEX idx_banda_pais ON banda(pais);
CREATE INDEX idx_banda_año ON banda(año_formacion);
CREATE INDEX idx_album_año ON album(año_lanzamiento);
CREATE INDEX idx_album_tipo ON album(tipo);
CREATE INDEX idx_cancion_single ON cancion(es_single);
CREATE INDEX idx_integra_fechas ON integra(fecha_entrada, fecha_salida);
CREATE INDEX idx_actuacion_fecha ON actuacion(fecha_actuacion);
CREATE INDEX idx_critica_puntuacion ON critica(puntuacion);
CREATE INDEX idx_festival_pais ON festival(pais);
CREATE INDEX idx_musico_pais ON musico(pais_origen);
CREATE INDEX idx_musico_instrumento ON musico(instrumento_principal);
CREATE INDEX idx_gira_fechas ON gira(fecha_inicio, fecha_fin);
CREATE INDEX idx_contrato_fechas ON contrato(fecha_inicio, fecha_fin);
CREATE INDEX idx_premio_año ON premio(año);

-- VISTAS ÚTILES PARA CONSULTAS FRECUENTES

-- Vista de bandas activas con información completa
CREATE VIEW v_bandas_activas AS
SELECT 
    b.cod_banda,
    b.nombre,
    b.pais,
    b.año_formacion,
    b.genero,
    COUNT(DISTINCT al.cod_album) as total_albums,
    COUNT(DISTINCT i.dni) as miembros_actuales,
    COALESCE(SUM(al.ventas), 0) as ventas_totales
FROM banda b
LEFT JOIN album al ON b.cod_banda = al.cod_banda
LEFT JOIN integra i ON b.cod_banda = i.cod_banda AND i.fecha_salida IS NULL
WHERE b.activa = TRUE
GROUP BY b.cod_banda, b.nombre, b.pais, b.año_formacion, b.genero;

-- Vista de álbumes con información de críticas
CREATE VIEW v_albums_criticas AS
SELECT 
    al.cod_album,
    al.titulo,
    b.nombre as banda,
    al.año_lanzamiento,
    al.tipo,
    al.ventas,
    COUNT(cr.cod_critica) as numero_criticas,
    ROUND(AVG(cr.puntuacion), 2) as puntuacion_promedio,
    MAX(cr.puntuacion) as mejor_puntuacion,
    MIN(cr.puntuacion) as peor_puntuacion
FROM album al
INNER JOIN banda b ON al.cod_banda = b.cod_banda
LEFT JOIN critica cr ON al.cod_album = cr.cod_album
GROUP BY al.cod_album, al.titulo, b.nombre, al.año_lanzamiento, al.tipo, al.ventas;

-- Vista de festivales con estadísticas
CREATE VIEW v_festivales_stats AS
SELECT 
    f.cod_festival,
    f.nombre,
    f.pais,
    f.capacidad_maxima,
    COUNT(DISTINCT a.cod_banda) as bandas_actuaron,
    COUNT(DISTINCT b.genero) as generos_diferentes,
    ROUND(AVG(a.cachet), 2) as cachet_promedio,
    SUM(a.cachet) as cachet_total,
    MAX(a.duracion_show) as show_mas_largo
FROM festival f
LEFT JOIN actuacion a ON f.cod_festival = a.cod_festival
LEFT JOIN banda b ON a.cod_banda = b.cod_banda
GROUP BY f.cod_festival, f.nombre, f.pais, f.capacidad_maxima;

-- Vista de músicos con carrera detallada
CREATE VIEW v_musicos_carrera AS
SELECT 
    m.dni,
    m.nombre,
    m.apellidos,
    m.pais_origen,
    m.instrumento_principal,
    COUNT(DISTINCT i.cod_banda) as bandas_total,
    COUNT(DISTINCT CASE WHEN i.fecha_salida IS NULL THEN i.cod_banda END) as bandas_actuales,
    MIN(i.fecha_entrada) as inicio_carrera,
    MAX(CASE WHEN i.fecha_salida IS NULL THEN CURRENT_DATE ELSE i.fecha_salida END) as fin_carrera,
    COUNT(DISTINCT col1.cod_cancion) + COUNT(DISTINCT col2.cod_cancion) as colaboraciones_total
FROM musico m
LEFT JOIN integra i ON m.dni = i.dni
LEFT JOIN colaboracion col1 ON m.dni = col1.dni_musico1
LEFT JOIN colaboracion col2 ON m.dni = col2.dni_musico2 AND col2.dni_musico1 != m.dni
GROUP BY m.dni, m.nombre, m.apellidos, m.pais_origen, m.instrumento_principal;

-- Vista de giras más rentables
CREATE VIEW v_giras_rentables AS
SELECT 
    g.cod_gira,
    g.nombre,
    b.nombre as banda,
    g.fecha_inicio,
    g.fecha_fin,
    g.numero_conciertos,
    g.recaudacion_total,
    ROUND(g.recaudacion_total / g.numero_conciertos, 2) as recaudacion_por_concierto,
    DATEDIFF(g.fecha_fin, g.fecha_inicio) as duracion_dias
FROM gira g
INNER JOIN banda b ON g.cod_banda = b.cod_banda
ORDER BY g.recaudacion_total DESC;

-- PROCEDIMIENTOS ALMACENADOS ÚTILES

DELIMITER //

-- Procedimiento para agregar un nuevo músico a una banda
CREATE PROCEDURE sp_agregar_musico_banda(
    IN p_dni VARCHAR(15),
    IN p_cod_banda VARCHAR(10),
    IN p_instrumento VARCHAR(50),
    IN p_es_fundador BOOLEAN
)
BEGIN
    DECLARE v_existe_musico INT DEFAULT 0;
    DECLARE v_existe_banda INT DEFAULT 0;
    
    -- Verificar si existe el músico
    SELECT COUNT(*) INTO v_existe_musico FROM musico WHERE dni = p_dni;
    
    -- Verificar si existe la banda
    SELECT COUNT(*) INTO v_existe_banda FROM banda WHERE cod_banda = p_cod_banda;
    
    IF v_existe_musico = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El músico no existe';
    ELSEIF v_existe_banda = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La banda no existe';
    ELSE
        INSERT INTO integra (dni, cod_banda, fecha_entrada, instrumento, es_fundador)
        VALUES (p_dni, p_cod_banda, CURRENT_DATE, p_instrumento, p_es_fundador);
    END IF;
END //

-- Procedimiento para calcular estadísticas de un género
CREATE PROCEDURE sp_estadisticas_genero(IN p_genero VARCHAR(50))
BEGIN
    SELECT 
        p_genero as genero,
        COUNT(DISTINCT b.cod_banda) as total_bandas,
        COUNT(DISTINCT al.cod_album) as total_albums,
        ROUND(AVG(al.ventas), 0) as ventas_promedio,
        SUM(al.ventas) as ventas_totales,
        MIN(b.año_formacion) as banda_mas_antigua,
        MAX(b.año_formacion) as banda_mas_nueva,
        COUNT(DISTINCT f.cod_festival) as festivales_participados
    FROM banda b
    LEFT JOIN album al ON b.cod_banda = al.cod_banda
    LEFT JOIN actuacion act ON b.cod_banda = act.cod_banda
    LEFT JOIN festival f ON act.cod_festival = f.cod_festival
    WHERE b.genero = p_genero;
END //

-- Función para calcular la edad de una banda
CREATE FUNCTION fn_edad_banda(p_cod_banda VARCHAR(10))
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_año_formacion INT;
    SELECT año_formacion INTO v_año_formacion 
    FROM banda 
    WHERE cod_banda = p_cod_banda;
    
    RETURN YEAR(CURRENT_DATE) - v_año_formacion;
END //

-- Función para obtener el álbum más vendido de una banda
CREATE FUNCTION fn_album_mas_vendido(p_cod_banda VARCHAR(10))
RETURNS VARCHAR(150)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_titulo VARCHAR(150);
    SELECT titulo INTO v_titulo
    FROM album
    WHERE cod_banda = p_cod_banda
    ORDER BY ventas DESC
    LIMIT 1;
    
    RETURN COALESCE(v_titulo, 'Sin álbumes');
END //

DELIMITER ;

-- TRIGGERS PARA MANTENER INTEGRIDAD

DELIMITER //

-- Trigger para validar fechas de integración
CREATE TRIGGER tr_validar_fechas_integracion
BEFORE INSERT ON integra
FOR EACH ROW
BEGIN
    DECLARE v_año_formacion INT;
    
    SELECT año_formacion INTO v_año_formacion
    FROM banda
    WHERE cod_banda = NEW.cod_banda;
    
    IF YEAR(NEW.fecha_entrada) < v_año_formacion THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La fecha de entrada no puede ser anterior a la formación de la banda';
    END IF;
    
    IF NEW.fecha_salida IS NOT NULL AND NEW.fecha_salida <= NEW.fecha_entrada THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La fecha de salida debe ser posterior a la fecha de entrada';
    END IF;
END //

-- Trigger para actualizar estadísticas después de insertar un álbum
CREATE TRIGGER tr_actualizar_stats_album
AFTER INSERT ON album
FOR EACH ROW
BEGIN
    -- Aquí se podrían actualizar tablas de estadísticas si existieran
    -- Por ejemplo, actualizar contadores de álbumes por género
    INSERT INTO log_actividad (tabla, accion, fecha, descripcion)
    VALUES ('album', 'INSERT', NOW(), CONCAT('Nuevo álbum: ', NEW.titulo));
END //

DELIMITER ;

-- TABLA DE LOG PARA EL TRIGGER ANTERIOR
CREATE TABLE log_actividad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabla VARCHAR(50) NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME NOT NULL,
    descripcion TEXT,
    usuario VARCHAR(50) DEFAULT USER()
);

-- DATOS ADICIONALES PARA COMPLETAR LA BASE DE DATOS

-- Más canciones representativas
INSERT INTO cancion VALUES
('CAN051', 'I Want Out', 265, 'ALB041', TRUE, FALSE),
('CAN052', 'Keeper of the Seven Keys', 830, 'ALB042', FALSE, FALSE),
('CAN053', 'Territory', 279, 'ALB043', TRUE, FALSE),
('CAN054', 'Cowboys from Hell', 246, 'ALB044', TRUE, FALSE),
('CAN055', 'Walk', 316, 'ALB045', TRUE, FALSE),
('CAN056', 'Pull Me Under', 498, 'ALB046', TRUE, FALSE),
('CAN057', 'The Dance of Eternity', 388, 'ALB047', FALSE, FALSE),
('CAN058', 'Madhouse', 252, 'ALB048', TRUE, FALSE);

-- Críticas adicionales
INSERT INTO critica VALUES
('CRIT031', 'Metal Hammer', 9.1, 'ALB041', '1987-11-15', 'Malcolm Dome', 'Reino Unido'),
('CRIT032', 'Kerrang!', 9.3, 'ALB042', '1988-05-20', 'Geoff Barton', 'Reino Unido'),
('CRIT033', 'Rolling Stone', 8.4, 'ALB043', '1993-10-25', 'David Fricke', 'Estados Unidos'),
('CRIT034', 'Metal Hammer', 8.9, 'ALB044', '1990-07-30', 'Malcolm Dome', 'Reino Unido'),
('CRIT035', 'Revolver', 9.5, 'ALB045', '1992-02-28', 'Jon Wiederhorn', 'Estados Unidos'),
('CRIT036', 'Prog Magazine', 9.7, 'ALB046', '1992-06-15', 'Jerry Ewing', 'Reino Unido'),
('CRIT037', 'Guitar World', 9.8, 'ALB047', '1999-10-30', 'Brad Tolinski', 'Estados Unidos'),
('CRIT038', 'Thrasher', 8.7, 'ALB048', '1985-10-15', 'Brian Slagel', 'Estados Unidos');

-- Más premios
INSERT INTO premio VALUES
('PREM021', 'Metal Hammer Golden Gods', 2019, 'Best Album', 'Reino Unido', 0, 'BND024', 'ALB042', NULL),
('PREM022', 'Roadrunner Records Award', 1994, 'Best Metal Album', 'Holanda', 0, 'BND019', 'ALB043', NULL),
('PREM023', 'Metal Edge Award', 1993, 'Album of the Year', 'Estados Unidos', 0, 'BND020', 'ALB045', NULL),
('PREM024', 'Progressive Music Award', 2000, 'Best Concept Album', 'Reino Unido', 0, 'BND021', 'ALB047', NULL),
('PREM025', 'MTV Headbangers Ball', 1993, 'Best Video', 'Estados Unidos', 0, 'BND021', 'ALB046', 'CAN056');

-- Mensaje de finalización
SELECT 'Base de datos Rock & Metal completada exitosamente!' as mensaje;
SELECT 'Tablas creadas, datos insertados, vistas, procedimientos y triggers añadidos.' as estado;

-- Consulta de verificación final
SELECT 
    (SELECT COUNT(*) FROM banda) as total_bandas,
    (SELECT COUNT(*) FROM musico) as total_musicos,
    (SELECT COUNT(*) FROM album) as total_albums,
    (SELECT COUNT(*) FROM cancion) as total_canciones,
    (SELECT COUNT(*) FROM festival) as total_festivales,
    (SELECT COUNT(*) FROM actuacion) as total_actuaciones;
