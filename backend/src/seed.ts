import type { PoolClient } from 'pg';

import { hashPassword } from './auth.js';
import { query, tx } from './db.js';

const DEMO_EMAIL = 'alex@myfitwellness.com';
const DEMO_PASSWORD = 'fitwellness';

const GYMS = [
  { name: 'Iron House Fitness', city: 'Lekki', address: '12 Admiralty Way, Lekki Phase 1' },
  { name: 'Pulse Fitness', city: 'Ikeja', address: '4 Allen Avenue, Ikeja' },
  { name: 'The Gym Hub', city: 'Victoria Island', address: '1 Adeola Odeku Street, VI' },
  { name: 'FitRepublic', city: 'Yaba', address: '8 Herbert Macaulay Way, Yaba' },
  { name: 'The Lift Room', city: 'Surulere', address: '22 Bode Thomas Street, Surulere' },
];

const VIDEOS = [
  {
    id: 'squat-form',
    title: 'Perfect squat form',
    level: 'Beginner',
    minutes: 8,
    premium: false,
    focus: 'Legs',
    image: 'assets/images/onboard_train.jpg',
  },
  {
    id: 'dumbbell-flow',
    title: 'Full-body dumbbell flow',
    level: 'Intermediate',
    minutes: 22,
    premium: false,
    focus: 'Full body',
    image: 'assets/images/onboard_track.jpg',
  },
  {
    id: 'fuel-training',
    title: 'Fuel your training',
    level: 'Beginner',
    minutes: 6,
    premium: false,
    focus: 'Nutrition',
    image: 'assets/images/onboard_food.jpg',
  },
  {
    id: 'push-mastery',
    title: 'Push-day mastery',
    level: 'Advanced',
    minutes: 34,
    premium: true,
    focus: 'Chest',
    image: 'assets/images/athlete_portrait.jpg',
  },
  {
    id: 'deadlift-power',
    title: 'Deadlift power block',
    level: 'Advanced',
    minutes: 28,
    premium: true,
    focus: 'Back',
    image: 'assets/images/onboard_train.jpg',
  },
  {
    id: 'macro-meals',
    title: 'Macro-balanced meals',
    level: 'Intermediate',
    minutes: 12,
    premium: true,
    focus: 'Nutrition',
    image: 'assets/images/onboard_food.jpg',
  },
];

const COACHES = [
  {
    key: 'daniel',
    name: 'Daniel Okoro',
    specialty: 'Strength & conditioning',
    rating: 4.9,
    sessions: 412,
    initials: 'DO',
    color: '#1F5D4A',
    role: 'trainer',
  },
  {
    key: 'maya',
    name: 'Maya Bennett',
    specialty: 'Mobility & recovery',
    rating: 4.8,
    sessions: 287,
    initials: 'MB',
    color: '#7A4E2D',
    role: 'trainer',
  },
  {
    key: 'tunde',
    name: 'Tunde Balogun',
    specialty: 'Hypertrophy coaching',
    rating: 4.7,
    sessions: 350,
    initials: 'TB',
    color: '#2C4A7A',
    role: 'trainer',
  },
  {
    key: 'amara',
    name: 'Coach Amara',
    specialty: 'Sports nutrition',
    rating: 4.9,
    sessions: 520,
    initials: 'AA',
    color: '#7A4E2D',
    role: 'nutritionist',
  },
];

const MEAL_PLANS = [
  {
    id: 'lean-strong',
    title: 'Lean & strong',
    premium: false,
    kcal: 2100,
    protein: 150,
    carbs: 210,
    fats: 68,
    meals: [
      { slot: 'Breakfast', title: 'Egg-white omelette, oats and berries', kcal: 430 },
      { slot: 'Lunch', title: 'Grilled chicken, quinoa and greens', kcal: 610 },
      { slot: 'Snack', title: 'Greek yogurt with almonds', kcal: 240 },
      { slot: 'Dinner', title: 'Baked salmon, sweet potato and broccoli', kcal: 720 },
    ],
  },
  {
    id: 'muscle-builder',
    title: 'Muscle builder',
    premium: true,
    kcal: 2800,
    protein: 190,
    carbs: 320,
    fats: 82,
    meals: [
      { slot: 'Breakfast', title: 'Protein pancakes and banana', kcal: 620 },
      { slot: 'Lunch', title: 'Beef bowl with rice and avocado', kcal: 840 },
      { slot: 'Snack', title: 'Mass shake and peanut butter toast', kcal: 520 },
      { slot: 'Dinner', title: 'Chicken pasta and parmesan', kcal: 820 },
    ],
  },
  {
    id: 'plant-powered',
    title: 'Plant powered',
    premium: true,
    kcal: 2300,
    protein: 130,
    carbs: 260,
    fats: 74,
    meals: [
      { slot: 'Breakfast', title: 'Tofu scramble and sourdough', kcal: 480 },
      { slot: 'Lunch', title: 'Chickpea and lentil power bowl', kcal: 650 },
      { slot: 'Snack', title: 'Soy yogurt and mixed seeds', kcal: 290 },
      { slot: 'Dinner', title: 'Tempeh stir-fry with brown rice', kcal: 880 },
    ],
  },
];

