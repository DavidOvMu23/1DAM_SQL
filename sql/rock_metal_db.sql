/* ================================================================================ */
/* BASE DE DATOS ROCK & METAL - SCRIPT COMPLETO DE INSTALACIÓN */
/* ================================================================================ */
/* Versión: 1.0 */
/* Fecha: 2025 */
/* Descripción: Base de datos completa para gestión de bandas de rock y metal */
/* ================================================================================ */

/* CREAR LA BASE DE DATOS */
/* ================================================================================ */
CREATE DATABASE IF NOT EXISTS rock_metal_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rock_metal_db;

/* ELIMINAR TABLAS SI EXISTEN (orden inverso por dependencias) */
/* ================================================================================ */
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

/* CREAR LAS TABLAS PRINCIPALES */
/* ================================================================================ */

/* Tabla: banda */
CREATE TABLE banda (
    cod_banda VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    pais VARCHAR(50) NOT NULL,
    anio_formacion INT NOT NULL CHECK (anio_formacion BETWEEN 1950 AND 2100),
    genero VARCHAR(50) NOT NULL,
    activa BOOLEAN DEFAULT TRUE,
    INDEX idx_banda_genero (genero),
    INDEX idx_banda_pais (pais),
    INDEX idx_banda_anio (anio_formacion)
);

/* Tabla: musico */
CREATE TABLE musico (
    dni VARCHAR(15) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    pais_origen VARCHAR(50) NOT NULL,
    instrumento_principal VARCHAR(50) NOT NULL,
    INDEX idx_musico_pais (pais_origen),
    INDEX idx_musico_instrumento (instrumento_principal)
);

/* Tabla: discografica */
CREATE TABLE discografica (
    cod_disco VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    pais VARCHAR(50) NOT NULL,
    anio_fundacion INT NOT NULL CHECK (anio_fundacion >= 1800),
    generos_especializados TEXT NOT NULL
);

/* Tabla: festival */
CREATE TABLE festival (
    cod_festival VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    capacidad_maxima INT NOT NULL CHECK (capacidad_maxima > 0),
    generos TEXT NOT NULL,
    INDEX idx_festival_pais (pais),
    CONSTRAINT chk_festival_fechas CHECK (fecha_fin >= fecha_inicio)
);

/* Tabla: album */
CREATE TABLE album (
    cod_album VARCHAR(10) PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    anio_lanzamiento INT NOT NULL CHECK (anio_lanzamiento >= 1950),
    tipo ENUM('Estudio', 'En vivo', 'Compilación', 'EP') NOT NULL,
    cod_banda VARCHAR(10) NOT NULL,
    duracion_total INT NOT NULL CHECK (duracion_total > 0), -- en segundos
    ventas BIGINT DEFAULT 0 CHECK (ventas >= 0),
    INDEX idx_album_anio (anio_lanzamiento),
    INDEX idx_album_tipo (tipo),
    FOREIGN KEY (cod_banda) REFERENCES banda(cod_banda) ON DELETE CASCADE
);

/* Tabla: cancion */
CREATE TABLE cancion (
    cod_cancion VARCHAR(10) PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    duracion INT NOT NULL CHECK (duracion > 0), -- en segundos
    cod_album VARCHAR(10) NOT NULL,
    es_single BOOLEAN DEFAULT FALSE,
    letra_explicita BOOLEAN DEFAULT FALSE,
    INDEX idx_cancion_single (es_single),
    FOREIGN KEY (cod_album) REFERENCES album(cod_album) ON DELETE CASCADE
);

/* Tabla: contrato */
CREATE TABLE contrato (
    cod_banda VARCHAR(10),
    cod_disco VARCHAR(10),
    fecha_inicio DATE,
    fecha_fin DATE,
    tipo_contrato VARCHAR(50) NOT NULL,
    valor_contrato DECIMAL(12,2) NOT NULL CHECK (valor_contrato >= 0),
    PRIMARY KEY (cod_banda, cod_disco, fecha_inicio),
    INDEX idx_contrato_fechas (fecha_inicio, fecha_fin),
    FOREIGN KEY (cod_banda) REFERENCES banda(cod_banda) ON DELETE CASCADE,
    FOREIGN KEY (cod_disco) REFERENCES discografica(cod_disco) ON DELETE CASCADE,
    CONSTRAINT chk_contrato_fechas CHECK (fecha_fin >= fecha_inicio)
);

/* Tabla: integra */
CREATE TABLE integra (
    dni VARCHAR(15),
    cod_banda VARCHAR(10),
    fecha_entrada DATE,
    fecha_salida DATE NULL,
    instrumento VARCHAR(50) NOT NULL,
    es_fundador BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (dni, cod_banda, fecha_entrada),
    INDEX idx_integra_fechas (fecha_entrada, fecha_salida),
    FOREIGN KEY (dni) REFERENCES musico(dni) ON DELETE CASCADE,
    FOREIGN KEY (cod_banda) REFERENCES banda(cod_banda) ON DELETE CASCADE,
    CONSTRAINT chk_integra_fechas CHECK (fecha_salida IS NULL OR fecha_salida > fecha_entrada)
);

/* Tabla: actuacion */
CREATE TABLE actuacion (
    cod_banda VARCHAR(10),
    cod_festival VARCHAR(10),
    fecha_actuacion DATE,
    duracion_show INT NOT NULL CHECK (duracion_show > 0), -- en minutos
    orden_actuacion INT NOT NULL CHECK (orden_actuacion > 0),
    cachet DECIMAL(10,2) NOT NULL CHECK (cachet >= 0),
    PRIMARY KEY (cod_banda, cod_festival, fecha_actuacion),
    INDEX idx_actuacion_fecha (fecha_actuacion),
    FOREIGN KEY (cod_banda) REFERENCES banda(cod_banda) ON DELETE CASCADE,
    FOREIGN KEY (cod_festival) REFERENCES festival(cod_festival) ON DELETE CASCADE
);

/* Tabla: gira */
CREATE TABLE gira (
    cod_gira VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    cod_banda VARCHAR(10) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    numero_conciertos INT NOT NULL CHECK (numero_conciertos > 0),
    recaudacion_total DECIMAL(15,2) NOT NULL CHECK (recaudacion_total >= 0),
    INDEX idx_gira_fechas (fecha_inicio, fecha_fin),
    FOREIGN KEY (cod_banda) REFERENCES banda(cod_banda) ON DELETE CASCADE,
    CONSTRAINT chk_gira_fechas CHECK (fecha_fin >= fecha_inicio)
);

/* Tabla: premio */
CREATE TABLE premio (
    cod_premio VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    anio INT NOT NULL CHECK (anio >= 1950),
    categoria VARCHAR(100) NOT NULL,
    pais_premio VARCHAR(50) NOT NULL,
    valor_premio DECIMAL(10,2) DEFAULT 0 CHECK (valor_premio >= 0),
    cod_banda VARCHAR(10) NULL,
    cod_album VARCHAR(10) NULL,
    cod_cancion VARCHAR(10) NULL,
    INDEX idx_premio_anio (anio),
    FOREIGN KEY (cod_banda) REFERENCES banda(cod_banda) ON DELETE SET NULL,
    FOREIGN KEY (cod_album) REFERENCES album(cod_album) ON DELETE SET NULL,
    FOREIGN KEY (cod_cancion) REFERENCES cancion(cod_cancion) ON DELETE SET NULL
);

/* Tabla: critica */
CREATE TABLE critica (
    cod_critica VARCHAR(10) PRIMARY KEY,
    medio_comunicacion VARCHAR(100) NOT NULL,
    puntuacion DECIMAL(3,1) NOT NULL CHECK (puntuacion >= 0 AND puntuacion <= 10),
    cod_album VARCHAR(10) NOT NULL,
    fecha_critica DATE NOT NULL,
    critico VARCHAR(100) NOT NULL,
    pais_critico VARCHAR(50) NOT NULL,
    INDEX idx_critica_puntuacion (puntuacion),
    FOREIGN KEY (cod_album) REFERENCES album(cod_album) ON DELETE CASCADE
);

/* Tabla: colaboracion */
CREATE TABLE colaboracion (
    dni_musico1 VARCHAR(15),
    dni_musico2 VARCHAR(15),
    cod_cancion VARCHAR(10),
    tipo_colaboracion VARCHAR(50) NOT NULL,
    PRIMARY KEY (dni_musico1, dni_musico2, cod_cancion),
    FOREIGN KEY (dni_musico1) REFERENCES musico(dni) ON DELETE CASCADE,
    FOREIGN KEY (dni_musico2) REFERENCES musico(dni) ON DELETE CASCADE,
    FOREIGN KEY (cod_cancion) REFERENCES cancion(cod_cancion) ON DELETE CASCADE,
    CONSTRAINT chk_colaboracion_diferentes CHECK (dni_musico1 != dni_musico2)
);

/* INSERCIÓN DE DATOS */
/* ================================================================================ */

/* BANDAS */
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

/* MÚSICOS */
INSERT INTO musico VALUES
/* Metallica */
('US001', 'James', 'Hetfield', '1963-08-03', 'Estados Unidos', 'Guitarra'),
('US002', 'Lars', 'Ulrich', '1963-12-26', 'Dinamarca', 'Batería'),
('US003', 'Kirk', 'Hammett', '1962-11-18', 'Estados Unidos', 'Guitarra'),
('US004', 'Robert', 'Trujillo', '1964-10-23', 'Estados Unidos', 'Bajo'),
('US005', 'Cliff', 'Burton', '1962-02-10', 'Estados Unidos', 'Bajo'),
('US006', 'Jason', 'Newsted', '1963-03-04', 'Estados Unidos', 'Bajo'),
('US007', 'Dave', 'Mustaine', '1961-09-13', 'Estados Unidos', 'Guitarra'),

/* Iron Maiden */
('UK001', 'Bruce', 'Dickinson', '1958-08-07', 'Reino Unido', 'Voz'),
('UK002', 'Steve', 'Harris', '1956-03-12', 'Reino Unido', 'Bajo'),
('UK003', 'Dave', 'Murray', '1956-12-23', 'Reino Unido', 'Guitarra'),
('UK004', 'Adrian', 'Smith', '1957-02-27', 'Reino Unido', 'Guitarra'),
('UK005', 'Janick', 'Gers', '1957-01-27', 'Reino Unido', 'Guitarra'),
('UK006', 'Nicko', 'McBrain', '1952-06-05', 'Reino Unido', 'Batería'),
('UK007', 'Paul', 'Di Anno', '1958-05-17', 'Reino Unido', 'Voz'),

/* Black Sabbath */
('UK008', 'Tony', 'Iommi', '1948-02-19', 'Reino Unido', 'Guitarra'),
('UK009', 'Ozzy', 'Osbourne', '1948-12-03', 'Reino Unido', 'Voz'),
('UK010', 'Geezer', 'Butler', '1949-07-17', 'Reino Unido', 'Bajo'),
('UK011', 'Bill', 'Ward', '1948-05-05', 'Reino Unido', 'Batería'),

/* Megadeth */
('US008', 'David', 'Ellefson', '1964-11-12', 'Estados Unidos', 'Bajo'),
('US009', 'Marty', 'Friedman', '1962-12-08', 'Estados Unidos', 'Guitarra'),
('US010', 'Nick', 'Menza', '1964-07-23', 'Estados Unidos', 'Batería'),
('US011', 'Kiko', 'Loureiro', '1972-06-16', 'Brasil', 'Guitarra'),
('US012', 'Dirk', 'Verbeuren', '1975-01-17', 'Bélgica', 'Batería'),

/* AC/DC */
('AU001', 'Angus', 'Young', '1955-03-31', 'Australia', 'Guitarra'),
('AU002', 'Malcolm', 'Young', '1953-01-06', 'Australia', 'Guitarra'),
('AU003', 'Brian', 'Johnson', '1947-10-05', 'Reino Unido', 'Voz'),
('AU004', 'Phil', 'Rudd', '1954-05-19', 'Australia', 'Batería'),
('AU005', 'Cliff', 'Williams', '1949-12-14', 'Reino Unido', 'Bajo'),
('AU006', 'Bon', 'Scott', '1946-07-09', 'Australia', 'Voz'),

/* Deep Purple */
('UK012', 'Ian', 'Gillan', '1945-08-19', 'Reino Unido', 'Voz'),
('UK013', 'Ritchie', 'Blackmore', '1945-04-14', 'Reino Unido', 'Guitarra'),
('UK014', 'Jon', 'Lord', '1941-06-09', 'Reino Unido', 'Teclado'),
('UK015', 'Roger', 'Glover', '1945-11-30', 'Reino Unido', 'Bajo'),
('UK016', 'Ian', 'Paice', '1948-06-29', 'Reino Unido', 'Batería'),

/* Judas Priest */
('UK017', 'Rob', 'Halford', '1951-08-25', 'Reino Unido', 'Voz'),
('UK018', 'Glenn', 'Tipton', '1947-10-25', 'Reino Unido', 'Guitarra'),
('UK019', 'K.K.', 'Downing', '1951-10-27', 'Reino Unido', 'Guitarra'),
('UK020', 'Ian', 'Hill', '1951-01-20', 'Reino Unido', 'Bajo'),
('UK021', 'Scott', 'Travis', '1961-09-06', 'Estados Unidos', 'Batería'),

/* Slayer */
('US013', 'Tom', 'Araya', '1961-06-06', 'Chile', 'Bajo'),
('US014', 'Jeff', 'Hanneman', '1964-01-31', 'Estados Unidos', 'Guitarra'),
('US015', 'Kerry', 'King', '1964-06-03', 'Estados Unidos', 'Guitarra'),
('US016', 'Dave', 'Lombardo', '1965-02-16', 'Cuba', 'Batería'),

/* Motörhead */
('UK022', 'Lemmy', 'Kilmister', '1945-12-24', 'Reino Unido', 'Bajo'),
('UK023', 'Phil', 'Campbell', '1961-05-07', 'Reino Unido', 'Guitarra'),
('UK024', 'Mikkey', 'Dee', '1963-10-31', 'Suecia', 'Batería'),

/* Otros músicos */
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
('US025', 'Mike', 'Portnoy', '1967-04-20', 'Estados Unidos', 'Batería'),
('GE003', 'Jörg', 'Michael', '1963-04-27', 'Alemania', 'Batería'),
('GE004', 'Marcus', 'Grosskopf', '1965-09-21', 'Alemania', 'Bajo'),
('GE005', 'Michael', 'Weikath', '1962-08-07', 'Alemania', 'Guitarra'),
('GE006', 'Andi', 'Deris', '1964-08-18', 'Alemania', 'Voz'),
('BR003', 'Paulo', 'Jr.', '1969-04-30', 'Brasil', 'Bajo'),
('BR004', 'Andreas', 'Kisser', '1968-08-24', 'Brasil', 'Guitarra'),
('US026', 'Philip', 'Anselmo', '1968-06-30', 'Estados Unidos', 'Voz'),
('US027', 'Rex', 'Brown', '1964-07-27', 'Estados Unidos', 'Bajo'),
('US028', 'James', 'LaBrie', '1963-05-05', 'Canadá', 'Voz'),
('US029', 'John', 'Myung', '1967-01-24', 'Estados Unidos', 'Bajo'),
('US030', 'Jordan', 'Rudess', '1956-11-04', 'Estados Unidos', 'Teclado');

/* DISCOGRÁFICAS */
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

/* FESTIVALES */
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

/* ÁLBUMES */
INSERT INTO album VALUES
/* Metallica */
('ALB001', 'Master of Puppets', 1986, 'Estudio', 'BND001', 3279, 6000000),
('ALB002', 'Ride the Lightning', 1984, 'Estudio', 'BND001', 2984, 5000000),
('ALB003', 'Kill Em All', 1983, 'Estudio', 'BND001', 3060, 3000000),
('ALB004', 'Metallica (Black Album)', 1991, 'Estudio', 'BND001', 3858, 31000000),
('ALB005', 'Load', 1996, 'Estudio', 'BND001', 4760, 5000000),
('ALB006', 'S&M', 1999, 'En vivo', 'BND001', 8424, 2500000),

/* Iron Maiden */
('ALB007', 'The Number of the Beast', 1982, 'Estudio', 'BND002', 2388, 14000000),
('ALB008', 'Powerslave', 1984, 'Estudio', 'BND002', 3072, 4000000),
('ALB009', 'Piece of Mind', 1983, 'Estudio', 'BND002', 2711, 3500000),
('ALB010', 'Seventh Son of a Seventh Son', 1988, 'Estudio', 'BND002', 2745, 2000000),
('ALB011', 'Live After Death', 1985, 'En vivo', 'BND002', 6120, 2000000),

/* Black Sabbath */
('ALB012', 'Paranoid', 1970, 'Estudio', 'BND003', 2558, 4000000),
('ALB013', 'Master of Reality', 1971, 'Estudio', 'BND003', 2073, 2000000),
('ALB014', 'Vol. 4', 1972, 'Estudio', 'BND003', 2532, 1500000),
('ALB015', 'Black Sabbath', 1970, 'Estudio', 'BND003', 2278, 5000000),

/* Megadeth */
('ALB016', 'Peace Sells... but Whos Buying?', 1986, 'Estudio', 'BND004', 2175, 2000000),
('ALB017', 'Rust in Peace', 1990, 'Estudio', 'BND004', 2395, 2500000),
('ALB018', 'Countdown to Extinction', 1992, 'Estudio', 'BND004', 3413, 2000000),
('ALB019', 'Dystopia', 2016, 'Estudio', 'BND004', 2700, 500000),

/* AC/DC */
('ALB020', 'Back in Black', 1980, 'Estudio', 'BND005', 2534, 50000000),
('ALB021', 'Highway to Hell', 1979, 'Estudio', 'BND005', 2511, 20000000),
('ALB022', 'For Those About to Rock', 1981, 'Estudio', 'BND005', 2405, 4000000),
('ALB023', 'Live at River Plate', 2012, 'En vivo', 'BND005', 9120, 1000000),

