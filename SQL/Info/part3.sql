-- 1) Написать функцию, возвращающую таблицу TransferredPoints в более человекочитаемом виде
CREATE OR REPLACE FUNCTION get_transferred_points_summary()
RETURNS TABLE(Peer1 VARCHAR, Peer2 VARCHAR, PointsAmount BIGINT) AS $$
BEGIN
    RETURN QUERY
    WITH reversed AS (
        SELECT
            CASE WHEN ReviewerPeerName > ReviewedPeerName THEN ReviewerPeerName ELSE ReviewedPeerName END AS Peer1,
            CASE WHEN ReviewerPeerName > ReviewedPeerName THEN ReviewedPeerName ELSE ReviewerPeerName END AS Peer2,
            CASE WHEN ReviewerPeerName > ReviewedPeerName THEN TotalPoints ELSE -TotalPoints END AS PointsAmount
        FROM TransferredPoints
    )
    SELECT reversed.Peer1, reversed.Peer2, SUM(reversed.PointsAmount) AS PointsAmount
    FROM reversed
    GROUP BY reversed.Peer1, reversed.Peer2;
  END;
$$ LANGUAGE plpgsql;

-- Проверка
-- SELECT * FROM get_transferred_points_summary();

-- 2) Создание функции для получения таблицы с данными о полученных XP
CREATE OR REPLACE FUNCTION get_xp_summary() RETURNS TABLE (
    "Peer" VARCHAR(255),
    "Task" VARCHAR(255),
    "XP" INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p2p.PeerName AS "Peer",
        checks.TaskName AS "Task",
        xp.XP AS "XP"
    FROM
        p2p
    JOIN XP ON p2p.checkid = xp.checkid
    JOIN verter ON xp.checkid = verter.checkid
    JOIN checks ON p2p.checkid = checks.id
    WHERE p2p.p2pstatus = 'Success'
    AND verter.verterstatus = 'Success';
END;
$$ LANGUAGE plpgsql;

-- Проверка
-- SELECT * FROM get_xp_summary();

-- 3) Создание функции для определения пиров, не выходивших из кампуса в течение дня
CREATE OR REPLACE FUNCTION get_in_campus_peers(tracking_date DATE) RETURNS TABLE (
    "PeerName" VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT tt.PeerName AS "PeerName"
    FROM TimeTracking tt
    WHERE tt.TrackingDate = tracking_date
    AND NOT EXISTS (
        SELECT 1
        FROM TimeTracking tt2
        WHERE tt2.PeerName = tt.PeerName
        AND tt2.TrackingDate = tracking_date
        AND tt2.TrackingStatus = 2
    );
END;
$$ LANGUAGE plpgsql;

-- Проверка
-- SELECT * FROM get_in_campus_peers('2023-09-15');

-- 4) Создание процедуры для подсчета изменения в количестве пир поинтов
CREATE OR REPLACE PROCEDURE changes_peer_points(INOUT ref refcursor) AS $$
BEGIN
    OPEN ref FOR
    WITH sum_reviewer AS (
        SELECT ReviewerPeerName AS Peer, SUM(TotalPoints) AS PointsChange
        FROM TransferredPoints
        WHERE ReviewerPeerName IS NOT NULL
        GROUP BY ReviewerPeerName
    ),
    sum_reviewed AS (
        SELECT ReviewedPeerName AS Peer, SUM(TotalPoints) AS PointsChange
        FROM TransferredPoints
        WHERE ReviewedPeerName IS NOT NULL
        GROUP BY ReviewedPeerName
    )
    SELECT COALESCE(s1.Peer, s2.Peer) AS Peer, -1 * (COALESCE(s1.PointsChange, 0) - COALESCE(s2.PointsChange, 0)) AS PointsChange
    FROM sum_reviewer s1
    FULL JOIN sum_reviewed s2 ON s1.Peer = s2.Peer
    ORDER BY PointsChange DESC;
END;
$$ LANGUAGE plpgsql;

