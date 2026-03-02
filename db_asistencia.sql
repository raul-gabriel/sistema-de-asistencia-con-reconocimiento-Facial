drop database if exists db_asistencia;
create database db_asistencia;
use db_asistencia;

CREATE TABLE usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    rol ENUM('admin', 'docente', 'auxiliar') NOT NULL,
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE horarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_horario VARCHAR(100) NOT NULL, -- horario norturna, mñn
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    minutos_tolerancia_entrada INT DEFAULT 15
);


CREATE TABLE alumno (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_modular VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100) NOT NULL,
    dni CHAR(8) UNIQUE NOT NULL,
    grado ENUM('1°', '2°', '3°', '4°', '5°', '6°') NOT NULL,
    seccion ENUM('A', 'B', 'C', 'D', 'E') NOT NULL,
    nivel ENUM('primaria', 'secundaria') NOT NULL,
    apoderado_nombre VARCHAR(150),
    apoderado_telefono VARCHAR(15),
    id_horario int not null, 
    estado ENUM('matriculado', 'retirado', 'trasladado') DEFAULT 'matriculado',
	FOREIGN KEY (id_horario) REFERENCES horarios(id) 
);






-- Tabla de embeddings faciales (para reconocimiento facial)
CREATE TABLE embeddings_faciales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    alumno_id INT NOT NULL,
    vector_embedding LONGTEXT NOT NULL,
    FOREIGN KEY (alumno_id) REFERENCES alumno(id) ON DELETE CASCADE
);




-- Tabla de registro de asistencia (principal)
CREATE TABLE registro_asistencia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    alumno_id INT NOT NULL,
    sesion_id INT NOT NULL,
    fecha DATE NOT NULL,
    hora_registro TIME NOT NULL,
    estado_asistencia ENUM('presente', 'tardanza') NOT NULL,
    observaciones VARCHAR(200),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (alumno_id) REFERENCES alumno(id) ON DELETE CASCADE
);







-- call registrar_asistencia(1);
DROP PROCEDURE IF EXISTS registrar_asistencia;
DELIMITER //

