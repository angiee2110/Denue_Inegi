#sp_alta_segura
DELIMITER //

CREATE PROCEDURE sp_act_alta_segura(
    IN p_codigo_act VARCHAR(10),
    IN p_nombre_act VARCHAR(250)
)
BEGIN
    -- Validar que el código o nombre no estén registrados
    IF EXISTS (
        SELECT 1
        FROM actividad
        WHERE codigo_act = p_codigo_act
           OR nombre_act = p_nombre_act
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: la actividad economica ya existe';

    ELSE

        -- Insertar la nueva actividad
        INSERT INTO actividad (codigo_act, nombre_act)
        VALUES (p_codigo_act, p_nombre_act);

        SELECT 'Actividad registrada correctamente' AS mensaje;

    END IF;
END //

DELIMITER ;

#sp_actividad_actualizar
DELIMITER //

CREATE PROCEDURE sp_act_actualizar(
    IN p_codigo_act VARCHAR(10),
    IN p_nuevo_nombre VARCHAR(250)
)
BEGIN
    -- Verificar que la actividad exista
    IF NOT EXISTS (
        SELECT 1
        FROM actividad
        WHERE codigo_act = p_codigo_act
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: la actividad no existe';

    ELSE

        -- Verificar que el nuevo nombre no esté duplicado
        IF EXISTS (
            SELECT 1
            FROM actividad
            WHERE nombre_act = p_nuevo_nombre
              AND codigo_act <> p_codigo_act
        ) THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: el nombre ya pertenece a otra actividad';

        ELSE

            -- Actualizar el nombre de la actividad
            UPDATE actividad
            SET nombre_act = p_nuevo_nombre
            WHERE codigo_act = p_codigo_act;

            SELECT 'Actividad actualizada correctamente' AS mensaje;

        END IF;
    END IF;
END //

DELIMITER ;

#sp_act_consultar_por_sector

DELIMITER //

CREATE PROCEDURE sp_act_consultar_por_sector(
    IN p_sector VARCHAR(2),
    IN p_texto VARCHAR(250)
)
BEGIN

    SELECT
        a.codigo_act AS Codigo,
        a.nombre_act AS Actividad,
        LEFT(a.codigo_act, 2) AS Sector,
        COUNT(e.id) AS Total_Establecimientos

    FROM actividad AS a

    LEFT JOIN establecimiento AS e
        ON a.codigo_act = e.codigo_act

    WHERE
        (p_sector IS NULL
         OR LEFT(a.codigo_act, 2) = p_sector)

	AND (
		p_texto IS NULL OR p_texto = ''
		OR a.codigo_act LIKE CONCAT('%', p_texto, '%')
		OR a.nombre_act LIKE CONCAT('%', p_texto, '%'))

    GROUP BY
        a.codigo_act,
        a.nombre_act

    ORDER BY
        Total_Establecimientos DESC;

END //

DELIMITER ;

SHOW PROCEDURE STATUS
WHERE Db = 'taller de base de datos';