-- Проверка
-- BEGIN;
-- CALL changes_peer_points('ref');
-- FETCH ALL IN "ref";
-- CLOSE ref;
-- END;

-- 5) Создание процедуры для подсчета изменения в количестве пир поинтов на основе данных из первой функции
CREATE OR REPLACE PROCEDURE calculate_point_changes_based_on_transferred_points(INOUT result_cursor refcursor) AS $$
BEGIN
    OPEN result_cursor FOR
    WITH temp AS (
        SELECT
            CASE WHEN ReviewerPeerName > ReviewedPeerName THEN ReviewerPeerName ELSE ReviewedPeerName END AS peer1,
            CASE WHEN ReviewerPeerName > ReviewedPeerName THEN ReviewedPeerName ELSE ReviewerPeerName END AS peer2,
            CASE WHEN ReviewerPeerName > ReviewedPeerName THEN TotalPoints ELSE -TotalPoints END AS PointsAmount
        FROM TransferredPoints
    ),
    earned_points AS (
        SELECT peer1, SUM(PointsAmount) AS sum FROM temp GROUP BY peer1
    ),
    given_points AS (
        SELECT peer2, SUM(PointsAmount) AS dif FROM temp GROUP BY peer2
    )
    SELECT trab.peer, COALESCE(given_points.dif, 0) - COALESCE(earned_points.sum, 0) FROM
    (SELECT peer1 AS peer FROM earned_points
    UNION
    SELECT peer2 AS peer FROM given_points) AS trab
    FULL JOIN earned_points ON earned_points.peer1 = trab.peer
    FULL JOIN given_points ON given_points.peer2 = trab.peer
    ORDER BY 1, 2;
END;
$$ LANGUAGE plpgsql;

-- Проверка
-- BEGIN;
-- CALL calculate_point_changes_based_on_transferred_points('cursor_name');
-- FETCH ALL FROM cursor_name;
-- CLOSE cursor_name;
-- END;

-- 6) Создание процедуры для определения самого часто проверяемого задания за каждый день
-- Создадим процедуру с параметрами OUT
CREATE OR REPLACE PROCEDURE find_popular_task(in cursor refcursor) AS $$
BEGIN
OPEN cursor FOR
    WITH t1 as (
        SELECT checks.taskname, checkdate, count(checks.taskname) as counts from checks
        group by checkdate, checks.taskname
    )
    SELECT checkdate, n.taskname FROM t1 as n
    WHERE counts = (
       SELECT MAX(counts)
       FROM (select * from t1 where n.checkdate = t1.checkdate) as res
    )
    ORDER BY 1 DESC, 2;
END;
$$ LANGUAGE plpgsql;

-- Проверка
-- BEGIN;
-- CALL find_popular_task('cursor');
-- FETCH ALL IN "cursor";
-- CLOSE cursor;
-- END;

-- 7) Найти всех пиров, выполнивших весь заданный блок задач и дату завершения последнего задания
CREATE OR REPLACE PROCEDURE find_peers_completed_block(
    block_name_part VARCHAR(255)
) AS $$
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_block_result AS
    WITH 
    task AS (
        SELECT *
        FROM tasks
        WHERE taskname SIMILAR TO CONCAT('D', '[0-9]%')
    ),
    last_project AS (
        SELECT MAX(taskname) AS taskname
        FROM task
    ),
    success AS (
        SELECT c.peername, c.taskname, c.checkdate
        FROM checks c
        JOIN p2p ON c.id = p2p.checkid
        LEFT JOIN verter v ON c.id = v.checkid
        WHERE p2p.p2pstatus = 'Success'
        AND v.verterstatus IS NULL OR v.verterstatus = 'Success'
        GROUP BY c.id
    )
    SELECT s.peername, s.checkdate
    FROM success s
    JOIN last_project l ON s.taskname = l.taskname;
END;
$$ LANGUAGE plpgsql;

-- Проверка
-- CALL find_peers_completed_block('D');
-- SELECT * FROM temp_block_result;
-- DROP TABLE IF EXISTS temp_block_result;

