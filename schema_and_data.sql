CREATE TABLE IF NOT EXISTS Location (
    LocationID INT PRIMARY KEY AUTO_INCREMENT,
    Address VARCHAR(255) NOT NULL
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

INSERT INTO Location (Address) VALUES 
('123 Green Street, London'),
('456 Oak Avenue, Manchester'),
('789 Pine Road, Birmingham');

INSERT INTO Meter (Type, LocationID) VALUES 
('Electric', 1),
('Gas', 2),
('Electric', 3);

INSERT INTO Reading (MeterID, Date, Value) VALUES 
(1, '2023-10-01', 150.50),
(1, '2023-10-15', 180.75),
(2, '2023-10-01', 95.00),
(3, '2023-10-20', 200.00);

INSERT INTO AuditLog (Action) VALUES 
('New Electric meter added at 123 Green Street'),
('Reading 150.50 recorded for Meter 1'),
('Reading 95.00 recorded for Meter 2');