/* Deep Purple */
('ALB024', 'Machine Head', 1972, 'Estudio', 'BND006', 2294, 3000000),
('ALB025', 'Deep Purple in Rock', 1970, 'Estudio', 'BND006', 2460, 2000000),
('ALB026', 'Made in Japan', 1972, 'En vivo', 'BND006', 4380, 2500000),

/* Judas Priest */
('ALB027', 'British Steel', 1980, 'Estudio', 'BND007', 2170, 2000000),
('ALB028', 'Screaming for Vengeance', 1982, 'Estudio', 'BND007', 2290, 1500000),
('ALB029', 'Painkiller', 1990, 'Estudio', 'BND007', 2985, 1000000),

/* Slayer */
('ALB030', 'Reign in Blood', 1986, 'Estudio', 'BND008', 1756, 2000000),
('ALB031', 'South of Heaven', 1988, 'Estudio', 'BND008', 2166, 1500000),
('ALB032', 'Seasons in the Abyss', 1990, 'Estudio', 'BND008', 2504, 1200000),

/* Motörhead */
('ALB033', 'Ace of Spades', 1980, 'Estudio', 'BND009', 2193, 1500000),
('ALB034', 'Overkill', 1979, 'Estudio', 'BND009', 2387, 1000000),
('ALB035', 'Bomber', 1979, 'Estudio', 'BND009', 2023, 800000),

/* Otros álbumes */
('ALB036', 'Holy Diver', 1983, 'Estudio', 'BND011', 2545, 2000000),
('ALB037', 'Blizzard of Ozz', 1980, 'Estudio', 'BND012', 2289, 5000000),
('ALB038', 'Among the Living', 1987, 'Estudio', 'BND013', 3165, 1000000),
('ALB039', 'The Legacy', 1987, 'Estudio', 'BND014', 2280, 500000),
('ALB040', 'Bonded by Blood', 1985, 'Estudio', 'BND015', 2275, 300000),
('ALB041', 'Keeper of the Seven Keys Part I', 1987, 'Estudio', 'BND024', 2634, 1000000),
('ALB042', 'Keeper of the Seven Keys Part II', 1988, 'Estudio', 'BND024', 3456, 1200000),
('ALB043', 'Chaos A.D.', 1993, 'Estudio', 'BND019', 2886, 2000000),
('ALB044', 'Cowboys from Hell', 1990, 'Estudio', 'BND020', 2270, 2000000),
('ALB045', 'Vulgar Display of Power', 1992, 'Estudio', 'BND020', 3168, 2500000),
('ALB046', 'Images and Words', 1992, 'Estudio', 'BND021', 3434, 2000000),
('ALB047', 'Metropolis Pt. 2: Scenes from a Memory', 1999, 'Estudio', 'BND021', 4677, 1500000),
('ALB048', 'Spreading the Disease', 1985, 'Estudio', 'BND013', 2289, 800000);

/* CANCIONES */
INSERT INTO cancion VALUES
/* Master of Puppets */
('CAN001', 'Battery', 312, 'ALB001', TRUE, FALSE),
('CAN002', 'Master of Puppets', 515, 'ALB001', TRUE, FALSE),
('CAN003', 'The Thing That Should Not Be', 396, 'ALB001', FALSE, FALSE),
('CAN004', 'Welcome Home (Sanitarium)', 387, 'ALB001', TRUE, FALSE),
('CAN005', 'Disposable Heroes', 496, 'ALB001', FALSE, TRUE),
('CAN006', 'Leper Messiah', 340, 'ALB001', FALSE, FALSE),
('CAN007', 'Orion', 508, 'ALB001', FALSE, FALSE),
('CAN008', 'Damage, Inc.', 329, 'ALB001', FALSE, TRUE),

/* The Number of the Beast */
('CAN009', 'Invaders', 203, 'ALB007', FALSE, FALSE),
('CAN010', 'Children of the Damned', 282, 'ALB007', FALSE, FALSE),
('CAN011', 'The Prisoner', 359, 'ALB007', FALSE, FALSE),
('CAN012', 'The Number of the Beast', 290, 'ALB007', TRUE, FALSE),
('CAN013', 'Run to the Hills', 228, 'ALB007', TRUE, FALSE),
('CAN014', 'Gangland', 227, 'ALB007', FALSE, FALSE),
('CAN015', 'Hallowed Be Thy Name', 432, 'ALB007', TRUE, FALSE),

/* Paranoid */
('CAN016', 'War Pigs', 466, 'ALB012', FALSE, TRUE),
('CAN017', 'Paranoid', 168, 'ALB012', TRUE, FALSE),
('CAN018', 'Planet Caravan', 263, 'ALB012', FALSE, FALSE),
('CAN019', 'Iron Man', 356, 'ALB012', TRUE, FALSE),
('CAN020', 'Electric Funeral', 289, 'ALB012', FALSE, FALSE),
('CAN021', 'Hand of Doom', 427, 'ALB012', FALSE, TRUE),
('CAN022', 'Rat Salad', 154, 'ALB012', FALSE, FALSE),
('CAN023', 'Fairies Wear Boots', 375, 'ALB012', FALSE, FALSE),

/* Back in Black */
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

/* Reign in Blood */
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

/* Más canciones */
('CAN044', 'Ace of Spades', 169, 'ALB033', TRUE, FALSE),
('CAN045', 'Holy Diver', 341, 'ALB036', TRUE, FALSE),
('CAN046', 'Crazy Train', 233, 'ALB037', TRUE, FALSE),
('CAN047', 'Among the Living', 317, 'ALB038', TRUE, FALSE),
('CAN048', 'Over the Wall', 246, 'ALB039', FALSE, FALSE),
('CAN049', 'Bonded by Blood', 202, 'ALB040', TRUE, TRUE),
('CAN050', 'Breaking the Law', 155, 'ALB027', TRUE, FALSE),
('CAN051', 'I Want Out', 265, 'ALB041', TRUE, FALSE),
('CAN052', 'Keeper of the Seven Keys', 830, 'ALB042', FALSE, FALSE),
('CAN053', 'Territory', 279, 'ALB043', TRUE, FALSE),
('CAN054', 'Cowboys from Hell', 246, 'ALB044', TRUE, FALSE),
('CAN055', 'Walk', 316, 'ALB045', TRUE, FALSE),
('CAN056', 'Pull Me Under', 498, 'ALB046', TRUE, FALSE),
('CAN057', 'The Dance of Eternity', 388, 'ALB047', FALSE, FALSE),
('CAN058', 'Madhouse', 252, 'ALB048', TRUE, FALSE);

/* CONTRATOS */
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

/* INTEGRA (Miembros de bandas) */
INSERT INTO integra VALUES
/* Metallica */
('US001', 'BND001', '1981-10-28', NULL, 'Guitarra', TRUE),
('US002', 'BND001', '1981-10-28', NULL, 'Batería', TRUE),
('US003', 'BND001', '1983-04-01', NULL, 'Guitarra', FALSE),
('US004', 'BND001', '2003-02-24', NULL, 'Bajo', FALSE),
('US005', 'BND001', '1982-10-01', '1986-09-27', 'Bajo', FALSE),
('US006', 'BND001', '1986-10-28', '2001-01-17', 'Bajo', FALSE),
('US007', 'BND001', '1981-10-28', '1983-04-11', 'Guitarra', TRUE),

/* Iron Maiden */
('UK001', 'BND002', '1981-02-01', NULL, 'Voz', FALSE),
('UK002', 'BND002', '1975-12-25', NULL, 'Bajo', TRUE),
('UK003', 'BND002', '1976-12-01', NULL, 'Guitarra', FALSE),
('UK004', 'BND002', '1980-01-01', '1990-01-01', 'Guitarra', FALSE),
('UK004', 'BND002', '1999-02-01', NULL, 'Guitarra', FALSE),
('UK005', 'BND002', '1990-01-01', NULL, 'Guitarra', FALSE),
('UK006', 'BND002', '1982-01-01', NULL, 'Batería', FALSE),
('UK007', 'BND002', '1978-05-01', '1981-02-01', 'Voz', FALSE),

/* Black Sabbath */
('UK008', 'BND003', '1968-01-01', NULL, 'Guitarra', TRUE),
('UK009', 'BND003', '1968-01-01', '1979-04-01', 'Voz', TRUE),
('UK009', 'BND003', '1997-06-01', '2017-02-04', 'Voz', TRUE),
('UK010', 'BND003', '1968-01-01', NULL, 'Bajo', TRUE),
('UK011', 'BND003', '1968-01-01', '1980-01-01', 'Batería', TRUE),

/* Megadeth */
('US007', 'BND004', '1983-05-01', NULL, 'Guitarra', TRUE),
('US008', 'BND004', '1983-11-01', '2002-02-01', 'Bajo', FALSE),
('US008', 'BND004', '2010-02-01', '2021-05-14', 'Bajo', FALSE),
('US009', 'BND004', '1990-02-01', '2000-01-01', 'Guitarra', FALSE),
('US010', 'BND004', '1989-01-01', '1998-07-01', 'Batería', FALSE),
('US011', 'BND004', '2015-04-01', NULL, 'Guitarra', FALSE),
('US012', 'BND004', '2016-07-01', NULL, 'Batería', FALSE),

/* AC/DC */
('AU001', 'BND005', '1973-11-01', NULL, 'Guitarra', TRUE),
('AU002', 'BND005', '1973-11-01', '2014-09-01', 'Guitarra', TRUE),
('AU003', 'BND005', '1980-03-01', NULL, 'Voz', FALSE),
('AU004', 'BND005', '1975-01-01', '1983-01-01', 'Batería', FALSE),
('AU004', 'BND005', '1994-09-01', '2015-11-01', 'Batería', FALSE),
('AU005', 'BND005', '1977-06-01', '2016-07-01', 'Bajo', FALSE),
('AU006', 'BND005', '1974-09-01', '1980-02-19', 'Voz', FALSE),

/* Deep Purple */
('UK012', 'BND006', '1969-06-01', '1973-06-01', 'Voz', FALSE),
('UK012', 'BND006', '1984-04-01', '1989-01-01', 'Voz', FALSE),
('UK012', 'BND006', '1992-01-01', NULL, 'Voz', FALSE),
('UK013', 'BND006', '1968-04-01', '1975-06-01', 'Guitarra', FALSE),
('UK013', 'BND006', '1984-04-01', '1993-01-01', 'Guitarra', FALSE),
('UK014', 'BND006', '1968-04-01', '2002-07-16', 'Teclado', TRUE),
('UK015', 'BND006', '1969-06-01', NULL, 'Bajo', FALSE),
('UK016', 'BND006', '1968-04-01', NULL, 'Batería', TRUE),

/* Judas Priest */
('UK017', 'BND007', '1973-05-01', '1992-05-01', 'Voz', FALSE),
('UK017', 'BND007', '2003-07-01', NULL, 'Voz', FALSE),
('UK018', 'BND007', '1974-01-01', NULL, 'Guitarra', FALSE),
('UK019', 'BND007', '1970-01-01', '2011-04-01', 'Guitarra', FALSE),
('UK020', 'BND007', '1970-01-01', NULL, 'Bajo', TRUE),
('UK021', 'BND007', '1989-08-01', NULL, 'Batería', FALSE),

/* Slayer */
('US013', 'BND008', '1981-01-01', NULL, 'Bajo', FALSE),
('US014', 'BND008', '1981-01-01', '2013-05-02', 'Guitarra', TRUE),
('US015', 'BND008', '1981-01-01', NULL, 'Guitarra', TRUE),
('US016', 'BND008', '1981-01-01', '1986-01-01', 'Batería', FALSE),
('US016', 'BND008', '1987-01-01', '1992-01-01', 'Batería', FALSE),
('US016', 'BND008', '2001-01-01', '2013-01-01', 'Batería', FALSE),

/* Motörhead */
('UK022', 'BND009', '1975-06-01', '2015-12-28', 'Bajo', TRUE),
('UK023', 'BND009', '1984-05-01', NULL, 'Guitarra', FALSE),
('UK024', 'BND009', '1992-09-01', NULL, 'Batería', FALSE),

/* Helloween */
('GE002', 'BND024', '1984-01-01', '1989-01-01', 'Guitarra', TRUE),
('GE005', 'BND024', '1982-01-01', NULL, 'Guitarra', TRUE),
('GE006', 'BND024', '1994-01-01', NULL, 'Voz', FALSE),
('GE003', 'BND024', '1994-01-01', '2016-01-01', 'Batería', FALSE),
('GE004', 'BND024', '1982-01-01', NULL, 'Bajo', FALSE),

/* Sepultura */
('BR001', 'BND019', '1984-01-01', '1996-12-01', 'Guitarra', TRUE),
('BR002', 'BND019', '1984-01-01', '2006-06-01', 'Batería', TRUE),
('BR003', 'BND019', '1984-01-01', NULL, 'Bajo', FALSE),
('BR004', 'BND019', '1987-01-01', NULL, 'Guitarra', FALSE),

/* Pantera */
('US022', 'BND020', '1982-01-01', '2004-12-08', 'Guitarra', FALSE),
('US023', 'BND020', '1982-01-01', '2018-06-22', 'Batería', FALSE),
('US026', 'BND020', '1987-01-01', '2003-01-01', 'Voz', FALSE),
('US027', 'BND020', '1982-01-01', '2003-01-01', 'Bajo', FALSE),

/* Dream Theater */
('US024', 'BND021', '1985-01-01', NULL, 'Guitarra', TRUE),
('US025', 'BND021', '1985-01-01', '2010-09-08', 'Batería', TRUE),
('US028', 'BND021', '1991-01-01', NULL, 'Voz', FALSE),
('US029', 'BND021', '1985-01-01', NULL, 'Bajo', TRUE),
('US030', 'BND021', '1999-07-26', NULL, 'Teclado', FALSE),

/* Anthrax */
('US020', 'BND013', '1981-07-01', NULL, 'Guitarra', TRUE),
('US021', 'BND013', '1983-01-01', NULL, 'Batería', FALSE);

/* ACTUACIONES EN FESTIVALES */
INSERT INTO actuacion VALUES
/* Wacken Open Air 2023 */
('BND001', 'FEST001', '2023-08-04', 120, 1, 500000.00),
('BND002', 'FEST001', '2023-08-03', 110, 1, 400000.00),
('BND004', 'FEST001', '2023-08-03', 90, 3, 200000.00),
('BND007', 'FEST001', '2023-08-04', 100, 2, 150000.00),
('BND016', 'FEST001', '2023-08-02', 80, 4, 100000.00),

/* Download Festival 2023 */
('BND002', 'FEST002', '2023-06-11', 150, 1, 800000.00),
('BND001', 'FEST002', '2023-06-10', 130, 1, 750000.00),
('BND005', 'FEST002', '2023-06-09', 110, 1, 600000.00),
('BND007', 'FEST002', '2023-06-10', 100, 3, 300000.00),
('BND012', 'FEST002', '2023-06-09', 90, 4, 250000.00),

/* Hellfest 2023 */
('BND001', 'FEST003', '2023-06-25', 140, 1, 600000.00),
('BND008', 'FEST003', '2023-06-24', 90, 2, 300000.00),
('BND009', 'FEST003', '2023-06-23', 85, 3, 200000.00),
('BND016', 'FEST003', '2023-06-22', 80, 4, 150000.00),
('BND019', 'FEST003', '2023-06-21', 75, 5, 100000.00),

/* Sweden Rock Festival 2023 */
('BND006', 'FEST005', '2023-06-10', 120, 1, 300000.00),
('BND002', 'FEST005', '2023-06-09', 110, 1, 400000.00),
('BND007', 'FEST005', '2023-06-08', 100, 2, 200000.00),
('BND005', 'FEST005', '2023-06-07', 95, 3, 350000.00),

/* Rock am Ring 2023 */
('BND001', 'FEST006', '2023-06-04', 135, 1, 700000.00),
('BND004', 'FEST006', '2023-06-03', 100, 2, 300000.00),
('BND013', 'FEST006', '2023-06-02', 85, 4, 150000.00),

/* Graspop Metal Meeting 2023 */
('BND002', 'FEST007', '2023-06-18', 130, 1, 500000.00),
('BND001', 'FEST007', '2023-06-17', 125, 1, 550000.00),
('BND007', 'FEST007', '2023-06-16', 95, 3, 250000.00),
('BND008', 'FEST007', '2023-06-15', 85, 4, 200000.00),

/* Rock in Rio 2022 */
('BND002', 'FEST009', '2022-09-11', 140, 1, 800000.00),
('BND001', 'FEST009', '2022-09-08', 130, 1, 750000.00),
('BND019', 'FEST009', '2022-09-04', 90, 3, 200000.00),

/* Copenhell 2023 */
('BND001', 'FEST011', '2023-06-17', 120, 1, 400000.00),
('BND002', 'FEST011', '2023-06-16', 110, 1, 350000.00),
('BND016', 'FEST011', '2023-06-15', 80, 3, 120000.00),

/* Resurrection Fest 2023 */
('BND001', 'FEST012', '2023-07-01', 125, 1, 300000.00),
('BND008', 'FEST012', '2023-06-30', 90, 2, 150000.00),
('BND013', 'FEST012', '2023-06-29', 85, 3, 100000.00),

/* ProgPower USA 2023 */
('BND021', 'FEST015', '2023-09-09', 120, 1, 50000.00),
('BND022', 'FEST015', '2023-09-08', 110, 2, 40000.00),
('BND024', 'FEST015', '2023-09-07', 100, 3, 35000.00);

/* GIRAS */
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

/* PREMIOS */
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
('PREM020', 'Wacken Metal Battle', 2018, 'Legend Award', 'Alemania', 0, 'BND016', NULL, NULL),
('PREM021', 'Metal Hammer Golden Gods', 2019, 'Best Album', 'Reino Unido', 0, 'BND024', 'ALB042', NULL),
('PREM022', 'Roadrunner Records Award', 1994, 'Best Metal Album', 'Holanda', 0, 'BND019', 'ALB043', NULL),
('PREM023', 'Metal Edge Award', 1993, 'Album of the Year', 'Estados Unidos', 0, 'BND020', 'ALB045', NULL),
('PREM024', 'Progressive Music Award', 2000, 'Best Concept Album', 'Reino Unido', 0, 'BND021', 'ALB047', NULL),
('PREM025', 'MTV Headbangers Ball', 1993, 'Best Video', 'Estados Unidos', 0, 'BND021', 'ALB046', 'CAN056');

