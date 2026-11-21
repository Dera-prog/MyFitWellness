import { pool } from './db.js';
import { migrate } from './migrate.js';
import { seedCatalog, seedDemoUser } from './seed.js';

const command = process.argv[2];

async function main() {
  if (command === 'migrate') {
    const applied = await migrate();
    console.log(applied.length ? `applied: ${applied.join(', ')}` : 'already up to date');
  } else if (command === 'seed') {
    await migrate();
    await seedCatalog();
    await seedDemoUser();
    console.log('catalog seeded');
  } else {
    console.error('usage: cli <migrate|seed>');
    process.exitCode = 1;
  }
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await pool.end();
  });
