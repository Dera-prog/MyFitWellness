import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';

import { app } from '../src/app.js';
import { pool } from '../src/db.js';
import { migrate } from '../src/migrate.js';
import { seedCatalog } from '../src/seed.js';

const email = `it-${Date.now()}@myfitwellness.test`;
const password = 'supersecret1';
let token = '';

interface ApiResult {
  status: number;
  json: any;
}

async function call(
  path: string,
  options: { method?: string; body?: unknown; token?: string | null } = {},
): Promise<ApiResult> {
  const headers: Record<string, string> = {};
  if (options.body !== undefined) headers['content-type'] = 'application/json';
  const auth = options.token === undefined ? token : options.token;
  if (auth) headers.authorization = `Bearer ${auth}`;
  const response = await app.request(path, {
    method: options.method ?? 'GET',
    headers,
    body: options.body === undefined ? undefined : JSON.stringify(options.body),
  });
  const text = await response.text();
  return { status: response.status, json: text ? JSON.parse(text) : null };
}

before(async () => {
  await migrate();
  await seedCatalog();
  const created = await call('/api/auth/register', {
    method: 'POST',
    token: null,
    body: { name: 'Test Runner', email, password, phone: '+2348000000000' },
  });
  assert.equal(created.status, 201, JSON.stringify(created.json));
  token = created.json.token;
});

after(async () => {
  await pool.query("DELETE FROM users WHERE email LIKE 'it-%@myfitwellness.test'");
  await pool.end();
});

test('health endpoint reports a live database', async () => {
  const result = await call('/healthz', { token: null });
  assert.equal(result.status, 200);
  assert.equal(result.json.ok, true);
  assert.equal(result.json.db, 'up');
});

test('registration rejects a duplicate email', async () => {
  const result = await call('/api/auth/register', {
    method: 'POST',
    token: null,
    body: { name: 'Copy Cat', email, password },
  });
  assert.equal(result.status, 409);
  assert.equal(result.json.error, 'email_taken');
});

test('login rejects a wrong password and accepts the right one', async () => {
  const bad = await call('/api/auth/login', {
    method: 'POST',
    token: null,
    body: { email, password: 'wrong-password' },
  });
  assert.equal(bad.status, 401);

  const good = await call('/api/auth/login', {
    method: 'POST',
    token: null,
    body: { email, password },
  });
  assert.equal(good.status, 200);
  assert.ok(good.json.token);
  assert.equal(good.json.user.email, email);
});

test('unauthenticated requests are rejected', async () => {
  const result = await call('/api/me', { token: null });
  assert.equal(result.status, 401);
});

test('bootstrap returns the seeded app state', async () => {
  const result = await call('/api/me');
  assert.equal(result.status, 200);
  assert.equal(result.json.user.plan, 'general');
  assert.equal(result.json.user.gym, 'Iron House Fitness');
  assert.equal(result.json.workout.length, 6);
  assert.equal(result.json.goals.length, 3);
  assert.equal(result.json.videos.length, 6);
  assert.equal(result.json.coaches.length, 4);
  assert.equal(result.json.reminders.length, 3);
  assert.equal(result.json.stats.totalToday, 6);
});

test('workout checklist items can be ticked', async () => {
  const me = await call('/api/me');
  const item = me.json.workout[1];
  const patched = await call(`/api/workouts/today/${item.id}`, {
    method: 'PATCH',
    body: { done: true },
  });
  assert.equal(patched.status, 200);
  assert.equal(patched.json.item.done, true);

  const today = await call('/api/workouts/today');
  assert.equal(today.json.workout[1].done, true);
});

test('stopwatch sets are persisted', async () => {
  const logged = await call('/api/workouts/sets', {
    method: 'POST',
    body: { exercise: 'Bench press', setNumber: 1, seconds: 74 },
  });
  assert.equal(logged.status, 201);
  assert.equal(logged.json.set.setNumber, 1);

  const sets = await call('/api/workouts/sets');
  assert.equal(sets.json.sets[0].seconds, 74);
});