/* CRÍTICAS */
INSERT INTO critica VALUES
/* Master of Puppets */
('CRIT001', 'Rolling Stone', 9.2, 'ALB001', '1986-03-15', 'David Fricke', 'Estados Unidos'),
('CRIT002', 'Kerrang!', 9.5, 'ALB001', '1986-03-10', 'Geoff Barton', 'Reino Unido'),
('CRIT003', 'Metal Hammer', 9.8, 'ALB001', '1986-03-20', 'Malcolm Dome', 'Reino Unido'),
('CRIT004', 'AllMusic', 9.0, 'ALB001', '1986-04-01', 'Steve Huey', 'Estados Unidos'),

/* The Number of the Beast */
('CRIT005', 'Kerrang!', 9.7, 'ALB007', '1982-03-25', 'Geoff Barton', 'Reino Unido'),
('CRIT006', 'Rolling Stone', 8.8, 'ALB007', '1982-04-02', 'Kurt Loder', 'Estados Unidos'),
('CRIT007', 'Metal Forces', 9.5, 'ALB007', '1982-04-10', 'Bernard Doe', 'Reino Unido'),
('CRIT008', 'Sounds', 9.2, 'ALB007', '1982-03-30', 'Dante Bonutto', 'Reino Unido'),

/* Paranoid */
('CRIT009', 'Rolling Stone', 8.5, 'ALB012', '1970-09-25', 'Lester Bangs', 'Estados Unidos'),
('CRIT010', 'NME', 8.8, 'ALB012', '1970-09-30', 'Roy Carr', 'Reino Unido'),
('CRIT011', 'Melody Maker', 9.0, 'ALB012', '1970-09-28', 'Chris Welch', 'Reino Unido'),

/* Back in Black */
('CRIT012', 'Rolling Stone', 9.3, 'ALB020', '1980-07-30', 'David Fricke', 'Estados Unidos'),
('CRIT013', 'Kerrang!', 9.6, 'ALB020', '1980-08-05', 'Geoff Barton', 'Reino Unido'),
('CRIT014', 'Sounds', 9.4, 'ALB020', '1980-08-02', 'Pete Makowski', 'Reino Unido'),
('CRIT015', 'Circus', 9.1, 'ALB020', '1980-08-10', 'Jon Young', 'Estados Unidos'),

/* Reign in Blood */
('CRIT016', 'Kerrang!', 9.8, 'ALB030', '1986-10-15', 'Malcolm Dome', 'Reino Unido'),
('CRIT017', 'Metal Forces', 9.9, 'ALB030', '1986-10-20', 'Bernard Doe', 'Reino Unido'),
('CRIT018', 'Thrasher', 9.7, 'ALB030', '1986-10-25', 'Brian Slagel', 'Estados Unidos'),
('CRIT019', 'AllMusic', 9.5, 'ALB030', '1986-11-01', 'Steve Huey', 'Estados Unidos'),

/* Más críticas */
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
('CRIT030', 'Pitchfork', 7.8, 'ALB004', '1991-08-15', 'Andy OConnor', 'Estados Unidos'),
('CRIT031', 'Metal Hammer', 9.1, 'ALB041', '1987-11-15', 'Malcolm Dome', 'Reino Unido'),
('CRIT032', 'Kerrang!', 9.3, 'ALB042', '1988-05-20', 'Geoff Barton', 'Reino Unido'),
('CRIT033', 'Rolling Stone', 8.4, 'ALB043', '1993-10-25', 'David Fricke', 'Estados Unidos'),
('CRIT034', 'Metal Hammer', 8.9, 'ALB044', '1990-07-30', 'Malcolm Dome', 'Reino Unido'),
('CRIT035', 'Revolver', 9.5, 'ALB045', '1992-02-28', 'Jon Wiederhorn', 'Estados Unidos'),
('CRIT036', 'Prog Magazine', 9.7, 'ALB046', '1992-06-15', 'Jerry Ewing', 'Reino Unido'),
('CRIT037', 'Guitar World', 9.8, 'ALB047', '1999-10-30', 'Brad Tolinski', 'Estados Unidos'),
('CRIT038', 'Thrasher', 8.7, 'ALB048', '1985-10-15', 'Brian Slagel', 'Estados Unidos');

/* COLABORACIONES */
INSERT INTO colaboracion VALUES
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
('BR001', 'US022', 'CAN047', 'Fusión estilos'),
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

/* ================================================================================ */