const WORKOUT_TEMPLATE = [
  ['Treadmill warm-up', 'Incline 4 · steady pace', 1, 0, 0, 8, 'directions_run', true],
  ['Barbell squats', 'Back squat · full depth', 4, 8, 60, 14, 'fitness_center', false],
  ['Dumbbell bench press', 'Flat bench · controlled tempo', 4, 10, 22.5, 12, 'sports_gymnastics', false],
  ['Cable rows', 'Neutral grip · squeeze 2s', 3, 12, 45, 10, 'rowing', false],
  ['Walking lunges', 'Bodyweight · long stride', 3, 16, 0, 9, 'accessibility_new', false],
  ['Core finisher', 'Plank + hollow hold circuit', 3, 1, 0, 7, 'self_improvement', false],
] as const;

const DEFAULT_GOALS = [
  ['Lose 6 kg', 'kg', 82, 76, 78.7, 'monitor_weight', 'green'],
  ['Build strength', 'kg', 40, 80, 60, 'fitness_center', 'navy'],
  ['Endurance', 'min', 10, 45, 31, 'bolt', 'amber'],
] as const;

const DEFAULT_REMINDERS = [
  ['Morning mobility', '06:30'],
  ['Workout reminder', '17:45'],
  ['Evening check-in', '21:00'],
] as const;

const HISTORY = [
  ['Push day', 1, 52, 7, 430, 0.82],
  ['Lower body strength', 2, 61, 6, 505, 0.9],
  ['HIIT + core', 3, 34, 9, 380, 0.74],
  ['Pull day', 4, 48, 6, 395, 0.78],
  ['Active recovery', 5, 26, 4, 180, 0.4],
  ['Full body circuit', 6, 55, 8, 470, 0.85],
] as const;

export async function seedCatalog(): Promise<void> {
  await tx(async (client) => {
    for (const gym of GYMS) {
      await client.query(
        `INSERT INTO gyms (name, city, address) VALUES ($1, $2, $3)
         ON CONFLICT (name) DO UPDATE SET city = excluded.city, address = excluded.address`,
        [gym.name, gym.city, gym.address],
      );
    }
    for (const [index, video] of VIDEOS.entries()) {
      await client.query(
        `INSERT INTO videos (id, title, level, minutes, premium, focus, image, position)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         ON CONFLICT (id) DO UPDATE SET
           title = excluded.title, level = excluded.level, minutes = excluded.minutes,
           premium = excluded.premium, focus = excluded.focus, image = excluded.image,
           position = excluded.position`,
        [
          video.id,
          video.title,
          video.level,
          video.minutes,
          video.premium,
          video.focus,
          video.image,
          index,
        ],
      );
    }
    for (const [index, coach] of COACHES.entries()) {
      await client.query(
        `INSERT INTO coaches (key, name, specialty, rating, sessions, initials, color, role, position)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
         ON CONFLICT (key) DO UPDATE SET
           name = excluded.name, specialty = excluded.specialty, rating = excluded.rating,
           sessions = excluded.sessions, initials = excluded.initials, color = excluded.color,
           role = excluded.role, position = excluded.position`,
        [
          coach.key,
          coach.name,
          coach.specialty,
          coach.rating,
          coach.sessions,
          coach.initials,
          coach.color,
          coach.role,
          index,
        ],
      );
    }
    for (const [index, plan] of MEAL_PLANS.entries()) {
      await client.query(
        `INSERT INTO meal_plans (id, title, premium, kcal, protein, carbs, fats, meals, position)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8::jsonb, $9)
         ON CONFLICT (id) DO UPDATE SET
           title = excluded.title, premium = excluded.premium, kcal = excluded.kcal,
           protein = excluded.protein, carbs = excluded.carbs, fats = excluded.fats,
           meals = excluded.meals, position = excluded.position`,
        [
          plan.id,
          plan.title,
          plan.premium,
          plan.kcal,
          plan.protein,
          plan.carbs,
          plan.fats,
          JSON.stringify(plan.meals),
          index,
        ],
      );
    }
  });
}