test('premium videos are locked until a Premium plan is purchased', async () => {
  const locked = await call('/api/videos/push-mastery/play', { method: 'POST' });
  assert.equal(locked.status, 402);
  assert.equal(locked.json.error, 'premium_required');

  const purchase = await call('/api/me/plan', {
    method: 'POST',
    body: { plan: 'premium', annual: false },
  });
  assert.equal(purchase.status, 200);
  assert.equal(purchase.json.user.plan, 'premium');
  assert.equal(purchase.json.payment.discountCents, 750);
  assert.equal(purchase.json.payment.amountCents, 749);
  assert.equal(purchase.json.payment.promo, true);
  assert.ok(purchase.json.user.renewalDate);

  const play = await call('/api/videos/push-mastery/play', { method: 'POST' });
  assert.equal(play.status, 200);

  const library = await call('/api/videos');
  assert.equal(library.json.videos.find((v: any) => v.id === 'push-mastery').locked, false);
});

test('plan switching and cancellation update the subscription', async () => {
  const annual = await call('/api/me/plan/switch', {
    method: 'POST',
    body: { plan: 'premium', annual: true },
  });
  assert.equal(annual.status, 200);
  assert.equal(annual.json.user.annualBilling, true);
  const days =
    (new Date(annual.json.user.renewalDate).getTime() - Date.now()) / (1000 * 60 * 60 * 24);
  assert.ok(days > 300, `expected an annual renewal, got ${days} days`);

  const cancel = await call('/api/me/plan/cancel', { method: 'POST' });
  assert.equal(cancel.status, 200);
  assert.equal(cancel.json.user.plan, 'general');
  assert.equal(cancel.json.user.planStartedAt, null);

  const lockedAgain = await call('/api/videos/push-mastery/play', { method: 'POST' });
  assert.equal(lockedAgain.status, 402);
});

test('goals can be created and progressed', async () => {
  const created = await call('/api/goals', {
    method: 'POST',
    body: { title: 'Run 5K', unit: 'km', start: 0, target: 5, icon: 'bolt', color: 'amber' },
  });
  assert.equal(created.status, 201);

  const updated = await call(`/api/goals/${created.json.goal.id}`, {
    method: 'PATCH',
    body: { current: 2.4 },
  });
  assert.equal(updated.status, 200);
  assert.equal(updated.json.goal.current, 2.4);

  const goals = await call('/api/goals');
  assert.equal(goals.json.goals.length, 4);
});

test('coaching stores the message and a coach reply', async () => {
  const sent = await call('/api/coaching/amara/messages', {
    method: 'POST',
    body: { text: 'What should I eat after a late session?' },
  });
  assert.equal(sent.status, 201);
  assert.equal(sent.json.message.from_me, true);
  assert.equal(sent.json.reply.from_me, false);

  const thread = await call('/api/coaching/amara/messages');
  assert.equal(thread.status, 200);
  assert.equal(thread.json.messages.length, 5);
});

test('reminders and gym membership can be updated', async () => {
  const reminders = await call('/api/me/reminders', {
    method: 'PUT',
    body: {
      reminders: [
        { label: 'Morning walk', time: '06:15', enabled: true },
        { label: 'Protein shake', time: '18:00', enabled: false },
      ],
    },
  });
  assert.equal(reminders.status, 200);
  assert.equal(reminders.json.reminders.length, 2);

  const gyms = await call('/api/gyms?q=Lekki', { token: null });
  assert.equal(gyms.status, 200);
  assert.ok(gyms.json.gyms.length >= 1);

  const gym = await call('/api/me/gym', {
    method: 'PUT',
    body: { gymId: gyms.json.gyms[0].id },
  });
  assert.equal(gym.status, 200);
  assert.equal(gym.json.user.gym, 'Iron House Fitness');
});

test('calendar entries can be booked and read back', async () => {
  const today = new Date().toISOString().slice(0, 10);
  const booked = await call('/api/workouts/schedule', {
    method: 'POST',
    body: { date: today, title: 'Evening HIIT', minutes: 30, kcal: 260, intensity: 0.7 },
  });
  assert.equal(booked.status, 201);

  const schedule = await call(`/api/workouts/schedule?from=${today}&to=${today}`);
  assert.equal(schedule.status, 200);
  assert.ok(schedule.json.entries.some((entry: any) => entry.title === 'Evening HIIT'));
});