/* ================================================================================ */
/* Lote masivo 2025: nuevas bandas y datos adicionales */
/* ================================================================================ */
INSERT INTO banda VALUES
('BND026', 'Lacuna Coil', 'Italia', 1994, 'Gothic Metal', TRUE),
('BND027', 'Nightwish', 'Finlandia', 1996, 'Symphonic Metal', TRUE),
('BND028', 'Within Temptation', 'Países Bajos', 1996, 'Symphonic Metal', TRUE),
('BND029', 'Epica', 'Países Bajos', 2002, 'Symphonic Metal', TRUE),
('BND030', 'Kamelot', 'Estados Unidos', 1991, 'Power Metal', TRUE),
('BND031', 'Sabaton', 'Suecia', 1999, 'Power Metal', TRUE),
('BND032', 'Avantasia', 'Alemania', 2001, 'Power Metal', TRUE),
('BND033', 'Trivium', 'Estados Unidos', 1999, 'Metalcore', TRUE),
('BND034', 'Gojira', 'Francia', 1996, 'Progressive Death Metal', TRUE),
('BND035', 'Mastodon', 'Estados Unidos', 2000, 'Progressive Sludge Metal', TRUE),
('BND036', 'Opeth', 'Suecia', 1990, 'Progressive Metal', TRUE),
('BND037', 'Lamb of God', 'Estados Unidos', 1994, 'Groove Metal', TRUE),
('BND038', 'Parkway Drive', 'Australia', 2003, 'Metalcore', TRUE),
('BND039', 'Architects', 'Reino Unido', 2004, 'Metalcore', TRUE),
('BND040', 'Jinjer', 'Ucrania', 2009, 'Progressive Metalcore', TRUE),
('BND041', 'Spiritbox', 'Canadá', 2017, 'Progressive Metalcore', TRUE),
('BND042', 'Babymetal', 'Japón', 2010, 'Kawaii Metal', TRUE),
('BND043', 'Powerwolf', 'Alemania', 2003, 'Power Metal', TRUE),
('BND044', 'Ghost', 'Suecia', 2006, 'Heavy Metal', TRUE),
('BND045', 'Tesseract', 'Reino Unido', 2003, 'Progressive Metal', TRUE),
('BND046', 'Polaris', 'Australia', 2012, 'Metalcore', TRUE),
('BND047', 'Soen', 'Suecia', 2010, 'Progressive Metal', TRUE),
('BND048', 'Leprous', 'Noruega', 2001, 'Progressive Metal', TRUE),
('BND049', 'Katatonia', 'Suecia', 1991, 'Progressive Doom Metal', TRUE),
('BND050', 'The Hu', 'Mongolia', 2016, 'Folk Metal', TRUE);
INSERT INTO musico VALUES
('NB001', 'Aisha', 'Almeida', '1970-01-01', 'Italia', 'Voz'),
('NB002', 'Bruno', 'Berg', '1975-02-02', 'Reino Unido', 'Guitarra'),
('NB003', 'Claudia', 'Carver', '1980-03-03', 'Italia', 'Bajo'),
('NB004', 'Dorian', 'Delacroix', '1985-04-04', 'Canadá', 'Batería'),
('NB005', 'Elena', 'Estevez', '1990-05-05', 'Italia', 'Teclado'),
('NB006', 'Bruno', 'Delacroix', '1974-01-02', 'Finlandia', 'Voz'),
('NB007', 'Claudia', 'Estevez', '1979-02-03', 'Suecia', 'Guitarra'),
('NB008', 'Dorian', 'Fowler', '1984-03-04', 'Finlandia', 'Bajo'),
('NB009', 'Elena', 'Grimm', '1989-04-05', 'Alemania', 'Batería'),
('NB010', 'Fabian', 'Holm', '1994-05-06', 'Finlandia', 'Teclado'),
('NB011', 'Claudia', 'Grimm', '1978-01-03', 'Países Bajos', 'Voz'),
('NB012', 'Dorian', 'Holm', '1983-02-04', 'Canadá', 'Guitarra'),
('NB013', 'Elena', 'Ivanov', '1988-03-05', 'Países Bajos', 'Bajo'),
('NB014', 'Fabian', 'Johansen', '1993-04-06', 'Australia', 'Batería'),
('NB015', 'Greta', 'Klein', '1998-05-07', 'Países Bajos', 'Teclado'),
('NB016', 'Dorian', 'Johansen', '1982-01-04', 'Países Bajos', 'Voz'),
('NB017', 'Elena', 'Klein', '1987-02-05', 'Alemania', 'Guitarra'),
('NB018', 'Fabian', 'Lopez', '1992-03-06', 'Países Bajos', 'Bajo'),
('NB019', 'Greta', 'Mori', '1997-04-07', 'Japón', 'Batería'),
('NB020', 'Hugo', 'Novak', '1972-05-08', 'Países Bajos', 'Teclado'),
('NB021', 'Elena', 'Mori', '1986-01-05', 'Estados Unidos', 'Voz'),
('NB022', 'Fabian', 'Novak', '1991-02-06', 'Australia', 'Guitarra'),
('NB023', 'Greta', 'Olsen', '1996-03-07', 'Estados Unidos', 'Bajo'),
('NB024', 'Hugo', 'Petrov', '1971-04-08', 'Brasil', 'Batería'),
('NB025', 'Ingrid', 'Quint', '1976-05-09', 'Estados Unidos', 'Teclado'),
('NB026', 'Fabian', 'Petrov', '1990-01-06', 'Suecia', 'Voz'),
('NB027', 'Greta', 'Quint', '1995-02-07', 'Japón', 'Guitarra'),
('NB028', 'Hugo', 'Rossetti', '1970-03-08', 'Suecia', 'Bajo'),
('NB029', 'Ingrid', 'Sato', '1975-04-09', 'Estados Unidos', 'Batería'),
('NB030', 'Jonas', 'Tavares', '1980-05-10', 'Suecia', 'Teclado'),
('NB031', 'Greta', 'Sato', '1994-01-07', 'Alemania', 'Voz'),
('NB032', 'Hugo', 'Tavares', '1999-02-08', 'Brasil', 'Guitarra'),
('NB033', 'Ingrid', 'Urban', '1974-03-09', 'Alemania', 'Bajo'),
('NB034', 'Jonas', 'Valdez', '1979-04-10', 'Reino Unido', 'Batería'),
('NB035', 'Kara', 'White', '1984-05-11', 'Alemania', 'Teclado'),
('NB036', 'Hugo', 'Valdez', '1998-01-08', 'Estados Unidos', 'Voz'),
('NB037', 'Ingrid', 'White', '1973-02-09', 'Estados Unidos', 'Guitarra'),
('NB038', 'Jonas', 'Xu', '1978-03-10', 'Estados Unidos', 'Bajo'),
('NB039', 'Kara', 'Young', '1983-04-11', 'Suecia', 'Batería'),
('NB040', 'Liam', 'Zimmer', '1988-05-12', 'Estados Unidos', 'Teclado'),
('NB041', 'Ingrid', 'Young', '1972-01-09', 'Francia', 'Voz'),
('NB042', 'Jonas', 'Zimmer', '1977-02-10', 'Reino Unido', 'Guitarra'),
('NB043', 'Kara', 'Almeida', '1982-03-11', 'Francia', 'Bajo'),
('NB044', 'Liam', 'Berg', '1987-04-12', 'Canadá', 'Batería'),
('NB045', 'Mila', 'Carver', '1992-05-13', 'Francia', 'Teclado'),
('NB046', 'Jonas', 'Berg', '1976-01-10', 'Estados Unidos', 'Voz'),
('NB047', 'Kara', 'Carver', '1981-02-11', 'Suecia', 'Guitarra'),
('NB048', 'Liam', 'Delacroix', '1986-03-12', 'Estados Unidos', 'Bajo'),
('NB049', 'Mila', 'Estevez', '1991-04-13', 'Alemania', 'Batería'),
('NB050', 'Noah', 'Fowler', '1996-05-14', 'Estados Unidos', 'Teclado'),
('NB051', 'Kara', 'Estevez', '1980-01-11', 'Suecia', 'Voz'),
('NB052', 'Liam', 'Fowler', '1985-02-12', 'Canadá', 'Guitarra'),
('NB053', 'Mila', 'Grimm', '1990-03-13', 'Suecia', 'Bajo'),
('NB054', 'Noah', 'Holm', '1995-04-14', 'Australia', 'Batería'),
('NB055', 'Olivia', 'Ivanov', '1970-05-15', 'Suecia', 'Teclado'),
('NB056', 'Liam', 'Holm', '1984-01-12', 'Estados Unidos', 'Voz'),
('NB057', 'Mila', 'Ivanov', '1989-02-13', 'Alemania', 'Guitarra'),
('NB058', 'Noah', 'Johansen', '1994-03-14', 'Estados Unidos', 'Bajo'),
('NB059', 'Olivia', 'Klein', '1999-04-15', 'Japón', 'Batería'),
('NB060', 'Paolo', 'Lopez', '1974-05-16', 'Estados Unidos', 'Teclado'),
('NB061', 'Mila', 'Klein', '1988-01-13', 'Australia', 'Voz'),
('NB062', 'Noah', 'Lopez', '1993-02-14', 'Australia', 'Guitarra'),
('NB063', 'Olivia', 'Mori', '1998-03-15', 'Australia', 'Bajo'),
('NB064', 'Paolo', 'Novak', '1973-04-16', 'Brasil', 'Batería'),
('NB065', 'Quentin', 'Olsen', '1978-05-17', 'Australia', 'Teclado'),
('NB066', 'Noah', 'Novak', '1992-01-14', 'Reino Unido', 'Voz'),
('NB067', 'Olivia', 'Olsen', '1997-02-15', 'Japón', 'Guitarra'),
('NB068', 'Paolo', 'Petrov', '1972-03-16', 'Reino Unido', 'Bajo'),
('NB069', 'Quentin', 'Quint', '1977-04-17', 'Estados Unidos', 'Batería'),
('NB070', 'Rina', 'Rossetti', '1982-05-18', 'Reino Unido', 'Teclado'),
('NB071', 'Olivia', 'Quint', '1996-01-15', 'Ucrania', 'Voz'),
('NB072', 'Paolo', 'Rossetti', '1971-02-16', 'Brasil', 'Guitarra'),
('NB073', 'Quentin', 'Sato', '1976-03-17', 'Ucrania', 'Bajo'),
('NB074', 'Rina', 'Tavares', '1981-04-18', 'Reino Unido', 'Batería'),
('NB075', 'Sergio', 'Urban', '1986-05-19', 'Ucrania', 'Teclado'),
('NB076', 'Paolo', 'Tavares', '1970-01-16', 'Canadá', 'Voz'),
('NB077', 'Quentin', 'Urban', '1975-02-17', 'Estados Unidos', 'Guitarra'),
('NB078', 'Rina', 'Valdez', '1980-03-18', 'Canadá', 'Bajo'),
('NB079', 'Sergio', 'White', '1985-04-19', 'Suecia', 'Batería'),
('NB080', 'Talia', 'Xu', '1990-05-20', 'Canadá', 'Teclado'),
('NB081', 'Quentin', 'White', '1974-01-17', 'Japón', 'Voz'),
('NB082', 'Rina', 'Xu', '1979-02-18', 'Reino Unido', 'Guitarra'),
('NB083', 'Sergio', 'Young', '1984-03-19', 'Japón', 'Bajo'),
('NB084', 'Talia', 'Zimmer', '1989-04-20', 'Canadá', 'Batería'),
('NB085', 'Uma', 'Almeida', '1994-05-21', 'Japón', 'Teclado'),
('NB086', 'Rina', 'Zimmer', '1978-01-18', 'Alemania', 'Voz'),
('NB087', 'Sergio', 'Almeida', '1983-02-19', 'Suecia', 'Guitarra'),
('NB088', 'Talia', 'Berg', '1988-03-20', 'Alemania', 'Bajo'),
('NB089', 'Uma', 'Carver', '1993-04-21', 'Alemania', 'Batería'),
('NB090', 'Viktor', 'Delacroix', '1998-05-22', 'Alemania', 'Teclado'),
('NB091', 'Sergio', 'Carver', '1982-01-19', 'Suecia', 'Voz'),
('NB092', 'Talia', 'Delacroix', '1987-02-20', 'Canadá', 'Guitarra'),
('NB093', 'Uma', 'Estevez', '1992-03-21', 'Suecia', 'Bajo'),
('NB094', 'Viktor', 'Fowler', '1997-04-22', 'Australia', 'Batería'),
('NB095', 'Willow', 'Grimm', '1972-05-23', 'Suecia', 'Teclado'),
('NB096', 'Talia', 'Fowler', '1986-01-20', 'Reino Unido', 'Voz'),
('NB097', 'Uma', 'Grimm', '1991-02-21', 'Alemania', 'Guitarra'),
('NB098', 'Viktor', 'Holm', '1996-03-22', 'Reino Unido', 'Bajo'),
('NB099', 'Willow', 'Ivanov', '1971-04-23', 'Japón', 'Batería'),
('NB100', 'Xavier', 'Johansen', '1976-05-24', 'Reino Unido', 'Teclado'),
('NB101', 'Uma', 'Ivanov', '1990-01-21', 'Australia', 'Voz'),
('NB102', 'Viktor', 'Johansen', '1995-02-22', 'Australia', 'Guitarra'),
('NB103', 'Willow', 'Klein', '1970-03-23', 'Australia', 'Bajo'),
('NB104', 'Xavier', 'Lopez', '1975-04-24', 'Brasil', 'Batería'),
('NB105', 'Yuri', 'Mori', '1980-05-25', 'Australia', 'Teclado'),
('NB106', 'Viktor', 'Lopez', '1994-01-22', 'Suecia', 'Voz'),
('NB107', 'Willow', 'Mori', '1999-02-23', 'Japón', 'Guitarra'),
('NB108', 'Xavier', 'Novak', '1974-03-24', 'Suecia', 'Bajo'),
('NB109', 'Yuri', 'Olsen', '1979-04-25', 'Estados Unidos', 'Batería'),
('NB110', 'Zara', 'Petrov', '1984-05-26', 'Suecia', 'Teclado'),
('NB111', 'Willow', 'Olsen', '1998-01-23', 'Noruega', 'Voz'),
('NB112', 'Xavier', 'Petrov', '1973-02-24', 'Brasil', 'Guitarra'),
('NB113', 'Yuri', 'Quint', '1978-03-25', 'Noruega', 'Bajo'),
('NB114', 'Zara', 'Rossetti', '1983-04-26', 'Reino Unido', 'Batería'),
('NB115', 'Aisha', 'Sato', '1988-05-27', 'Noruega', 'Teclado'),
('NB116', 'Xavier', 'Rossetti', '1972-01-24', 'Suecia', 'Voz'),
('NB117', 'Yuri', 'Sato', '1977-02-25', 'Estados Unidos', 'Guitarra'),
('NB118', 'Zara', 'Tavares', '1982-03-26', 'Suecia', 'Bajo'),
('NB119', 'Aisha', 'Urban', '1987-04-27', 'Suecia', 'Batería'),
('NB120', 'Bruno', 'Valdez', '1992-05-28', 'Suecia', 'Teclado'),
('NB121', 'Yuri', 'Urban', '1976-01-25', 'Mongolia', 'Voz'),
('NB122', 'Zara', 'Valdez', '1981-02-26', 'Reino Unido', 'Guitarra'),
('NB123', 'Aisha', 'White', '1986-03-27', 'Mongolia', 'Bajo'),
('NB124', 'Bruno', 'Xu', '1991-04-28', 'Canadá', 'Batería'),
('NB125', 'Claudia', 'Young', '1996-05-01', 'Mongolia', 'Teclado');
INSERT INTO discografica VALUES
('DISC016', 'Napalm Records', 'Austria', 1992, 'Symphonic Metal, Power Metal'),
('DISC017', 'Kscope', 'Reino Unido', 2008, 'Progressive Rock, Progressive Metal'),
('DISC018', 'Rise Records', 'Estados Unidos', 1991, 'Metalcore, Post-hardcore'),
('DISC019', 'Peaceville Records', 'Reino Unido', 1987, 'Doom Metal, Extreme Metal'),
('DISC020', 'Eleven Seven', 'Estados Unidos', 2006, 'Alternative Metal, Hard Rock');
INSERT INTO festival VALUES
('FEST016', 'ArcTanGent', 'Reino Unido', '2023-08-17', '2023-08-19', 15000, 'Math Rock, Progressive Metal'),
('FEST017', '70,000 Tons of Metal', 'Internacional', '2023-01-30', '2023-02-03', 3000, 'Power Metal, Progressive Metal'),
('FEST018', 'Summer Breeze', 'Alemania', '2023-08-16', '2023-08-19', 45000, 'Extreme Metal, Power Metal'),
('FEST019', 'Vive Latino Metal', 'México', '2023-03-18', '2023-03-19', 90000, 'Latin Metal, Rock Fusión'),
('FEST020', 'Gothic Wave', 'Rumanía', '2023-10-05', '2023-10-08', 10000, 'Gothic Metal, Symphonic Metal');
INSERT INTO album VALUES
('ALB200', 'Lacuna Coil Chronicles Vol. 1', 1998, 'Estudio', 'BND026', 2400, 300000),
('ALB201', 'Lacuna Coil Chronicles Vol. 2', 2001, 'Estudio', 'BND026', 2520, 320000),
('ALB202', 'Lacuna Coil Chronicles Vol. 3', 2004, 'En vivo', 'BND026', 2640, 340000),
('ALB203', 'Nightwish Chronicles Vol. 1', 2000, 'Estudio', 'BND027', 2520, 345000),
('ALB204', 'Nightwish Chronicles Vol. 2', 2003, 'Estudio', 'BND027', 2640, 365000),
('ALB205', 'Nightwish Chronicles Vol. 3', 2006, 'En vivo', 'BND027', 2760, 385000),
('ALB206', 'Within Temptation Chronicles Vol. 1', 2000, 'Estudio', 'BND028', 2640, 390000),
('ALB207', 'Within Temptation Chronicles Vol. 2', 2003, 'Estudio', 'BND028', 2760, 410000),
('ALB208', 'Within Temptation Chronicles Vol. 3', 2006, 'En vivo', 'BND028', 2880, 430000),
('ALB209', 'Epica Chronicles Vol. 1', 2006, 'Estudio', 'BND029', 2760, 435000),
('ALB210', 'Epica Chronicles Vol. 2', 2009, 'Estudio', 'BND029', 2880, 455000),
('ALB211', 'Epica Chronicles Vol. 3', 2012, 'En vivo', 'BND029', 3000, 475000),
('ALB212', 'Kamelot Chronicles Vol. 1', 1995, 'Estudio', 'BND030', 2880, 480000),
('ALB213', 'Kamelot Chronicles Vol. 2', 1998, 'Estudio', 'BND030', 3000, 500000),
('ALB214', 'Kamelot Chronicles Vol. 3', 2001, 'En vivo', 'BND030', 3120, 520000),
('ALB215', 'Sabaton Chronicles Vol. 1', 2003, 'Estudio', 'BND031', 3000, 525000),
('ALB216', 'Sabaton Chronicles Vol. 2', 2006, 'Estudio', 'BND031', 3120, 545000),
('ALB217', 'Sabaton Chronicles Vol. 3', 2009, 'En vivo', 'BND031', 3240, 565000),
('ALB218', 'Avantasia Chronicles Vol. 1', 2005, 'Estudio', 'BND032', 3120, 570000),
('ALB219', 'Avantasia Chronicles Vol. 2', 2008, 'Estudio', 'BND032', 3240, 590000),
('ALB220', 'Avantasia Chronicles Vol. 3', 2011, 'En vivo', 'BND032', 3360, 610000),
('ALB221', 'Trivium Chronicles Vol. 1', 2003, 'Estudio', 'BND033', 3240, 615000),
('ALB222', 'Trivium Chronicles Vol. 2', 2006, 'Estudio', 'BND033', 3360, 635000),
('ALB223', 'Trivium Chronicles Vol. 3', 2009, 'En vivo', 'BND033', 3480, 655000),
('ALB224', 'Gojira Chronicles Vol. 1', 2000, 'Estudio', 'BND034', 3360, 660000),
('ALB225', 'Gojira Chronicles Vol. 2', 2003, 'Estudio', 'BND034', 3480, 680000),
('ALB226', 'Gojira Chronicles Vol. 3', 2006, 'En vivo', 'BND034', 3600, 700000),
('ALB227', 'Mastodon Chronicles Vol. 1', 2004, 'Estudio', 'BND035', 3480, 705000),
('ALB228', 'Mastodon Chronicles Vol. 2', 2007, 'Estudio', 'BND035', 3600, 725000),
('ALB229', 'Mastodon Chronicles Vol. 3', 2010, 'En vivo', 'BND035', 3720, 745000),
('ALB230', 'Opeth Chronicles Vol. 1', 1994, 'Estudio', 'BND036', 3600, 750000),
('ALB231', 'Opeth Chronicles Vol. 2', 1997, 'Estudio', 'BND036', 3720, 770000),
('ALB232', 'Opeth Chronicles Vol. 3', 2000, 'En vivo', 'BND036', 3840, 790000),
('ALB233', 'Lamb of God Chronicles Vol. 1', 1998, 'Estudio', 'BND037', 3720, 795000),
('ALB234', 'Lamb of God Chronicles Vol. 2', 2001, 'Estudio', 'BND037', 3840, 815000),
('ALB235', 'Lamb of God Chronicles Vol. 3', 2004, 'En vivo', 'BND037', 3960, 835000),
('ALB236', 'Parkway Drive Chronicles Vol. 1', 2007, 'Estudio', 'BND038', 3840, 840000),
('ALB237', 'Parkway Drive Chronicles Vol. 2', 2010, 'Estudio', 'BND038', 3960, 860000),
('ALB238', 'Parkway Drive Chronicles Vol. 3', 2013, 'En vivo', 'BND038', 4080, 880000),
('ALB239', 'Architects Chronicles Vol. 1', 2008, 'Estudio', 'BND039', 3960, 885000),
('ALB240', 'Architects Chronicles Vol. 2', 2011, 'Estudio', 'BND039', 4080, 905000),
('ALB241', 'Architects Chronicles Vol. 3', 2014, 'En vivo', 'BND039', 4200, 925000),
('ALB242', 'Jinjer Chronicles Vol. 1', 2013, 'Estudio', 'BND040', 4080, 930000),
('ALB243', 'Jinjer Chronicles Vol. 2', 2016, 'Estudio', 'BND040', 4200, 950000),
('ALB244', 'Jinjer Chronicles Vol. 3', 2019, 'En vivo', 'BND040', 4320, 970000),
('ALB245', 'Spiritbox Chronicles Vol. 1', 2021, 'Estudio', 'BND041', 4200, 975000),
('ALB246', 'Spiritbox Chronicles Vol. 2', 2024, 'Estudio', 'BND041', 4320, 995000),
('ALB247', 'Spiritbox Chronicles Vol. 3', 2024, 'En vivo', 'BND041', 4440, 1015000),
('ALB248', 'Babymetal Chronicles Vol. 1', 2014, 'Estudio', 'BND042', 4320, 1020000),
('ALB249', 'Babymetal Chronicles Vol. 2', 2017, 'Estudio', 'BND042', 4440, 1040000),
('ALB250', 'Babymetal Chronicles Vol. 3', 2020, 'En vivo', 'BND042', 4560, 1060000),
('ALB251', 'Powerwolf Chronicles Vol. 1', 2007, 'Estudio', 'BND043', 4440, 1065000),
('ALB252', 'Powerwolf Chronicles Vol. 2', 2010, 'Estudio', 'BND043', 4560, 1085000),
('ALB253', 'Powerwolf Chronicles Vol. 3', 2013, 'En vivo', 'BND043', 4680, 1105000),
('ALB254', 'Ghost Chronicles Vol. 1', 2010, 'Estudio', 'BND044', 4560, 1110000),
('ALB255', 'Ghost Chronicles Vol. 2', 2013, 'Estudio', 'BND044', 4680, 1130000),
('ALB256', 'Ghost Chronicles Vol. 3', 2016, 'En vivo', 'BND044', 4800, 1150000),
('ALB257', 'Tesseract Chronicles Vol. 1', 2007, 'Estudio', 'BND045', 4680, 1155000),
('ALB258', 'Tesseract Chronicles Vol. 2', 2010, 'Estudio', 'BND045', 4800, 1175000),
('ALB259', 'Tesseract Chronicles Vol. 3', 2013, 'En vivo', 'BND045', 4920, 1195000),
('ALB260', 'Polaris Chronicles Vol. 1', 2016, 'Estudio', 'BND046', 4800, 1200000),
('ALB261', 'Polaris Chronicles Vol. 2', 2019, 'Estudio', 'BND046', 4920, 1220000),
('ALB262', 'Polaris Chronicles Vol. 3', 2022, 'En vivo', 'BND046', 5040, 1240000),
('ALB263', 'Soen Chronicles Vol. 1', 2014, 'Estudio', 'BND047', 4920, 1245000),
('ALB264', 'Soen Chronicles Vol. 2', 2017, 'Estudio', 'BND047', 5040, 1265000),
('ALB265', 'Soen Chronicles Vol. 3', 2020, 'En vivo', 'BND047', 5160, 1285000),
('ALB266', 'Leprous Chronicles Vol. 1', 2005, 'Estudio', 'BND048', 5040, 1290000),
('ALB267', 'Leprous Chronicles Vol. 2', 2008, 'Estudio', 'BND048', 5160, 1310000),
('ALB268', 'Leprous Chronicles Vol. 3', 2011, 'En vivo', 'BND048', 5280, 1330000),
('ALB269', 'Katatonia Chronicles Vol. 1', 1995, 'Estudio', 'BND049', 5160, 1335000),
('ALB270', 'Katatonia Chronicles Vol. 2', 1998, 'Estudio', 'BND049', 5280, 1355000),
('ALB271', 'Katatonia Chronicles Vol. 3', 2001, 'En vivo', 'BND049', 5400, 1375000),
('ALB272', 'The Hu Chronicles Vol. 1', 2020, 'Estudio', 'BND050', 5280, 1380000),
('ALB273', 'The Hu Chronicles Vol. 2', 2023, 'Estudio', 'BND050', 5400, 1400000),
('ALB274', 'The Hu Chronicles Vol. 3', 2024, 'En vivo', 'BND050', 5520, 1420000);
INSERT INTO cancion VALUES
('CAN200', 'Lacuna Coil Track 1-1', 195, 'ALB200', TRUE, FALSE),
('CAN201', 'Lacuna Coil Track 1-2', 210, 'ALB200', FALSE, FALSE),
('CAN202', 'Lacuna Coil Track 1-3', 225, 'ALB200', FALSE, FALSE),
('CAN203', 'Lacuna Coil Track 2-1', 210, 'ALB201', TRUE, FALSE),
('CAN204', 'Lacuna Coil Track 2-2', 225, 'ALB201', FALSE, FALSE),
('CAN205', 'Lacuna Coil Track 2-3', 240, 'ALB201', FALSE, FALSE),
('CAN206', 'Lacuna Coil Track 3-1', 225, 'ALB202', TRUE, FALSE),
('CAN207', 'Lacuna Coil Track 3-2', 240, 'ALB202', FALSE, FALSE),
('CAN208', 'Lacuna Coil Track 3-3', 255, 'ALB202', FALSE, FALSE),
('CAN209', 'Nightwish Track 1-1', 195, 'ALB203', TRUE, FALSE),
('CAN210', 'Nightwish Track 1-2', 210, 'ALB203', FALSE, FALSE),
('CAN211', 'Nightwish Track 1-3', 225, 'ALB203', FALSE, FALSE),
('CAN212', 'Nightwish Track 2-1', 210, 'ALB204', TRUE, FALSE),
('CAN213', 'Nightwish Track 2-2', 225, 'ALB204', FALSE, FALSE),
('CAN214', 'Nightwish Track 2-3', 240, 'ALB204', FALSE, FALSE),
('CAN215', 'Nightwish Track 3-1', 225, 'ALB205', TRUE, FALSE),
('CAN216', 'Nightwish Track 3-2', 240, 'ALB205', FALSE, FALSE),
('CAN217', 'Nightwish Track 3-3', 255, 'ALB205', FALSE, FALSE),
('CAN218', 'Within Temptation Track 1-1', 195, 'ALB206', TRUE, FALSE),
('CAN219', 'Within Temptation Track 1-2', 210, 'ALB206', FALSE, FALSE),
('CAN220', 'Within Temptation Track 1-3', 225, 'ALB206', FALSE, FALSE),
('CAN221', 'Within Temptation Track 2-1', 210, 'ALB207', TRUE, FALSE),
('CAN222', 'Within Temptation Track 2-2', 225, 'ALB207', FALSE, FALSE),
('CAN223', 'Within Temptation Track 2-3', 240, 'ALB207', FALSE, FALSE),
('CAN224', 'Within Temptation Track 3-1', 225, 'ALB208', TRUE, FALSE),
('CAN225', 'Within Temptation Track 3-2', 240, 'ALB208', FALSE, FALSE),
('CAN226', 'Within Temptation Track 3-3', 255, 'ALB208', FALSE, FALSE),
('CAN227', 'Epica Track 1-1', 195, 'ALB209', TRUE, FALSE),
('CAN228', 'Epica Track 1-2', 210, 'ALB209', FALSE, FALSE),
('CAN229', 'Epica Track 1-3', 225, 'ALB209', FALSE, FALSE),
('CAN230', 'Epica Track 2-1', 210, 'ALB210', TRUE, FALSE),
('CAN231', 'Epica Track 2-2', 225, 'ALB210', FALSE, FALSE),
('CAN232', 'Epica Track 2-3', 240, 'ALB210', FALSE, FALSE),
('CAN233', 'Epica Track 3-1', 225, 'ALB211', TRUE, FALSE),
('CAN234', 'Epica Track 3-2', 240, 'ALB211', FALSE, FALSE),
('CAN235', 'Epica Track 3-3', 255, 'ALB211', FALSE, FALSE),
('CAN236', 'Kamelot Track 1-1', 195, 'ALB212', TRUE, FALSE),
('CAN237', 'Kamelot Track 1-2', 210, 'ALB212', FALSE, FALSE),
('CAN238', 'Kamelot Track 1-3', 225, 'ALB212', FALSE, FALSE),
('CAN239', 'Kamelot Track 2-1', 210, 'ALB213', TRUE, FALSE),
('CAN240', 'Kamelot Track 2-2', 225, 'ALB213', FALSE, FALSE),
('CAN241', 'Kamelot Track 2-3', 240, 'ALB213', FALSE, FALSE),
('CAN242', 'Kamelot Track 3-1', 225, 'ALB214', TRUE, FALSE),
('CAN243', 'Kamelot Track 3-2', 240, 'ALB214', FALSE, FALSE),
('CAN244', 'Kamelot Track 3-3', 255, 'ALB214', FALSE, FALSE),
('CAN245', 'Sabaton Track 1-1', 195, 'ALB215', TRUE, FALSE),
('CAN246', 'Sabaton Track 1-2', 210, 'ALB215', FALSE, FALSE),
('CAN247', 'Sabaton Track 1-3', 225, 'ALB215', FALSE, FALSE),
('CAN248', 'Sabaton Track 2-1', 210, 'ALB216', TRUE, FALSE),
('CAN249', 'Sabaton Track 2-2', 225, 'ALB216', FALSE, FALSE),
('CAN250', 'Sabaton Track 2-3', 240, 'ALB216', FALSE, FALSE),
('CAN251', 'Sabaton Track 3-1', 225, 'ALB217', TRUE, FALSE),
('CAN252', 'Sabaton Track 3-2', 240, 'ALB217', FALSE, FALSE),
('CAN253', 'Sabaton Track 3-3', 255, 'ALB217', FALSE, FALSE),
('CAN254', 'Avantasia Track 1-1', 195, 'ALB218', TRUE, FALSE),
('CAN255', 'Avantasia Track 1-2', 210, 'ALB218', FALSE, FALSE),
('CAN256', 'Avantasia Track 1-3', 225, 'ALB218', FALSE, FALSE),
('CAN257', 'Avantasia Track 2-1', 210, 'ALB219', TRUE, FALSE),
('CAN258', 'Avantasia Track 2-2', 225, 'ALB219', FALSE, FALSE),
('CAN259', 'Avantasia Track 2-3', 240, 'ALB219', FALSE, FALSE),
('CAN260', 'Avantasia Track 3-1', 225, 'ALB220', TRUE, FALSE),
('CAN261', 'Avantasia Track 3-2', 240, 'ALB220', FALSE, FALSE),
('CAN262', 'Avantasia Track 3-3', 255, 'ALB220', FALSE, FALSE),
('CAN263', 'Trivium Track 1-1', 195, 'ALB221', TRUE, FALSE),
('CAN264', 'Trivium Track 1-2', 210, 'ALB221', FALSE, FALSE),
('CAN265', 'Trivium Track 1-3', 225, 'ALB221', FALSE, TRUE),
('CAN266', 'Trivium Track 2-1', 210, 'ALB222', TRUE, FALSE),
('CAN267', 'Trivium Track 2-2', 225, 'ALB222', FALSE, FALSE),
('CAN268', 'Trivium Track 2-3', 240, 'ALB222', FALSE, TRUE),
('CAN269', 'Trivium Track 3-1', 225, 'ALB223', TRUE, FALSE),
('CAN270', 'Trivium Track 3-2', 240, 'ALB223', FALSE, FALSE),
('CAN271', 'Trivium Track 3-3', 255, 'ALB223', FALSE, TRUE),
('CAN272', 'Gojira Track 1-1', 195, 'ALB224', TRUE, FALSE),
('CAN273', 'Gojira Track 1-2', 210, 'ALB224', FALSE, FALSE),
('CAN274', 'Gojira Track 1-3', 225, 'ALB224', FALSE, FALSE),
('CAN275', 'Gojira Track 2-1', 210, 'ALB225', TRUE, FALSE),
('CAN276', 'Gojira Track 2-2', 225, 'ALB225', FALSE, FALSE),
('CAN277', 'Gojira Track 2-3', 240, 'ALB225', FALSE, FALSE),
('CAN278', 'Gojira Track 3-1', 225, 'ALB226', TRUE, FALSE),
('CAN279', 'Gojira Track 3-2', 240, 'ALB226', FALSE, FALSE),
('CAN280', 'Gojira Track 3-3', 255, 'ALB226', FALSE, FALSE),
('CAN281', 'Mastodon Track 1-1', 195, 'ALB227', TRUE, FALSE),
('CAN282', 'Mastodon Track 1-2', 210, 'ALB227', FALSE, FALSE),
('CAN283', 'Mastodon Track 1-3', 225, 'ALB227', FALSE, FALSE),
('CAN284', 'Mastodon Track 2-1', 210, 'ALB228', TRUE, FALSE),
('CAN285', 'Mastodon Track 2-2', 225, 'ALB228', FALSE, FALSE),
('CAN286', 'Mastodon Track 2-3', 240, 'ALB228', FALSE, FALSE),
('CAN287', 'Mastodon Track 3-1', 225, 'ALB229', TRUE, FALSE),
('CAN288', 'Mastodon Track 3-2', 240, 'ALB229', FALSE, FALSE),
('CAN289', 'Mastodon Track 3-3', 255, 'ALB229', FALSE, FALSE),
('CAN290', 'Opeth Track 1-1', 195, 'ALB230', TRUE, FALSE),
('CAN291', 'Opeth Track 1-2', 210, 'ALB230', FALSE, FALSE),
('CAN292', 'Opeth Track 1-3', 225, 'ALB230', FALSE, FALSE),
('CAN293', 'Opeth Track 2-1', 210, 'ALB231', TRUE, FALSE),
('CAN294', 'Opeth Track 2-2', 225, 'ALB231', FALSE, FALSE),
('CAN295', 'Opeth Track 2-3', 240, 'ALB231', FALSE, FALSE),
('CAN296', 'Opeth Track 3-1', 225, 'ALB232', TRUE, FALSE),
('CAN297', 'Opeth Track 3-2', 240, 'ALB232', FALSE, FALSE),
('CAN298', 'Opeth Track 3-3', 255, 'ALB232', FALSE, FALSE),
('CAN299', 'Lamb of God Track 1-1', 195, 'ALB233', TRUE, FALSE),
('CAN300', 'Lamb of God Track 1-2', 210, 'ALB233', FALSE, FALSE),
('CAN301', 'Lamb of God Track 1-3', 225, 'ALB233', FALSE, FALSE),
('CAN302', 'Lamb of God Track 2-1', 210, 'ALB234', TRUE, FALSE),
('CAN303', 'Lamb of God Track 2-2', 225, 'ALB234', FALSE, FALSE),
('CAN304', 'Lamb of God Track 2-3', 240, 'ALB234', FALSE, FALSE),
('CAN305', 'Lamb of God Track 3-1', 225, 'ALB235', TRUE, FALSE),
('CAN306', 'Lamb of God Track 3-2', 240, 'ALB235', FALSE, FALSE),
('CAN307', 'Lamb of God Track 3-3', 255, 'ALB235', FALSE, FALSE),
('CAN308', 'Parkway Drive Track 1-1', 195, 'ALB236', TRUE, FALSE),
('CAN309', 'Parkway Drive Track 1-2', 210, 'ALB236', FALSE, FALSE),
('CAN310', 'Parkway Drive Track 1-3', 225, 'ALB236', FALSE, TRUE),
('CAN311', 'Parkway Drive Track 2-1', 210, 'ALB237', TRUE, FALSE),
('CAN312', 'Parkway Drive Track 2-2', 225, 'ALB237', FALSE, FALSE),
('CAN313', 'Parkway Drive Track 2-3', 240, 'ALB237', FALSE, TRUE),
('CAN314', 'Parkway Drive Track 3-1', 225, 'ALB238', TRUE, FALSE),
('CAN315', 'Parkway Drive Track 3-2', 240, 'ALB238', FALSE, FALSE),
('CAN316', 'Parkway Drive Track 3-3', 255, 'ALB238', FALSE, TRUE),
('CAN317', 'Architects Track 1-1', 195, 'ALB239', TRUE, FALSE),
('CAN318', 'Architects Track 1-2', 210, 'ALB239', FALSE, FALSE),
('CAN319', 'Architects Track 1-3', 225, 'ALB239', FALSE, TRUE),
('CAN320', 'Architects Track 2-1', 210, 'ALB240', TRUE, FALSE),
('CAN321', 'Architects Track 2-2', 225, 'ALB240', FALSE, FALSE),
('CAN322', 'Architects Track 2-3', 240, 'ALB240', FALSE, TRUE),
('CAN323', 'Architects Track 3-1', 225, 'ALB241', TRUE, FALSE),
('CAN324', 'Architects Track 3-2', 240, 'ALB241', FALSE, FALSE),
('CAN325', 'Architects Track 3-3', 255, 'ALB241', FALSE, TRUE),
('CAN326', 'Jinjer Track 1-1', 195, 'ALB242', TRUE, FALSE),
('CAN327', 'Jinjer Track 1-2', 210, 'ALB242', FALSE, FALSE),
('CAN328', 'Jinjer Track 1-3', 225, 'ALB242', FALSE, TRUE),
('CAN329', 'Jinjer Track 2-1', 210, 'ALB243', TRUE, FALSE),
('CAN330', 'Jinjer Track 2-2', 225, 'ALB243', FALSE, FALSE),
('CAN331', 'Jinjer Track 2-3', 240, 'ALB243', FALSE, TRUE),
('CAN332', 'Jinjer Track 3-1', 225, 'ALB244', TRUE, FALSE),
('CAN333', 'Jinjer Track 3-2', 240, 'ALB244', FALSE, FALSE),
('CAN334', 'Jinjer Track 3-3', 255, 'ALB244', FALSE, TRUE),
('CAN335', 'Spiritbox Track 1-1', 195, 'ALB245', TRUE, FALSE),
('CAN336', 'Spiritbox Track 1-2', 210, 'ALB245', FALSE, FALSE),
('CAN337', 'Spiritbox Track 1-3', 225, 'ALB245', FALSE, TRUE),
('CAN338', 'Spiritbox Track 2-1', 210, 'ALB246', TRUE, FALSE),
('CAN339', 'Spiritbox Track 2-2', 225, 'ALB246', FALSE, FALSE),
('CAN340', 'Spiritbox Track 2-3', 240, 'ALB246', FALSE, TRUE),
('CAN341', 'Spiritbox Track 3-1', 225, 'ALB247', TRUE, FALSE),
('CAN342', 'Spiritbox Track 3-2', 240, 'ALB247', FALSE, FALSE),
('CAN343', 'Spiritbox Track 3-3', 255, 'ALB247', FALSE, TRUE),
('CAN344', 'Babymetal Track 1-1', 195, 'ALB248', TRUE, FALSE),
('CAN345', 'Babymetal Track 1-2', 210, 'ALB248', FALSE, FALSE),
('CAN346', 'Babymetal Track 1-3', 225, 'ALB248', FALSE, FALSE),
('CAN347', 'Babymetal Track 2-1', 210, 'ALB249', TRUE, FALSE),
('CAN348', 'Babymetal Track 2-2', 225, 'ALB249', FALSE, FALSE),
('CAN349', 'Babymetal Track 2-3', 240, 'ALB249', FALSE, FALSE),
('CAN350', 'Babymetal Track 3-1', 225, 'ALB250', TRUE, FALSE),
('CAN351', 'Babymetal Track 3-2', 240, 'ALB250', FALSE, FALSE),
('CAN352', 'Babymetal Track 3-3', 255, 'ALB250', FALSE, FALSE),
('CAN353', 'Powerwolf Track 1-1', 195, 'ALB251', TRUE, FALSE),
('CAN354', 'Powerwolf Track 1-2', 210, 'ALB251', FALSE, FALSE),
('CAN355', 'Powerwolf Track 1-3', 225, 'ALB251', FALSE, FALSE),
('CAN356', 'Powerwolf Track 2-1', 210, 'ALB252', TRUE, FALSE),
('CAN357', 'Powerwolf Track 2-2', 225, 'ALB252', FALSE, FALSE),
('CAN358', 'Powerwolf Track 2-3', 240, 'ALB252', FALSE, FALSE),
('CAN359', 'Powerwolf Track 3-1', 225, 'ALB253', TRUE, FALSE),
('CAN360', 'Powerwolf Track 3-2', 240, 'ALB253', FALSE, FALSE),
('CAN361', 'Powerwolf Track 3-3', 255, 'ALB253', FALSE, FALSE),
('CAN362', 'Ghost Track 1-1', 195, 'ALB254', TRUE, FALSE),
('CAN363', 'Ghost Track 1-2', 210, 'ALB254', FALSE, FALSE),
('CAN364', 'Ghost Track 1-3', 225, 'ALB254', FALSE, FALSE),
('CAN365', 'Ghost Track 2-1', 210, 'ALB255', TRUE, FALSE),
('CAN366', 'Ghost Track 2-2', 225, 'ALB255', FALSE, FALSE),
('CAN367', 'Ghost Track 2-3', 240, 'ALB255', FALSE, FALSE),
('CAN368', 'Ghost Track 3-1', 225, 'ALB256', TRUE, FALSE),
('CAN369', 'Ghost Track 3-2', 240, 'ALB256', FALSE, FALSE),
('CAN370', 'Ghost Track 3-3', 255, 'ALB256', FALSE, FALSE),
('CAN371', 'Tesseract Track 1-1', 195, 'ALB257', TRUE, FALSE),
('CAN372', 'Tesseract Track 1-2', 210, 'ALB257', FALSE, FALSE),
('CAN373', 'Tesseract Track 1-3', 225, 'ALB257', FALSE, FALSE),
('CAN374', 'Tesseract Track 2-1', 210, 'ALB258', TRUE, FALSE),
('CAN375', 'Tesseract Track 2-2', 225, 'ALB258', FALSE, FALSE),
('CAN376', 'Tesseract Track 2-3', 240, 'ALB258', FALSE, FALSE),
('CAN377', 'Tesseract Track 3-1', 225, 'ALB259', TRUE, FALSE),
('CAN378', 'Tesseract Track 3-2', 240, 'ALB259', FALSE, FALSE),
('CAN379', 'Tesseract Track 3-3', 255, 'ALB259', FALSE, FALSE),
('CAN380', 'Polaris Track 1-1', 195, 'ALB260', TRUE, FALSE),
('CAN381', 'Polaris Track 1-2', 210, 'ALB260', FALSE, FALSE),
('CAN382', 'Polaris Track 1-3', 225, 'ALB260', FALSE, TRUE),
('CAN383', 'Polaris Track 2-1', 210, 'ALB261', TRUE, FALSE),
('CAN384', 'Polaris Track 2-2', 225, 'ALB261', FALSE, FALSE),
('CAN385', 'Polaris Track 2-3', 240, 'ALB261', FALSE, TRUE),
('CAN386', 'Polaris Track 3-1', 225, 'ALB262', TRUE, FALSE),
('CAN387', 'Polaris Track 3-2', 240, 'ALB262', FALSE, FALSE),
('CAN388', 'Polaris Track 3-3', 255, 'ALB262', FALSE, TRUE),
('CAN389', 'Soen Track 1-1', 195, 'ALB263', TRUE, FALSE),
('CAN390', 'Soen Track 1-2', 210, 'ALB263', FALSE, FALSE),
('CAN391', 'Soen Track 1-3', 225, 'ALB263', FALSE, FALSE),
('CAN392', 'Soen Track 2-1', 210, 'ALB264', TRUE, FALSE),
('CAN393', 'Soen Track 2-2', 225, 'ALB264', FALSE, FALSE),
('CAN394', 'Soen Track 2-3', 240, 'ALB264', FALSE, FALSE),
('CAN395', 'Soen Track 3-1', 225, 'ALB265', TRUE, FALSE),
('CAN396', 'Soen Track 3-2', 240, 'ALB265', FALSE, FALSE),
('CAN397', 'Soen Track 3-3', 255, 'ALB265', FALSE, FALSE),
('CAN398', 'Leprous Track 1-1', 195, 'ALB266', TRUE, FALSE),
('CAN399', 'Leprous Track 1-2', 210, 'ALB266', FALSE, FALSE),
('CAN400', 'Leprous Track 1-3', 225, 'ALB266', FALSE, FALSE),
('CAN401', 'Leprous Track 2-1', 210, 'ALB267', TRUE, FALSE),
('CAN402', 'Leprous Track 2-2', 225, 'ALB267', FALSE, FALSE),
('CAN403', 'Leprous Track 2-3', 240, 'ALB267', FALSE, FALSE),
('CAN404', 'Leprous Track 3-1', 225, 'ALB268', TRUE, FALSE),
('CAN405', 'Leprous Track 3-2', 240, 'ALB268', FALSE, FALSE),
('CAN406', 'Leprous Track 3-3', 255, 'ALB268', FALSE, FALSE),
('CAN407', 'Katatonia Track 1-1', 195, 'ALB269', TRUE, FALSE),
('CAN408', 'Katatonia Track 1-2', 210, 'ALB269', FALSE, FALSE),
('CAN409', 'Katatonia Track 1-3', 225, 'ALB269', FALSE, FALSE),
('CAN410', 'Katatonia Track 2-1', 210, 'ALB270', TRUE, FALSE),
('CAN411', 'Katatonia Track 2-2', 225, 'ALB270', FALSE, FALSE),
('CAN412', 'Katatonia Track 2-3', 240, 'ALB270', FALSE, FALSE),
('CAN413', 'Katatonia Track 3-1', 225, 'ALB271', TRUE, FALSE),
('CAN414', 'Katatonia Track 3-2', 240, 'ALB271', FALSE, FALSE),
('CAN415', 'Katatonia Track 3-3', 255, 'ALB271', FALSE, FALSE),
('CAN416', 'The Hu Track 1-1', 195, 'ALB272', TRUE, FALSE),
('CAN417', 'The Hu Track 1-2', 210, 'ALB272', FALSE, FALSE),
('CAN418', 'The Hu Track 1-3', 225, 'ALB272', FALSE, FALSE),
('CAN419', 'The Hu Track 2-1', 210, 'ALB273', TRUE, FALSE),
('CAN420', 'The Hu Track 2-2', 225, 'ALB273', FALSE, FALSE),
('CAN421', 'The Hu Track 2-3', 240, 'ALB273', FALSE, FALSE),
('CAN422', 'The Hu Track 3-1', 225, 'ALB274', TRUE, FALSE),
('CAN423', 'The Hu Track 3-2', 240, 'ALB274', FALSE, FALSE),
('CAN424', 'The Hu Track 3-3', 255, 'ALB274', FALSE, FALSE);
INSERT INTO contrato VALUES
('BND026', 'DISC016', '1999-01-01', '2030-12-31', 'Distribución Global', 2500000),
('BND027', 'DISC017', '2001-01-01', '2030-12-31', 'Distribución Global', 3000000),
('BND028', 'DISC018', '2001-01-01', '2030-12-31', 'Distribución Global', 3500000),
('BND029', 'DISC019', '2007-01-01', '2030-12-31', 'Distribución Global', 4000000),
('BND030', 'DISC020', '1996-01-01', '2030-12-31', 'Distribución Global', 4500000),
('BND031', 'DISC016', '2004-01-01', '2030-12-31', 'Distribución Global', 5000000),
('BND032', 'DISC017', '2006-01-01', '2030-12-31', 'Distribución Global', 5500000),
('BND033', 'DISC018', '2004-01-01', '2030-12-31', 'Distribución Global', 6000000),
('BND034', 'DISC019', '2001-01-01', '2030-12-31', 'Distribución Global', 6500000),
('BND035', 'DISC020', '2005-01-01', '2030-12-31', 'Distribución Global', 7000000),
('BND036', 'DISC016', '1995-01-01', '2030-12-31', 'Distribución Global', 7500000),
('BND037', 'DISC017', '1999-01-01', '2030-12-31', 'Distribución Global', 8000000),
('BND038', 'DISC018', '2008-01-01', '2030-12-31', 'Distribución Global', 8500000),
('BND039', 'DISC019', '2009-01-01', '2030-12-31', 'Distribución Global', 9000000),
('BND040', 'DISC020', '2014-01-01', '2030-12-31', 'Distribución Global', 9500000),
('BND041', 'DISC016', '2022-01-01', '2030-12-31', 'Distribución Global', 10000000),
('BND042', 'DISC017', '2015-01-01', '2030-12-31', 'Distribución Global', 10500000),
('BND043', 'DISC018', '2008-01-01', '2030-12-31', 'Distribución Global', 11000000),
('BND044', 'DISC019', '2011-01-01', '2030-12-31', 'Distribución Global', 11500000),
('BND045', 'DISC020', '2008-01-01', '2030-12-31', 'Distribución Global', 12000000),
('BND046', 'DISC016', '2017-01-01', '2030-12-31', 'Distribución Global', 12500000),
('BND047', 'DISC017', '2015-01-01', '2030-12-31', 'Distribución Global', 13000000),
('BND048', 'DISC018', '2006-01-01', '2030-12-31', 'Distribución Global', 13500000),
('BND049', 'DISC019', '1996-01-01', '2030-12-31', 'Distribución Global', 14000000),
('BND050', 'DISC020', '2021-01-01', '2030-12-31', 'Distribución Global', 14500000);
INSERT INTO integra VALUES
('NB001', 'BND026', '1994-01-01', NULL, 'Voz', TRUE),
('NB002', 'BND026', '1995-02-01', NULL, 'Guitarra', TRUE),
('NB003', 'BND026', '1996-03-01', NULL, 'Bajo', TRUE),
('NB004', 'BND026', '1997-04-01', NULL, 'Batería', FALSE),
('NB005', 'BND026', '1998-05-01', NULL, 'Teclado', FALSE),
('NB006', 'BND027', '1996-01-01', NULL, 'Voz', TRUE),
('NB007', 'BND027', '1997-02-01', NULL, 'Guitarra', TRUE),
('NB008', 'BND027', '1998-03-01', NULL, 'Bajo', TRUE),
('NB009', 'BND027', '1999-04-01', NULL, 'Batería', FALSE),
('NB010', 'BND027', '2000-05-01', NULL, 'Teclado', FALSE),
('NB011', 'BND028', '1996-01-01', NULL, 'Voz', TRUE),
('NB012', 'BND028', '1997-02-01', NULL, 'Guitarra', TRUE),
('NB013', 'BND028', '1998-03-01', NULL, 'Bajo', TRUE),
('NB014', 'BND028', '1999-04-01', NULL, 'Batería', FALSE),
('NB015', 'BND028', '2000-05-01', NULL, 'Teclado', FALSE),
('NB016', 'BND029', '2002-01-01', NULL, 'Voz', TRUE),
('NB017', 'BND029', '2003-02-01', NULL, 'Guitarra', TRUE),
('NB018', 'BND029', '2004-03-01', NULL, 'Bajo', TRUE),
('NB019', 'BND029', '2005-04-01', NULL, 'Batería', FALSE),
('NB020', 'BND029', '2006-05-01', NULL, 'Teclado', FALSE),
('NB021', 'BND030', '1991-01-01', NULL, 'Voz', TRUE),
('NB022', 'BND030', '1992-02-01', NULL, 'Guitarra', TRUE),
('NB023', 'BND030', '1993-03-01', NULL, 'Bajo', TRUE),
('NB024', 'BND030', '1994-04-01', NULL, 'Batería', FALSE),
('NB025', 'BND030', '1995-05-01', NULL, 'Teclado', FALSE),
('NB026', 'BND031', '1999-01-01', NULL, 'Voz', TRUE),
('NB027', 'BND031', '2000-02-01', NULL, 'Guitarra', TRUE),
('NB028', 'BND031', '2001-03-01', NULL, 'Bajo', TRUE),
('NB029', 'BND031', '2002-04-01', NULL, 'Batería', FALSE),
('NB030', 'BND031', '2003-05-01', NULL, 'Teclado', FALSE),
('NB031', 'BND032', '2001-01-01', NULL, 'Voz', TRUE),
('NB032', 'BND032', '2002-02-01', NULL, 'Guitarra', TRUE),
('NB033', 'BND032', '2003-03-01', NULL, 'Bajo', TRUE),
('NB034', 'BND032', '2004-04-01', NULL, 'Batería', FALSE),
('NB035', 'BND032', '2005-05-01', NULL, 'Teclado', FALSE),
('NB036', 'BND033', '1999-01-01', NULL, 'Voz', TRUE),
('NB037', 'BND033', '2000-02-01', NULL, 'Guitarra', TRUE),
('NB038', 'BND033', '2001-03-01', NULL, 'Bajo', TRUE),
('NB039', 'BND033', '2002-04-01', NULL, 'Batería', FALSE),
('NB040', 'BND033', '2003-05-01', NULL, 'Teclado', FALSE),
('NB041', 'BND034', '1996-01-01', NULL, 'Voz', TRUE),
('NB042', 'BND034', '1997-02-01', NULL, 'Guitarra', TRUE),
('NB043', 'BND034', '1998-03-01', NULL, 'Bajo', TRUE),
('NB044', 'BND034', '1999-04-01', NULL, 'Batería', FALSE),
('NB045', 'BND034', '2000-05-01', NULL, 'Teclado', FALSE),
('NB046', 'BND035', '2000-01-01', NULL, 'Voz', TRUE),
('NB047', 'BND035', '2001-02-01', NULL, 'Guitarra', TRUE),
('NB048', 'BND035', '2002-03-01', NULL, 'Bajo', TRUE),
('NB049', 'BND035', '2003-04-01', NULL, 'Batería', FALSE),
('NB050', 'BND035', '2004-05-01', NULL, 'Teclado', FALSE),
('NB051', 'BND036', '1990-01-01', NULL, 'Voz', TRUE),
('NB052', 'BND036', '1991-02-01', NULL, 'Guitarra', TRUE),
('NB053', 'BND036', '1992-03-01', NULL, 'Bajo', TRUE),
('NB054', 'BND036', '1993-04-01', NULL, 'Batería', FALSE),
('NB055', 'BND036', '1994-05-01', NULL, 'Teclado', FALSE),
('NB056', 'BND037', '1994-01-01', NULL, 'Voz', TRUE),
('NB057', 'BND037', '1995-02-01', NULL, 'Guitarra', TRUE),
('NB058', 'BND037', '1996-03-01', NULL, 'Bajo', TRUE),
('NB059', 'BND037', '1997-04-01', NULL, 'Batería', FALSE),
('NB060', 'BND037', '1998-05-01', NULL, 'Teclado', FALSE),
('NB061', 'BND038', '2003-01-01', NULL, 'Voz', TRUE),
('NB062', 'BND038', '2004-02-01', NULL, 'Guitarra', TRUE),
('NB063', 'BND038', '2005-03-01', NULL, 'Bajo', TRUE),
('NB064', 'BND038', '2006-04-01', NULL, 'Batería', FALSE),
('NB065', 'BND038', '2007-05-01', NULL, 'Teclado', FALSE),
('NB066', 'BND039', '2004-01-01', NULL, 'Voz', TRUE),
('NB067', 'BND039', '2005-02-01', NULL, 'Guitarra', TRUE),
('NB068', 'BND039', '2006-03-01', NULL, 'Bajo', TRUE),
('NB069', 'BND039', '2007-04-01', NULL, 'Batería', FALSE),
('NB070', 'BND039', '2008-05-01', NULL, 'Teclado', FALSE),
('NB071', 'BND040', '2009-01-01', NULL, 'Voz', TRUE),
('NB072', 'BND040', '2010-02-01', NULL, 'Guitarra', TRUE),
('NB073', 'BND040', '2011-03-01', NULL, 'Bajo', TRUE),
('NB074', 'BND040', '2012-04-01', NULL, 'Batería', FALSE),
('NB075', 'BND040', '2013-05-01', NULL, 'Teclado', FALSE),
('NB076', 'BND041', '2017-01-01', NULL, 'Voz', TRUE),
('NB077', 'BND041', '2018-02-01', NULL, 'Guitarra', TRUE),
('NB078', 'BND041', '2019-03-01', NULL, 'Bajo', TRUE),
('NB079', 'BND041', '2020-04-01', NULL, 'Batería', FALSE),
('NB080', 'BND041', '2021-05-01', NULL, 'Teclado', FALSE),
('NB081', 'BND042', '2010-01-01', NULL, 'Voz', TRUE),
('NB082', 'BND042', '2011-02-01', NULL, 'Guitarra', TRUE),
('NB083', 'BND042', '2012-03-01', NULL, 'Bajo', TRUE),
('NB084', 'BND042', '2013-04-01', NULL, 'Batería', FALSE),
('NB085', 'BND042', '2014-05-01', NULL, 'Teclado', FALSE),
('NB086', 'BND043', '2003-01-01', NULL, 'Voz', TRUE),
('NB087', 'BND043', '2004-02-01', NULL, 'Guitarra', TRUE),
('NB088', 'BND043', '2005-03-01', NULL, 'Bajo', TRUE),
('NB089', 'BND043', '2006-04-01', NULL, 'Batería', FALSE),
('NB090', 'BND043', '2007-05-01', NULL, 'Teclado', FALSE),
('NB091', 'BND044', '2006-01-01', NULL, 'Voz', TRUE),
('NB092', 'BND044', '2007-02-01', NULL, 'Guitarra', TRUE),
('NB093', 'BND044', '2008-03-01', NULL, 'Bajo', TRUE),
('NB094', 'BND044', '2009-04-01', NULL, 'Batería', FALSE),
('NB095', 'BND044', '2010-05-01', NULL, 'Teclado', FALSE),
('NB096', 'BND045', '2003-01-01', NULL, 'Voz', TRUE),
('NB097', 'BND045', '2004-02-01', NULL, 'Guitarra', TRUE),
('NB098', 'BND045', '2005-03-01', NULL, 'Bajo', TRUE),
('NB099', 'BND045', '2006-04-01', NULL, 'Batería', FALSE),
('NB100', 'BND045', '2007-05-01', NULL, 'Teclado', FALSE),
('NB101', 'BND046', '2012-01-01', NULL, 'Voz', TRUE),
('NB102', 'BND046', '2013-02-01', NULL, 'Guitarra', TRUE),
('NB103', 'BND046', '2014-03-01', NULL, 'Bajo', TRUE),
('NB104', 'BND046', '2015-04-01', NULL, 'Batería', FALSE),
('NB105', 'BND046', '2016-05-01', NULL, 'Teclado', FALSE),
('NB106', 'BND047', '2010-01-01', NULL, 'Voz', TRUE),
('NB107', 'BND047', '2011-02-01', NULL, 'Guitarra', TRUE),
('NB108', 'BND047', '2012-03-01', NULL, 'Bajo', TRUE),
('NB109', 'BND047', '2013-04-01', NULL, 'Batería', FALSE),
('NB110', 'BND047', '2014-05-01', NULL, 'Teclado', FALSE),
('NB111', 'BND048', '2001-01-01', NULL, 'Voz', TRUE),
('NB112', 'BND048', '2002-02-01', NULL, 'Guitarra', TRUE),
('NB113', 'BND048', '2003-03-01', NULL, 'Bajo', TRUE),
('NB114', 'BND048', '2004-04-01', NULL, 'Batería', FALSE),
('NB115', 'BND048', '2005-05-01', NULL, 'Teclado', FALSE),
('NB116', 'BND049', '1991-01-01', NULL, 'Voz', TRUE),
('NB117', 'BND049', '1992-02-01', NULL, 'Guitarra', TRUE),
('NB118', 'BND049', '1993-03-01', NULL, 'Bajo', TRUE),
('NB119', 'BND049', '1994-04-01', NULL, 'Batería', FALSE),
('NB120', 'BND049', '1995-05-01', NULL, 'Teclado', FALSE),
('NB121', 'BND050', '2016-01-01', NULL, 'Voz', TRUE),
('NB122', 'BND050', '2017-02-01', NULL, 'Guitarra', TRUE),
('NB123', 'BND050', '2018-03-01', NULL, 'Bajo', TRUE),
('NB124', 'BND050', '2019-04-01', NULL, 'Batería', FALSE),
('NB125', 'BND050', '2020-05-01', NULL, 'Teclado', FALSE);
INSERT INTO actuacion VALUES
('BND026', 'FEST001', '2024-01-10', 75, 1, 90000),
('BND026', 'FEST002', '2024-04-10', 90, 2, 91000),
('BND027', 'FEST003', '2024-02-11', 75, 1, 92500),
('BND027', 'FEST004', '2024-05-11', 90, 2, 93500),
('BND028', 'FEST005', '2024-03-12', 75, 1, 95000),
('BND028', 'FEST006', '2024-06-12', 90, 2, 96000),
('BND029', 'FEST007', '2024-04-13', 75, 1, 97500),
('BND029', 'FEST008', '2024-07-13', 90, 2, 98500),
('BND030', 'FEST009', '2024-05-14', 75, 1, 100000),
('BND030', 'FEST010', '2024-08-14', 90, 2, 101000),
('BND031', 'FEST011', '2024-06-15', 75, 1, 102500),
('BND031', 'FEST012', '2024-09-15', 90, 2, 103500),
('BND032', 'FEST013', '2024-07-16', 75, 1, 105000),
('BND032', 'FEST014', '2024-10-16', 90, 2, 106000),
('BND033', 'FEST015', '2024-08-17', 75, 1, 107500),
('BND033', 'FEST016', '2024-11-17', 90, 2, 108500),
('BND034', 'FEST017', '2024-09-18', 75, 1, 110000),
('BND034', 'FEST018', '2024-12-18', 90, 2, 111000),
('BND035', 'FEST019', '2024-10-19', 75, 1, 112500),
('BND035', 'FEST020', '2024-01-19', 90, 2, 113500),
('BND036', 'FEST001', '2024-11-10', 75, 1, 115000),
('BND036', 'FEST002', '2024-02-10', 90, 2, 116000),
('BND037', 'FEST003', '2024-12-11', 75, 1, 117500),
('BND037', 'FEST004', '2024-03-11', 90, 2, 118500),
('BND038', 'FEST005', '2024-01-12', 75, 1, 120000),
('BND038', 'FEST006', '2024-04-12', 90, 2, 121000),
('BND039', 'FEST007', '2024-02-13', 75, 1, 122500),
('BND039', 'FEST008', '2024-05-13', 90, 2, 123500),
('BND040', 'FEST009', '2024-03-14', 75, 1, 125000),
('BND040', 'FEST010', '2024-06-14', 90, 2, 126000),
('BND041', 'FEST011', '2024-04-15', 75, 1, 127500),
('BND041', 'FEST012', '2024-07-15', 90, 2, 128500),
('BND042', 'FEST013', '2024-05-16', 75, 1, 130000),
('BND042', 'FEST014', '2024-08-16', 90, 2, 131000),
('BND043', 'FEST015', '2024-06-17', 75, 1, 132500),
('BND043', 'FEST016', '2024-09-17', 90, 2, 133500),
('BND044', 'FEST017', '2024-07-18', 75, 1, 135000),
('BND044', 'FEST018', '2024-10-18', 90, 2, 136000),
('BND045', 'FEST019', '2024-08-19', 75, 1, 137500),
('BND045', 'FEST020', '2024-11-19', 90, 2, 138500),
('BND046', 'FEST001', '2024-09-10', 75, 1, 140000),
('BND046', 'FEST002', '2024-12-10', 90, 2, 141000),
('BND047', 'FEST003', '2024-10-11', 75, 1, 142500),
('BND047', 'FEST004', '2024-01-11', 90, 2, 143500),
('BND048', 'FEST005', '2024-11-12', 75, 1, 145000),
('BND048', 'FEST006', '2024-02-12', 90, 2, 146000),
('BND049', 'FEST007', '2024-12-13', 75, 1, 147500),
('BND049', 'FEST008', '2024-03-13', 90, 2, 148500),
('BND050', 'FEST009', '2024-01-14', 75, 1, 150000),
('BND050', 'FEST010', '2024-04-14', 90, 2, 151000);
INSERT INTO gira VALUES
('GIR200', 'Lacuna Coil World Circuit', 'BND026', '2024-03-01', '2024-11-30', 45, 1500000),
('GIR201', 'Nightwish World Circuit', 'BND027', '2024-03-01', '2024-11-30', 46, 1620000),
('GIR202', 'Within Temptation World Circuit', 'BND028', '2024-03-01', '2024-11-30', 47, 1740000),
('GIR203', 'Epica World Circuit', 'BND029', '2024-03-01', '2024-11-30', 48, 1860000),
('GIR204', 'Kamelot World Circuit', 'BND030', '2024-03-01', '2024-11-30', 49, 1980000),
('GIR205', 'Sabaton World Circuit', 'BND031', '2024-03-01', '2024-11-30', 50, 2100000),
('GIR206', 'Avantasia World Circuit', 'BND032', '2024-03-01', '2024-11-30', 51, 2220000),
('GIR207', 'Trivium World Circuit', 'BND033', '2024-03-01', '2024-11-30', 52, 2340000),
('GIR208', 'Gojira World Circuit', 'BND034', '2024-03-01', '2024-11-30', 53, 2460000),
('GIR209', 'Mastodon World Circuit', 'BND035', '2024-03-01', '2024-11-30', 54, 2580000),
('GIR210', 'Opeth World Circuit', 'BND036', '2024-03-01', '2024-11-30', 45, 2700000),
('GIR211', 'Lamb of God World Circuit', 'BND037', '2024-03-01', '2024-11-30', 46, 2820000),
('GIR212', 'Parkway Drive World Circuit', 'BND038', '2024-03-01', '2024-11-30', 47, 2940000),
('GIR213', 'Architects World Circuit', 'BND039', '2024-03-01', '2024-11-30', 48, 3060000),
('GIR214', 'Jinjer World Circuit', 'BND040', '2024-03-01', '2024-11-30', 49, 3180000),
('GIR215', 'Spiritbox World Circuit', 'BND041', '2024-03-01', '2024-11-30', 50, 3300000),
('GIR216', 'Babymetal World Circuit', 'BND042', '2024-03-01', '2024-11-30', 51, 3420000),
('GIR217', 'Powerwolf World Circuit', 'BND043', '2024-03-01', '2024-11-30', 52, 3540000),
('GIR218', 'Ghost World Circuit', 'BND044', '2024-03-01', '2024-11-30', 53, 3660000),
('GIR219', 'Tesseract World Circuit', 'BND045', '2024-03-01', '2024-11-30', 54, 3780000),
('GIR220', 'Polaris World Circuit', 'BND046', '2024-03-01', '2024-11-30', 45, 3900000),
('GIR221', 'Soen World Circuit', 'BND047', '2024-03-01', '2024-11-30', 46, 4020000),
('GIR222', 'Leprous World Circuit', 'BND048', '2024-03-01', '2024-11-30', 47, 4140000),
('GIR223', 'Katatonia World Circuit', 'BND049', '2024-03-01', '2024-11-30', 48, 4260000),
('GIR224', 'The Hu World Circuit', 'BND050', '2024-03-01', '2024-11-30', 49, 4380000);
INSERT INTO premio VALUES
('PREM200', 'Premio Vanguard Lacuna Coil', 2015, 'Innovación Sonora', 'Italia', 25000, 'BND026', 'ALB200', 'CAN200'),
('PREM201', 'Premio Vanguard Nightwish', 2016, 'Innovación Sonora', 'Finlandia', 25500, 'BND027', 'ALB203', 'CAN209'),
('PREM202', 'Premio Vanguard Within Temptation', 2017, 'Innovación Sonora', 'Países Bajos', 26000, 'BND028', 'ALB206', 'CAN218'),
('PREM203', 'Premio Vanguard Epica', 2018, 'Innovación Sonora', 'Países Bajos', 26500, 'BND029', 'ALB209', 'CAN227'),
('PREM204', 'Premio Vanguard Kamelot', 2019, 'Innovación Sonora', 'Estados Unidos', 27000, 'BND030', 'ALB212', 'CAN236'),
('PREM205', 'Premio Vanguard Sabaton', 2020, 'Innovación Sonora', 'Suecia', 27500, 'BND031', 'ALB215', 'CAN245'),
('PREM206', 'Premio Vanguard Avantasia', 2021, 'Innovación Sonora', 'Alemania', 28000, 'BND032', 'ALB218', 'CAN254'),
('PREM207', 'Premio Vanguard Trivium', 2022, 'Innovación Sonora', 'Estados Unidos', 28500, 'BND033', 'ALB221', 'CAN263'),
('PREM208', 'Premio Vanguard Gojira', 2015, 'Innovación Sonora', 'Francia', 29000, 'BND034', 'ALB224', 'CAN272'),
('PREM209', 'Premio Vanguard Mastodon', 2016, 'Innovación Sonora', 'Estados Unidos', 29500, 'BND035', 'ALB227', 'CAN281'),
('PREM210', 'Premio Vanguard Opeth', 2017, 'Innovación Sonora', 'Suecia', 30000, 'BND036', 'ALB230', 'CAN290'),
('PREM211', 'Premio Vanguard Lamb of God', 2018, 'Innovación Sonora', 'Estados Unidos', 30500, 'BND037', 'ALB233', 'CAN299'),
('PREM212', 'Premio Vanguard Parkway Drive', 2019, 'Innovación Sonora', 'Australia', 31000, 'BND038', 'ALB236', 'CAN308'),
('PREM213', 'Premio Vanguard Architects', 2020, 'Innovación Sonora', 'Reino Unido', 31500, 'BND039', 'ALB239', 'CAN317'),
('PREM214', 'Premio Vanguard Jinjer', 2021, 'Innovación Sonora', 'Ucrania', 32000, 'BND040', 'ALB242', 'CAN326'),
('PREM215', 'Premio Vanguard Spiritbox', 2022, 'Innovación Sonora', 'Canadá', 32500, 'BND041', 'ALB245', 'CAN335'),
('PREM216', 'Premio Vanguard Babymetal', 2015, 'Innovación Sonora', 'Japón', 33000, 'BND042', 'ALB248', 'CAN344'),
('PREM217', 'Premio Vanguard Powerwolf', 2016, 'Innovación Sonora', 'Alemania', 33500, 'BND043', 'ALB251', 'CAN353'),
('PREM218', 'Premio Vanguard Ghost', 2017, 'Innovación Sonora', 'Suecia', 34000, 'BND044', 'ALB254', 'CAN362'),
('PREM219', 'Premio Vanguard Tesseract', 2018, 'Innovación Sonora', 'Reino Unido', 34500, 'BND045', 'ALB257', 'CAN371'),
('PREM220', 'Premio Vanguard Polaris', 2019, 'Innovación Sonora', 'Australia', 35000, 'BND046', 'ALB260', 'CAN380'),
('PREM221', 'Premio Vanguard Soen', 2020, 'Innovación Sonora', 'Suecia', 35500, 'BND047', 'ALB263', 'CAN389'),
('PREM222', 'Premio Vanguard Leprous', 2021, 'Innovación Sonora', 'Noruega', 36000, 'BND048', 'ALB266', 'CAN398'),
('PREM223', 'Premio Vanguard Katatonia', 2022, 'Innovación Sonora', 'Suecia', 36500, 'BND049', 'ALB269', 'CAN407'),
('PREM224', 'Premio Vanguard The Hu', 2015, 'Innovación Sonora', 'Mongolia', 37000, 'BND050', 'ALB272', 'CAN416');
INSERT INTO critica VALUES
('CRIT200', 'Prog Archive', 8.20, 'ALB200', '1998-09-01', 'Auto Reviewer', 'Global'),
('CRIT201', 'Prog Archive', 8.70, 'ALB201', '2001-09-01', 'Auto Reviewer', 'Global'),
('CRIT202', 'Prog Archive', 9.20, 'ALB202', '2004-09-01', 'Auto Reviewer', 'Global'),
('CRIT203', 'Prog Archive', 8.20, 'ALB203', '2000-09-01', 'Auto Reviewer', 'Global'),
('CRIT204', 'Prog Archive', 8.70, 'ALB204', '2003-09-01', 'Auto Reviewer', 'Global'),
('CRIT205', 'Prog Archive', 9.20, 'ALB205', '2006-09-01', 'Auto Reviewer', 'Global'),
('CRIT206', 'Prog Archive', 8.20, 'ALB206', '2000-09-01', 'Auto Reviewer', 'Global'),
('CRIT207', 'Prog Archive', 8.70, 'ALB207', '2003-09-01', 'Auto Reviewer', 'Global'),
('CRIT208', 'Prog Archive', 9.20, 'ALB208', '2006-09-01', 'Auto Reviewer', 'Global'),
('CRIT209', 'Prog Archive', 8.20, 'ALB209', '2006-09-01', 'Auto Reviewer', 'Global'),
('CRIT210', 'Prog Archive', 8.70, 'ALB210', '2009-09-01', 'Auto Reviewer', 'Global'),
('CRIT211', 'Prog Archive', 9.20, 'ALB211', '2012-09-01', 'Auto Reviewer', 'Global'),
('CRIT212', 'Prog Archive', 8.20, 'ALB212', '1995-09-01', 'Auto Reviewer', 'Global'),
('CRIT213', 'Prog Archive', 8.70, 'ALB213', '1998-09-01', 'Auto Reviewer', 'Global'),
('CRIT214', 'Prog Archive', 9.20, 'ALB214', '2001-09-01', 'Auto Reviewer', 'Global'),
('CRIT215', 'Prog Archive', 8.20, 'ALB215', '2003-09-01', 'Auto Reviewer', 'Global'),
('CRIT216', 'Prog Archive', 8.70, 'ALB216', '2006-09-01', 'Auto Reviewer', 'Global'),
('CRIT217', 'Prog Archive', 9.20, 'ALB217', '2009-09-01', 'Auto Reviewer', 'Global'),
('CRIT218', 'Prog Archive', 8.20, 'ALB218', '2005-09-01', 'Auto Reviewer', 'Global'),
('CRIT219', 'Prog Archive', 8.70, 'ALB219', '2008-09-01', 'Auto Reviewer', 'Global'),
('CRIT220', 'Prog Archive', 9.20, 'ALB220', '2011-09-01', 'Auto Reviewer', 'Global'),
('CRIT221', 'Prog Archive', 8.20, 'ALB221', '2003-09-01', 'Auto Reviewer', 'Global'),
('CRIT222', 'Prog Archive', 8.70, 'ALB222', '2006-09-01', 'Auto Reviewer', 'Global'),
('CRIT223', 'Prog Archive', 9.20, 'ALB223', '2009-09-01', 'Auto Reviewer', 'Global'),
('CRIT224', 'Prog Archive', 8.20, 'ALB224', '2000-09-01', 'Auto Reviewer', 'Global'),
('CRIT225', 'Prog Archive', 8.70, 'ALB225', '2003-09-01', 'Auto Reviewer', 'Global'),
('CRIT226', 'Prog Archive', 9.20, 'ALB226', '2006-09-01', 'Auto Reviewer', 'Global'),
('CRIT227', 'Prog Archive', 8.20, 'ALB227', '2004-09-01', 'Auto Reviewer', 'Global'),
('CRIT228', 'Prog Archive', 8.70, 'ALB228', '2007-09-01', 'Auto Reviewer', 'Global'),
('CRIT229', 'Prog Archive', 9.20, 'ALB229', '2010-09-01', 'Auto Reviewer', 'Global'),
('CRIT230', 'Prog Archive', 8.20, 'ALB230', '1994-09-01', 'Auto Reviewer', 'Global'),
('CRIT231', 'Prog Archive', 8.70, 'ALB231', '1997-09-01', 'Auto Reviewer', 'Global'),
('CRIT232', 'Prog Archive', 9.20, 'ALB232', '2000-09-01', 'Auto Reviewer', 'Global'),
('CRIT233', 'Prog Archive', 8.20, 'ALB233', '1998-09-01', 'Auto Reviewer', 'Global'),
('CRIT234', 'Prog Archive', 8.70, 'ALB234', '2001-09-01', 'Auto Reviewer', 'Global'),
('CRIT235', 'Prog Archive', 9.20, 'ALB235', '2004-09-01', 'Auto Reviewer', 'Global'),
('CRIT236', 'Prog Archive', 8.20, 'ALB236', '2007-09-01', 'Auto Reviewer', 'Global'),
('CRIT237', 'Prog Archive', 8.70, 'ALB237', '2010-09-01', 'Auto Reviewer', 'Global'),
('CRIT238', 'Prog Archive', 9.20, 'ALB238', '2013-09-01', 'Auto Reviewer', 'Global'),
('CRIT239', 'Prog Archive', 8.20, 'ALB239', '2008-09-01', 'Auto Reviewer', 'Global'),
('CRIT240', 'Prog Archive', 8.70, 'ALB240', '2011-09-01', 'Auto Reviewer', 'Global'),
('CRIT241', 'Prog Archive', 9.20, 'ALB241', '2014-09-01', 'Auto Reviewer', 'Global'),
('CRIT242', 'Prog Archive', 8.20, 'ALB242', '2013-09-01', 'Auto Reviewer', 'Global'),
('CRIT243', 'Prog Archive', 8.70, 'ALB243', '2016-09-01', 'Auto Reviewer', 'Global'),
('CRIT244', 'Prog Archive', 9.20, 'ALB244', '2019-09-01', 'Auto Reviewer', 'Global'),
('CRIT245', 'Prog Archive', 8.20, 'ALB245', '2021-09-01', 'Auto Reviewer', 'Global'),
('CRIT246', 'Prog Archive', 8.70, 'ALB246', '2024-09-01', 'Auto Reviewer', 'Global'),
('CRIT247', 'Prog Archive', 9.20, 'ALB247', '2024-09-01', 'Auto Reviewer', 'Global'),
('CRIT248', 'Prog Archive', 8.20, 'ALB248', '2014-09-01', 'Auto Reviewer', 'Global'),
('CRIT249', 'Prog Archive', 8.70, 'ALB249', '2017-09-01', 'Auto Reviewer', 'Global'),
('CRIT250', 'Prog Archive', 9.20, 'ALB250', '2020-09-01', 'Auto Reviewer', 'Global'),
('CRIT251', 'Prog Archive', 8.20, 'ALB251', '2007-09-01', 'Auto Reviewer', 'Global'),
('CRIT252', 'Prog Archive', 8.70, 'ALB252', '2010-09-01', 'Auto Reviewer', 'Global'),
('CRIT253', 'Prog Archive', 9.20, 'ALB253', '2013-09-01', 'Auto Reviewer', 'Global'),
('CRIT254', 'Prog Archive', 8.20, 'ALB254', '2010-09-01', 'Auto Reviewer', 'Global'),
('CRIT255', 'Prog Archive', 8.70, 'ALB255', '2013-09-01', 'Auto Reviewer', 'Global'),
('CRIT256', 'Prog Archive', 9.20, 'ALB256', '2016-09-01', 'Auto Reviewer', 'Global'),
('CRIT257', 'Prog Archive', 8.20, 'ALB257', '2007-09-01', 'Auto Reviewer', 'Global'),
('CRIT258', 'Prog Archive', 8.70, 'ALB258', '2010-09-01', 'Auto Reviewer', 'Global'),
('CRIT259', 'Prog Archive', 9.20, 'ALB259', '2013-09-01', 'Auto Reviewer', 'Global'),
('CRIT260', 'Prog Archive', 8.20, 'ALB260', '2016-09-01', 'Auto Reviewer', 'Global'),
('CRIT261', 'Prog Archive', 8.70, 'ALB261', '2019-09-01', 'Auto Reviewer', 'Global'),
('CRIT262', 'Prog Archive', 9.20, 'ALB262', '2022-09-01', 'Auto Reviewer', 'Global'),
('CRIT263', 'Prog Archive', 8.20, 'ALB263', '2014-09-01', 'Auto Reviewer', 'Global'),
('CRIT264', 'Prog Archive', 8.70, 'ALB264', '2017-09-01', 'Auto Reviewer', 'Global'),
('CRIT265', 'Prog Archive', 9.20, 'ALB265', '2020-09-01', 'Auto Reviewer', 'Global'),
('CRIT266', 'Prog Archive', 8.20, 'ALB266', '2005-09-01', 'Auto Reviewer', 'Global'),
('CRIT267', 'Prog Archive', 8.70, 'ALB267', '2008-09-01', 'Auto Reviewer', 'Global'),
('CRIT268', 'Prog Archive', 9.20, 'ALB268', '2011-09-01', 'Auto Reviewer', 'Global'),
('CRIT269', 'Prog Archive', 8.20, 'ALB269', '1995-09-01', 'Auto Reviewer', 'Global'),
('CRIT270', 'Prog Archive', 8.70, 'ALB270', '1998-09-01', 'Auto Reviewer', 'Global'),
('CRIT271', 'Prog Archive', 9.20, 'ALB271', '2001-09-01', 'Auto Reviewer', 'Global'),
('CRIT272', 'Prog Archive', 8.20, 'ALB272', '2020-09-01', 'Auto Reviewer', 'Global'),
('CRIT273', 'Prog Archive', 8.70, 'ALB273', '2023-09-01', 'Auto Reviewer', 'Global'),
('CRIT274', 'Prog Archive', 9.20, 'ALB274', '2024-09-01', 'Auto Reviewer', 'Global');
INSERT INTO colaboracion VALUES
('NB001', 'NB002', 'CAN200', 'Invitado especial'),
('NB003', 'NB004', 'CAN201', 'Invitado especial'),
('NB005', 'NB006', 'CAN202', 'Invitado especial'),
('NB007', 'NB008', 'CAN203', 'Invitado especial'),
('NB009', 'NB010', 'CAN204', 'Invitado especial'),
('NB011', 'NB012', 'CAN205', 'Invitado especial'),
('NB013', 'NB014', 'CAN206', 'Invitado especial'),
('NB015', 'NB016', 'CAN207', 'Invitado especial'),
('NB017', 'NB018', 'CAN208', 'Invitado especial'),
('NB019', 'NB020', 'CAN209', 'Invitado especial'),
('NB021', 'NB022', 'CAN210', 'Invitado especial'),
('NB023', 'NB024', 'CAN211', 'Invitado especial'),
('NB025', 'NB026', 'CAN212', 'Invitado especial'),
('NB027', 'NB028', 'CAN213', 'Invitado especial'),
('NB029', 'NB030', 'CAN214', 'Invitado especial'),
('NB031', 'NB032', 'CAN215', 'Invitado especial'),
('NB033', 'NB034', 'CAN216', 'Invitado especial'),
('NB035', 'NB036', 'CAN217', 'Invitado especial'),
('NB037', 'NB038', 'CAN218', 'Invitado especial'),
('NB039', 'NB040', 'CAN219', 'Invitado especial'),
('NB041', 'NB042', 'CAN220', 'Invitado especial'),
('NB043', 'NB044', 'CAN221', 'Invitado especial'),
('NB045', 'NB046', 'CAN222', 'Invitado especial'),
('NB047', 'NB048', 'CAN223', 'Invitado especial'),
('NB049', 'NB050', 'CAN224', 'Invitado especial'),
('NB051', 'NB052', 'CAN225', 'Invitado especial'),
('NB053', 'NB054', 'CAN226', 'Invitado especial'),
('NB055', 'NB056', 'CAN227', 'Invitado especial'),
('NB057', 'NB058', 'CAN228', 'Invitado especial'),
('NB059', 'NB060', 'CAN229', 'Invitado especial'),
('NB061', 'NB062', 'CAN230', 'Invitado especial'),
('NB063', 'NB064', 'CAN231', 'Invitado especial'),
('NB065', 'NB066', 'CAN232', 'Invitado especial'),
('NB067', 'NB068', 'CAN233', 'Invitado especial'),
('NB069', 'NB070', 'CAN234', 'Invitado especial'),
('NB071', 'NB072', 'CAN235', 'Invitado especial'),
('NB073', 'NB074', 'CAN236', 'Invitado especial'),
('NB075', 'NB076', 'CAN237', 'Invitado especial'),
('NB077', 'NB078', 'CAN238', 'Invitado especial'),
('NB079', 'NB080', 'CAN239', 'Invitado especial'),
('NB081', 'NB082', 'CAN240', 'Invitado especial'),
('NB083', 'NB084', 'CAN241', 'Invitado especial'),
('NB085', 'NB086', 'CAN242', 'Invitado especial'),
('NB087', 'NB088', 'CAN243', 'Invitado especial'),
('NB089', 'NB090', 'CAN244', 'Invitado especial'),
('NB091', 'NB092', 'CAN245', 'Invitado especial'),
('NB093', 'NB094', 'CAN246', 'Invitado especial'),
('NB095', 'NB096', 'CAN247', 'Invitado especial'),
('NB097', 'NB098', 'CAN248', 'Invitado especial'),
('NB099', 'NB100', 'CAN249', 'Invitado especial'),
('NB101', 'NB102', 'CAN250', 'Invitado especial'),
('NB103', 'NB104', 'CAN251', 'Invitado especial'),
('NB105', 'NB106', 'CAN252', 'Invitado especial'),
('NB107', 'NB108', 'CAN253', 'Invitado especial'),
('NB109', 'NB110', 'CAN254', 'Invitado especial'),
('NB111', 'NB112', 'CAN255', 'Invitado especial'),
('NB113', 'NB114', 'CAN256', 'Invitado especial'),
('NB115', 'NB116', 'CAN257', 'Invitado especial'),
('NB117', 'NB118', 'CAN258', 'Invitado especial'),
('NB119', 'NB120', 'CAN259', 'Invitado especial'),
('NB121', 'NB122', 'CAN260', 'Invitado especial'),
('NB123', 'NB124', 'CAN261', 'Invitado especial');