-- 8) Процедура рекомендаций к какому пиру стоит идти на проверку каждому обучающемуся
CREATE OR REPLACE PROCEDURE find_peer_to_review() AS $$
BEGIN
    CREATE TEMPORARY TABLE temp_friend_recommendations AS
    SELECT
        f.PeerName1 AS "Peer",
        f.PeerName2 AS "RecommendedPeer"
    FROM
        friends f;
    
    CREATE TEMPORARY TABLE temp_recommendation_counts AS
    SELECT
        "RecommendedPeer",
        COUNT(*) AS "RecommendationCount"
    FROM
        temp_friend_recommendations
    GROUP BY
        "RecommendedPeer";

    CREATE TEMPORARY TABLE IF NOT EXISTS peer_to_review_result AS
    WITH max_recommendations AS (
        SELECT
            "RecommendedPeer",
            "RecommendationCount",
            RANK() OVER (ORDER BY "RecommendationCount" DESC) AS ranking
        FROM
            temp_recommendation_counts
    )
    SELECT
        fr."Peer",
        mr."RecommendedPeer"
    FROM
        temp_friend_recommendations fr
    INNER JOIN
        max_recommendations mr
    ON
        fr."RecommendedPeer" = mr."RecommendedPeer"
    WHERE
        mr.ranking = 1;

    DROP TABLE IF EXISTS temp_recommendation_counts;
    DROP TABLE IF EXISTS temp_friend_recommendations;
END;
$$ LANGUAGE plpgsql;

-- Проверка
-- CALL find_peer_to_review();
-- SELECT * FROM peer_to_review_result;
-- DROP TABLE IF EXISTS peer_to_review_result;

-- 9) Определить процент пиров, которые:
    -- Приступили только к блоку 1
    -- Приступили только к блоку 2
    -- Приступили к обоим
    -- Не приступили ни к одному

CREATE OR REPLACE PROCEDURE successful_checks_blocks(
    IN block1 TEXT,
    IN block2 TEXT,
    OUT StartedBlock1 BIGINT,
    OUT StartedBlock2 BIGINT,
    OUT StartedBothBlock BIGINT,
    OUT DidntStartAnyBlock BIGINT
) AS $$
DECLARE
    count_peers BIGINT;
BEGIN
    SELECT COUNT(*) INTO count_peers FROM peers;
    CREATE TEMP TABLE temp_blocks (
        b1 TEXT,
        b2 TEXT,
        c_peers BIGINT
    );
    INSERT INTO temp_blocks (b1, b2, c_peers) VALUES (block1, block2, count_peers);
    CREATE TEMP VIEW temp_view AS (
        WITH start_block1 AS (
            SELECT DISTINCT c.peername
            FROM checks c
            WHERE c.taskname SIMILAR TO concat((SELECT b1 FROM temp_blocks), '[0-9]%')
        ),
        start_block2 AS (
            SELECT DISTINCT c.peername
            FROM checks c
            WHERE c.taskname SIMILAR TO concat((SELECT b2 FROM temp_blocks), '[0-9]%')
        ),
        start_only_block1 AS (
            SELECT peername FROM start_block1
            EXCEPT
            SELECT peername FROM start_block2
        ),
        start_only_block2 AS (
            SELECT peername FROM start_block2
            EXCEPT
            SELECT peername FROM start_block1
        ),
        start_both_block AS (
            SELECT peername FROM start_block1
            INTERSECT
            SELECT peername FROM start_block2
        ),
        didnt_start AS (
            SELECT COUNT(peers.PeerName) AS peer_count
            FROM peers
            LEFT JOIN checks c ON peers.PeerName = c.PeerName
            WHERE c.PeerName IS NULL
        )
        SELECT
            (((SELECT COUNT(*) FROM start_only_block1) * 100) / (SELECT c_peers FROM temp_blocks)) AS s1,
            (((SELECT COUNT(*) FROM start_only_block2) * 100) / (SELECT c_peers FROM temp_blocks)) AS s2,
            (((SELECT COUNT(*) FROM start_both_block) * 100) / (SELECT c_peers FROM temp_blocks)) AS s3,
            (((SELECT peer_count FROM didnt_start) * 100) / (SELECT c_peers FROM temp_blocks)) AS s4
    );

    SELECT s1, s2, s3, s4 INTO StartedBlock1, StartedBlock2, StartedBothBlock, DidntStartAnyBlock FROM temp_view;
    DROP VIEW temp_view;
    DROP TABLE temp_blocks;
