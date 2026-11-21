import { Hono } from 'hono';

import { query } from '../db.js';
import { PRICES } from '../serialize.js';
import type { AppEnv } from '../http.js';

export const publicRoutes = new Hono<AppEnv>();

publicRoutes.get('/gyms', async (c) => {
  const q = (c.req.query('q') ?? '').trim();
  const gyms = await query(
    `SELECT id, name, city, address
       FROM gyms
      WHERE ($1 = '' OR name ILIKE '%' || $1 || '%' OR city ILIKE '%' || $1 || '%')
      ORDER BY name`,
    [q],
  );
  return c.json({ gyms });
});

publicRoutes.get('/pricing', async (c) => {
  return c.json({
    currency: 'USD',
    promo: '50% off the first month on monthly plans',
    plans: [
      { key: 'general', name: 'General', ...PRICES.general },
      { key: 'premium', name: 'Premium', ...PRICES.premium },
    ],
  });
});
