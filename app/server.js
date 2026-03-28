// server.js
const express = require('express');
const path = require('path');

const app = express();
const port = process.env.PORT || 8080;

// Proper JSON health endpoint for ALB/ECS
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Serve static React build
app.use(express.static(path.join(__dirname, 'build')));

// SPA fallback
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