END;
$$ LANGUAGE plpgsql;

-- Проверка
-- CALL successful_checks_blocks('C', 'D0', NULL, NULL, NULL, NULL);

-- 10) Создание процедуры для расчета процентов успешных и неуспешных проверок в день рождения
CREATE OR REPLACE PROCEDURE calculate_success_failure_per_birthday(OUT SuccessfulPercentage NUMERIC, OUT UnsuccessfulPercentage NUMERIC) AS $$
DECLARE
    total_peers INTEGER;
BEGIN
    -- Подсчитываем общее количество пиров, у которых день рождения совпадает с датой проверки
    SELECT COUNT(*) 
    INTO total_peers
    FROM peers p
    JOIN checks ch ON p.PeerName = ch.PeerName
    WHERE TO_CHAR(p.BirthDate, 'MM-DD') = TO_CHAR(ch.CheckDate, 'MM-DD');
    -- Проверяем, что общее количество пиров больше нуля
    IF total_peers > 0 THEN
        -- Подсчитываем количество успешных проверок в день рождения
        SELECT COUNT(*) * 100.0 / total_peers
        INTO SuccessfulPercentage
        FROM p2p p
        JOIN checks ch ON p.CheckID = ch.ID
        JOIN peers pe ON pe.PeerName = ch.PeerName
        WHERE TO_CHAR(pe.BirthDate, 'MM-DD') = TO_CHAR(ch.CheckDate, 'MM-DD')
        AND p.P2PStatus = 'Success';
        -- Подсчитываем количество неуспешных проверок в день рождения
        SELECT COUNT(*) * 100.0 / total_peers
        INTO UnsuccessfulPercentage
        FROM p2p p
        JOIN checks ch ON p.CheckID = ch.ID
        JOIN peers pe ON pe.PeerName = ch.PeerName
        WHERE TO_CHAR(pe.BirthDate, 'MM-DD') = TO_CHAR(ch.CheckDate, 'MM-DD')
        AND p.P2PStatus = 'Failure';
    ELSE
        -- Если общее количество пиров равно нулю, устанавливаем проценты в ноль
        SuccessfulPercentage := 0;
        UnsuccessfulPercentage := 0;
    END IF;
END;
$$ 
LANGUAGE plpgsql;

-- Проверка
-- CALL calculate_success_failure_per_birthday(NULL, NULL);

-- 11) Создаем процедуру определяющую всех пиров, которые сдали заданные задания 1 и 2, но не сдали задание 3
CREATE OR REPLACE PROCEDURE find_peers_completed_tasks(Task1Name VARCHAR(255), Task2Name VARCHAR(255), Task3Name VARCHAR(255)) AS $$
BEGIN
    CREATE TEMP TABLE temp_completed_tasks_peers AS
    SELECT DISTINCT c1.peername
    FROM checks c1
    JOIN checks c2 ON c1.peername = c2.peername AND c1.id != c2.id
    JOIN verter v1 ON c1.id = v1.checkid AND (v1.verterstatus = 'Success' OR v1.verterstatus IS NULL)
    JOIN verter v2 ON c2.id = v2.checkid AND (v2.verterstatus = 'Success' OR v2.verterstatus IS NULL)
    JOIN p2p p2p1 ON c1.id = p2p1.checkid AND p2p1.p2pstatus = 'Success' 
    JOIN p2p p2p2 ON c1.id = p2p2.checkid AND p2p2.p2pstatus = 'Success' 
    WHERE c1.taskname = task1name AND c2.taskname = task2name
    AND c1.peername NOT IN (
        SELECT c.peername
        FROM checks c
        JOIN p2p ON p2p.checkid = c.id AND p2p.p2pstatus = 'Success'
        JOIN verter v ON c.id = v.checkid AND (v.verterstatus = 'Success' OR v.verterstatus IS NULL)
        WHERE c.taskname = task3name
    );
