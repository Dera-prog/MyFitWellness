import { Hono } from 'hono';
import { z } from 'zod';

import { one, query } from '../db.js';
import { HttpError, parse, readJson, type AppEnv } from '../http.js';

const createSchema = z.object({
  title: z.string().trim().min(1).max(120),
  unit: z.string().trim().max(16).default(''),
  start: z.number().min(-100000).max(100000).default(0),
  target: z.number().min(-100000).max(100000),
  current: z.number().min(-100000).max(100000).optional(),
  icon: z.string().trim().max(40).default('flag'),
  color: z.string().trim().max(20).default('green'),
});

const patchSchema = z.object({
  title: z.string().trim().min(1).max(120).optional(),
  target: z.number().min(-100000).max(100000).optional(),
  current: z.number().min(-100000).max(100000).optional(),
});

export const goalRoutes = new Hono<AppEnv>();

goalRoutes.get('/', async (c) => {
  const goals = await query(
    `SELECT id, title, unit, start_value AS start, target_value AS target,
            current_value AS current, icon, color
       FROM goals
      WHERE user_id = $1
      ORDER BY position, created_at`,
    [c.get('userId')],
  );
  return c.json({ goals });
});

goalRoutes.post('/', async (c) => {
  const userId = c.get('userId');
  const body = parse(createSchema, await readJson(c));
  const next = await one<{ next: number }>(
    'SELECT coalesce(max(position), -1) + 1 AS next FROM goals WHERE user_id = $1',
    [userId],
  );
  const rows = await query(
    `INSERT INTO goals
       (user_id, title, unit, start_value, target_value, current_value, icon, color, position)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
     RETURNING id, title, unit, start_value AS start, target_value AS target,
               current_value AS current, icon, color`,
    [
      userId,
      body.title,
      body.unit,
      body.start,
      body.target,
      body.current ?? body.start,
      body.icon,
      body.color,
      next?.next ?? 0,
    ],
  );
  return c.json({ goal: rows[0] }, 201);
});

goalRoutes.patch('/:id', async (c) => {
  const userId = c.get('userId');
  const id = parse(z.string().uuid(), c.req.param('id'));
  const body = parse(patchSchema, await readJson(c));
  const fields: string[] = [];
  const values: unknown[] = [id, userId];
  const set = (column: string, value: unknown) => {
    values.push(value);
    fields.push(`${column} = $${values.length}`);
  };
  if (body.title !== undefined) set('title', body.title);
  if (body.target !== undefined) set('target_value', body.target);
  if (body.current !== undefined) set('current_value', body.current);
  if (fields.length === 0) throw new HttpError(400, 'validation_error', 'Nothing to update');

  const rows = await query(
    `UPDATE goals SET ${fields.join(', ')}
      WHERE id = $1 AND user_id = $2
      RETURNING id, title, unit, start_value AS start, target_value AS target,
                current_value AS current, icon, color`,
    values,
  );
  if (rows.length === 0) throw new HttpError(404, 'not_found', 'Goal not found');
  return c.json({ goal: rows[0] });
});

goalRoutes.delete('/:id', async (c) => {
  const userId = c.get('userId');
  const id = parse(z.string().uuid(), c.req.param('id'));
  const rows = await query('DELETE FROM goals WHERE id = $1 AND user_id = $2 RETURNING id', [
    id,
    userId,
  ]);
  if (rows.length === 0) throw new HttpError(404, 'not_found', 'Goal not found');
  return c.body(null, 204);
});
