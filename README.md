# MyFitWellness

MyFitWellness is a full-stack fitness app. Members register with their gym, follow a daily
workout plan, log sets, track goals, chat with a coach, and manage a General or Premium
subscription. The Flutter client is wired to a real Hono + PostgreSQL API: accounts, plans,
workout progress, goals and messages all persist.

**Live**

| What | URL |
| --- | --- |
| Web app | https://myfitwellness.vercel.app |
| API | https://myfitwellness-api.vercel.app |
| Staging API | https://myfitwellness-api-staging.vercel.app |
| Health check | https://myfitwellness-api.vercel.app/healthz |

**Demo account**

```
Email:    alex@myfitwellness.com
Password: fitwellness
```

The demo account is created automatically (idempotently) on API boot, so the prefilled
sign-in form works on a fresh database. Any email can also create a new account from the
Sign Up tab.

---

## Architecture

```
Flutter web (CanvasKit)          Hono API (Node 24)              PostgreSQL 17
┌──────────────────────┐        ┌───────────────────────┐       ┌──────────────────┐
│ lib/data/api_client  │  HTTPS │ backend/src/app.ts    │  TCP  │ Neon (prod)      │
│ lib/data/app_state   │ ─────► │ auth · me · workouts  │ ────► │ Docker (local)   │
│ screens / widgets    │ Bearer │ goals · videos ·      │  pg   │ 5437 / 5432      │
└──────────────────────┘ tokens │ coaching · public     │       └──────────────────┘
                                └───────────────────────┘
```

- **Offline-tolerant client.** Every screen renders from local state first and syncs in the
  background. If the API is unreachable the UI keeps working and `AppState.offline` is set;
  the next successful call clears it.
- **Opaque sessions.** Login returns a random 32-byte token. Only its SHA-256 hash is stored
  server-side (`sessions.token_hash`), and the app keeps the token in
  `SharedPreferences` (web: `localStorage`, key `mfw.token`).
- **Passwords.** `scrypt` (N=16384, r=8, p=1, 64-byte key) with a per-user salt.
- **SQL only.** No ORM. Migrations are plain `.sql` files applied under a Postgres advisory
  lock, so concurrent cold starts cannot double-apply.
- **Idempotent catalog.** Gyms, videos, coaches and meal plans are upserted at boot; new
  users get seeded defaults (today's workout, goals, reminders, six history entries,
  welcome messages).

### Repository layout

```
lib/                   Flutter app (screens, widgets, theme, data layer)
  data/api_client.dart typed HTTP client + token storage
  data/app_state.dart  AppState/AppScope state container + backend sync
backend/
  src/                 Hono app, routes, auth, migrate, seed, OpenAPI doc
  migrations/001_init.sql
  test/api.test.ts     13 integration tests against a real Postgres
  Dockerfile           multi-stage: deps → build → test → prod-deps → runtime
  docker-compose.yml   db + api + test profile
  vercel.json          Container preset for Vercel Functions
```

---

## Run the whole stack locally (WSL Ubuntu + Docker)

Prerequisites: Windows with WSL2, Ubuntu installed, Docker Desktop running with WSL
integration enabled. From Ubuntu:

```bash
cd /mnt/c/Users/Chizoba/Documents/Qoder/2026-11-19/81c40c01/backend
docker compose up -d --build
```

That starts:

- `myfitwellness-db-1` — Postgres 17 on host port **5437** (container 5432)
- `myfitwellness-api-1` — API on host port **8090**, container port 8080

The API migrates and seeds on boot, then listens. Check it:

```bash
curl http://localhost:8090/healthz
curl -X POST http://localhost:8090/api/auth/login \
  -H 'content-type: application/json' \
  -d '{"email":"alex@myfitwellness.com","password":"fitwellness"}'
```

Run the client against the local API:

```bash
cd /mnt/c/Users/Chizoba/Documents/Qoder/2026-11-19/81c40c01
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8090/api
```

Without the define, a non-`vercel.app` web host calls `${origin}/api`, and desktop builds
call `http://localhost:8090/api`.

### Integration tests (real database, no mocks)

```bash
cd backend
docker compose --profile test run --rm --build test
```

The test service creates `myfitwellness_test`, runs `node --test` against live HTTP routes
(register, login, bootstrap, workout checklist, set logs, premium gate + purchase, plan
switch/cancel, goals, coaching, reminders/gym, calendar) and cleans up its users.

### Backend without Docker

```bash
cd backend
npm ci
cp .env.example .env        # point DATABASE_URL at any Postgres
npm run migrate
npm run seed
npm run dev                 # tsx watch on :8080
```

Useful scripts: `npm run build` (tsc), `npm start` (dist), `npm run typecheck`.

---

## API

All routes are under `/api`. Authenticated routes take `Authorization: Bearer <token>`.
Errors are `{ "error": "code", "message": "human readable" }`.

