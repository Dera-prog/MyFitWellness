import { Hono } from 'hono';
import { z } from 'zod';

import { createSession, hashPassword, revokeSession, verifyPassword } from '../auth.js';
import { one, query } from '../db.js';
import { HttpError, parse, readJson, type AppEnv } from '../http.js';
import { seedUserDefaults } from '../seed.js';
import { userJson, type UserRow } from '../serialize.js';

const registerSchema = z.object({
  name: z.string().trim().min(2, 'Name is too short').max(80),
  email: z.string().trim().email('Enter a valid email').max(200),
  password: z.string().min(6, 'Use at least 6 characters').max(200),
  phone: z.string().trim().max(40).optional(),
});

const loginSchema = z.object({
  email: z.string().trim().email('Enter a valid email').max(200),
  password: z.string().min(1).max(200),
});

export const authRoutes = new Hono<AppEnv>();

authRoutes.post('/register', async (c) => {
  const body = parse(registerSchema, await readJson(c));
  const email = body.email.toLowerCase();
  const existing = await one('SELECT id FROM users WHERE email = $1', [email]);
  if (existing) throw new HttpError(409, 'email_taken', 'That email already has an account');

  const passwordHash = await hashPassword(body.password);
  let user: UserRow;
  try {
    const rows = await query<UserRow>(
      `INSERT INTO users (name, email, phone, password_hash)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [body.name, email, body.phone ?? null, passwordHash],
    );
    user = rows[0]!;
  } catch (error) {
    if ((error as { code?: string }).code === '23505') {
      throw new HttpError(409, 'email_taken', 'That email already has an account');
    }
    throw error;
  }

  await seedUserDefaults(user.id, user.name);
  const fresh = (await one<UserRow>('SELECT * FROM users WHERE id = $1', [user.id]))!;
  const token = await createSession(user.id);
  return c.json({ token, user: userJson(fresh) }, 201);
});

authRoutes.post('/login', async (c) => {
  const body = parse(loginSchema, await readJson(c));
  const user = await one<UserRow>('SELECT * FROM users WHERE email = $1', [
    body.email.toLowerCase(),
  ]);
  if (!user || !(await verifyPassword(body.password, user.password_hash))) {
    throw new HttpError(401, 'invalid_credentials', 'Email or password is incorrect');
  }
  const token = await createSession(user.id);
  return c.json({ token, user: userJson(user) });
});

authRoutes.post('/logout', async (c) => {
  const header = c.req.header('authorization') ?? '';
  const token = header.toLowerCase().startsWith('bearer ') ? header.slice(7).trim() : '';
  if (token) await revokeSession(token);
  return c.body(null, 204);
});
