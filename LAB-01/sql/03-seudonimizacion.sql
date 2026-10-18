-- LAB-01 | 03. Seudonimización y separación de funciones

CREATE SCHEMA pii;
CREATE SCHEMA analitica;

CREATE TABLE pii.mapa_cliente (
    token UUID PRIMARY KEY,
    cliente_id BIGINT UNIQUE REFERENCES clientes(id)
);

CREATE EXTENSION pgcrypto;

INSERT INTO pii.mapa_cliente (token, cliente_id)
SELECT gen_random_uuid(), id
FROM clientes;

CREATE TABLE analitica.clientes AS
SELECT
    mapa.token AS cliente_token,
    clientes.edad,
    clientes.ciudad,
    clientes.codigo_postal,
    clientes.fecha_alta
FROM pii.mapa_cliente AS mapa
JOIN clientes ON clientes.id = mapa.cliente_id;

CREATE ROLE analista NOLOGIN;
GRANT USAGE ON SCHEMA analitica TO analista;
GRANT SELECT ON analitica.clientes TO analista;
REVOKE ALL ON pii.mapa_cliente FROM analista;
REVOKE ALL ON public.clientes FROM analista;

SELECT * FROM analitica.clientes;