async function insertTemplate(client: PoolClient, userId: string, date: string): Promise<void> {
  for (const [position, item] of WORKOUT_TEMPLATE.entries()) {
    await client.query(
      `INSERT INTO workout_items
         (user_id, name, detail, sets, reps, weight, minutes, icon, done, position, workout_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
      [userId, item[0], item[1], item[2], item[3], item[4], item[5], item[6], item[7], position, date],
    );
  }
}

export async function seedUserDefaults(userId: string, name: string): Promise<void> {
  const gym = await query<{ id: string; name: string }>(
    `SELECT id, name FROM gyms WHERE name = 'Iron House Fitness' LIMIT 1`,
  );
  await tx(async (client) => {
    await client.query(
      `UPDATE users SET gym_id = $2, gym_label = $3, streak = 6 WHERE id = $1`,
      [userId, gym[0]?.id ?? null, gym[0]?.name ?? 'Iron House Fitness'],
    );
    await insertTemplate(client, userId, new Date().toISOString().slice(0, 10));
    for (const [position, goal] of DEFAULT_GOALS.entries()) {
      await client.query(
        `INSERT INTO goals
           (user_id, title, unit, start_value, target_value, current_value, icon, color, position)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [userId, goal[0], goal[1], goal[2], goal[3], goal[4], goal[5], goal[6], position],
      );
    }
    for (const [position, reminder] of DEFAULT_REMINDERS.entries()) {
      await client.query(
        `INSERT INTO reminders (user_id, label, time_label, enabled, position)
         VALUES ($1, $2, $3, TRUE, $4)`,
        [userId, reminder[0], reminder[1], position],
      );
    }
    for (const [title, daysAgo, minutes, exercises, kcal, intensity] of HISTORY) {
      await client.query(
        `INSERT INTO schedule_entries
           (user_id, entry_date, title, minutes, exercises, kcal, intensity)
         VALUES ($1, CURRENT_DATE - $2::int, $3, $4, $5, $6, $7)`,
        [userId, daysAgo, title, minutes, exercises, kcal, intensity],
      );
    }
    const first = name.trim().split(/\s+/)[0] || 'there';
    const welcome: Array<[string, boolean]> = [
      [`Hi ${first}! I reviewed your week — solid consistency on push days.`, false],
      ['Thanks! I am struggling with post-workout meals though.', true],
      [
        'Let us fix that. Aim for 35g protein within an hour — Greek yogurt, eggs or a shake all work. I will add options to your plan.',
        false,
      ],
    ];
    for (const [body, fromMe] of welcome) {
      await client.query(
        `INSERT INTO messages (user_id, coach_key, body, from_me) VALUES ($1, 'amara', $2, $3)`,
        [userId, body, fromMe],
      );
    }
    await client.query(
      `INSERT INTO messages (user_id, coach_key, body, from_me)
       VALUES ($1, 'daniel', $2, FALSE)`,
      [userId, `Welcome ${first}! Pick a slot and I will build your first session around your goals.`],
    );
  });
}

/** Creates the demo account the prefilled sign-in form uses. */
export async function seedDemoUser(): Promise<void> {
  const existing = await query<{ id: string }>('SELECT id FROM users WHERE email = $1', [
    DEMO_EMAIL,
  ]);
  if (existing.length > 0) return;

  const rows = await query<{ id: string }>(
    `INSERT INTO users (name, email, phone, password_hash)
     VALUES ($1, $2, $3, $4)
     RETURNING id`,
    ['Alex Morgan', DEMO_EMAIL, '+234 803 555 0123', await hashPassword(DEMO_PASSWORD)],
  );
  const id = rows[0]!.id;
  await seedUserDefaults(id, 'Alex');
}

/** Copies the previous session into today when the user opens a new day. */
export async function ensureTodayWorkout(userId: string): Promise<void> {
  const today = new Date().toISOString().slice(0, 10);
  const existing = await query<{ count: string }>(
    `SELECT count(*)::text AS count FROM workout_items WHERE user_id = $1 AND workout_date = $2`,
    [userId, today],
  );
  if (Number(existing[0]?.count ?? '0') > 0) return;

  const rows = await query<{
    name: string;
    detail: string;
    sets: number;
    reps: number;
    weight: number;
    minutes: number;
    icon: string;
    position: number;
  }>(
    `SELECT name, detail, sets, reps, weight, minutes, icon, position
       FROM workout_items
      WHERE user_id = $1
        AND workout_date = (SELECT max(workout_date) FROM workout_items WHERE user_id = $1)
      ORDER BY position`,
    [userId],
  );

  await tx(async (client) => {
    if (rows.length === 0) {
      await insertTemplate(client, userId, today);
      return;
    }
    for (const row of rows) {
      await client.query(
        `INSERT INTO workout_items
           (user_id, name, detail, sets, reps, weight, minutes, icon, done, position, workout_date)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, FALSE, $9, $10)`,
        [
          userId,
          row.name,
          row.detail,
          row.sets,
          row.reps,
          row.weight,
          row.minutes,
          row.icon,
          row.position,
          today,
        ],
      );
    }
  });
}

export { COACHES, DEMO_EMAIL, GYMS, MEAL_PLANS, VIDEOS };
