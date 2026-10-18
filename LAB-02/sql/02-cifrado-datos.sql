-- LAB-02 | Actividad 2: Cifrado de información sensible

CREATE TABLE clientes_protegidos (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    rfc_cifrado BYTEA NOT NULL
);

INSERT INTO clientes_protegidos (nombre, rfc_cifrado)
VALUES (
    'Cliente de prueba',
    pgp_sym_encrypt('RFC-FICTICIO-001', 'CLAVE-DE-PRUEBA')
);

-- Muestra el dato cifrado almacenado (BYTEA).
SELECT id, nombre, rfc_cifrado
FROM clientes_protegidos;

-- Descifra el dato usando la misma clave de laboratorio.
SELECT
    id,
    nombre,
    pgp_sym_decrypt(rfc_cifrado, 'CLAVE-DE-PRUEBA') AS rfc_descifrado
FROM clientes_protegidos;

-- clave incorrecta
SELECT pgp_sym_decrypt(rfc_cifrado, 'CLAVE-INCORRECTA') FROM clientes_protegidos;