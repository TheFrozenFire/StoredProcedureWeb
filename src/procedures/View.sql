CREATE PROCEDURE view_create (IN template_name VARCHAR(255), OUT view_id INT UNSIGNED)
BEGIN
    INSERT INTO `View` (template)
    VALUES (template_name)
    ;
    
    SET view_id = LAST_INSERT_ID();
END|

CREATE PROCEDURE view_clean (IN view_id INT UNSIGNED)
BEGIN
    DELETE FROM `View`
    WHERE
        `View`.`id` = view_id
    ;
END|

CREATE PROCEDURE view_render (IN view_id INT UNSIGNED, OUT rendered TEXT)
BEGIN
    DECLARE view_callback VARCHAR(255);
    DECLARE view_template_name VARCHAR(255);
    
    CALL view_get_template (view_id, view_template_name);
    
    CALL view_template_get_callback (view_template_name, view_callback);

    SET @view_template_call := CONCAT('CALL ', view_callback, ' (', view_id, ')');
    PREPARE view_template_call_statement FROM @view_template_call;
    EXECUTE view_template_call_statement;
    DEALLOCATE PREPARE view_template_call_statement;
    
    CALL view_render_get_result_clean (view_id, rendered);
END|

CREATE PROCEDURE view_register_template (IN view_template_name VARCHAR(255), IN view_template_callback VARCHAR(255))
BEGIN
    INSERT INTO `View_Template` (name, callback)
    VALUES (view_template_name, view_template_callback)
    ;
END|

CREATE PROCEDURE view_get_template (IN view_id INT UNSIGNED, OUT view_template_name VARCHAR(255))
BEGIN
    SELECT
        `View`.`template`
    INTO
        view_template_name
    FROM `View`
    WHERE
        `View`.`id` = view_id
    ;
END;

CREATE PROCEDURE view_template_get_callback (IN name VARCHAR(255), OUT view_callback VARCHAR(255))
BEGIN
    SELECT
        `View_Template`.`callback`
    INTO
        view_callback
    FROM `View_Template`
    WHERE
        `View_Template`.`name` = name
    ;
END|

CREATE PROCEDURE view_render_create_result (IN view_id INT UNSIGNED, IN rendered TEXT)
BEGIN
    INSERT INTO `View_Rendered` (id, result)
    VALUES (view_id, rendered)
    ;
END|

CREATE PROCEDURE view_render_get_result_clean (IN view_id INT UNSIGNED, OUT rendered TEXT)
BEGIN
    CALL view_render_get_result (view_id, rendered);
    
    DELETE FROM `View_Rendered`
    WHERE
        `View_Rendered`.`id` = view_id
    ;
END|

CREATE PROCEDURE view_render_get_result (IN view_id INT UNSIGNED, OUT rendered TEXT)
BEGIN
    SELECT
        `View_Rendered`.`result`
    INTO
        rendered
    FROM `View_Rendered`
    WHERE
        `View_Rendered`.`id` = view_id
    ;
END|