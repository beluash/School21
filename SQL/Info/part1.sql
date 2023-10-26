-- Создание базы данных School21
-- CREATE DATABASE IF NOT EXISTS School21;
-- Переключение на созданную базу данных
--\c School21;

-- Удаление старых таблиц
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS xp CASCADE;
DROP TABLE IF EXISTS verter CASCADE;
DROP TABLE IF EXISTS checks CASCADE;
DROP TABLE IF EXISTS p2p CASCADE;
DROP TABLE IF EXISTS transferredpoints CASCADE;
DROP TABLE IF EXISTS friends CASCADE;
DROP TABLE IF EXISTS peers CASCADE;
DROP TABLE IF EXISTS recommendations CASCADE;
DROP TABLE IF EXISTS timetracking CASCADE;
DROP TYPE IF EXISTS checkstatus;

-- Создание типа перечисления для статуса проверки
CREATE TYPE CheckStatus AS ENUM ('Start', 'Success', 'Failure');

-- Создание таблицы Peers
CREATE TABLE IF NOT EXISTS Peers (
    PeerName VARCHAR(255) PRIMARY KEY UNIQUE NOT NULL,
    BirthDate DATE NOT NULL
);

-- Создание таблицы Tasks
CREATE TABLE IF NOT EXISTS Tasks (
    TaskName VARCHAR(255) PRIMARY KEY UNIQUE NOT NULL,
    EntryTaskName VARCHAR(255) NULL REFERENCES Tasks(TaskName),
    MaxXP INT CHECK (MaxXP > 0) NOT NULL
);

-- Создание таблицы Checks
CREATE TABLE IF NOT EXISTS Checks (
    ID SERIAL PRIMARY KEY,
    PeerName VARCHAR(255) REFERENCES Peers(PeerName) NOT NULL,
    TaskName VARCHAR(255) REFERENCES Tasks(TaskName) NOT NULL,
    CheckDate DATE NOT NULL
);

-- Создание таблицы P2P
CREATE TABLE IF NOT EXISTS P2P (
    ID SERIAL PRIMARY KEY,
    CheckID INT REFERENCES Checks(ID) NOT NULL,
    PeerName VARCHAR(255) REFERENCES Peers(PeerName) NOT NULL,
    P2PStatus CheckStatus NOT NULL,
    P2PTime TIME NOT NULL
);

-- Создание таблицы Verter
CREATE TABLE IF NOT EXISTS Verter (
    ID SERIAL PRIMARY KEY,
    CheckID INT REFERENCES Checks(ID) NOT NULL,
    VerterStatus CheckStatus NOT NULL,
    VerterTime TIME
);

-- Создание таблицы TransferredPoints
CREATE TABLE IF NOT EXISTS TransferredPoints (
    ID SERIAL PRIMARY KEY,
    ReviewerPeerName VARCHAR(255) REFERENCES Peers(PeerName) NOT NULL,
    ReviewedPeerName VARCHAR(255) REFERENCES Peers(PeerName) NOT NULL,
    TotalPoints INT NOT NULL
);

-- Создание таблицы Friends
CREATE TABLE IF NOT EXISTS Friends (
    ID SERIAL PRIMARY KEY,
    PeerName1 VARCHAR(255) REFERENCES Peers(PeerName) NOT NULL,
    PeerName2 VARCHAR(255) REFERENCES Peers(PeerName) NOT NULL,
    UNIQUE(PeerName1, PeerName2)
);

-- Создание таблицы Recommendations
CREATE TABLE IF NOT EXISTS Recommendations (
    ID SERIAL PRIMARY KEY,
    PeerName VARCHAR(255) REFERENCES Peers(PeerName) NOT NULL,
    RecommendedPeerName VARCHAR(255) REFERENCES Peers(PeerName) NOT NULL
);

-- Создание таблицы XP
CREATE TABLE IF NOT EXISTS XP (
    ID SERIAL PRIMARY KEY,
    CheckID INT REFERENCES Checks(ID) NOT NULL,
    XP INT NOT NULL
);

-- Создание таблицы TimeTracking
CREATE TABLE IF NOT EXISTS TimeTracking (
    ID SERIAL PRIMARY KEY,
    PeerName VARCHAR(255) REFERENCES Peers(PeerName) NOT NULL,
    TrackingDate DATE NOT NULL,
    TrackingTime TIME NOT NULL,
    TrackingStatus SMALLINT CHECK(
        TrackingStatus = 1
        OR TrackingStatus = 2
    ) NOT NULL
);

-- Вставка данных в таблицу Peers
INSERT INTO Peers (PeerName, BirthDate)
VALUES ('maegorri', '1990-09-15'), 
       ('dolorest', '1995-03-15'), 
       ('lavondas', '1987-07-20'), 
       ('karleenk', '1998-11-05'), 
       ('eruahim', '1992-09-10'),
       ('eruahimaw', '1992-01-10'),
       ('lenmurik', '2001-02-10'),
       ('qwertiew', '1995-04-15'),
       ('mountydew', '1995-09-01'),
       ('lapertyp', '2001-05-15');

