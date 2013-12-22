CREATE PROCEDURE module$load_modules ()
BEGIN
    DECLARE done TINYINT(1) DEFAULT FALSE;
    DECLARE module_name VARCHAR(255);
    DECLARE modules CURSOR FOR
        SELECT
            `Module`.`name`
        FROM `Module`
        WHERE
            `Module`.`enabled` = 1
    ;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN modules;
    
    module_load_loop: LOOP
        FETCH modules INTO module_name;
        IF done THEN
            LEAVE module_load_loop;
        END IF;
        
        CALL module$load_module (module_name);
    END LOOP;
    
    CLOSE modules;
END|

CREATE PROCEDURE module$load_module (IN module_name VARCHAR(255))
BEGIN
    CALL module$ducktype_method (module_name, 'init');
    CALL module$ducktype_method (module_name, 'register_routes');
    CALL module$ducktype_method (module_name, 'register_views');
    CALL module$ducktype_method (module_name, 'load_assets');
END|

CREATE PROCEDURE module$ducktype_method (IN name VARCHAR(255), IN method VARCHAR(255))
BEGIN
    DECLARE method_exists TINYINT(1) DEFAULT FALSE;
    
    CALL procedure_exists (CONCAT(name, '$', method), method_exists);
    
    IF method_exists
    THEN
        SET @ducktyped_call := CONCAT('CALL ', name, '$', method);
        PREPARE ducktyped_call FROM @ducktyped_call;
        EXECUTE ducktyped_call;
        DEALLOCATE PREPARE ducktyped_call;
    END IF;
END|

CREATE PROCEDURE module$register_module (IN module_name VARCHAR(255), IN enabled TINYINT(1))
BEGIN
    INSERT INTO `Module` (name, enabled)
    VALUES (module_name, enabled)
    ;
END|

CREATE PROCEDURE module$trigger_event (IN event_name VARCHAR(255))
BEGIN
    DECLARE done TINYINT(1) DEFAULT FALSE;
    DECLARE module_name VARCHAR(255);
    DECLARE modules CURSOR FOR
        SELECT
            `Module`.`name`
        FROM `Module`
        WHERE
            `Module`.`enabled` = 1
    ;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN modules;
    
    module_load_loop: LOOP
        FETCH modules INTO module_name;
        IF done THEN
            LEAVE module_load_loop;
        END IF;
        
        CALL module$ducktype_method (module_name, CONCAT('event_', event_name));
    END LOOP;
    
    CLOSE modules;
END|
