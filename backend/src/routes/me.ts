import { randomBytes } from 'node:crypto';

import { Hono } from 'hono';
import { z } from 'zod';

import { one, query, tx } from '../db.js';
import { HttpError, parse, readJson, type AppEnv } from '../http.js';
import { ensureTodayWorkout } from '../seed.js';
import {
  PRICES,
  priceFor,
  renewalFrom,
  userJson,
  type UserRow,
} from '../serialize.js';

const patchSchema = z.object({
  name: z.string().trim().min(2).max(80).optional(),
  email: z.string().trim().email().max(200).optional(),
  phone: z.string().trim().max(40).nullable().optional(),
  reminders: z.boolean().optional(),
  goalCheckIns: z.boolean().optional(),
  renewalAlerts: z.boolean().optional(),
  stopwatchPaired: z.boolean().optional(),
});

const gymSchema = z.object({
  gymId: z.string().uuid().nullable().optional(),
  label: z.string().trim().min(1).max(120).optional(),
});

const planSchema = z.object({
  plan: z.enum(['general', 'premium']),
  annual: z.boolean().default(false),
});

const remindersSchema = z.object({
  reminders: z
    .array(
      z.object({
        label: z.string().trim().min(1).max(120),
        time: z.string().trim().min(1).max(20),
        enabled: z.boolean().default(true),
      }),
    )
    .max(20),
});

export const meRoutes = new Hono<AppEnv>();

meRoutes.get('/', async (c) => {
  const userId = c.get('userId');
  const user = await one<UserRow>('SELECT * FROM users WHERE id = $1', [userId]);
  if (!user) throw new HttpError(401, 'unauthorized');

  await ensureTodayWorkout(userId);
  const today = new Date().toISOString().slice(0, 10);

  const [workout, history, goals, videos, coaches, reminders, messages, mealPlans, sets, week] =
    await Promise.all([
      query(
        `SELECT id, name, detail, sets, reps, weight, minutes, icon, done
           FROM workout_items
          WHERE user_id = $1 AND workout_date = $2
          ORDER BY position`,
        [userId, today],
      ),
      query(
        `SELECT id, to_char(entry_date, 'YYYY-MM-DD') AS date, title, minutes, exercises, kcal, intensity
           FROM schedule_entries
          WHERE user_id = $1
          ORDER BY entry_date DESC
          LIMIT 30`,
        [userId],
      ),
      query(
        `SELECT id, title, unit, start_value AS start, target_value AS target,
                current_value AS current, icon, color
           FROM goals
          WHERE user_id = $1
          ORDER BY position, created_at`,
        [userId],
      ),
      query('SELECT * FROM videos ORDER BY position'),
      query('SELECT * FROM coaches ORDER BY position'),
      query(
        'SELECT id, label, time_label AS time, enabled FROM reminders WHERE user_id = $1 ORDER BY position',
        [userId],
      ),
      query(
        `SELECT id, coach_key, body, from_me, created_at
           FROM messages
          WHERE user_id = $1
          ORDER BY created_at`,
        [userId],
      ),
      query('SELECT * FROM meal_plans ORDER BY position'),
      query(
        `SELECT id, exercise, set_number, seconds, logged_at
           FROM workout_logs
          WHERE user_id = $1
          ORDER BY logged_at DESC
          LIMIT 20`,
        [userId],
      ),
      one<{ minutes: number }>(
        `SELECT coalesce(sum(minutes), 0)::int AS minutes
           FROM schedule_entries
          WHERE user_id = $1 AND entry_date >= CURRENT_DATE - 6`,
        [userId],
      ),
    ]);

  const premium = user.plan === 'premium';
  const completedToday = workout.filter(
    (row) => (row as { done?: boolean }).done === true,
  ).length;

  return c.json({
    user: userJson(user),
    workout: workout.map((row: Record<string, unknown>) => ({ ...row })),
    history,
    goals,
    videos: videos.map((row: Record<string, unknown>) => ({
      ...row,
      locked: Boolean(row.premium) && !premium,
    })),
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
    reminders,
    messages,
    mealPlans: mealPlans.map((row: Record<string, unknown>) => ({
      ...row,
      locked: Boolean(row.premium) && !premium,
    })),
    sets,
    stats: {
      completedToday,
      totalToday: workout.length,
      minutesThisWeek: week?.minutes ?? 0,
      streak: user.streak,
    },
    prices: PRICES,
  });
});

meRoutes.patch('/', async (c) => {
  const userId = c.get('userId');
  const body = parse(patchSchema, await readJson(c));
  const fields: string[] = [];
  const values: unknown[] = [userId];
  const set = (column: string, value: unknown) => {
    values.push(value);
    fields.push(`${column} = $${values.length}`);
  };

  if (body.name !== undefined) set('name', body.name);
  if (body.email !== undefined) set('email', body.email.toLowerCase());
  if (body.phone !== undefined) set('phone', body.phone);
  if (body.reminders !== undefined) set('reminders', body.reminders);
  if (body.goalCheckIns !== undefined) set('goal_check_ins', body.goalCheckIns);
  if (body.renewalAlerts !== undefined) set('renewal_alerts', body.renewalAlerts);
  if (body.stopwatchPaired !== undefined) set('stopwatch_paired', body.stopwatchPaired);

  if (fields.length > 0) {
    try {
      await query(`UPDATE users SET ${fields.join(', ')} WHERE id = $1`, values);
    } catch (error) {
      if ((error as { code?: string }).code === '23505') {
        throw new HttpError(409, 'email_taken', 'That email already has an account');
      }
      throw error;
    }
  }
  const user = await one<UserRow>('SELECT * FROM users WHERE id = $1', [userId]);
  return c.json({ user: userJson(user!) });
});

