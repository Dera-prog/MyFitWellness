import { serve } from '@hono/node-server';

import { app } from './app.js';
import { env, pool } from './db.js';
import { migrate } from './migrate.js';
import { seedCatalog, seedDemoUser } from './seed.js';

async function main() {
  const applied = await migrate();
  if (applied.length > 0) console.log(`[db] applied migrations: ${applied.join(', ')}`);
  await seedCatalog();
  await seedDemoUser();
  console.log('[db] catalog ready');

  const server = serve({ fetch: app.fetch, port: env.port, hostname: '0.0.0.0' }, (info) => {
    console.log(`[api] listening on :${info.port} (${env.nodeEnv})`);
  });

  const shutdown = async (signal: string) => {
    console.log(`[api] ${signal} received, shutting down`);
    server.close();
    await pool.end();
    process.exit(0);
  };
  process.on('SIGTERM', () => void shutdown('SIGTERM'));
  process.on('SIGINT', () => void shutdown('SIGINT'));
}

main().catch(async (error) => {
  console.error('[api] failed to start', error);
  await pool.end().catch(() => undefined);
  process.exit(1);
});