-- Вставка данных в таблицу Tasks
INSERT INTO Tasks (TaskName, EntryTaskName, MaxXP)
VALUES ('C2_SimpleBashUtils', NULL, 350), 
       ('C3_StringPlus', 'C2_SimpleBashUtils', 750), 
       ('C4_Math', 'C2_SimpleBashUtils', 300), 
       ('C5_Decimal', 'C2_SimpleBashUtils', 350), 
       ('C6_Matrix', 'C5_Decimal', 300), 
       ('D01_Linux', 'C3_StringPlus', 300);

-- Вставка данных в таблицу Checks
INSERT INTO Checks (PeerName, TaskName, CheckDate)
VALUES ('maegorri', 'C2_SimpleBashUtils', '2023-09-15'), 
       ('dolorest', 'C3_StringPlus', '2023-09-15'), 
       ('karleenk', 'C4_Math', '2023-09-15'), 
       ('dolorest', 'C4_Math', '2023-09-15'), 
       ('maegorri', 'C3_StringPlus', '2023-09-15'), 
       ('lavondas', 'D01_Linux', '2023-09-16');

-- Вставка данных в таблицу P2P
INSERT INTO P2P (CheckID, PeerName, P2PStatus, P2PTime)
VALUES (1, 'maegorri', 'Start', NOW()), 
       (1, 'maegorri', 'Success', NOW()), 
       (2, 'dolorest', 'Start', NOW()), 
       (2, 'dolorest', 'Failure', NOW()), 
       (3, 'lavondas', 'Start', NOW()), 
       (3, 'lavondas', 'Success', NOW()), 
       (6, 'lavondas', 'Success', '2023-09-16 22:00:00');

-- Вставка данных в таблицу Verter
INSERT INTO Verter (CheckID, VerterStatus, VerterTime)
VALUES (1, 'Start', NOW()), 
       (1, 'Success', NOW()), 
       (2, 'Start', NOW()), 
       (2, 'Failure', NOW()), 
       (3, 'Start', NOW()), 
       (3, 'Failure', NOW());

-- Вставка данных в таблицу XP
INSERT INTO XP (CheckID, XP)
VALUES (1, 297), 
       (2, 295), 
       (3, 300), 
       (4, 500), 
       (5, 750);

-- Вставка данных в таблицу TimeTracking
INSERT INTO TimeTracking (PeerName, TrackingDate, TrackingTime, TrackingStatus)
VALUES ('maegorri', '2023-09-15', '08:00:00', 1), 
       ('maegorri', '2023-09-15', '12:30:00', 2), 
       ('dolorest', '2023-09-15', '09:15:00', 1),
       ('dolorest', '2023-09-15', '13:45:00', 2), 
       ('dolorest', '2023-09-15', '14:30:00', 1), 
       ('lavondas', '2023-09-15', '12:10:00', 1),
       ('mountydew', '2023-09-16','12:15:00', 1);

-- Вставка данных в таблицу Recommendations
INSERT INTO Recommendations(PeerName, RecommendedPeerName)
VALUES ('maegorri', 'dolorest'), 
       ('maegorri', 'lavondas'), 
       ('lavondas', 'maegorri'), 
       ('lavondas', 'dolorest'), 
       ('dolorest', 'maegorri');

-- Вставка данных в таблицу Friends
INSERT INTO Friends (PeerName1, PeerName2)
VALUES ('maegorri', 'dolorest'), 
       ('dolorest', 'lavondas'), 
       ('lavondas', 'maegorri'), 
       ('karleenk', 'dolorest'), 
       ('karleenk', 'maegorri');

-- Вставка данных в таблицу TransferredPoints
INSERT INTO TransferredPoints (ReviewerPeerName, ReviewedPeerName, TotalPoints)
VALUES ('maegorri', 'dolorest', 10),
       ('dolorest', 'maegorri', 5),
       ('dolorest', 'lavondas', 8),
       ('lavondas', 'karleenk', 3),
       ('lavondas', 'eruahim', 4);

-- Процедуры для работы с файлами
CREATE OR REPLACE PROCEDURE import(table_name VARCHAR(20), file_path TEXT, _delimiter CHARACTER(1)) AS 
$$ DECLARE BEGIN
    EXECUTE format('COPY %s FROM %L WITH DELIMITER %L CSV HEADER', table_name, file_path, _delimiter);
END;
$$ LANGUAGE plpgsql;

-- CALL import('peers', '/home/maegorri/SQL2_Info21_v1.0-1/src/csvs/peers.csv', ',');

CREATE OR REPLACE PROCEDURE export(table_name VARCHAR(20), file_path TEXT, _delimiter CHARACTER(1)) AS 
$$ DECLARE BEGIN
    EXECUTE format('COPY %s TO %L WITH DELIMITER %L CSV HEADER', table_name, file_path, _delimiter);
END;
$$ LANGUAGE plpgsql;

-- CALL export('peers', '/home/maegorri/SQL2_Info21_v1.0-1/src/csvs/peers_new.csv', ',');
