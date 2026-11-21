import type { Context } from 'hono';
import type { z } from 'zod';

import { findSessionUser } from './auth.js';

export type AppEnv = { Variables: { userId: string; token: string } };
export type AppContext = Context<AppEnv>;

export class HttpError extends Error {
  status: number;
  code: string;

  constructor(status: number, code: string, message?: string) {
    super(message ?? code);
    this.status = status;
    this.code = code;
  }
}

export function parse<S extends z.ZodTypeAny>(schema: S, value: unknown): z.infer<S> {
  const result = schema.safeParse(value);
  if (!result.success) {
    const issue = result.error.issues[0];
    const path = issue?.path.join('.');
    throw new HttpError(
      400,
      'validation_error',
      path ? `${path}: ${issue?.message}` : issue?.message,
    );
  }
  return result.data;
}

export async function readJson(c: AppContext): Promise<unknown> {
  try {
    return await c.req.json();
  } catch {
    throw new HttpError(400, 'invalid_json', 'Request body must be valid JSON');
  }
}

export async function authMiddleware(c: AppContext, next: () => Promise<void>) {
  const header = c.req.header('authorization') ?? '';
  const token = header.toLowerCase().startsWith('bearer ') ? header.slice(7).trim() : '';
  if (!token) throw new HttpError(401, 'unauthorized', 'Missing bearer token');
  const userId = await findSessionUser(token);
  if (!userId) throw new HttpError(401, 'unauthorized', 'Session expired or invalid');
  c.set('userId', userId);
  c.set('token', token);
  await next();
}

export function bearerToken(c: AppContext): string {
  return c.get('token');
}
