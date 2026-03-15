const express = require('express');
const cors    = require('cors');
const mongoose = require('mongoose');

const app  = express();
const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb+srv://f223716:sultan%403716@cluster0.0vzypjh.mongodb.net/snakegame?retryWrites=true&w=majority';

// ─── Middleware ───────────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// ─── MongoDB Connection ───────────────────────────────────────────────────────
mongoose.connect(MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log(`[DB] Connected to MongoDB at ${MONGO_URI}`))
  .catch(err => {
    console.error('[DB] Connection error:', err.message);
    process.exit(1);
  });

// ─── Schema & Model ───────────────────────────────────────────────────────────
const scoreSchema = new mongoose.Schema({
  name:  { type: String, required: true, trim: true, maxlength: 50 },
  score: { type: Number, required: true, min: 0 },
  date:  { type: Date, default: Date.now },
});

const Score = mongoose.model('Score', scoreSchema);

// ─── Routes ───────────────────────────────────────────────────────────────────

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// GET /scores — top 10 scores sorted descending
app.get('/scores', async (req, res) => {
  try {
    const scores = await Score
      .find({}, { __v: 0 })
      .sort({ score: -1 })
      .limit(10)
      .lean();
    res.json(scores);
  } catch (err) {
    console.error('[GET /scores]', err.message);
    res.status(500).json({ error: 'Failed to fetch scores.' });
  }
});

// POST /scores — save a new score
app.post('/scores', async (req, res) => {
  const { name, score } = req.body;

  if (!name || typeof name !== 'string' || name.trim().length === 0) {
    return res.status(400).json({ error: 'Name is required.' });
  }
  if (score === undefined || typeof score !== 'number' || score < 0) {
    return res.status(400).json({ error: 'A valid score (number >= 0) is required.' });
  }

  try {
    const entry = new Score({ name: name.trim(), score });
    await entry.save();
    console.log(`[POST /scores] Saved: ${name.trim()} — ${score}`);
    res.status(201).json({ message: 'Score saved.', data: entry });
  } catch (err) {
    console.error('[POST /scores]', err.message);
    res.status(500).json({ error: 'Failed to save score.' });
  }
});

// 404 fallback
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found.' });
});

// ─── Start Server ─────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`[API] Snake Game backend running on port ${PORT}`);
});
