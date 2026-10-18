# LAB-02 — Cifrado, credenciales y comunicaciones seguras

**Estudiante:** Diego Villarreal Lopez  
**Entorno:** PostgreSQL 18.6 en Windows, administrado con pgAdmin; extensión `pgcrypto`.

## 1. Introducción

El objetivo de este laboratorio fue practicar formas distintas de proteger credenciales y datos sensibles en PostgreSQL. Se comparó el almacenamiento de contraseñas en texto claro con el uso de hashes, se cifró y descifró un dato ficticio, se analizaron medidas para proteger las claves y se comprobó el uso de TLS en una conexión.

Las pruebas utilizaron únicamente valores ficticios. El dato `RFC-FICTICIO-001`, las contraseñas de demostración y las claves de laboratorio no corresponden a información real.

## 2. Protección de credenciales

Se creó una tabla de demostración insegura (`usuarios_insegura`) que guarda una contraseña en texto claro. La consulta permitió verla directamente. Después se creó `usuarios_segura`, que almacena el resultado de `crypt()` con `gen_salt('bf')`, usando bcrypt con salt.

La contraseña correcta (`Password123`) encontró el usuario `juan_demo`; la contraseña incorrecta (`OtraPassword`) no devolvió filas. Un hash sirve para verificar una contraseña sin guardar la contraseña original y no se descifra como si fuera texto cifrado. Para recuperar un dato original se requiere cifrado reversible, no un hash.

La comparación y sus capturas están en [evidencias/07-comparacion.md](evidencias/07-comparacion.md) y [evidencias/01-credenciales.md](evidencias/01-credenciales.md).

## 3. Cifrado de información sensible

Se cifró el valor ficticio `RFC-FICTICIO-001` con `pgp_sym_encrypt()` y la clave de laboratorio `CLAVE-DE-PRUEBA`, guardándolo en una columna `BYTEA`. La lectura mostró contenido binario cifrado. Al usar `pgp_sym_decrypt()` con la clave correcta, se recuperó el valor original. Con `CLAVE-INCORRECTA`, PostgreSQL devolvió `Wrong key or corrupt data` (SQLSTATE 39000), por lo que no se recuperó el dato.

Al volver a ejecutar el bloque de creación, PostgreSQL indicó que `clientes_protegidos` ya existía (SQLSTATE 42P07). La tabla ya se había creado en una ejecución previa; no fue un error de cifrado. Las consultas posteriores permitieron verificar el registro existente.

Los pasos y capturas están documentados en [evidencias/08-analisis-escenario.md](evidencias/08-analisis-escenario.md) y [evidencias/02-cifrado-datos.md](evidencias/02-cifrado-datos.md).

## 4. Gestión de claves

Una clave escrita dentro de un script queda visible para quien tenga acceso al archivo. Si el script se comparte o se sube al repositorio, la clave puede exponerse; incluso si después se borra, puede permanecer en el historial de Git o en respaldos. La demostración temporal usó una clave ficticia y el archivo demostrativo se eliminó.

Las claves reales deben mantenerse fuera del código y del repositorio, con acceso limitado y respaldos protegidos. Si una clave se expone, debe reemplazarse y evaluarse qué datos protegía. La política propuesta se encuentra en [evidencias/10-politica-claves.md](evidencias/10-politica-claves.md), y el ejercicio se explica en [evidencias/03-gestion-claves.md](evidencias/03-gestion-claves.md).

## 5. Comunicaciones seguras con TLS

Al inicio, `SHOW ssl` devolvió `off` y la sesión consultada en `pg_stat_ssl` mostró `ssl = false`, sin versión ni cifrado. Se generaron un certificado y una clave locales de prueba para PostgreSQL, se habilitó SSL en `postgresql.conf` y se recargó la configuración. Después, `SHOW ssl` devolvió `on`.

