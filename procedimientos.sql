use db_asistencia;

-- select SHA2('77354960',256);
-- call verificar_usuario('rg.raul200@gmail.com','77354960');

DROP PROCEDURE IF EXISTS verificar_usuario;
DELIMITER $$
CREATE PROCEDURE verificar_usuario (
    IN username_input VARCHAR(50),
    IN password_input VARCHAR(255)
)
BEGIN
    DECLARE user_exists INT DEFAULT 0;
    DECLARE id_usuario INT DEFAULT NULL;
    DECLARE nombres_usuario VARCHAR(100);
    DECLARE apellidos_usuario VARCHAR(100);
    DECLARE stored_password VARCHAR(255);
    DECLARE rol_usuario ENUM('admin', 'docente', 'auxiliar');

    -- Obtener los datos del usuario si existe y está activo
    SELECT u.id, u.nombres, u.apellidos, u.password_hash, u.rol
    INTO id_usuario, nombres_usuario, apellidos_usuario, stored_password, rol_usuario
    FROM usuario u
    WHERE u.username = username_input AND u.estado = 'activo'
    LIMIT 1;

    -- Verificar si la contraseña es correcta
    IF id_usuario IS NOT NULL AND stored_password = SHA2(password_input, 256) THEN
        SET user_exists = 1;
    ELSE
        SET id_usuario = NULL;
        SET nombres_usuario = NULL;
        SET apellidos_usuario = NULL;
        SET rol_usuario = NULL;
    END IF;

    -- Retornar el estado y los datos del usuario si es válido
    SELECT user_exists AS status, id_usuario AS id, nombres_usuario AS nombres, apellidos_usuario AS apellidos, rol_usuario AS rol;
END$$
DELIMITER ;




-- ================================= USUARIOS ============================================
DROP PROCEDURE IF EXISTS CrearUsuario;
DELIMITER $$
CREATE PROCEDURE CrearUsuario(
    IN p_username VARCHAR(50),
    IN p_password TEXT,
    IN p_nombres VARCHAR(100),
    IN p_apellidos VARCHAR(100),
    IN p_rol ENUM('admin', 'docente', 'auxiliar'),
    IN p_estado ENUM('activo', 'inactivo')
)
BEGIN
    DECLARE usuario_existente INT;
    SELECT COUNT(*) INTO usuario_existente FROM usuario WHERE username = p_username;
    IF usuario_existente = 0 THEN
        INSERT INTO usuario (username, password_hash, nombres, apellidos, rol, estado)
        VALUES (p_username, SHA2(p_password, 256), p_nombres, p_apellidos, p_rol, p_estado);
        SELECT 'Usuario creado correctamente.' AS mensaje, 1 AS cod;
    ELSE
        SELECT 'Ya existe un usuario con ese nombre de usuario.' AS mensaje, 0 AS cod;
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS ActualizarUsuario;
DELIMITER $$
CREATE PROCEDURE ActualizarUsuario(
    IN p_id INT,
    IN p_username VARCHAR(50),
    IN p_password TEXT,
    IN p_nombres VARCHAR(100),
    IN p_apellidos VARCHAR(100),
    IN p_rol ENUM('admin', 'docente', 'auxiliar'),
    IN p_estado ENUM('activo', 'inactivo')
)
BEGIN
    DECLARE usuario_existente INT;
    SELECT COUNT(*) INTO usuario_existente 
    FROM usuario 
    WHERE username = p_username AND id != p_id;

    IF usuario_existente = 0 THEN
        IF p_password = '-' THEN
            -- No actualizar contraseña
            UPDATE usuario
            SET username = p_username,
                nombres = p_nombres,
                apellidos = p_apellidos,
                rol = p_rol,
                estado = p_estado
            WHERE id = p_id;
        ELSE
            -- Actualizar también la contraseña
            UPDATE usuario
            SET username = p_username,
                password_hash = SHA2(p_password, 256),
                nombres = p_nombres,
                apellidos = p_apellidos,
                rol = p_rol,
                estado = p_estado
            WHERE id = p_id;
        END IF;

        SELECT 'Usuario actualizado correctamente.' AS mensaje, 1 AS cod;
    ELSE
        SELECT 'Ya existe un usuario con ese nombre de usuario.' AS mensaje, 0 AS cod;
    END IF;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS EliminarUsuario;
