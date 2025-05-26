import express from 'express';
import pool from '../utils/dblogin.js';
import { broadcastChannelDeleted } from '../websocket.js';

const router = express.Router();

// Create a new channel
router.post('/channels', async (req, res) => {
  const { user_id0, user_id1, type } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO channels (user_id0, user_id1, type)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [user_id0, user_id1, type]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get all channels
router.get('/channels', async (req, res) => {
  const userId = parseInt(req.query.user_id, 10); // Get user_id from query string
  const channelType = req.query.type; // Get type from query string

  try {
    let result;
    let query = 'SELECT * FROM channels';
    const conditions = [];
    const values = [];

    if (!isNaN(userId)) {
      conditions.push('(user_id0 = $1 OR user_id1 = $1)');
      values.push(userId);
    }

    if (channelType) {
      const index = values.length + 1;
      conditions.push(`type = $${index}`);
      values.push(channelType);
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    result = await pool.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'No channels found' });
    }

    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// delete channel
router.delete('/channels/:id', async (req, res) => {
  const channelId = parseInt(req.params.id, 10);
  console.log(`[HTTP] DELETE /channels/${channelId} received`);  // ← new

  try {
    // 1) Fetch participants
    const chanRes = await pool.query(
      'SELECT user_id0, user_id1 FROM channels WHERE id = $1',
      [channelId]
    );
    console.log(`[HTTP] fetched participants:`, chanRes.rows);    // ← new

    if (chanRes.rows.length === 0) {
      console.log(`[HTTP] channel ${channelId} not found`);      // ← new
      return res.status(404).json({ error: 'Channel not found' });
    }
    const participants = chanRes.rows[0];

    // 2) Delete channel
    const delRes = await pool.query(
      'DELETE FROM channels WHERE id = $1 RETURNING *',
      [channelId]
    );
    console.log(`[HTTP] deleted channel row:`, delRes.rows[0]);  // ← new

    // 3) Broadcast deletion
    console.log(
      `[WS] broadcasting channel_deleted to users`,
      participants.user_id0, participants.user_id1
    );                                                          // ← new
    broadcastChannelDeleted(channelId, {
      userId0: participants.user_id0,
      userId1: participants.user_id1,
    });

    // 4) HTTP response
    res.json({ message: 'Channel deleted', channel: delRes.rows[0] });
  } catch (err) {
    console.error('[HTTP] Error deleting channel:', err);       // ← new
    res.status(500).json({ error: err.message });
  }
});

// Get channel by ID
router.get('/channels/:id', async (req, res) => {
  const channelId = parseInt(req.params.id, 10);

  if (isNaN(channelId)) {
    return res.status(400).json({ error: 'Invalid channel ID' });
  }

  try {
    const result = await pool.query(
      'SELECT * FROM channels WHERE id = $1',
      [channelId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Channel not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
