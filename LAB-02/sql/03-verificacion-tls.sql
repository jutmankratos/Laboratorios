-- LAB-02 | Verificación del estado de TLS en PostgreSQL
-- Estas consultas solo leen la configuración y el estado de la sesión.

SHOW ssl;
SHOW ssl_min_protocol_version;
SHOW port;
SHOW listen_addresses;

SELECT
    inet_client_addr() AS direccion_cliente,
    inet_client_port() AS puerto_cliente;

-- ssl = true indica que esta sesión usa TLS.
-- version y cipher muestran el protocolo y el cifrado negociados.
SELECT
    ssl,
    version,
    cipher
FROM pg_stat_ssl
WHERE pid = pg_backend_pid();