DELIMITER $$
CREATE PROCEDURE EliminarUsuario(
    IN p_id INT
)
BEGIN
    -- Verificar si el usuario está vinculado a otras tablas (si las hubiera)
    DELETE FROM usuario WHERE id = p_id;
    SELECT 'Usuario eliminado correctamente.' AS mensaje, 1 AS cod;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS ObtenerUsuario;
DELIMITER $$
CREATE PROCEDURE ObtenerUsuario(
    IN p_id INT
)
BEGIN
    SELECT id, username, nombres, apellidos, rol, estado, fecha_creacion
    FROM usuario
    WHERE id = p_id;
END$$
DELIMITER ;



-- ================================= HORARIOS ============================================
DROP PROCEDURE IF EXISTS CrearHorario;
DELIMITER $$
CREATE PROCEDURE CrearHorario(
    IN p_nombre_horario VARCHAR(100),
    IN p_hora_inicio TIME,
    IN p_hora_fin TIME,
    IN p_minutos_tolerancia_entrada INT
)
BEGIN
    DECLARE horario_existente INT;
    SELECT COUNT(*) INTO horario_existente FROM horarios WHERE nombre_horario = p_nombre_horario;
    IF horario_existente = 0 THEN
        INSERT INTO horarios (nombre_horario, hora_inicio, hora_fin, minutos_tolerancia_entrada)
        VALUES (p_nombre_horario, p_hora_inicio, p_hora_fin, p_minutos_tolerancia_entrada);
        SELECT 'Horario creado correctamente.' AS mensaje, 1 AS cod;
    ELSE
        SELECT 'Ya existe un horario con ese nombre.' AS mensaje, 0 AS cod;
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS ActualizarHorario;
DELIMITER $$
CREATE PROCEDURE ActualizarHorario(
    IN p_id INT,
    IN p_nombre_horario VARCHAR(100),
    IN p_hora_inicio TIME,
    IN p_hora_fin TIME,
    IN p_minutos_tolerancia_entrada INT
)
BEGIN
    DECLARE horario_existente INT;
    SELECT COUNT(*) INTO horario_existente 
    FROM horarios 
    WHERE nombre_horario = p_nombre_horario AND id != p_id;
    IF horario_existente = 0 THEN
        UPDATE horarios
        SET nombre_horario = p_nombre_horario,
            hora_inicio = p_hora_inicio,
            hora_fin = p_hora_fin,
            minutos_tolerancia_entrada = p_minutos_tolerancia_entrada
        WHERE id = p_id;
        SELECT 'Horario actualizado correctamente.' AS mensaje, 1 AS cod;
    ELSE
        SELECT 'Ya existe un horario con ese nombre.' AS mensaje, 0 AS cod;
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS EliminarHorario;
DELIMITER $$
CREATE PROCEDURE EliminarHorario(
    IN p_id INT
)
BEGIN
    DECLARE horario_vinculado INT;
    SELECT COUNT(*) INTO horario_vinculado
    FROM alumno
    WHERE id_horario = p_id;
    IF horario_vinculado > 0 THEN
        SELECT 'No se puede eliminar el horario porque está vinculado a alumnos.' AS mensaje, 0 AS cod;
    ELSE
        DELETE FROM horarios WHERE id = p_id;
        SELECT 'Horario eliminado correctamente.' AS mensaje, 1 AS cod;
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS ObtenerHorario;
DELIMITER $$
CREATE PROCEDURE ObtenerHorario(
    IN p_id INT
)
BEGIN
    SELECT id, nombre_horario, hora_inicio, hora_fin, minutos_tolerancia_entrada
    FROM horarios
    WHERE id = p_id;
END$$
DELIMITER ;



