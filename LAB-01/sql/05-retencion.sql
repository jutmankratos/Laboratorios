-- LAB-01 | 05. Retención de datos
-- El periodo didáctico del ejercicio es de cinco años.

SELECT *
FROM clientes
WHERE fecha_alta < CURRENT_DATE - INTERVAL '5 years';
