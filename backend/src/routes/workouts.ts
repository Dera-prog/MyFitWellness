import { Hono } from 'hono';
import { z } from 'zod';

import { one, query } from '../db.js';
import { HttpError, parse, readJson, type AppEnv } from '../http.js';
import { ensureTodayWorkout } from '../seed.js';

const itemSchema = z.object({
  name: z.string().trim().min(1).max(120),
  detail: z.string().trim().max(200).default(''),
  sets: z.number().int().min(0).max(99).default(1),
  reps: z.number().int().min(0).max(999).default(0),
  weight: z.number().min(0).max(1000).default(0),
  minutes: z.number().int().min(0).max(600).default(0),
  icon: z.string().trim().max(40).default('fitness_center'),
});

const doneSchema = z.object({ done: z.boolean() });

const logSchema = z.object({
  exercise: z.string().trim().min(1).max(120),
  setNumber: z.number().int().min(1).max(99),
  seconds: z.number().int().min(0).max(86400),
});

const scheduleSchema = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Use YYYY-MM-DD'),
  title: z.string().trim().min(1).max(120),
  minutes: z.number().int().min(0).max(1440).default(0),
  exercises: z.number().int().min(0).max(99).default(0),
  kcal: z.number().int().min(0).max(5000).default(0),
  intensity: z.number().min(0).max(1).default(0.5),
});

export const workoutRoutes = new Hono<AppEnv>();

workoutRoutes.get('/today', async (c) => {
  const userId = c.get('userId');
  await ensureTodayWorkout(userId);
  const workout = await query(
    `SELECT id, name, detail, sets, reps, weight, minutes, icon, done
       FROM workout_items
      WHERE user_id = $1 AND workout_date = CURRENT_DATE
      ORDER BY position, created_at`,
    [userId],
  );
  return c.json({ workout });
});

workoutRoutes.post('/today', async (c) => {
  const userId = c.get('userId');
  const body = parse(itemSchema, await readJson(c));
  const next = await one<{ next: number }>(
    `SELECT coalesce(max(position), -1) + 1 AS next
       FROM workout_items
      WHERE user_id = $1 AND workout_date = CURRENT_DATE`,
    [userId],
  );
  const rows = await query(
    `INSERT INTO workout_items
       (user_id, name, detail, sets, reps, weight, minutes, icon, done, position, workout_date)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, FALSE, $9, CURRENT_DATE)
     RETURNING id, name, detail, sets, reps, weight, minutes, icon, done`,
    [
      userId,
      body.name,
      body.detail,
      body.sets,
      body.reps,
      body.weight,
      body.minutes,
      body.icon,
      next?.next ?? 0,
    ],
  );
  return c.json({ item: rows[0] }, 201);
});

workoutRoutes.patch('/today/:id', async (c) => {
  const userId = c.get('userId');
  const id = parse(z.string().uuid(), c.req.param('id'));
  const body = parse(doneSchema, await readJson(c));
  const rows = await query(
    `UPDATE workout_items
        SET done = $3
      WHERE id = $1 AND user_id = $2 AND workout_date = CURRENT_DATE
      RETURNING id, name, detail, sets, reps, weight, minutes, icon, done`,
    [id, userId, body.done],
  );
  if (rows.length === 0) throw new HttpError(404, 'not_found', 'Workout item not found');
  return c.json({ item: rows[0] });
});

workoutRoutes.delete('/today/:id', async (c) => {
  const userId = c.get('userId');
  const id = parse(z.string().uuid(), c.req.param('id'));
  const rows = await query(
    'DELETE FROM workout_items WHERE id = $1 AND user_id = $2 RETURNING id',
    [id, userId],
  );
  if (rows.length === 0) throw new HttpError(404, 'not_found', 'Workout item not found');
  return c.body(null, 204);
});

workoutRoutes.get('/history', async (c) => {
  const userId = c.get('userId');
  const history = await query(
    `SELECT id, to_char(entry_date, 'YYYY-MM-DD') AS date, title, minutes, exercises, kcal, intensity
       FROM schedule_entries
      WHERE user_id = $1
      ORDER BY entry_date DESC
      LIMIT 60`,
    [userId],
  );
  return c.json({ history });
});

workoutRoutes.get('/schedule', async (c) => {
  const userId = c.get('userId');
  const from = c.req.query('from');
  const to = c.req.query('to');
  const entries = await query(
    `SELECT id, to_char(entry_date, 'YYYY-MM-DD') AS date, title, minutes, exercises, kcal, intensity, completed
       FROM schedule_entries
      WHERE user_id = $1
        AND ($2::date IS NULL OR entry_date >= $2::date)
        AND ($3::date IS NULL OR entry_date <= $3::date)
      ORDER BY entry_date`,
    [userId, from ?? null, to ?? null],
  );
  return c.json({ entries });
});

workoutRoutes.post('/schedule', async (c) => {
  const userId = c.get('userId');
  const body = parse(scheduleSchema, await readJson(c));
  const rows = await query(
    `INSERT INTO schedule_entries
       (user_id, entry_date, title, minutes, exercises, kcal, intensity)
     VALUES ($1, $2::date, $3, $4, $5, $6, $7)
     RETURNING id, to_char(entry_date, 'YYYY-MM-DD') AS date, title, minutes, exercises, kcal, intensity`,
    [userId, body.date, body.title, body.minutes, body.exercises, body.kcal, body.intensity],
  );
  return c.json({ entry: rows[0] }, 201);
});

workoutRoutes.post('/sets', async (c) => {
  const userId = c.get('userId');
  const body = parse(logSchema, await readJson(c));
  const rows = await query(
    `INSERT INTO workout_logs (user_id, exercise, set_number, seconds)
     VALUES ($1, $2, $3, $4)
     RETURNING id, exercise, set_number AS "setNumber", seconds, logged_at AS "loggedAt"`,
    [userId, body.exercise, body.setNumber, body.seconds],
  );
  return c.json({ set: rows[0] }, 201);
});

workoutRoutes.get('/sets', async (c) => {
  const userId = c.get('userId');
  const limit = Math.min(Math.max(Number(c.req.query('limit') ?? 20), 1), 100);
  const sets = await query(
    `SELECT id, exercise, set_number AS "setNumber", seconds, logged_at AS "loggedAt"
       FROM workout_logs
      WHERE user_id = $1
      ORDER BY logged_at DESC
      LIMIT $2`,
    [userId, limit],
  );
  return c.json({ sets });
});