-- ================================= ALUMNOS ============================================
DROP PROCEDURE IF EXISTS CrearAlumno;
DELIMITER $$
CREATE PROCEDURE CrearAlumno(
    IN p_codigo_modular VARCHAR(20),
    IN p_nombres VARCHAR(100),
    IN p_apellido_paterno VARCHAR(100),
    IN p_apellido_materno VARCHAR(100),
    IN p_dni CHAR(8),
    IN p_grado ENUM('1°', '2°', '3°', '4°', '5°', '6°'),
    IN p_seccion ENUM('A', 'B', 'C', 'D', 'E'),
    IN p_nivel ENUM('primaria', 'secundaria'),
    IN p_apoderado_nombre VARCHAR(150),
    IN p_apoderado_telefono VARCHAR(15),
    IN p_id_horario INT,
    IN p_estado ENUM('matriculado', 'retirado', 'trasladado')
)
BEGIN
    DECLARE alumno_existente_codigo INT;
    DECLARE alumno_existente_dni INT;
    DECLARE horario_existe INT;
    
    -- Verificar si existe el horario
    SELECT COUNT(*) INTO horario_existe FROM horarios WHERE id = p_id_horario;
    IF horario_existe = 0 THEN
        SELECT 'El horario especificado no existe.' AS mensaje, 0 AS cod;
    ELSE
        -- Verificar código modular único
        SELECT COUNT(*) INTO alumno_existente_codigo FROM alumno WHERE codigo_modular = p_codigo_modular;
        -- Verificar DNI único
        SELECT COUNT(*) INTO alumno_existente_dni FROM alumno WHERE dni = p_dni;
        
        IF alumno_existente_codigo > 0 THEN
            SELECT 'Ya existe un alumno con ese código modular.' AS mensaje, 0 AS cod;
        ELSEIF alumno_existente_dni > 0 THEN
            SELECT 'Ya existe un alumno con ese DNI.' AS mensaje, 0 AS cod;
        ELSE
            INSERT INTO alumno (codigo_modular, nombres, apellido_paterno, apellido_materno, dni, grado, seccion, nivel, apoderado_nombre, apoderado_telefono, id_horario, estado)
            VALUES (p_codigo_modular, p_nombres, p_apellido_paterno, p_apellido_materno, p_dni, p_grado, p_seccion, p_nivel, p_apoderado_nombre, p_apoderado_telefono, p_id_horario, p_estado);
            SELECT 'Alumno creado correctamente.' AS mensaje, 1 AS cod;
        END IF;
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS ActualizarAlumno;
DELIMITER $$
CREATE PROCEDURE ActualizarAlumno(
    IN p_id INT,
    IN p_codigo_modular VARCHAR(20),
    IN p_nombres VARCHAR(100),
    IN p_apellido_paterno VARCHAR(100),
    IN p_apellido_materno VARCHAR(100),
    IN p_dni CHAR(8),
    IN p_grado ENUM('1°', '2°', '3°', '4°', '5°', '6°'),
    IN p_seccion ENUM('A', 'B', 'C', 'D', 'E'),
    IN p_nivel ENUM('primaria', 'secundaria'),
    IN p_apoderado_nombre VARCHAR(150),
    IN p_apoderado_telefono VARCHAR(15),
    IN p_id_horario INT,
    IN p_estado ENUM('matriculado', 'retirado', 'trasladado')
)
BEGIN
    DECLARE alumno_existente_codigo INT;
    DECLARE alumno_existente_dni INT;
    DECLARE horario_existe INT;
    
    -- Verificar si existe el horario
    SELECT COUNT(*) INTO horario_existe FROM horarios WHERE id = p_id_horario;
    IF horario_existe = 0 THEN
        SELECT 'El horario especificado no existe.' AS mensaje, 0 AS cod;
    ELSE
        -- Verificar código modular único (excluyendo el alumno actual)
        SELECT COUNT(*) INTO alumno_existente_codigo 
        FROM alumno 
        WHERE codigo_modular = p_codigo_modular AND id != p_id;
        
        -- Verificar DNI único (excluyendo el alumno actual)
        SELECT COUNT(*) INTO alumno_existente_dni 
        FROM alumno 
        WHERE dni = p_dni AND id != p_id;
        
        IF alumno_existente_codigo > 0 THEN
            SELECT 'Ya existe un alumno con ese código modular.' AS mensaje, 0 AS cod;
        ELSEIF alumno_existente_dni > 0 THEN
            SELECT 'Ya existe un alumno con ese DNI.' AS mensaje, 0 AS cod;
        ELSE
            UPDATE alumno
            SET codigo_modular = p_codigo_modular,
                nombres = p_nombres,
                apellido_paterno = p_apellido_paterno,
                apellido_materno = p_apellido_materno,
                dni = p_dni,
                grado = p_grado,
                seccion = p_seccion,
                nivel = p_nivel,
                apoderado_nombre = p_apoderado_nombre,
                apoderado_telefono = p_apoderado_telefono,
                id_horario = p_id_horario,
                estado = p_estado
            WHERE id = p_id;
            SELECT 'Alumno actualizado correctamente.' AS mensaje, 1 AS cod;
        END IF;
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS EliminarAlumno;
DELIMITER $$
CREATE PROCEDURE EliminarAlumno(
    IN p_id INT
)
BEGIN
    -- Aquí podrían agregarse validaciones si el alumno está vinculado a otras tablas
    DELETE FROM alumno WHERE id = p_id;
    SELECT 'Alumno eliminado correctamente.' AS mensaje, 1 AS cod;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS ObtenerAlumno;
