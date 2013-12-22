CREATE PROCEDURE sqlunit$register_test (IN name VARCHAR(255))
BEGIN
    INSERT INTO `Test` (name)
    VALUES (name)
    ;
END|

CREATE PROCEDURE sqlunit$execute ()
BEGIN
    DECLARE test_name VARCHAR(255);
    DECLARE done TINYINT(1) DEFAULT FALSE;
    DECLARE tests CURSOR FOR SELECT
        `Test`.`name`
    FROM `Test`
    ;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = true;
    
    DROP TEMPORARY TABLE IF EXISTS `sqlunit_results`;
    CREATE TEMPORARY TABLE sqlunit_results (
        result ENUM('PASS', 'FAIL', 'INCOMPLETE', 'SKIPPED') NOT NULL,
        name VARCHAR(255) NOT NULL,
        message TEXT
    ) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB;
    
    CALL module$trigger_event ('sqlunit_start');
    
    OPEN tests;
    
    test_loop: LOOP
        FETCH tests INTO test_name;
        
        IF done THEN
            LEAVE test_loop;
        END IF;
        
        CALL module$trigger_event ('sqlunit_setup');
        
        CALL sqlunit$execute_test (test_name);
        
        CALL module$trigger_event ('sqlunit_teardown');
    END LOOP;
    
    CLOSE tests;
    
    CALL module$trigger_event ('sqlunit_end');
END|

CREATE PROCEDURE sqlunit$results ()
BEGIN
    SELECT
        *
    FROM `sqlunit_results`
    ;
END|

CREATE PROCEDURE sqlunit$execute_test (IN name VARCHAR(255))
BEGIN
    SET @execute_test = CONCAT('CALL ', name);
    PREPARE execute_test FROM @execute_test;
    EXECUTE execute_test;
    DEALLOCATE PREPARE execute_test;
END|

CREATE PROCEDURE sqlunit$pass (IN name VARCHAR(255), IN message TEXT)
BEGIN
    INSERT INTO `sqlunit_results` (result, name, message)
    VALUES ('PASS', name, message);
END|

CREATE PROCEDURE sqlunit$fail (IN name VARCHAR(255), IN message TEXT)
BEGIN
    INSERT INTO `sqlunit_results` (result, name, message)
    VALUES ('FAIL', name, message);
END|

CREATE PROCEDURE sqlunit$incomplete (IN name VARCHAR(255), IN message TEXT)
BEGIN
    INSERT INTO `sqlunit_results` (result, name, message)
    VALUES ('INCOMPLETE', name, message);
END|

CREATE PROCEDURE sqlunit$skip (IN name VARCHAR(255), IN message TEXT)
BEGIN
    INSERT INTO `sqlunit_results` (result, name, message)
    VALUES ('SKIPPED', name, message);
END|
