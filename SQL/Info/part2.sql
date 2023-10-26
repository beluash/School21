-- Процедура добавления P2P проверки
CREATE OR REPLACE PROCEDURE add_p2p_check(
    examinee VARCHAR(255),
    examiner VARCHAR(255),
    task_name VARCHAR(255),
    check_status CheckStatus,
    check_time TIME
) AS $$
BEGIN
    IF (check_status = 'Start') THEN
        INSERT INTO checks
        VALUES ((SELECT COALESCE(max(id), 0) + 1 FROM checks),
                examinee,
                task_name,
                NOW());
        INSERT INTO p2p
        VALUES ((SELECT COALESCE(max(id), 0) + 1 FROM p2p),
            (SELECT max(id) FROM checks),
            examiner,
            check_status,
            (NOW()::date + check_time::time));
    ELSE
    INSERT INTO p2p
    VALUES ((SELECT COALESCE(max(id), 0) + 1 FROM p2p),
            (SELECT p2p.checkid FROM checks
                JOIN p2p ON p2p.checkid = checks.id
                WHERE p2p.peername = examiner
                AND checks.taskname = task_name
                AND checks.peername = examinee),
            examiner,
            check_status,
            (NOW()::date + check_time::time));
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Для проверки
-- CALL add_p2p_check('lavondas', 'karleenk', 'C3_StringPlus', 'Start', '15:30:00');
-- CALL add_p2p_check('maegorri', 'dolorest', 'C3_StringPlus', 'Start', '15:32:00');
-- CALL add_p2p_check('maegorri', 'dolorest', 'C3_StringPlus', 'Success', '15:45:00');
-- CALL add_p2p_check('lavondas', 'karleenk', 'C3_StringPlus', 'Success', '16:00:00');

-- Процедура добавления проверки Verter'ом
CREATE OR REPLACE PROCEDURE add_verter_check(
    examinee VARCHAR(255),
    task_name VARCHAR(255),
    verter_status CheckStatus,
    check_time TIME
) AS $$
BEGIN
    IF (verter_status = 'Start') THEN
        INSERT INTO verter
        VALUES ((SELECT COALESCE(max(id), 0) + 1 FROM verter),
            (
                SELECT checkid
                FROM p2p
                JOIN checks ON checks.id = p2p.checkid
                WHERE checks.peername = examinee
                AND checks.taskname = task_name
                AND p2p.p2pstatus = 'Success'
            ),
            verter_status,
            (NOW()::date + check_time::time));
    ELSE
        INSERT INTO verter
        VALUES ((SELECT COALESCE(max(id), 0) + 1 FROM verter),
            (   
                SELECT verter.checkid
                FROM verter
                GROUP BY checkid
                HAVING COUNT(*) % 2 = 1
            ),
            verter_status,
            (NOW()::date + check_time::time));
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Для проверки
-- CALL add_verter_check('lavondas', 'C3_StringPlus', 'Start', '15:46:00');
-- CALL add_verter_check('lavondas', 'C3_StringPlus', 'Success', '15:47:00');
-- CALL add_verter_check('maegorri', 'C3_StringPlus', 'Start', '16:01:00');
-- CALL add_verter_check('maegorri', 'C3_StringPlus', 'Success', '16:02:00');

-- Триггер: после добавления записи со статутом "начало" в таблицу P2P, изменить соответствующую запись в таблице TransferredPoints
CREATE OR REPLACE FUNCTION update_transferred_points()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.p2pstatus = 'Start' THEN
        WITH tmp AS (   
                        SELECT checks.peername
                        FROM checks
                        JOIN p2p ON p2p.checkid = checks.id
                        WHERE p2p.p2pstatus = 'Start'
                        AND NEW.checkid = checks.id
                    )
        UPDATE TransferredPoints
        SET totalpoints = totalpoints + 1
        FROM tmp
        WHERE reviewerpeername = NEW.peername AND reviewedpeername = tmp.peername;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER p2p_status_trigger
AFTER INSERT
ON P2P
FOR EACH ROW
EXECUTE FUNCTION update_transferred_points();

-- Триггер: перед добавлением записи в таблицу XP, проверить корректность добавляемой записи
CREATE OR REPLACE FUNCTION check_xp_record()
RETURNS TRIGGER AS $$
BEGIN
    IF ((
        SELECT maxxp
        FROM tasks
        JOIN checks ON checks.taskname = tasks.taskname
        WHERE NEW.checkid = checks.id
    ) < NEW.xp) THEN RAISE EXCEPTION 'Error: XP exceeds the maximum value';
    ELSEIF ((
        SELECT p2p.p2pstatus
        FROM p2p
        WHERE NEW.checkid = p2p.checkid
        AND p2p.p2pstatus IN ('Success', 'Failure')
    ) = 'Failure') THEN RAISE EXCEPTION 'Error: Failure check';
    ELSEIF ((
        SELECT verter.verterstatus
        FROM verter
        WHERE NEW.checkid = verter.checkid
        AND verter.verterstatus IN ('Success', 'Failure')
    ) = 'Failure') THEN RAISE EXCEPTION 'Error: Failure check';
    END IF;
    RETURN (NEW.id, NEW.checkid, NEW.xp);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER xp_check_trigger
BEFORE INSERT
ON XP
FOR EACH ROW
EXECUTE FUNCTION check_xp_record();

-- Для проверки
-- INSERT INTO XP VALUES ((SELECT max(id) + 1 FROM xp), 7, 600);
-- INSERT INTO XP VALUES ((SELECT max(id) + 1 FROM xp), 6, 300);
-- INSERT INTO XP VALUES ((SELECT max(id) + 1 FROM xp), 8, 250);
-- INSERT INTO XP VALUES ((SELECT max(id) + 1 FROM xp), 4, 400); -- Error: XP exceeds the maximum value

-- Варианты улучшения кода:
-- Сделать всепокрывающие exceptions
