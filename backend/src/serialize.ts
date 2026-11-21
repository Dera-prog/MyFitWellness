import { HttpError } from './http.js';

export const PRICES = {
  general: { monthly: 499, annual: 4900 },
  premium: { monthly: 1499, annual: 14900 },
} as const;

export type Plan = keyof typeof PRICES;

export interface UserRow {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  password_hash: string;
  plan: Plan;
  annual_billing: boolean;
  plan_started_at: Date | null;
  plan_renews_at: Date | null;
  plan_status: 'active' | 'cancelled';
  promo_used: boolean;
  gym_id: string | null;
  gym_label: string | null;
  reminders: boolean;
  goal_check_ins: boolean;
  renewal_alerts: boolean;
  stopwatch_paired: boolean;
  streak: number;
  created_at: Date;
}

export function addMonths(date: Date, months: number): Date {
  const d = new Date(date);
  d.setMonth(d.getMonth() + months);
  return d;
}

export function renewalFrom(startedAt: Date | null, annual: boolean): Date | null {
  if (!startedAt) return null;
  const step = annual ? 12 : 1;
  let next = addMonths(startedAt, step);
  const now = new Date();
  while (next.getTime() <= now.getTime()) {
    next = addMonths(next, step);
  }
  return next;
}

export function userJson(row: UserRow) {
  return {
    id: row.id,
    name: row.name,
    email: row.email,
    phone: row.phone,
    plan: row.plan,
    annualBilling: row.annual_billing,
    planStartedAt: row.plan_started_at,
    planRenewsAt: row.plan_renews_at,
    renewalDate: renewalFrom(row.plan_started_at, row.annual_billing),
    planStatus: row.plan_status,
    promoUsed: row.promo_used,
    gymId: row.gym_id,
    gym: row.gym_label,
    reminders: row.reminders,
    goalCheckIns: row.goal_check_ins,
    renewalAlerts: row.renewal_alerts,
    stopwatchPaired: row.stopwatch_paired,
    streak: row.streak,
    createdAt: row.created_at,
  };
}

export function priceFor(plan: Plan, annual: boolean): number {
  return PRICES[plan][annual ? 'annual' : 'monthly'];
}

export function requirePlan(value: string | undefined): Plan {
  if (value !== 'general' && value !== 'premium') {
    throw new HttpError(400, 'validation_error', 'plan must be general or premium');
  }
  return value;
}
