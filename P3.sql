-- P3
SELECT MeterID, Date, Value 
FROM Reading 
WHERE Value > 100 
ORDER BY Date DESC;

SELECT M.MeterID, L.Address, R.Date, R.Value 
FROM Meter M
JOIN Location L ON M.LocationID = L.LocationID
JOIN Reading R ON M.MeterID = R.MeterID;


UPDATE Reading 
SET Value = 190.00 
WHERE ReadingID = 2;

DELETE FROM Meter WHERE MeterID = 3;
-- Cascading delete removes associated readings.