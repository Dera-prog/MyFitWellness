export const openapi = {
  openapi: '3.0.3',
  info: {
    title: 'MyFitWellness API',
    version: '1.0.0',
    description:
      'Accounts, subscriptions, training, goals, video library and coaching for the MyFitWellness app.',
  },
  servers: [{ url: '/api' }],
  components: {
    securitySchemes: {
      bearerAuth: { type: 'http', scheme: 'bearer' },
    },
  },
  security: [{ bearerAuth: [] }],
  paths: {
    '/auth/register': {
      post: {
        tags: ['Auth'],
        summary: 'Create an account and receive a session token',
        security: [],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['name', 'email', 'password'],
                properties: {
                  name: { type: 'string' },
                  email: { type: 'string', format: 'email' },
                  password: { type: 'string', minLength: 6 },
                  phone: { type: 'string' },
                },
              },
            },
          },
        },
        responses: { '201': { description: 'Account created' }, '409': { description: 'Email taken' } },
      },
    },
    '/auth/login': {
      post: {
        tags: ['Auth'],
        summary: 'Exchange credentials for a session token',
        security: [],
        responses: { '200': { description: 'Signed in' }, '401': { description: 'Bad credentials' } },
      },
    },
    '/auth/logout': {
      post: { tags: ['Auth'], summary: 'Revoke the current session', responses: { '204': { description: 'Signed out' } } },
    },
    '/me': {
      get: {
        tags: ['Profile'],
        summary: 'Bootstrap payload: user, plan, workout, goals, videos, coaches, reminders',
        responses: { '200': { description: 'App state' } },
      },
      patch: { tags: ['Profile'], summary: 'Update profile and notification settings', responses: { '200': { description: 'Updated' } } },
    },
    '/me/plan': {
      get: { tags: ['Billing'], summary: 'Current subscription and pricing', responses: { '200': { description: 'Plan' } } },
      post: {
        tags: ['Billing'],
        summary: 'Purchase a plan (50% off first monthly payment)',
        responses: { '200': { description: 'Charged and activated' } },
      },
    },
    '/me/plan/switch': {
      post: { tags: ['Billing'], summary: 'Switch plan or billing cycle', responses: { '200': { description: 'Switched' } } },
    },
    '/me/plan/cancel': {
      post: { tags: ['Billing'], summary: 'Cancel and return to the free General tier', responses: { '200': { description: 'Cancelled' } } },
    },
    '/me/gym': {
      put: { tags: ['Profile'], summary: 'Attach a registered gym or a gym code', responses: { '200': { description: 'Updated' } } },
    },
    '/me/reminders': {
      put: { tags: ['Profile'], summary: 'Replace the reminder list', responses: { '200': { description: 'Saved' } } },
    },
    '/workouts/today': {
      get: { tags: ['Training'], summary: "Today's workout checklist", responses: { '200': { description: 'Items' } } },
      post: { tags: ['Training'], summary: 'Add an exercise to today', responses: { '201': { description: 'Created' } } },
    },
    '/workouts/today/{id}': {
      patch: { tags: ['Training'], summary: 'Tick or untick an exercise', responses: { '200': { description: 'Updated' } } },
      delete: { tags: ['Training'], summary: 'Remove an exercise', responses: { '204': { description: 'Removed' } } },
    },
    '/workouts/sets': {
      get: { tags: ['Training'], summary: 'Recent stopwatch sets', responses: { '200': { description: 'Sets' } } },
      post: { tags: ['Training'], summary: 'Log a stopwatch set', responses: { '201': { description: 'Logged' } } },
    },
    '/workouts/schedule': {
      get: { tags: ['Training'], summary: 'Workout calendar entries', responses: { '200': { description: 'Entries' } } },
      post: { tags: ['Training'], summary: 'Book a workout on the calendar', responses: { '201': { description: 'Booked' } } },
    },
    '/goals': {
      get: { tags: ['Goals'], summary: 'List goals', responses: { '200': { description: 'Goals' } } },
      post: { tags: ['Goals'], summary: 'Create a goal', responses: { '201': { description: 'Created' } } },
    },
    '/goals/{id}': {
      patch: { tags: ['Goals'], summary: 'Log progress or edit a goal', responses: { '200': { description: 'Updated' } } },
      delete: { tags: ['Goals'], summary: 'Delete a goal', responses: { '204': { description: 'Deleted' } } },
    },
    '/videos': {
      get: { tags: ['Library'], summary: 'Video library with premium locks', responses: { '200': { description: 'Videos' } } },
    },
    '/videos/{id}/play': {
      post: {
        tags: ['Library'],
        summary: 'Record a play; 402 when the session is premium-only',
        responses: { '200': { description: 'Playing' }, '402': { description: 'Premium required' } },
      },
    },
    '/coaching/{key}/messages': {
      get: { tags: ['Coaching'], summary: 'Conversation with a coach', responses: { '200': { description: 'Messages' } } },
      post: { tags: ['Coaching'], summary: 'Send a message and get a coach reply', responses: { '201': { description: 'Sent' } } },
    },
    '/gyms': {
      get: { tags: ['Directory'], summary: 'Search registered gyms', security: [], responses: { '200': { description: 'Gyms' } } },
    },
    '/pricing': {
      get: { tags: ['Directory'], summary: 'Plan pricing', security: [], responses: { '200': { description: 'Prices' } } },
    },
  },
} as const;
