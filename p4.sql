-- P4
INSERT INTO Reading (MeterID, Date, Value) 
VALUES (2, '2023-10-25', 85.50); -- ok

INSERT INTO Reading (MeterID, Date, Value) 
VALUES (1, '2023-10-30', -50); -- no ok

INSERT INTO Reading (MeterID, Date, Value) 
VALUES (99, '2023-10-25', 100.00); -- Error: Invalid MeterID