DELIMITER $$
CREATE PROCEDURE ObtenerAlumno(
    IN p_id INT
)
BEGIN
    SELECT a.id, a.codigo_modular, a.nombres, a.apellido_paterno, a.apellido_materno, 
           a.dni, a.grado, a.seccion, a.nivel, a.apoderado_nombre, a.apoderado_telefono,
           a.id_horario, h.nombre_horario, a.estado
    FROM alumno a
    INNER JOIN horarios h ON a.id_horario = h.id
    WHERE a.id = p_id;
END$$
DELIMITER ;




DROP PROCEDURE IF EXISTS buscar_alumno;
DELIMITER $$
CREATE PROCEDURE buscar_alumno (
    IN filtro VARCHAR(100)
)
BEGIN
    SELECT 
        a.id,
        a.codigo_modular,
        a.nombres,
        a.apellido_paterno,
        a.apellido_materno,
        a.dni,
        a.grado,
        a.seccion,
        a.nivel,
        a.apoderado_nombre,
        a.apoderado_telefono,
        a.estado,
        a.id_horario
    FROM alumno a
    WHERE 
        a.estado = 'matriculado' 
        AND (
            a.codigo_modular LIKE CONCAT('%', filtro, '%') OR
            a.dni LIKE CONCAT('%', filtro, '%') OR
            CONCAT(a.nombres, ' ', a.apellido_paterno, ' ', a.apellido_materno) LIKE CONCAT('%', filtro, '%')
        );
END$$
DELIMITER ;




-- ================================================= EMBEDDDING ============================================
DROP PROCEDURE IF EXISTS eliminar_embedding_faciales;
DELIMITER //
CREATE PROCEDURE eliminar_embedding_faciales (
    IN p_id INT,
    OUT p_type INT,
    OUT p_message VARCHAR(255),
    OUT p_id_eliminado INT
)
BEGIN
    DECLARE existe_id INT;

    -- Verificar si existe el ID
    SELECT id INTO existe_id FROM embeddings_faciales WHERE id = p_id LIMIT 1;

    IF existe_id IS NOT NULL THEN
        -- Eliminar el registro
        DELETE FROM embeddings_faciales WHERE id = existe_id;

        -- Retornar datos de eliminación
        SET p_type = 1;
        SET p_message = CONCAT('Embedding facial eliminado correctamente. ID eliminado: ', existe_id);
        SET p_id_eliminado = existe_id;
    ELSE
        -- No se encontró el ID
        SET p_type = 0;
        SET p_message = CONCAT('No se encontró el embedding con ID: ', p_id);
        SET p_id_eliminado = NULL;
    END IF;

    -- Este SELECT devuelve el resultado directo a Laravel como si fuera un SELECT normal
    SELECT p_type AS type, p_message AS message, p_id_eliminado AS id_eliminado;
END;
//
DELIMITER ;



