import { Hono } from 'hono';
import { z } from 'zod';

import { one, query } from '../db.js';
import { HttpError, parse, readJson, type AppEnv } from '../http.js';

const messageSchema = z.object({
  text: z.string().trim().min(1, 'Write a message first').max(2000),
});

const NUTRITION_REPLIES = [
  'Logged. Keep protein within an hour of training — 35g is the target.',
  'Good question. Build the plate around protein, then add colour and a smart carb.',
  'I updated your plan notes. Hydrate first and we can adjust after your next weigh-in.',
  'Try to keep the same meal timing this week so we can compare properly.',
];

const TRAINER_REPLIES = [
  'Noted — I will work that into your next session.',
  'Good check-in. Keep the tempo controlled and tell me how the last set felt.',
  'Let us review this on your next session; bring your numbers with you.',
  'That is a solid plan. Keep one rep in reserve on every working set.',
];

export const coachingRoutes = new Hono<AppEnv>();

coachingRoutes.get('/coaches', async (c) => {
  const coaches = await query('SELECT * FROM coaches ORDER BY position');
  return c.json({
    coaches: coaches.map((row: Record<string, unknown>) => ({
      key: row.key,
      name: row.name,
      specialty: row.specialty,
      rating: row.rating,
      sessions: row.sessions,
      initials: row.initials,
      color: row.color,
      role: row.role,
    })),
  });
});

coachingRoutes.get('/:key/messages', async (c) => {
  const userId = c.get('userId');
  const key = c.req.param('key');
  const coach = await one('SELECT key FROM coaches WHERE key = $1', [key]);
  if (!coach) throw new HttpError(404, 'not_found', 'Coach not found');
  const messages = await query(
    `SELECT id, coach_key, body, from_me, created_at
       FROM messages
      WHERE user_id = $1 AND coach_key = $2
      ORDER BY created_at`,
    [userId, key],
  );
  return c.json({ messages });
});

coachingRoutes.post('/:key/messages', async (c) => {
  const userId = c.get('userId');
  const key = c.req.param('key');
  const body = parse(messageSchema, await readJson(c));

  const coach = await one<{ key: string; role: string }>(
    'SELECT key, role FROM coaches WHERE key = $1',
    [key],
  );
  if (!coach) throw new HttpError(404, 'not_found', 'Coach not found');

  const pool = coach.role === 'nutritionist' ? NUTRITION_REPLIES : TRAINER_REPLIES;
  const replyText = pool[body.text.length % pool.length]!;

  const inserted = await query(
    `INSERT INTO messages (user_id, coach_key, body, from_me)
     VALUES ($1, $2, $3, TRUE)
     RETURNING id, coach_key, body, from_me, created_at`,
    [userId, key, body.text],
  );
  const reply = await query(
    `INSERT INTO messages (user_id, coach_key, body, from_me)
     VALUES ($1, $2, $3, FALSE)
     RETURNING id, coach_key, body, from_me, created_at`,
    [userId, key, replyText],
  );
  return c.json({ message: inserted[0], reply: reply[0] }, 201);
});
