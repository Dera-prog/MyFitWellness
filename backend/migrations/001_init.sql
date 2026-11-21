-- MyFitWellness initial schema

CREATE TABLE IF NOT EXISTS gyms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  city TEXT NOT NULL,
  address TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  password_hash TEXT NOT NULL,
  plan TEXT NOT NULL DEFAULT 'general' CHECK (plan IN ('general', 'premium')),
  annual_billing BOOLEAN NOT NULL DEFAULT FALSE,
  plan_started_at TIMESTAMPTZ,
  plan_renews_at TIMESTAMPTZ,
  plan_status TEXT NOT NULL DEFAULT 'active' CHECK (plan_status IN ('active', 'cancelled')),
  promo_used BOOLEAN NOT NULL DEFAULT FALSE,
  gym_id UUID REFERENCES gyms(id) ON DELETE SET NULL,
  gym_label TEXT,
  reminders BOOLEAN NOT NULL DEFAULT TRUE,
  goal_check_ins BOOLEAN NOT NULL DEFAULT TRUE,
  renewal_alerts BOOLEAN NOT NULL DEFAULT TRUE,
  stopwatch_paired BOOLEAN NOT NULL DEFAULT FALSE,
  streak INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sessions (
  token_hash TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX IF NOT EXISTS sessions_user_idx ON sessions(user_id);
CREATE INDEX IF NOT EXISTS sessions_expiry_idx ON sessions(expires_at);

CREATE TABLE IF NOT EXISTS goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  unit TEXT NOT NULL DEFAULT '',
  start_value DOUBLE PRECISION NOT NULL DEFAULT 0,
  target_value DOUBLE PRECISION NOT NULL DEFAULT 0,
  current_value DOUBLE PRECISION NOT NULL DEFAULT 0,
  icon TEXT NOT NULL DEFAULT 'flag',
  color TEXT NOT NULL DEFAULT 'green',
  position INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS goals_user_idx ON goals(user_id);

CREATE TABLE IF NOT EXISTS workout_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  detail TEXT NOT NULL DEFAULT '',
  sets INTEGER NOT NULL DEFAULT 1,
  reps INTEGER NOT NULL DEFAULT 0,
  weight DOUBLE PRECISION NOT NULL DEFAULT 0,
  minutes INTEGER NOT NULL DEFAULT 0,
  icon TEXT NOT NULL DEFAULT 'fitness_center',
  done BOOLEAN NOT NULL DEFAULT FALSE,
  position INTEGER NOT NULL DEFAULT 0,
  workout_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS workout_items_user_date_idx ON workout_items(user_id, workout_date);

CREATE TABLE IF NOT EXISTS workout_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  exercise TEXT NOT NULL,
  set_number INTEGER NOT NULL,
  seconds INTEGER NOT NULL,
  logged_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS workout_logs_user_idx ON workout_logs(user_id, logged_at DESC);

CREATE TABLE IF NOT EXISTS schedule_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  entry_date DATE NOT NULL,
  title TEXT NOT NULL,
  minutes INTEGER NOT NULL DEFAULT 0,
  exercises INTEGER NOT NULL DEFAULT 0,
  kcal INTEGER NOT NULL DEFAULT 0,
  intensity DOUBLE PRECISION NOT NULL DEFAULT 0.5,
  completed BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS schedule_user_date_idx ON schedule_entries(user_id, entry_date);

CREATE TABLE IF NOT EXISTS videos (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  level TEXT NOT NULL,
  minutes INTEGER NOT NULL,
  premium BOOLEAN NOT NULL DEFAULT FALSE,
  focus TEXT NOT NULL DEFAULT '',
  image TEXT NOT NULL DEFAULT '',
  position INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS video_plays (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  video_id TEXT NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
  played_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS video_plays_user_idx ON video_plays(user_id, played_at DESC);

CREATE TABLE IF NOT EXISTS coaches (
  key TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  specialty TEXT NOT NULL,
  rating DOUBLE PRECISION NOT NULL DEFAULT 5,
  sessions INTEGER NOT NULL DEFAULT 0,
  initials TEXT NOT NULL,
  color TEXT NOT NULL DEFAULT '#1F5D4A',
  role TEXT NOT NULL DEFAULT 'trainer',
  position INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  coach_key TEXT NOT NULL REFERENCES coaches(key) ON DELETE CASCADE,
  body TEXT NOT NULL,
  from_me BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS messages_user_coach_idx ON messages(user_id, coach_key, created_at);

CREATE TABLE IF NOT EXISTS meal_plans (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  premium BOOLEAN NOT NULL DEFAULT FALSE,
  kcal INTEGER NOT NULL DEFAULT 0,
  protein INTEGER NOT NULL DEFAULT 0,
  carbs INTEGER NOT NULL DEFAULT 0,
  fats INTEGER NOT NULL DEFAULT 0,
  meals JSONB NOT NULL DEFAULT '[]'::jsonb,
  position INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS reminders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  time_label TEXT NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  position INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS reminders_user_idx ON reminders(user_id);

CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  plan TEXT NOT NULL,
  billing TEXT NOT NULL CHECK (billing IN ('monthly', 'annual')),
  amount_cents INTEGER NOT NULL,
  discount_cents INTEGER NOT NULL DEFAULT 0,
  promo BOOLEAN NOT NULL DEFAULT FALSE,
  receipt_code TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS payments_user_idx ON payments(user_id, created_at DESC);
