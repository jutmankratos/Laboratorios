-- LAB-02 | Actividad 1: Protección de credenciales

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Ejemplo inseguro: la contraseña queda legible en la tabla.
CREATE TABLE usuarios_insegura (
    usuario VARCHAR(50) PRIMARY KEY,
    password VARCHAR(100) NOT NULL
);

INSERT INTO usuarios_insegura (usuario, password)
VALUES ('juan_demo', 'Password123');

-- La consulta permite ver la contraseña en texto claro.
SELECT usuario, password
FROM usuarios_insegura;

-- Ejemplo protegido: se almacena un hash con salt usando bcrypt.
CREATE TABLE usuarios_segura (
    usuario VARCHAR(50) PRIMARY KEY,
    password_hash TEXT NOT NULL
);

INSERT INTO usuarios_segura (usuario, password_hash)
VALUES (
    'juan_demo',
    crypt('Password123', gen_salt('bf'))
);

-- El hash no es la contraseña original y no se puede descifrar.
SELECT usuario, password_hash
FROM usuarios_segura;

-- Verifica la contraseña comparándola con el hash guardado.
SELECT usuario
FROM usuarios_segura
WHERE password_hash = crypt('Password123', password_hash);

-- Prueba una contraseña incorrecta.

SELECT usuario
FROM usuarios_segura
WHERE password_hash = crypt('OtraPassword', password_hash);



