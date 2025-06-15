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

router.get('/channels', async (req, res) => {
  console.log(req.query.archived, req.query.all);  // Log 'all' query param for debugging
  const userId = parseInt(req.query.user_id, 10); // Get user_id from query string
  const channelType = req.query.type; // Get type from query string
  const archivedQuery = req.query.archived; // Get archived from query string
  const allQuery = req.query.all; // Get all from query string

  try {
    let result;
    let query = 'SELECT * FROM channels';
    const conditions = [];
    const values = [];

    if (!isNaN(userId)) {
      conditions.push(`(user_id0 = $${values.length + 1} OR user_id1 = $${values.length + 1})`);
      values.push(userId);
    }

    if (channelType) {
      conditions.push(`type = $${values.length + 1}`);
      values.push(channelType);
    }

    // Handle the 'all' query - return all channels if 'all' is true
    if (allQuery === 'true') {
      // Skip the archived filter if 'all' is true
      if (conditions.length > 0) {
        query += ' WHERE ' + conditions.join(' AND ');
      }
    } else {
      // Handle archived filtering when 'all' is not true
      if (archivedQuery === 'true') {
        conditions.push(`archived = $${values.length + 1}`);
        values.push(true);
      } else {
        // Default to archived = false
        conditions.push(`archived = $${values.length + 1}`);
        values.push(false);
      }

      if (conditions.length > 0) {
        query += ' WHERE ' + conditions.join(' AND ');
      }
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


router.delete('/channels/:id', async (req, res) => {
  const channelId = parseInt(req.params.id, 10);
  console.log(`[HTTP] DELETE /channels/${channelId} received`);

  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // 1) Fetch channel including archived status and participants
    const chanRes = await client.query(
      'SELECT user_id0, user_id1, archived FROM channels WHERE id = $1',
      [channelId]
    );
    console.log(`[HTTP] fetched channel:`, chanRes.rows);

    if (chanRes.rows.length === 0) {
      console.log(`[HTTP] channel ${channelId} not found`);
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Channel not found' });
    }

    const channel = chanRes.rows[0];
    const shouldDelete = channel.archived === true;

    let result;

    if (shouldDelete) {
      // 2a) Physically delete the channel
      result = await client.query(
        'DELETE FROM channels WHERE id = $1 RETURNING *',
        [channelId]
      );
      console.log(`[HTTP] deleted channel row:`, result.rows[0]);
    } else {
      // 2b) Archive the channel
      result = await client.query(
        'UPDATE channels SET archived = true WHERE id = $1 RETURNING *',
        [channelId]
      );
      console.log(`[HTTP] archived channel row:`, result.rows[0]);

      // 3) Fetch roles of the users involved
      const userRolesRes = await client.query(
        `SELECT id, role FROM users WHERE id = $1 OR id = $2`,
        [channel.user_id0, channel.user_id1]
      );

      const roles = {};
      userRolesRes.rows.forEach(u => {
        roles[u.id] = u.role;
      });

      const role0 = roles[channel.user_id0];
      const role1 = roles[channel.user_id1];

      let reviewerId = null;
      let revieweeId = null;

      if (role0 === 'user' && (role1 === 'doctor' || role1 === 'customer service')) {
        reviewerId = channel.user_id0;
        revieweeId = channel.user_id1;
      } else if (role1 === 'user' && (role0 === 'doctor' || role0 === 'customer service')) {
        reviewerId = channel.user_id1;
        revieweeId = channel.user_id0;
      }
      await client.query(
        `INSERT INTO reviews (reviewer_id,reviewee_id)
        VALUES ($1,$2)`,
        [reviewerId, revieweeId]
      );
      

    }

    await client.query('COMMIT');

    // 4) Broadcast deletion/archive
    console.log(
      `[WS] broadcasting channel_deleted to users`,
      channel.user_id0, channel.user_id1
    );
    broadcastChannelDeleted(channelId, {
      userId0: channel.user_id0,
      userId1: channel.user_id1,
    });

    // 5) HTTP response
    res.json({
      message: shouldDelete ? 'Channel deleted' : 'Channel archived',
      channel: result.rows[0],
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('[HTTP] Error deleting/archiving channel:', err);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
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

// Get chat counts
router.get('/channels_count', async (req, res) => {
  const staffId = req.query.staff_id ? parseInt(req.query.staff_id, 10) : null;
  const period = req.query.period === 'month' ? 'month' : 'day';
  const type = req.query.type; // Get the type query parameter

  // Validate staff_id if it's provided
  if (staffId && isNaN(staffId)) {
    return res.status(400).json({ error: 'Invalid staff_id parameter' });
  }

  try {
    // If staff_id is provided, check if user is doctor or customer_service
    if (staffId) {
      const roleCheck = await pool.query(
        'SELECT role FROM users WHERE id = $1 AND role IN ($2, $3)',
        [staffId, 'doctor', 'customer service']
      );

      if (roleCheck.rows.length === 0) {
        return res.status(400).json({ error: 'User is not a doctor or customer_service staff' });
      }
    }

    // Group format for day or month
    const groupByFormat = period === 'month' ? 'YYYY-MM' : 'YYYY-MM-DD';

    // Base query for counting chats
    let query = `
      SELECT to_char(created_at, '${groupByFormat}') AS period,
             COUNT(*) AS chat_count
      FROM channels
      WHERE (user_id0 = $1 OR user_id1 = $1 OR $1 IS NULL)
    `;

    // Add additional condition for type if it's provided
    const queryParams = [staffId];

    if (type) {
      query += ' AND type = $2';
      queryParams.push(type); // Add type to query parameters
    }

    query += `
      GROUP BY period
      ORDER BY period ASC
    `;

    // Execute the query with the appropriate parameters
    const result = await pool.query(query, queryParams);

    res.json({
      staff_id: staffId,
      period,
      data: result.rows, // array of { period: "2025-06-05", chat_count: "3" } or monthly
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


export default router;