CREATE PROCEDURE registrar_asistencia (
    IN p_alumno_id INT
)
BEGIN
    DECLARE v_hora_inicio TIME;
    DECLARE v_hora_fin TIME;
    DECLARE v_tolerancia INT;
    DECLARE v_estado_asistencia ENUM('presente', 'tardanza');
    DECLARE v_now TIME;
    DECLARE v_fecha DATE;
    DECLARE v_count INT;
    DECLARE v_nombres VARCHAR(100);
    DECLARE v_apellido_paterno VARCHAR(100);
    DECLARE v_apellido_materno VARCHAR(100);
    DECLARE v_nivel VARCHAR(20);
    DECLARE v_estado_alumno ENUM('matriculado', 'retirado', 'trasladado');
    DECLARE v_hora_permitida_inicio TIME;
    DECLARE v_hora_limite_puntual TIME;

    -- Configurar zona horaria y obtener fecha/hora actual
    SET time_zone = '-05:00';
    SET v_now = CURTIME();
    SET v_fecha = CURDATE();

    -- Verificar duplicidad
    SELECT COUNT(*) INTO v_count
    FROM registro_asistencia
    WHERE alumno_id = p_alumno_id AND fecha = v_fecha;

    IF v_count > 0 THEN
        -- Obtener datos del alumno para el mensaje de duplicidad
        SELECT a.nombres, a.apellido_paterno, a.apellido_materno, a.nivel
        INTO v_nombres, v_apellido_paterno, v_apellido_materno, v_nivel
        FROM alumno a
        WHERE a.id = p_alumno_id;
        
        SELECT 
            'ASISTENCIA_DUPLICADO' AS estado,
            CONCAT_WS(' ', v_nombres, v_apellido_paterno, v_apellido_materno, ', ya registraste tu asistencia. Solo puedes hacerlo una vez al día.') AS mensaje,
            NULL AS nombres,
            NULL AS apellido_paterno,
            NULL AS apellido_materno,
            NULL AS nivel;
    ELSE
        -- Obtener datos del alumno y horario
        SELECT h.hora_inicio, h.hora_fin, h.minutos_tolerancia_entrada,
               a.nombres, a.apellido_paterno, a.apellido_materno, a.nivel, a.estado
        INTO v_hora_inicio, v_hora_fin, v_tolerancia,
             v_nombres, v_apellido_paterno, v_apellido_materno, v_nivel, v_estado_alumno
        FROM alumno a
        JOIN horarios h ON a.id_horario = h.id
        WHERE a.id = p_alumno_id;

        -- Verificar si el alumno existe
        IF v_nombres IS NULL THEN
            SELECT 
                'NO_ENCONTRADO' AS estado,
                CONCAT('Alumno no encontrado con ID: ', p_alumno_id) AS mensaje,
                NULL AS nombres,
                NULL AS apellido_paterno,
                NULL AS apellido_materno,
                NULL AS nivel;
        -- Verificar si el alumno está matriculado
        ELSEIF v_estado_alumno != 'matriculado' THEN
            SELECT 
                'ALUMNO_NO_MATRICULADO' AS estado,
                CONCAT(v_nombres, ' ', v_apellido_paterno, ' ', v_apellido_materno, ' no está matriculado. Estado actual: ', v_estado_alumno) AS mensaje,
                NULL AS nombres,
                NULL AS apellido_paterno,
                NULL AS apellido_materno,
                NULL AS nivel;
        ELSE
            -- Calcular horarios permitidos
            -- Permitir registro desde 1 hora antes de la hora de inicio
            SET v_hora_permitida_inicio = SUBTIME(v_hora_inicio, '01:00:00');
            -- Calcular límite para ser considerado puntual (hora inicio + tolerancia)
            SET v_hora_limite_puntual = ADDTIME(v_hora_inicio, SEC_TO_TIME(v_tolerancia * 60));

            -- Verificar si está dentro del horario permitido para registrar asistencia
            IF v_now < v_hora_permitida_inicio OR v_now > v_hora_fin THEN
                SELECT 
                    'FUERA_DE_HORARIO' AS estado,
                    CONCAT_WS(' ', v_nombres, v_apellido_paterno, v_apellido_materno, ', estás fuera del horario permitido. No puedes registrar tu asistencia.') AS mensaje,
                    NULL AS nombres,
                    NULL AS apellido_paterno,
                    NULL AS apellido_materno,
                    NULL AS nivel;
            ELSE
                -- Evaluar tipo de asistencia
                IF v_now <= v_hora_limite_puntual THEN
                    SET v_estado_asistencia = 'presente';
                    
                    -- Insertar registro de asistencia
                    INSERT INTO registro_asistencia (alumno_id, sesion_id, fecha, hora_registro, estado_asistencia)
                    VALUES (p_alumno_id, 1, v_fecha, v_now, v_estado_asistencia);

                    -- Retornar resultado exitoso - PUNTUAL
                    SELECT 
                        'ASISTENCIA_REGISTRADO_PUNTUAL' AS estado,
                        'Asistencia registrada como presente' AS mensaje,
                        v_nombres AS nombres,
                        v_apellido_paterno AS apellido_paterno,
                        v_apellido_materno AS apellido_materno,
                        v_nivel AS nivel;
                ELSE
                    SET v_estado_asistencia = 'tardanza';
                    
                    -- Insertar registro de asistencia
                    INSERT INTO registro_asistencia (alumno_id, sesion_id, fecha, hora_registro, estado_asistencia)
                    VALUES (p_alumno_id, 1, v_fecha, v_now, v_estado_asistencia);

                    -- Retornar resultado exitoso - TARDE
                    SELECT 
                        'ASISTENCIA_REGISTRADO_TARDE' AS estado,
                        'Se ha registrado la asistencia correctamente con estado: Tarde.' AS mensaje,
                        v_nombres AS nombres,
                        v_apellido_paterno AS apellido_paterno,
                        v_apellido_materno AS apellido_materno,
                        v_nivel AS nivel;
                END IF;
            END IF;
        END IF;
    END IF;

END;
//
DELIMITER ;


/*
NO_ENCONTRADO	
ASISTENCIA_REGISTRADO_PUNTUAL
ASISTENCIA_REGISTRADO_TARDE
ASISTENCIA_DUPLICADO	
ALUMNO_NO_MATRICULADO	
FUERA_DE_HORARIO	
ERROR
*/


-- estado 0 error, 1 --registrado  , 2 - duplicado
-- call registrar_asistencia(1);