| Method | Path | What it does |
| --- | --- | --- |
| GET | `/healthz` | Liveness + DB check (no `/api` prefix) |
| GET | `/api/openapi.json` | OpenAPI 3 document |
| GET | `/api/gyms?q=` | Gym directory search |
| GET | `/api/pricing` | Plan prices |
| POST | `/api/auth/register` | Create account, seed defaults, return token |
| POST | `/api/auth/login` | Email + password → token |
| POST | `/api/auth/logout` | Revoke the current token |
| GET | `/api/me` | Bootstrap: user, today's workout, history, goals, videos, coaches, reminders, messages, meal plans, sets, stats, prices |
| PATCH | `/api/me` | Name, email, phone, alert flags, stopwatch pairing |
| PUT | `/api/me/gym` | Link a catalog gym (`gymId`) or a free-text label |
| GET | `/api/me/plan` | Plan, prices, renewal date |
| POST | `/api/me/plan` | Purchase General/Premium (monthly or annual), returns payment |
| POST | `/api/me/plan/switch` | Change plan or billing cadence |
| POST | `/api/me/plan/cancel` | Downgrade to General |
| PUT | `/api/me/reminders` | Replace reminder list |
| GET/POST | `/api/workouts/today` | Read or append today's exercises |
| PATCH/DELETE | `/api/workouts/today/:id` | Tick or remove an exercise |
| GET | `/api/workouts/history` | Last 60 sessions |
| GET/POST | `/api/workouts/schedule` | Calendar entries (`from`/`to` filters) |
| GET/POST | `/api/workouts/sets` | Stopwatch set log |
| GET/POST | `/api/goals` | List or create goals |
| PATCH/DELETE | `/api/goals/:id` | Update progress or title, delete |
| GET | `/api/videos` | Library with `locked` flags |
| POST | `/api/videos/:id/play` | Play; `402 premium_required` when locked |
| GET | `/api/coaching/coaches` | Trainers + nutritionist |
| GET/POST | `/api/coaching/:key/messages` | Thread; a post stores the reply too |

### Plan rules

- General: $4.99/mo or $49/yr. Premium: $14.99/mo or $149/yr.
- The first monthly purchase gets a 50% promo discount (recorded in `payments` with a
  `MFW-XXXXXX` receipt). Annual plans roll the renewal date 12 months from the start.
- Premium unlocks advanced videos, meal plans and coaching gates; cancelling downgrades
  immediately and re-locks them.

### Environment variables

| Variable | Default | Notes |
| --- | --- | --- |
| `DATABASE_URL` | `postgres://myfit:myfit@localhost:5437/myfitwellness` | Neon URL in production |
| `DATABASE_SSL` | auto | Enabled automatically for `sslmode=require` or `*.neon.tech` hosts |
| `PORT` | 8080 | Vercel container project sets 8080 |
| `CORS_ORIGIN` | `*` | Bearer tokens, no cookies, so `*` is safe |
| `SESSION_DAYS` | 30 | Token lifetime |
| `PG_POOL_MAX` | 10 | Pool size |
| `ADMIN_DATABASE_URL` | — | Only for `create-test-db` |

---

## Deploy

Both projects live on Vercel under the `dera19` team. The API is a **Container Runtime**
Function built from `backend/Dockerfile`; the database is a dedicated Neon store linked
through the Vercel Marketplace integration (env vars are injected by the integration).

### API

```bash
cd backend
vercel link --project myfitwellness-api --scope dera19
vercel deploy --prod --yes --scope dera19
```

Project settings that matter: framework `container`, `PORT=8080`, `CORS_ORIGIN=*`,
`NODE_ENV=production`, and the Neon integration variables (`DATABASE_URL`, …). On first
boot the container applies `migrations/001_init.sql`, seeds the catalog and the demo
account, then serves on `$PORT`.

### Web client

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://myfitwellness-api.vercel.app/api
cd build/web
vercel link --project myfitwellness --scope dera19
vercel deploy --prod --yes --scope dera19
```

The API URL is compiled into the bundle (`String.fromEnvironment`), so rebuild whenever the
API host changes. Vercel SSO protection must stay off for both projects so the app and the
API are publicly reachable.

### Staging database

A second Neon store (`myfitwellness-db-staging`) is connected to the
`myfitwellness-api-staging` Vercel project, so staging writes never reach production. The
schema and seed catalog are already applied. Push later schema changes by pointing the
backend CLI at the staging `DATABASE_URL` from that project:

```bash
cd backend
npm run migrate     # or: node dist/cli.js migrate
npm run seed        # idempotent catalog + demo user
```

The staging API project is deployed at https://myfitwellness-api-staging.vercel.app
(`myfitwellness-api-staging`). Redeploy it with `vercel link --project
myfitwellness-api-staging --scope dera19` followed by `vercel deploy --prod --yes`, then
relink `backend/` to `myfitwellness-api` before shipping to production. Any pulled `.env*`
file holds real credentials — keep it out of git and delete it after use.

---

## Roadmap

- Password reset email delivery (the screen is present, delivery is not wired).
- Push notifications for reminders and renewals.
- Trainer-side inbox for replying to member messages.
- Real video streaming (the library currently tracks plays and entitlements only).