/* CREAR VISTAS ÚTILES */
/* ================================================================================ */

/* Vista de bandas activas con información completa */
CREATE OR REPLACE VIEW v_bandas_activas AS
SELECT 
    b.cod_banda,
    b.nombre,
    b.pais,
    b.anio_formacion,
    b.genero,
    COUNT(DISTINCT al.cod_album) as total_albums,
    COUNT(DISTINCT i.dni) as miembros_actuales,
    COALESCE(SUM(al.ventas), 0) as ventas_totales,
    YEAR(CURDATE()) - b.anio_formacion as anios_activa
FROM banda b
LEFT JOIN album al ON b.cod_banda = al.cod_banda
LEFT JOIN integra i ON b.cod_banda = i.cod_banda AND i.fecha_salida IS NULL
WHERE b.activa = TRUE
GROUP BY b.cod_banda, b.nombre, b.pais, b.anio_formacion, b.genero;

/* Vista de álbumes con información de críticas */
CREATE OR REPLACE VIEW v_albums_criticas AS
SELECT 
    al.cod_album,
    al.titulo,
    b.nombre as banda,
    al.anio_lanzamiento,
    al.tipo,
    al.ventas,
    COUNT(cr.cod_critica) as numero_criticas,
    ROUND(AVG(cr.puntuacion), 2) as puntuacion_promedio,
    MAX(cr.puntuacion) as mejor_puntuacion,
    MIN(cr.puntuacion) as peor_puntuacion