meRoutes.put('/gym', async (c) => {
  const userId = c.get('userId');
  const body = parse(gymSchema, await readJson(c));
  if (body.gymId) {
    const gym = await one<{ id: string; name: string }>(
      'SELECT id, name FROM gyms WHERE id = $1',
      [body.gymId],
    );
    if (!gym) throw new HttpError(404, 'gym_not_found', 'That gym is not registered yet');
    await query('UPDATE users SET gym_id = $2, gym_label = $3 WHERE id = $1', [
      userId,
      gym.id,
      gym.name,
    ]);
  } else if (body.label) {
    await query('UPDATE users SET gym_id = NULL, gym_label = $2 WHERE id = $1', [
      userId,
      body.label,
    ]);
  } else {
    throw new HttpError(400, 'validation_error', 'Provide a gymId or a label');
  }
  const user = await one<UserRow>('SELECT * FROM users WHERE id = $1', [userId]);
  return c.json({ user: userJson(user!) });
});

meRoutes.get('/plan', async (c) => {
  const user = await one<UserRow>('SELECT * FROM users WHERE id = $1', [c.get('userId')]);
  return c.json({
    user: userJson(user!),
    prices: PRICES,
    renewalDate: renewalFrom(user!.plan_started_at, user!.annual_billing),
  });
});

meRoutes.post('/plan', async (c) => {
  const userId = c.get('userId');
  const body = parse(planSchema, await readJson(c));
  const user = (await one<UserRow>('SELECT * FROM users WHERE id = $1', [userId]))!;

  const full = priceFor(body.plan, body.annual);
  const promo = !body.annual && !user.promo_used;
  const discount = promo ? Math.round(full / 2) : 0;
  const amount = full - discount;
  const receipt = `MFW-${randomBytes(3).toString('hex').toUpperCase()}`;

  if (body.plan === 'premium') {
    const started = new Date();
    const renews = renewalFrom(started, body.annual)!;
    await query(
      `UPDATE users
          SET plan = 'premium', annual_billing = $2, plan_started_at = $3,
              plan_renews_at = $4, plan_status = 'active', promo_used = promo_used OR $5
        WHERE id = $1`,
      [userId, body.annual, started, renews, promo],
    );
  } else {
    await query(
      `UPDATE users
          SET plan = 'general', annual_billing = $2, plan_started_at = NULL,
              plan_renews_at = NULL, plan_status = 'active', promo_used = promo_used OR $3
        WHERE id = $1`,
      [userId, body.annual, promo],
    );
  }

  await query(
    `INSERT INTO payments (user_id, plan, billing, amount_cents, discount_cents, promo, receipt_code)
     VALUES ($1, $2, $3, $4, $5, $6, $7)`,
    [userId, body.plan, body.annual ? 'annual' : 'monthly', amount, discount, promo, receipt],
  );
  const fresh = (await one<UserRow>('SELECT * FROM users WHERE id = $1', [userId]))!;
  return c.json({
    user: userJson(fresh),
    payment: {
      amountCents: amount,
      discountCents: discount,
      promo,
      receiptCode: receipt,
      billing: body.annual ? 'annual' : 'monthly',
    },
  });
});

meRoutes.post('/plan/switch', async (c) => {
  const userId = c.get('userId');
  const body = parse(planSchema, await readJson(c));
  if (body.plan === 'premium') {
    const user = (await one<UserRow>('SELECT * FROM users WHERE id = $1', [userId]))!;
    const started = user.plan_started_at ?? new Date();
    const renews = renewalFrom(started, body.annual)!;
    await query(
      `UPDATE users
          SET plan = 'premium', annual_billing = $2, plan_started_at = $3,
              plan_renews_at = $4, plan_status = 'active'
        WHERE id = $1`,
      [userId, body.annual, started, renews],
    );
  } else {
    await query(
      `UPDATE users
          SET plan = 'general', annual_billing = FALSE, plan_started_at = NULL,
              plan_renews_at = NULL, plan_status = 'active'
        WHERE id = $1`,
      [userId],
    );
  }
  const fresh = (await one<UserRow>('SELECT * FROM users WHERE id = $1', [userId]))!;
  return c.json({ user: userJson(fresh) });
});

meRoutes.post('/plan/cancel', async (c) => {
  const userId = c.get('userId');
  await query(
    `UPDATE users
        SET plan = 'general', annual_billing = FALSE, plan_started_at = NULL,
            plan_renews_at = NULL, plan_status = 'cancelled'
      WHERE id = $1`,
    [userId],
  );
  const fresh = (await one<UserRow>('SELECT * FROM users WHERE id = $1', [userId]))!;
  return c.json({ user: userJson(fresh) });
});

meRoutes.put('/reminders', async (c) => {
  const userId = c.get('userId');
  const body = parse(remindersSchema, await readJson(c));
  await tx(async (client) => {
    await client.query('DELETE FROM reminders WHERE user_id = $1', [userId]);
    for (const [index, reminder] of body.reminders.entries()) {
      await client.query(
        `INSERT INTO reminders (user_id, label, time_label, enabled, position)
         VALUES ($1, $2, $3, $4, $5)`,
        [userId, reminder.label, reminder.time, reminder.enabled, index],
      );
    }
  });
  const reminders = await query(
    'SELECT id, label, time_label AS time, enabled FROM reminders WHERE user_id = $1 ORDER BY position',
    [userId],
  );
  return c.json({ reminders });
});