La comprobación inicial de la sesión todavía devolvió `false` porque se ejecutó desde otra conexión/base de datos. En la conexión del laboratorio, la consulta final a `pg_stat_ssl` devolvió `ssl = true` y `version = TLSv1.3`; la columna también mostró el cifrado negociado, aunque su nombre quedó truncado en la captura. El mínimo configurado fue `TLSv1.2`, el puerto fue `5432`, `listen_addresses` devolvió `*` y la dirección de cliente observada fue `::1` (loopback IPv6).

La evidencia detallada está en [evidencias/04-tls.md](evidencias/04-tls.md). La captura final confirma TLS 1.3 en la sesión del laboratorio; la captura anterior sin TLS se conserva como parte del diagnóstico inicial.

## 6. Resultados

- Se observó que una contraseña guardada en texto claro puede leerse directamente desde la tabla.
- Se verificó una contraseña usando bcrypt: la correcta encontró al usuario y la incorrecta no.
- Se cifró un valor ficticio y se recuperó con la clave correcta; una clave incorrecta produjo el error esperado.
- Se identificó el riesgo de incluir claves en scripts y se propusieron medidas para protegerlas.
- Se habilitó SSL en PostgreSQL y se confirmó una sesión TLS 1.3 mediante `pg_stat_ssl`.

Las capturas y explicaciones están organizadas en la carpeta [evidencias](evidencias/).

## 7. Problemas encontrados y resolución

- **La tabla `clientes_protegidos` ya existía (42P07):** se continuó con las consultas de lectura y descifrado, sin volver a crear la tabla.
- **La clave incorrecta produjo `Wrong key or corrupt data` (39000):** era el resultado esperado al intentar descifrar con una clave distinta.
- **La primera sesión indicó `ssl = false`:** se identificó que la consulta se estaba realizando desde otra conexión/base de datos. La verificación repetida en la conexión del laboratorio mostró `ssl = true` y TLS 1.3.
- **La primera generación del certificado falló por el formato de `-subj` en Git Bash:** se corrigió la conversión de rutas de MSYS y se generaron `server.crt` y `server.key` en el directorio de datos de PostgreSQL.

## 8. Conclusiones

El laboratorio mostró que el hash y el cifrado resuelven necesidades distintas: el hash permite verificar contraseñas sin guardar su forma original, mientras que el cifrado permite recuperar datos mediante una clave. La protección del cifrado depende de mantener esa clave confidencial y recuperable de forma controlada.

También se comprobó que activar SSL en el servidor no basta para demostrar que una sesión concreta usa TLS. La vista `pg_stat_ssl` permitió verificarlo para la conexión del laboratorio, que negoció TLS 1.3. El certificado utilizado fue de prueba y local; este ejercicio no constituye una configuración validada para producción.

## 9. Preguntas de reflexión

1. **¿Por qué no conviene almacenar contraseñas en texto claro?** Quien obtenga acceso a la tabla podría leerlas directamente. Un hash de contraseña dificulta recuperar el valor original y permite comprobarlo sin almacenarlo en claro.
2. **¿Cuál es la diferencia entre hash y cifrado?** El hash es una transformación de una sola vía destinada a verificación; el cifrado es reversible con la clave adecuada.
3. **¿Qué ocurre si se pierde o se expone una clave de cifrado?** Si se pierde, los datos pueden quedar inaccesibles. Si se expone, quien la obtenga podría descifrar los datos protegidos; se debe sustituir la clave y evaluar el impacto.
4. **¿Cómo se comprobó que la conexión utiliza TLS?** La consulta a `pg_stat_ssl` para el proceso de la sesión devolvió `ssl = true`, `version = TLSv1.3` y un valor de cifrado.
5. **¿Qué diferencia hay entre el mínimo TLS configurado y la versión negociada?** `ssl_min_protocol_version` establece la versión mínima permitida; `pg_stat_ssl.version` indica la versión realmente negociada por esa sesión. En la prueba fueron TLS 1.2 como mínimo y TLS 1.3 negociado.
