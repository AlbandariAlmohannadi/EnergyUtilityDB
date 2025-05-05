const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Database Connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',         // Update with your credentials
  password: '',
  database: 'EnergyUtilityDB'
});

db.connect(err => {
  if (err) throw err;
  console.log('Connected to MySQL');
});

// API Endpoints
app.get('/api/meters', (req, res) => {
  db.query(`
    SELECT m.MeterID, m.Type, a.Street, a.City 
    FROM Meter m
    JOIN Location l ON m.LocationID = l.LocationID
    JOIN Address a ON l.AddressID = a.AddressID
  `, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.post('/api/readings', (req, res) => {
  const { meterId, date, value } = req.body;
  db.query(
    'INSERT INTO Reading (MeterID, Date, Value) VALUES (?, ?, ?)',
    [meterId, date, value],
    (err, results) => {
      if (err) return res.status(500).json({ error: 'Failed to save reading' });
      
      // Log to audit table
      db.query(
        'INSERT INTO Audit (Action) VALUES (?)',
        [`New reading: Meter ${meterId} - ${value} kWh`]
      );
      
      res.json({ success: true });
    }
  );
});

// Start Server
const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));