FROM album al
INNER JOIN banda b ON al.cod_banda = b.cod_banda
LEFT JOIN critica cr ON al.cod_album = cr.cod_album
GROUP BY al.cod_album, al.titulo, b.nombre, al.anio_lanzamiento, al.tipo, al.ventas;

/* Vista de festivales con estadísticas */
CREATE OR REPLACE VIEW v_festivales_stats AS
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

/* Vista de músicos con carrera detallada */
CREATE OR REPLACE VIEW v_musicos_carrera AS
SELECT 
    m.dni,
    m.nombre,
    m.apellidos,
    m.pais_origen,
    m.instrumento_principal,
    COUNT(DISTINCT i.cod_banda) as bandas_total,
    COUNT(DISTINCT CASE WHEN i.fecha_salida IS NULL THEN i.cod_banda END) as bandas_actuales,
    MIN(i.fecha_entrada) as inicio_carrera,
    MAX(CASE WHEN i.fecha_salida IS NULL THEN CURDATE() ELSE i.fecha_salida END) as fin_carrera,
    COUNT(DISTINCT col1.cod_cancion) + COUNT(DISTINCT col2.cod_cancion) as colaboraciones_total
FROM musico m
LEFT JOIN integra i ON m.dni = i.dni
LEFT JOIN colaboracion col1 ON m.dni = col1.dni_musico1
LEFT JOIN colaboracion col2 ON m.dni = col2.dni_musico2 AND col2.dni_musico1 != m.dni
GROUP BY m.dni, m.nombre, m.apellidos, m.pais_origen, m.instrumento_principal;