END;
$$ LANGUAGE plpgsql;

-- Проверка
-- CALL find_peers_completed_tasks('C2_SimpleBashUtils', 'C3_StringPlus', 'C4_Math');
-- SELECT * FROM temp_completed_tasks_peers;
-- DROP TABLE IF EXISTS temp_completed_tasks_peers;

-- 12) Используя рекурсивное обобщенное табличное выражение, для каждой задачи вывести кол-во предшествующих ей задач
CREATE OR REPLACE PROCEDURE prev_task_count(INOUT ref refcursor) AS $$
BEGIN
    OPEN ref FOR
    WITH RECURSIVE prev_tasks AS (
        SELECT TaskName, EntryTaskName, 0 AS count FROM Tasks
        WHERE EntryTaskName IS NULL
        UNION ALL
        SELECT t.TaskName, t.EntryTaskName, count + 1
        FROM Tasks t
        JOIN prev_tasks pt ON pt.TaskName = t.EntryTaskName
    )
    SELECT TaskName AS Task, count AS PrevCount
    FROM prev_tasks;
END;
$$ LANGUAGE plpgsql;

-- Проверка
-- BEGIN;
-- CALL prev_task_count('tmp_ref');
-- FETCH ALL FROM "tmp_ref";
-- CLOSE tmp_ref;
-- END;

-- 13) Процедура поиска "удачных" для проверок дней. День считается "удачным", если в нем есть хотя бы N идущих подряд успешных проверки
CREATE OR REPLACE PROCEDURE find_successful_check_days(IN N INT) AS $$
DECLARE
    consecutive_success INT := 0;
    check_date DATE := (SELECT MIN(DATE_TRUNC('day', checkdate)) FROM checks);
BEGIN
    CREATE TEMPORARY TABLE temp_success_days(checkdate DATE);
    CREATE TEMPORARY TABLE lucky AS (
        SELECT c.id, c.checkdate, p2ptime, p2pstatus, verterstatus
        FROM checks c
        JOIN p2p p ON c.id = p.checkid
        LEFT JOIN verter v ON c.id = v.checkid
        JOIN tasks t ON c.taskname = t.taskname
        JOIN xp ON c.id = xp.checkid
        WHERE p.p2pstatus IN ('Success', 'Failure')
        AND (v.verterstatus IN ('Success', 'Failure') OR v.verterstatus IS NULL)
        AND xp >= maxxp * 0.8
    );
    CREATE TEMPORARY TABLE lag_result AS (
        SELECT
            checkdate,
            LAG(p2pstatus) OVER (ORDER BY p2ptime) = 'Success'
            AND LAG(verterstatus) OVER (ORDER BY p2ptime) = 'Success' AS consecutive_values
        FROM lucky
    );
    FOR check_date IN (SELECT DISTINCT DATE_TRUNC('day', checkdate) FROM checks ORDER BY DATE_TRUNC('day', checkdate)) LOOP
        SELECT COUNT(*)
        INTO consecutive_success
        FROM lag_result
        WHERE DATE_TRUNC('day', checkdate) = check_date
        AND consecutive_values = 'True';
        IF consecutive_success >= N - 1 THEN
            INSERT INTO temp_success_days VALUES (check_date);
        END IF;
        consecutive_success := 0;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Проверка
-- CALL find_successful_check_days(1);
-- SELECT * FROM temp_success_days;
-- DROP TABLE IF EXISTS temp_success_days;
-- DROP TABLE IF EXISTS lucky;
-- DROP TABLE IF EXISTS lag_result;

