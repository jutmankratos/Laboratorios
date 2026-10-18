## 19. Informe

### 19.1 Clasificación

Los datos que requieren mayor protección son `nombre`, `correo`, `telefono` y `rfc`, porque identifican directamente a una persona o permiten contactarla. El RFC merece cuidado especial por su carácter fiscal y su capacidad de vincular registros. `edad`, `ciudad` y `codigo_postal` son cuasi-identificadores: por separado quizá no identifiquen a alguien, pero al combinarse pueden reducir mucho el grupo de personas posibles. `id` es un identificador interno que permite enlazar registros dentro del sistema, y `fecha_alta` es un dato operativo que también podría ayudar a reconocer a una persona al cruzarse con otras fuentes.

### 19.2 Enmascaramiento

- **Qué se ocultó:** partes del correo, el teléfono y el RFC.
- **Para quién:** para el personal de soporte, mediante el rol `soporte`.
- **Por qué:** para que pueda atender consultas sin ver los valores completos de contacto e identificación fiscal.
- **Mecanismo utilizado:** una vista llamada `v_clientes_soporte` que muestra versiones parciales de esos datos. Se concede lectura sobre la vista y se busca impedir el acceso directo a la tabla `clientes`.

### 19.3 Seudonimización

- **Cómo se generaron los tokens:** con `gen_random_uuid()`, que genera un UUID para cada cliente.
- **Dónde se encuentra el mapa:** en `pii.mapa_cliente`, que relaciona el token con el identificador original.
- **Quién debería poder acceder a él:** solo personal autorizado que necesite reidentificar registros por una finalidad aprobada; el rol `analista` no debería acceder al mapa.
- **Por qué se separaron los permisos:** para que el área de analítica trabaje con tokens y atributos reducidos sin poder vincularlos directamente con la identidad original. Esto aplica mínimo privilegio y separación de funciones.

### 19.4 Anonimización

- **Qué identificadores fueron eliminados:** la salida agregada no muestra nombre, correo, teléfono, RFC, identificador de cliente ni token.
- **Qué atributos fueron generalizados:** la edad se agrupa en `18-30`, `31-45` y `46+`; el código postal se reduce a sus dos primeros caracteres.
- **Qué grupos fueron suprimidos:** los que tienen menos de cinco registros. Con los cinco datos de ejemplo, la combinación más grande contiene tres filas, así que se espera que no aparezcan grupos.
- **Qué riesgo de reidentificación permanece:** el rango de edad y la región aún pueden combinarse con datos externos. También podrían influir otros atributos o fechas. El umbral `k=5` es didáctico y no garantiza por sí solo anonimato completo.

### 19.5 Retención

- **Qué criterio se utilizó:** identificar registros cuya `fecha_alta` sea anterior a la fecha actual menos cinco años. La consulta localiza candidatos y no ejecuta `DELETE`.
- **Qué información debería conservarse:** solo la necesaria para la finalidad del negocio y durante el plazo autorizado o requerido por la organización.
- **Qué información podría eliminarse:** los registros que hayan superado el periodo aprobado y ya no tengan una finalidad o necesidad vigente, después de revisar obligaciones y excepciones aplicables.
- **Qué controles deberían existir antes de eliminarla:** una política de retención justificada, revisión y aprobación del responsable, respaldo verificado y protegido, ejecución controlada, registro de la decisión y un procedimiento de recuperación ante eliminación accidental.

### 19.6 Conclusiones

- **¿Qué técnica utilizarías para un área de soporte?** Enmascaramiento mediante una vista que exponga solo los campos necesarios, junto con permisos que impidan consultar directamente los datos originales.
- **¿Qué técnica utilizarías para un área de analítica?** Seudonimización, con tokens y el mapa de correspondencia aislado y accesible solo a personal autorizado.
- **¿Qué técnica utilizarías para publicar estadísticas?** Agregación, generalización de atributos y supresión de grupos pequeños; también revisaría el riesgo de reidentificación antes de publicar.
- **¿Por qué ninguna de estas técnicas sustituye al control de acceso?** Porque enmascarar o transformar la presentación no impide por sí mismo que una persona lea las tablas originales. Los permisos definen quién puede acceder; las técnicas de privacidad reducen qué información se expone después del acceso autorizado.

## 20. Preguntas de reflexión

1. **¿Cuál es la diferencia entre enmascaramiento y seudonimización?** El enmascaramiento oculta parte de un valor al mostrarlo. La seudonimización sustituye identificadores por tokens y conserva por separado un mapa que puede volver a vincularlos con la persona.
2. **¿Por qué la seudonimización no significa anonimización?** Porque el mapa u otra información adicional puede permitir asociar el token con la identidad original.
3. **¿Por qué eliminar `nombre` y `RFC` no garantiza que un conjunto de datos sea anónimo?** Porque edad, ubicación, fechas y sus combinaciones pueden distinguir a una persona, sobre todo al cruzarse con fuentes externas.
4. **¿Qué función tienen los cuasi-identificadores?** Son atributos que no identifican necesariamente por sí solos, pero combinados pueden reducir el grupo de personas posibles y facilitar una reidentificación.
5. **¿Por qué es importante separar el mapa de seudonimización?** Para limitar quién puede relacionar los tokens con identidades y reducir el daño si el conjunto analítico se expone.
6. **¿Qué principio de seguridad se aplica al impedir que el analista acceda al mapa?** El principio de mínimo privilegio y la separación de funciones.
7. **¿Por qué una vista puede ser preferible a entregar acceso directo a la tabla?** Porque permite mostrar únicamente las columnas y transformaciones necesarias y otorgar permisos sobre esa presentación sin revelar toda la tabla original.
8. **¿Qué diferencia existe entre proteger un dato para visualización y protegerlo contra acceso no autorizado?** El enmascaramiento cambia cómo se presenta el dato; los permisos controlan quién puede leerlo. El enmascaramiento no reemplaza la autorización.
9. **¿Por qué la retención forma parte de la protección de datos?** Porque conservar información más tiempo del necesario prolonga su exposición a accesos indebidos, filtraciones y usos no previstos.
10. **¿Qué riesgo existe si una organización conserva información indefinidamente?** Aumentan el tiempo de exposición, el impacto potencial de una filtración y la posibilidad de que los datos se usen o relacionen con otros fuera de su finalidad original.
