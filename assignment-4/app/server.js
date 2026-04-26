const express = require('express');
const app = express();
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/hello', (req, res) => {
  res.json({ message: 'Hello from DevOps App!' });
});

app.post('/api/add', (req, res) => {
  const { a, b } = req.body;
  res.json({ result: a + b });
});

function multiply(a, b) { return a * b; }
function divide(a, b) {
  if (b === 0) throw new Error('Division by zero');
  return a / b;
}

module.exports = { app, multiply, divide };

if (require.main === module) {
  app.listen(3000, () => console.log('Server running on port 3000'));
}