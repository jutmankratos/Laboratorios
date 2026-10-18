-- LAB-01 | 05. Retención de datos
-- El periodo didáctico del ejercicio es de cinco años.
-- Esta consulta identifica registros para revisión; no los elimina.

SELECT *
FROM clientes
WHERE fecha_alta < CURRENT_DATE - INTERVAL '5 years';

-- No ejecutar DELETE sobre la tabla principal en esta práctica.
