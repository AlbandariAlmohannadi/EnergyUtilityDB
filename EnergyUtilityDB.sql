-- Database Setup
DROP DATABASE IF EXISTS EnergyUtilityDB;
CREATE DATABASE IF NOT EXISTS EnergyUtilityDB;
USE EnergyUtilityDB;

-- Table Creation
CREATE TABLE IF NOT EXISTS Location (
    LocationID INT PRIMARY KEY AUTO_INCREMENT,
    Address VARBINARY(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS Meter (
    MeterID INT PRIMARY KEY AUTO_INCREMENT,
    Type ENUM('Electric', 'Gas') NOT NULL,
    LocationID INT,
    FOREIGN KEY (LocationID) 
        REFERENCES Location(LocationID) 
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Reading (
    ReadingID INT PRIMARY KEY AUTO_INCREMENT,
    MeterID INT NOT NULL,
    Date DATE NOT NULL,
    Value DECIMAL(10, 2) CHECK (Value > 0),
    FOREIGN KEY (MeterID) 
        REFERENCES Meter(MeterID) 
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS AuditLog (
    AuditID INT PRIMARY KEY AUTO_INCREMENT,
    Action VARCHAR(255) NOT NULL,
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Data Insertion
INSERT INTO Location (Address) VALUES 
(AES_ENCRYPT('123 Green Street, London', 'encryption_key_123')),
(AES_ENCRYPT('456 Oak Avenue, Manchester', 'encryption_key_123')),
(AES_ENCRYPT('789 Pine Road, Birmingham', 'encryption_key_123')),
(AES_ENCRYPT('321 Maple Lane, Leeds', 'encryption_key_123'));

INSERT INTO Meter (Type, LocationID) VALUES 
('Electric', 1),
('Gas', 2),
('Electric', 3),
('Gas', 4);

INSERT INTO Reading (MeterID, Date, Value) VALUES 
(1, '2025-10-01', 150.50),
(2, '2025-10-01', 95.00),
(1, '2025-10-02', 155.00),
(2, '2025-10-02', 92.50),
(3, '2025-10-02', 160.75),
(4, '2025-10-02', 85.30),
(3, '2025-10-03', 165.00),
(4, '2025-10-03', 87.00);

INSERT INTO AuditLog (Action) VALUES 
('New meter added: Electric at 123 Green Street'),
('New location added: 789 Pine Road, Birmingham'),
('New location added: 321 Maple Lane, Leeds'),
('New meter added: Electric at 789 Pine Road, Birmingham'),
('New meter added: Gas at 321 Maple Lane, Leeds');

-- Index Management
SET @old_sql_notes = @@sql_notes, sql_notes = 0;
DROP PROCEDURE IF EXISTS DropIndexIfExists;
DELIMITER $$
CREATE PROCEDURE DropIndexIfExists(
    IN tableName VARCHAR(128),
    IN indexName VARCHAR(128)
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.statistics 
        WHERE table_schema = DATABASE()
        AND table_name = tableName
        AND index_name = indexName
    ) THEN
        SET @s = CONCAT('DROP INDEX ', indexName, ' ON ', tableName);
        PREPARE stmt FROM @s;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

CALL DropIndexIfExists('Reading', 'idx_reading_date');
CREATE INDEX idx_reading_date ON Reading(Date);

CALL DropIndexIfExists('Meter', 'idx_meter_type');
CREATE INDEX idx_meter_type ON Meter(Type);
SET @@sql_notes = @old_sql_notes;

-- Security Configuration
DROP USER IF EXISTS 'admin_user'@'localhost';
DROP USER IF EXISTS 'basic_user'@'localhost';
DROP ROLE IF EXISTS admin;
DROP ROLE IF EXISTS user;
DROP ROLE IF EXISTS auditor;

CREATE ROLE admin;
GRANT ALL PRIVILEGES ON EnergyUtilityDB.* TO admin;

CREATE ROLE user;
GRANT SELECT, INSERT, UPDATE ON EnergyUtilityDB.Reading TO user;

CREATE ROLE auditor;
GRANT SELECT ON EnergyUtilityDB.AuditLog TO auditor;

CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'SecureAdminPass123!';
GRANT admin TO 'admin_user'@'localhost';

CREATE USER 'basic_user'@'localhost' IDENTIFIED BY 'UserPass123!';
GRANT user TO 'basic_user'@'localhost';

ALTER USER 'admin_user'@'localhost' REQUIRE SSL;

-- Trigger Setup
DELIMITER $$
DROP TRIGGER IF EXISTS after_reading_insert$$
CREATE TRIGGER after_reading_insert
AFTER INSERT ON Reading
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (Action)
    VALUES (CONCAT('New reading added: ', NEW.Value, ' for Meter ', NEW.MeterID));
END$$
DELIMITER ;