-- 14) Определить пира с наибольшим количеством XP
CREATE OR REPLACE PROCEDURE get_xp(INOUT ref refcursor) AS $$
BEGIN
    OPEN ref FOR
    SELECT PeerName AS Peer, SUM(XP) AS XP
    FROM (
        SELECT c.PeerName, c.TaskName, MAX(xp.XP) AS XP
        FROM Checks c
        JOIN XP xp ON c.ID = xp.CheckID
        GROUP BY c.PeerName, c.TaskName
    ) AS tmp
    GROUP BY PeerName
    ORDER BY 2 DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Проверка
-- BEGIN;
-- CALL get_xp('tmp_ref');
-- FETCH ALL FROM "tmp_ref";
-- CLOSE tmp_ref;
-- END;

-- 15) Определить пиров, приходивших раньше заданного времени не менее N раз за всё время
CREATE OR REPLACE PROCEDURE find_peer_timeVisit(IN cursor refcursor, target_time TIME, target_count INT) AS $$
BEGIN
    OPEN cursor FOR
    SELECT PeerName
    FROM TimeTracking
    WHERE TrackingTime < target_time
    AND trackingstatus = 1
    GROUP BY PeerName
    HAVING COUNT(*) >= target_count
    ORDER BY PeerName DESC;
END;
$$ LANGUAGE plpgsql;

-- Проверка
-- BEGIN;
-- CALL find_peer_timeVisit('cursor', '21:00:00', 1);
-- FETCH ALL IN "cursor";
-- END;

-- 16) Определить пиров, выходивших за последние N дней из кампуса больше M раз
CREATE OR REPLACE PROCEDURE find_peer_exit(IN cursor refcursor, target_date INT, target_count INT) AS $$
BEGIN
    OPEN cursor FOR
    SELECT PeerName
    FROM (
        SELECT PeerName, TrackingDate, COUNT(*) AS counts
        FROM TimeTracking
        WHERE TrackingDate > (CURRENT_DATE - target_date)
        AND trackingstatus = 2
        GROUP BY PeerName, TrackingDate
    ) AS t1
    GROUP BY PeerName
    HAVING SUM(counts) > target_count;
END;
$$ LANGUAGE plpgsql;

-- Проверка
-- BEGIN;
-- CALL find_peer_exit('cursor', 30, 0);
-- FETCH ALL IN "cursor";
-- END;

-- 17) Определить для каждого месяца процент ранних входов
CREATE OR REPLACE PROCEDURE calculate_early_entries_percentage() AS $$
BEGIN
    CREATE TEMPORARY TABLE temp_early_entries_percentage AS
    WITH all_visits AS (
        SELECT
            TO_CHAR(p.birthdate, 'Month') AS month,
            COUNT(*) AS visits
        FROM peers p
        JOIN timetracking tt ON p.peername = tt.peername
        WHERE TO_CHAR(tt.trackingdate, 'Month') = TO_CHAR(p.birthdate, 'Month') 
            AND tt.trackingstatus = 1
        GROUP BY TO_CHAR(p.birthdate, 'Month')
    ),
    early_visits AS (
        SELECT
            TO_CHAR(p.birthdate, 'Month') AS month,
            COUNT(*) AS visits
        FROM peers p
        JOIN timetracking tt ON p.peername = tt.peername
        WHERE TO_CHAR(tt.trackingdate, 'Month') = TO_CHAR(p.birthdate, 'Month') 
            AND tt.trackingstatus = 1
            AND EXTRACT(HOUR FROM trackingtime) < 12
        GROUP BY TO_CHAR(p.birthdate, 'Month')
    )
    SELECT
        b.month AS "Month",
        CASE WHEN b.visits = 0 THEN 0.00
            ELSE ROUND((e.visits::decimal / b.visits) * 100, 2)
        END AS "EarlyEntries"
    FROM
        all_visits b
    FULL OUTER JOIN
        early_visits e ON b.month = e.month
    ORDER BY
        b.month;
    END;
$$ LANGUAGE plpgsql;

-- Проверка
-- CALL calculate_early_entries_percentage();
-- SELECT * FROM temp_early_entries_percentage;
-- DROP TABLE IF EXISTS temp_early_entries_percentage;
