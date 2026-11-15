USE grades_db;
-- =============================================================
-- TABLA DE RESULTADOS
-- Un registro por test: PASS si la operación prohibida se rechazó,
-- FAIL si se permitió
-- =============================================================
CREATE OR REPLACE TABLE test_results(
	 test_id VARCHAR(20) PRIMARY KEY,
	 test_name VARCHAR(200) NOT NULL,
	 test_menssage VARCHAR(500) NOT NULL,
	 test_status ENUM("PASS","FAIL") NOT NULL,
	 execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- =============================================================
-- PROCEDIMIENTO AUXILIAR
-- Registra el resultado de un test. El nombre es el texto del mensaje
-- anterior a ':' (SUBSTRING_INDEX), por ejemplo 'RN01'
-- =============================================================
DELIMITER //
CREATE OR REPLACE PROCEDURE p_log_test(
	 IN p_test_id VARCHAR(20),
	 IN p_message VARCHAR(500),
	 IN p_status ENUM("PASS","FAIL")
)
BEGIN 
	 INSERT INTO test_results(test_id,test_name, test_message, test_status)
	 VALUES (p_test_id,SUBSTRING_INDEX(p_message,":",1),p_message,p_status);
END//
DELIMITER ;
-- =============================================================
-- TESTS DE RESTRICCIONES DECLARATIVAS
-- Todos siguen el mismo esquema:
-- 1. Un handler: si la operación lanza un error (SQLEXCEPTION), registra
--    PASS y sale del procedimiento (EXIT).
-- 2. p_populate() restaura los datos iniciales.
-- 3. Se intenta la operación que la regla prohíbe.
-- 4. Si la ejecución llega a la última línea, no hubo error: FAIL.
-- =============================================================

-- Test RN01: Matrícula de honor requiere nota >= 9
DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn01_mh_requierement()
BEGIN 
	 DECLARE EXIT HANDLER FOR SQLEXCEPTION
	 	 CALL p_log_test("RN01","RN01: La MH requiere nota>=9","PASS");
	 	 
	 CALL p_populate();
	 
	 UPDATE grades SET with_honors=1 WHERE grade_id=21;
	 
	 CALL p_log_test("RN01","ERROR: Se permitió MH con nota inferior a 9","FAIL");
END //
DELIMITER;

-- Test RN09: Los atributos obligatorios no pueden quedar a NULL
CREATE OR REPLACE PROCEDURE p_test_rn09_not_null_attributes()
BEGIN 
	 DECLARE EXIT HANDLER 