/* Vista de giras más rentables */
CREATE OR REPLACE VIEW v_giras_rentables AS
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

/* PROCEDIMIENTOS ALMACENADOS */
/* ================================================================================ */

DROP PROCEDURE IF EXISTS sp_agregar_musico_banda;
DROP PROCEDURE IF EXISTS sp_estadisticas_genero;
DROP PROCEDURE IF EXISTS sp_top_bandas;

DELIMITER //

/* Procedimiento para agregar un nuevo músico a una banda */
CREATE PROCEDURE sp_agregar_musico_banda(
    IN p_dni VARCHAR(15),
    IN p_cod_banda VARCHAR(10),
    IN p_instrumento VARCHAR(50),
    IN p_es_fundador BOOLEAN
)
BEGIN
    DECLARE v_existe_musico INT DEFAULT 0;
    DECLARE v_existe_banda INT DEFAULT 0;
    DECLARE v_banda_activa BOOLEAN DEFAULT FALSE;
    
    /* Verificar si existe el músico */
    SELECT COUNT(*) INTO v_existe_musico FROM musico WHERE dni = p_dni;
    
    /* Verificar si existe la banda y está activa */
    SELECT COUNT(*), MAX(activa) INTO v_existe_banda, v_banda_activa 
    FROM banda WHERE cod_banda = p_cod_banda;
    
    IF v_existe_musico = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El músico no existe en la base de datos';
    ELSEIF v_existe_banda = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La banda no existe';
    ELSEIF v_banda_activa = FALSE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede agregar músicos a una banda inactiva';
    ELSE
        INSERT INTO integra (dni, cod_banda, fecha_entrada, instrumento, es_fundador)
        VALUES (p_dni, p_cod_banda, CURDATE(), p_instrumento, p_es_fundador);
        
        SELECT 'Músico agregado exitosamente a la banda' as resultado;
    END IF;
