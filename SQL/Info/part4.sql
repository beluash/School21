----------------------------------------------------------- 1)

-- Создание таблиц
CREATE TABLE TableName_test1 (
    id SERIAL PRIMARY KEY,
    name VARCHAR(10)
);

CREATE TABLE TableName_test2 (
    id SERIAL PRIMARY KEY,
    description TEXT
);

CREATE TABLE TestTable (
    id SERIAL PRIMARY KEY,
    value INT
);

-- Заполнение таблиц
INSERT INTO tablename_test1(name) VALUES ('dolorest');
INSERT INTO tablename_test2(description) VALUES ('very big and stinky');
INSERT INTO testtable(value) VALUES (11);

-- Создать хранимую процедуру, которая, не уничтожая базу данных, 
-- уничтожает все те таблицы текущей базы данных, 
-- имена которых начинаются с фразы 'TableName'.
CREATE OR REPLACE PROCEDURE drop_tables_starting_with_table_name()
AS $$
DECLARE
    table_name VARCHAR(255);
BEGIN
    FOR table_name IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename LIKE 'tablename%') LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || table_name;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Проверка
CALL drop_tables_starting_with_table_name();
SELECT tablename FROM pg_tables WHERE schemaname = 'public';


----------------------------------------------------------- 2)

-- Функция, возвращающая имя из таблицы tablename_test1 по id
CREATE OR REPLACE FUNCTION get_name_by_id(get_id BIGINT) 
RETURNS VARCHAR(10) AS $$
DECLARE 
    result_name VARCHAR(10);
    table_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'tablename_test1' AND table_schema = 'public'
    ) INTO table_exists;
    IF table_exists THEN
        SELECT t.name INTO result_name FROM tablename_test1 t WHERE t.id = get_id;
        RETURN result_name;
    ELSE RAISE EXCEPTION 'Error: tablename_test1 does not exist';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Функция, возвращающая description из таблицы tablename_test2 по id
CREATE OR REPLACE FUNCTION get_description_by_id(get_id BIGINT) 
RETURNS TEXT AS $$
DECLARE 
    result_text TEXT;
    table_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'tablename_test2' AND table_schema = 'public'
    ) INTO table_exists;
    IF table_exists THEN
        SELECT t.description INTO result_text FROM tablename_test2 t WHERE t.id = get_id;
        RETURN result_text;
    ELSE RAISE EXCEPTION 'Error: tablename_test2 does not exist';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Функция, возвращающая value из таблицы testtable по id
CREATE OR REPLACE FUNCTION get_value_by_id(get_id BIGINT) 
RETURNS TEXT AS $$
DECLARE 
    result_value INT;
    table_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'testtable' AND table_schema = 'public'
    ) INTO table_exists;
    IF table_exists THEN
        SELECT t.value INTO result_value FROM testtable t WHERE t.id = get_id;
        RETURN result_value;
    ELSE RAISE EXCEPTION 'Error: testtable does not exist';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Проверка
SELECT get_name_by_id(1);
SELECT get_description_by_id(1);
SELECT get_value_by_id(1);

-- Создать хранимую процедуру с выходным параметром, которая выводит список имен и параметров 
-- всех скалярных SQL функций пользователя в текущей базе данных. 
-- Имена функций без параметров не выводить. 
-- Имена и список параметров должны выводиться в одну строку. 
-- Выходной параметр возвращает количество найденных функций.

-- (запускать через консоль, иначе raise не выводит)

CREATE OR REPLACE PROCEDURE get_user_functions(OUT num_functions INT) AS $$
DECLARE
    function_name TEXT := '';
    function_list TEXT := '';
    param_type TEXT := '';
    temp_row RECORD;
BEGIN
    num_functions := 0;
    CREATE TEMP TABLE IF NOT EXISTS temp_functions AS
        SELECT 
            routine_name AS "function_name",
            data_type AS "param_type"
        FROM 
            information_schema.routines
        WHERE 
            routine_type = 'FUNCTION'
            AND specific_schema = 'public'
            AND routine_schema = current_schema()
            AND routine_name NOT LIKE 'pg_%'
            AND data_type IS NOT NULL;
    SELECT COUNT(*) INTO num_functions FROM temp_functions;
    FOR temp_row IN (
        SELECT * FROM temp_functions
    ) 
    LOOP
        function_list := function_list || temp_row.function_name || '(' || temp_row.param_type || '), ';
    END LOOP;
    function_list := SUBSTRING(function_list, 1, LENGTH(function_list) - 2);
    RAISE NOTICE '%', function_list;
    DROP TABLE temp_functions;
END;
$$ LANGUAGE plpgsql;

-- Проверка
DO
$$
    DECLARE
        num_functions INT;
    BEGIN
        CALL get_user_functions(num_functions);
        RAISE NOTICE 'TOTAL: %', num_functions;
    END
$$;


----------------------------------------------------------- 3)

-- Создание триггера, функция проверяет, что value, которое вставляется в таблицу testtable больше нуля
CREATE OR REPLACE FUNCTION check_value_positive()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.value <= 0 THEN
        RAISE EXCEPTION 'Value should be positive';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_value
BEFORE UPDATE ON testtable
FOR EACH ROW
EXECUTE FUNCTION check_value_positive();

INSERT INTO testtable(value) VALUES (5);
UPDATE testtable SET value = -2;

-- Создать хранимую процедуру с выходным параметром, 
-- которая уничтожает все SQL DML триггеры в текущей базе данных. 
-- Выходной параметр возвращает количество уничтоженных триггеров.

CREATE OR REPLACE PROCEDURE destroy_all_triggers(OUT num INT) AS
$$
DECLARE
    trg_name   TEXT;
    table_name TEXT;
BEGIN
    num := 0;
    FOR trg_name, table_name IN (SELECT DISTINCT trigger_name, event_object_table
                                 FROM information_schema.triggers
                                 WHERE trigger_schema = 'public')
    LOOP
        EXECUTE CONCAT('DROP TRIGGER ', trg_name, ' ON ', table_name);
        num := num + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Проверка (запускать через консоль, иначе raise не выводит)
DO
$$
    DECLARE
        num_triggers INT;
    BEGIN
        CALL destroy_all_triggers(num_triggers);
        RAISE NOTICE '% DML triggers were deleted', num_triggers;
    END
$$;


----------------------------------------------------------- 4) 

-- Создать хранимую процедуру с входным параметром, которая выводит имена и описания типа объектов 
-- (только хранимых процедур и скалярных функций), в тексте которых на языке SQL встречается строка, задаваемая параметром процедуры.

-- (запускать через консоль, иначе raise не выводит)

CREATE OR REPLACE PROCEDURE show_all_proc_and_func(IN string TEXT) AS $$
DECLARE
    proc_and_func_list TEXT := '';
    temp_row RECORD;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS temp_proc_and_func AS
        SELECT routine_name,
               routine_type
        FROM information_schema.routines
        WHERE specific_schema = 'public'
        AND routine_name LIKE CONCAT('%', string, '%');
    FOR temp_row IN (
        SELECT * FROM temp_proc_and_func
    ) 
    LOOP
        proc_and_func_list := proc_and_func_list || temp_row.routine_name || '(' || temp_row.routine_type || ')' || E'\n';
    END LOOP;
    RAISE NOTICE '%', proc_and_func_list;
    DROP TABLE temp_proc_and_func;
END;
$$ LANGUAGE plpgsql;

-- Проверка
CALL show_all_proc_and_func('check');
