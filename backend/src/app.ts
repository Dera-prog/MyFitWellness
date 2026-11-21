import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';

import { query } from './db.js';
import { env } from './db.js';
import { authMiddleware, HttpError, type AppEnv } from './http.js';
import { openapi } from './openapi.js';
import { authRoutes } from './routes/auth.js';
import { coachingRoutes } from './routes/coaching.js';
import { goalRoutes } from './routes/goals.js';
import { meRoutes } from './routes/me.js';
import { publicRoutes } from './routes/public.js';
import { videoRoutes } from './routes/videos.js';
import { workoutRoutes } from './routes/workouts.js';

export const app = new Hono<AppEnv>();

app.use('*', logger());
app.use(
  '*',
  cors({
    origin: (origin) => {
      if (!origin) return '*';
      if (env.corsOrigin === '*') return origin;
      const allowed = env.corsOrigin.split(',').map((value) => value.trim());
      return allowed.includes(origin) ? origin : (allowed[0] ?? '');
    },
    allowMethods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization'],
    maxAge: 86400,
  }),
);

app.get('/healthz', async (c) => {
  try {
    await query('SELECT 1');
    return c.json({ ok: true, db: 'up', version: '1.0.0' });
  } catch {
    return c.json({ ok: false, db: 'down' }, 503);
  }
});

const api = new Hono<AppEnv>();

api.get('/', (c) =>
  c.json({
    name: 'MyFitWellness API',
    version: '1.0.0',
    docs: '/api/openapi.json',
    endpoints: {
      auth: ['POST /api/auth/register', 'POST /api/auth/login', 'POST /api/auth/logout'],
      profile: ['GET /api/me', 'PATCH /api/me', 'PUT /api/me/gym', 'PUT /api/me/reminders'],
      billing: [
        'GET /api/me/plan',
        'POST /api/me/plan',
        'POST /api/me/plan/switch',
        'POST /api/me/plan/cancel',
      ],
      training: [
        'GET /api/workouts/today',
        'POST /api/workouts/today',
        'PATCH /api/workouts/today/:id',
        'DELETE /api/workouts/today/:id',
        'POST /api/workouts/sets',
        'GET /api/workouts/schedule',
        'POST /api/workouts/schedule',
      ],
      goals: ['GET /api/goals', 'POST /api/goals', 'PATCH /api/goals/:id', 'DELETE /api/goals/:id'],
      library: ['GET /api/videos', 'POST /api/videos/:id/play'],
      coaching: ['GET /api/coaching/coaches', 'GET /api/coaching/:key/messages', 'POST /api/coaching/:key/messages'],
    },
  }),
);
api.get('/openapi.json', (c) => c.json(openapi));
api.route('/', publicRoutes);
api.route('/auth', authRoutes);

api.use('*', authMiddleware);
api.route('/me', meRoutes);
api.route('/workouts', workoutRoutes);
api.route('/goals', goalRoutes);
api.route('/videos', videoRoutes);
api.route('/coaching', coachingRoutes);

app.route('/api', api);

app.notFound((c) => c.json({ error: 'not_found', message: 'No route matches this request' }, 404));

app.onError((error, c) => {
  if (error instanceof HttpError) {
    return c.json({ error: error.code, message: error.message }, error.status as 400);
  }
  console.error('[api] unhandled error', error);
  return c.json({ error: 'internal_error', message: 'Something went wrong' }, 500);
});
