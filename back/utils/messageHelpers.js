import pool from './dblogin.js';
import sharp from 'sharp';

/**
 * Saves a message to the database, optionally resizing base64 image input.
 * @param {Object} message
 * @param {number} message.channel_id
 * @param {number} message.user_id
 * @param {string} message.content
 * @param {string} message.type - 'text', 'image', etc.
 * @param {string} [message.image] - Base64 image string (optional)
 * @returns {Promise<Object>} The saved message row
 */
export async function saveMessageToDb({ channel_id, user_id, content, type, image }) {
  let imageBuffer = null;

  try {
    if (image) {
      imageBuffer = Buffer.from(image, 'base64'); // Convert base64 to Buffer
      imageBuffer = await sharp(imageBuffer)
        .resize({ width: 800 })
        .jpeg({ quality: 70 })
        .toBuffer();
    }

    const result = await pool.query(
      `INSERT INTO messages (channel_id, user_id, content, type, image)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [channel_id, user_id, content, type, imageBuffer]
    );

    return result.rows[0];
  } catch (err) {
    console.error('Error saving message to DB:', err);
    throw err;
  }
}
