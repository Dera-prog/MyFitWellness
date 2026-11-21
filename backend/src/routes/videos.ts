import { Hono } from 'hono';

import { one, query } from '../db.js';
import { HttpError, type AppEnv } from '../http.js';
import type { UserRow } from '../serialize.js';

export const videoRoutes = new Hono<AppEnv>();

async function planOf(userId: string): Promise<UserRow['plan']> {
  const user = await one<{ plan: UserRow['plan'] }>('SELECT plan FROM users WHERE id = $1', [
    userId,
  ]);
  if (!user) throw new HttpError(401, 'unauthorized');
  return user.plan;
}

videoRoutes.get('/', async (c) => {
  const plan = await planOf(c.get('userId'));
  const videos = await query(
    `SELECT id, title, level, minutes, premium, focus, image
       FROM videos
      ORDER BY position`,
  );
  return c.json({
    videos: videos.map((row: Record<string, unknown>) => ({
      ...row,
      locked: Boolean(row.premium) && plan !== 'premium',
    })),
  });
});

videoRoutes.post('/:id/play', async (c) => {
  const userId = c.get('userId');
  const videoId = c.req.param('id');
  const video = await one<{ id: string; premium: boolean }>(
    'SELECT id, premium FROM videos WHERE id = $1',
    [videoId],
  );
  if (!video) throw new HttpError(404, 'not_found', 'Video not found');

  const plan = await planOf(userId);
  if (video.premium && plan !== 'premium') {
    throw new HttpError(402, 'premium_required', 'Upgrade to Premium to watch this session');
  }

  await query('INSERT INTO video_plays (user_id, video_id) VALUES ($1, $2)', [userId, videoId]);
  return c.json({ ok: true, videoId });
});