END //

/* Procedimiento para calcular estadísticas de un género */
CREATE PROCEDURE sp_estadisticas_genero(IN p_genero VARCHAR(50))
BEGIN
    SELECT 
        p_genero as genero,
        COUNT(DISTINCT b.cod_banda) as total_bandas,
        COUNT(DISTINCT al.cod_album) as total_albums,
        ROUND(AVG(al.ventas), 0) as ventas_promedio,
        SUM(al.ventas) as ventas_totales,
        MIN(b.anio_formacion) as banda_mas_antigua,
        MAX(b.anio_formacion) as banda_mas_nueva,
        COUNT(DISTINCT f.cod_festival) as festivales_participados,
        COUNT(DISTINCT p.cod_premio) as premios_totales
    FROM banda b
    LEFT JOIN album al ON b.cod_banda = al.cod_banda
    LEFT JOIN actuacion act ON b.cod_banda = act.cod_banda
    LEFT JOIN festival f ON act.cod_festival = f.cod_festival
    LEFT JOIN premio p ON b.cod_banda = p.cod_banda
    WHERE b.genero = p_genero;
END //

/* Procedimiento para obtener el top de bandas por criterio */
CREATE PROCEDURE sp_top_bandas(
    IN p_criterio VARCHAR(20), -- 'ventas', 'albums', 'premios', 'giras'
    IN p_limite INT
)
BEGIN
    CASE p_criterio
        WHEN 'ventas' THEN
            SELECT b.nombre, SUM(al.ventas) as total_ventas
            FROM banda b 
            INNER JOIN album al ON b.cod_banda = al.cod_banda
            GROUP BY b.cod_banda, b.nombre
            ORDER BY total_ventas DESC
            LIMIT p_limite;
            
        WHEN 'albums' THEN
            SELECT b.nombre, COUNT(al.cod_album) as total_albums
            FROM banda b 
            INNER JOIN album al ON b.cod_banda = al.cod_banda
            GROUP BY b.cod_banda, b.nombre
            ORDER BY total_albums DESC
            LIMIT p_limite;
            
        WHEN 'premios' THEN
            SELECT b.nombre, COUNT(p.cod_premio) as total_premios
            FROM banda b 
            INNER JOIN premio p ON b.cod_banda = p.cod_banda
            GROUP BY b.cod_banda, b.nombre
            ORDER BY total_premios DESC
            LIMIT p_limite;
            
        WHEN 'giras' THEN
            SELECT b.nombre, SUM(g.recaudacion_total) as recaudacion_total
            FROM banda b 
            INNER JOIN gira g ON b.cod_banda = g.cod_banda
            GROUP BY b.cod_banda, b.nombre
            ORDER BY recaudacion_total DESC
            LIMIT p_limite;
            
        ELSE
            SELECT 'Criterio no válido. Use: ventas, albums, premios, giras' as error;
    END CASE;
END //

DELIMITER ;

/* FUNCIONES ÚTILES */
/* ================================================================================ */

DROP FUNCTION IF EXISTS fn_edad_banda;
DROP FUNCTION IF EXISTS fn_album_mas_vendido;
DROP FUNCTION IF EXISTS fn_promedio_criticas_banda;

DELIMITER //

/* Función para calcular la edad de una banda */
CREATE FUNCTION fn_edad_banda(p_cod_banda VARCHAR(10))
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_anio_formacion INT;
    SELECT anio_formacion INTO v_anio_formacion 
    FROM banda 
    WHERE cod_banda = p_cod_banda;
    
    RETURN YEAR(CURDATE()) - COALESCE(v_anio_formacion, YEAR(CURDATE()));
END //

/* Función para obtener el álbum más vendido de una banda */
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

/* Función para calcular el promedio de críticas de una banda */
CREATE FUNCTION fn_promedio_criticas_banda(p_cod_banda VARCHAR(10))
RETURNS DECIMAL(3,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_promedio DECIMAL(3,2);
    SELECT AVG(cr.puntuacion) INTO v_promedio
    FROM album al
    INNER JOIN critica cr ON al.cod_album = cr.cod_album
    WHERE al.cod_banda = p_cod_banda;
    
    RETURN COALESCE(v_promedio, 0.00);
END //

DELIMITER ;

/* TRIGGERS PARA INTEGRIDAD DE DATOS */
/* ================================================================================ */

DROP TRIGGER IF EXISTS tr_validar_fechas_integracion;
DROP TRIGGER IF EXISTS tr_log_album_insert;
DROP TRIGGER IF EXISTS tr_validar_puntuacion_critica;
DROP TRIGGER IF EXISTS tr_validar_cachet_actuacion;

DELIMITER //

/* Trigger para validar fechas de integración */
CREATE TRIGGER tr_validar_fechas_integracion
BEFORE INSERT ON integra
FOR EACH ROW
BEGIN
    DECLARE v_anio_formacion INT;
    
    SELECT anio_formacion INTO v_anio_formacion
    FROM banda
    WHERE cod_banda = NEW.cod_banda;
    
    IF YEAR(NEW.fecha_entrada) < v_anio_formacion THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La fecha de entrada no puede ser anterior a la formación de la banda';
    END IF;
    
    IF NEW.fecha_salida IS NOT NULL AND NEW.fecha_salida <= NEW.fecha_entrada THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La fecha de salida debe ser posterior a la fecha de entrada';
    END IF;
END //

/* Trigger para validar puntuaciones de críticas */
CREATE TRIGGER tr_validar_puntuacion_critica
BEFORE INSERT ON critica
FOR EACH ROW
BEGIN
    IF NEW.puntuacion < 0 OR NEW.puntuacion > 10 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La puntuación debe estar entre 0 y 10';
    END IF;
END //

/* Trigger para validar cachets de actuaciones */
CREATE TRIGGER tr_validar_cachet_actuacion
BEFORE INSERT ON actuacion
FOR EACH ROW
BEGIN
    IF NEW.cachet < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El cachet no puede ser negativo';
    END IF;
    
    IF NEW.duracion_show < 30 OR NEW.duracion_show > 300 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La duración del show debe estar entre 30 y 300 minutos';
    END IF;
END //

DELIMITER ;

/* CONSULTAS DE VERIFICACIÓN FINAL */
/* ================================================================================ */

/* Verificar que todas las tablas tienen datos */
SELECT 'VERIFICACIÓN DE DATOS INSERTADOS' as titulo;

SELECT 
    'BANDAS' as tabla,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN activa = TRUE THEN 1 END) as bandas_activas,
    COUNT(CASE WHEN activa = FALSE THEN 1 END) as bandas_inactivas
FROM banda

UNION ALL

SELECT 
    'MÚSICOS' as tabla,
    COUNT(*) as total_registros,
    COUNT(DISTINCT pais_origen) as paises_origen,
    COUNT(DISTINCT instrumento_principal) as instrumentos_diferentes
FROM musico

UNION ALL

SELECT 
    'ÁLBUMES' as tabla,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN tipo = 'Estudio' THEN 1 END) as albums_estudio,
    COUNT(CASE WHEN tipo = 'En vivo' THEN 1 END) as albums_vivo
FROM album

UNION ALL

SELECT 
    'CANCIONES' as tabla,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN es_single = TRUE THEN 1 END) as singles,
    COUNT(CASE WHEN letra_explicita = TRUE THEN 1 END) as con_letra_explicita
FROM cancion

UNION ALL

SELECT 
    'FESTIVALES' as tabla,
    COUNT(*) as total_registros,
    COUNT(DISTINCT pais) as paises_festivales,
    AVG(capacidad_maxima) as capacidad_promedio
FROM festival

UNION ALL

SELECT 
    'ACTUACIONES' as tabla,
    COUNT(*) as total_registros,
    COUNT(DISTINCT cod_banda) as bandas_actuaron,
    AVG(cachet) as cachet_promedio
FROM actuacion

UNION ALL

SELECT 
    'GIRAS' as tabla,
    COUNT(*) as total_registros,
    AVG(numero_conciertos) as conciertos_promedio,
    SUM(recaudacion_total) as recaudacion_total_general
FROM gira

UNION ALL

SELECT 
    'PREMIOS' as tabla,
    COUNT(*) as total_registros,
    COUNT(DISTINCT categoria) as categorias_diferentes,
    COUNT(DISTINCT pais_premio) as paises_premios
FROM premio

UNION ALL

SELECT 
    'CRÍTICAS' as tabla,
    COUNT(*) as total_registros,
    AVG(puntuacion) as puntuacion_promedio,
    COUNT(DISTINCT critico) as criticos_diferentes
FROM critica

UNION ALL

SELECT 
    'COLABORACIONES' as tabla,
    COUNT(*) as total_registros,
    COUNT(DISTINCT tipo_colaboracion) as tipos_colaboracion,
    COUNT(DISTINCT cod_cancion) as canciones_con_colaboraciones
FROM colaboracion;

/* Mostrar algunas estadísticas interesantes */
SELECT 'ESTADÍSTICAS GENERALES' as titulo;

SELECT 
    b.genero,
    COUNT(*) as num_bandas,
    AVG(YEAR(CURDATE()) - b.anio_formacion) as edad_promedio,
    SUM(al.ventas) as ventas_totales_genero
FROM banda b
LEFT JOIN album al ON b.cod_banda = al.cod_banda
GROUP BY b.genero
ORDER BY ventas_totales_genero DESC;

/* Verificar integridad referencial */
SELECT 'VERIFICACIÓN DE INTEGRIDAD REFERENCIAL' as titulo;

/* Verificar que no hay registros huérfanos */
SELECT 
    'Albums sin banda' as verificacion,
    COUNT(*) as registros_problematicos
FROM album al
LEFT JOIN banda b ON al.cod_banda = b.cod_banda
WHERE b.cod_banda IS NULL

UNION ALL

SELECT 
    'Canciones sin álbum' as verificacion,
    COUNT(*) as registros_problematicos
FROM cancion ca
LEFT JOIN album al ON ca.cod_album = al.cod_album
WHERE al.cod_album IS NULL

UNION ALL

SELECT 
    'Integraciones sin músico' as verificacion,
    COUNT(*) as registros_problematicos
FROM integra i
LEFT JOIN musico m ON i.dni = m.dni
WHERE m.dni IS NULL

UNION ALL

SELECT 
    'Integraciones sin banda' as verificacion,
    COUNT(*) as registros_problematicos
FROM integra i
LEFT JOIN banda b ON i.cod_banda = b.cod_banda
WHERE b.cod_banda IS NULL;

/* Mensaje final de instalación */
SELECT 
    '🎸 BASE DE DATOS ROCK & METAL INSTALADA CORRECTAMENTE 🎸' as estado,
    'Todas las tablas, datos, vistas, procedimientos y triggers han sido creados' as detalle,
    CONCAT('Total de ', 
           (SELECT COUNT(*) FROM banda), ' bandas, ',
           (SELECT COUNT(*) FROM musico), ' músicos, ',
           (SELECT COUNT(*) FROM album), ' álbumes y ',
           (SELECT COUNT(*) FROM cancion), ' canciones cargadas') as resumen;