DROP PROCEDURE IF EXISTS sp_guardar_embedding;
DELIMITER $
CREATE PROCEDURE sp_guardar_embedding(
    IN p_alumno_id INT,
    IN p_vector_embedding LONGTEXT,
    OUT p_embedding_id INT,
    OUT p_mensaje VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1
            p_mensaje = MESSAGE_TEXT;
        SET p_embedding_id = -1;
    END;
    
    START TRANSACTION;
    -- Verificar que el alumno existe
    IF NOT EXISTS (SELECT 1 FROM alumno WHERE id = p_alumno_id) THEN
        SET p_embedding_id = -1;
        SET p_mensaje = 'El alumno no existe';
        ROLLBACK;
    ELSE
        -- Siempre insertar nuevo embedding
        INSERT INTO embeddings_faciales (alumno_id, vector_embedding) 
        VALUES (p_alumno_id, p_vector_embedding);
        
        SET p_embedding_id = LAST_INSERT_ID();
        SET p_mensaje = 'Embedding guardado correctamente';
        COMMIT;
    END IF;
END$
DELIMITER ;



-- ====================================================== asistenias ===============================================
drop procedure if exists ListarFechasAsistencias;
DELIMITER $$
CREATE PROCEDURE ListarFechasAsistencias()
BEGIN
    -- Establecer idioma en español
    SET lc_time_names = 'es_ES';

    -- Seleccionar fechas únicas y legibles
    SELECT DISTINCT
        fecha,
        DATE_FORMAT(fecha, '%W %d de %M de %Y') AS fecha_legible
    FROM registro_asistencia
    ORDER BY fecha DESC;
END $$
DELIMITER ;




drop procedure if exists sp_listado_asistencias;
DELIMITER //
CREATE PROCEDURE sp_listado_asistencias(
    IN p_fecha DATE,
    IN p_grado ENUM('1°', '2°', '3°', '4°', '5°', '6°'),
    IN p_nivel ENUM('primaria', 'secundaria')
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Crear tabla temporal para el reporte
    CREATE TEMPORARY TABLE temp_reporte_asistencia (
        alumno_id INT,
        codigo_modular VARCHAR(20),
        nombres_completos VARCHAR(300),
        grado VARCHAR(3),
        seccion VARCHAR(1),
        nivel VARCHAR(20),
        estado_asistencia VARCHAR(20),
        hora_registro TIME,
        observaciones VARCHAR(200),
        horario_entrada TIME,
        minutos_tolerancia INT
    );

    -- Insertar alumnos que SÍ tienen registro de asistencia (PRESENTES o TARDANZAS)
    INSERT INTO temp_reporte_asistencia (
        alumno_id, codigo_modular, nombres_completos, grado, seccion, nivel,
        estado_asistencia, hora_registro, observaciones, horario_entrada, minutos_tolerancia
    )
    SELECT 
        a.id,
        a.codigo_modular,
        CONCAT(a.nombres, ' ', a.apellido_paterno, ' ', a.apellido_materno) as nombres_completos,
        a.grado,
        a.seccion,
        a.nivel,
        CASE 
            WHEN ra.estado_asistencia = 'presente' THEN 'PRESENTE'
            WHEN ra.estado_asistencia = 'tardanza' THEN 'TARDANZA'
        END as estado_asistencia,
        ra.hora_registro,
        ra.observaciones,
        h.hora_inicio,
        h.minutos_tolerancia_entrada
    FROM alumno a
    INNER JOIN registro_asistencia ra ON a.id = ra.alumno_id
    INNER JOIN horarios h ON a.id_horario = h.id
    WHERE ra.fecha = p_fecha
        AND a.grado = p_grado
        AND a.nivel = p_nivel
        AND a.estado = 'matriculado';

    -- Insertar alumnos que NO tienen registro de asistencia (FALTARON)
    INSERT INTO temp_reporte_asistencia (
        alumno_id, codigo_modular, nombres_completos, grado, seccion, nivel,
        estado_asistencia, hora_registro, observaciones, horario_entrada, minutos_tolerancia
    )
    SELECT 
        a.id,
        a.codigo_modular,
        CONCAT(a.nombres, ' ', a.apellido_paterno, ' ', a.apellido_materno) as nombres_completos,
        a.grado,
        a.seccion,
        a.nivel,
        'FALTA' as estado_asistencia,
        NULL as hora_registro,
        'Sin registro de asistencia' as observaciones,
        h.hora_inicio,
        h.minutos_tolerancia_entrada
    FROM alumno a
    INNER JOIN horarios h ON a.id_horario = h.id
    LEFT JOIN registro_asistencia ra ON a.id = ra.alumno_id AND ra.fecha = p_fecha
    WHERE ra.id IS NULL  -- No tiene registro para esa fecha
        AND a.grado = p_grado
        AND a.nivel = p_nivel
        AND a.estado = 'matriculado';

    -- Devolver el resultado final ordenado
    SELECT 
        codigo_modular as 'Código Modular',
        nombres_completos as 'Nombres y Apellidos',
        grado as 'Grado',
        seccion as 'Sección',
        nivel as 'Nivel',
        estado_asistencia as 'Estado',
        CASE 
            WHEN hora_registro IS NOT NULL THEN TIME_FORMAT(hora_registro, '%H:%i:%s')
            ELSE 'No registró'
        END as 'Hora Registro',
        observaciones as 'Observaciones'
    FROM temp_reporte_asistencia
    ORDER BY 
        seccion ASC,
        nombres_completos ASC;

    -- Limpiar tabla temporal
    DROP TEMPORARY TABLE temp_reporte_asistencia;
END //
DELIMITER ;





-- CALL sp_listado_asistencias('2025-08-02', '5°', 'secundaria');