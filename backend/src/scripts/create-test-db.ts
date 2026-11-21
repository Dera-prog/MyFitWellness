import pg from 'pg';

async function main() {
  const target = process.env.DATABASE_URL;
  if (!target) throw new Error('DATABASE_URL is required');
  const adminUrl = process.env.ADMIN_DATABASE_URL;
  if (!adminUrl) throw new Error('ADMIN_DATABASE_URL is required');

  const dbName = decodeURIComponent(new URL(target).pathname.replace(/^\//, ''));
  if (!/^[A-Za-z0-9_]+$/.test(dbName)) throw new Error(`Unsafe database name: ${dbName}`);

  const ssl = /sslmode=(require|verify)/i.test(adminUrl) ? { rejectUnauthorized: false } : undefined;
  const client = new pg.Client({ connectionString: adminUrl, ssl });
  await client.connect();
  try {
    const existing = await client.query('SELECT 1 FROM pg_database WHERE datname = $1', [dbName]);
    if (existing.rowCount === 0) {
      await client.query(`CREATE DATABASE "${dbName}"`);
      console.log(`created database ${dbName}`);
    } else {
      console.log(`database ${dbName} already exists`);
    }
  } finally {
    await client.end();
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
