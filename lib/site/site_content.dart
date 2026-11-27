import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SiteFeature {
  const SiteFeature({
    required this.icon,
    required this.tint,
    required this.ink,
    required this.title,
    required this.body,
    required this.detailTitle,
    required this.detailBody,
    required this.bullets,
  });

  final IconData icon;
  final Color tint;
  final Color ink;
  final String title;
  final String body;
  final String detailTitle;
  final String detailBody;
  final List<String> bullets;
}

const siteFeatures = <SiteFeature>[
  SiteFeature(
    icon: Icons.fitness_center_rounded,
    tint: Color(0x1F35B81F),
    ink: AppColors.greenDeep,
    title: 'Daily workout tracking',
    body:
        'A plan for today, not a library to browse. Tap to check off sets, and your progress is saved the moment you do.',
    detailTitle: 'A plan for today, not a library to browse.',
    detailBody:
        "Open the app and today's session is already built: warm-up, working sets, reps, weights and how long it should take. Tap each exercise as you finish it — the checkmark is saved the moment you do.",
    bullets: [
      'Sets, reps, weight and rest written out',
      "Add your own exercises to today's list",
      'Checkmarks sync even if the signal drops',
    ],
  ),
  SiteFeature(
    icon: Icons.local_fire_department_rounded,
    tint: Color(0x1F35B81F),
    ink: AppColors.greenDeep,
    title: 'Streaks that stick',
    body:
        'See the week at a glance. Small wins add up, and a six-day streak is hard to walk away from.',
    detailTitle: 'Streaks that make skipping feel expensive.',
    detailBody:
        'See the week at a glance. Each finished session fills in another day, and a six-day streak is a lot harder to walk away from than a blank calendar.',
    bullets: [
      'Current streak and week view on the home screen',
      "A progress ring for today's session",
      'History of the last 60 sessions',
    ],
  ),
  SiteFeature(
    icon: Icons.track_changes_rounded,
    tint: Color(0x24F5A524),
    ink: Color(0xFFB9761E),
    title: 'Goals with numbers',
    body:
        'Weight, distance, strength — set a target and watch the bar move instead of guessing.',
    detailTitle: 'Targets you can watch move.',
    detailBody:
        "Weight, distance or strength — set a goal with a start and a target, then update the number as you go. The bar moves instead of you guessing whether it's working.",
    bullets: [
      'Goals with a start, current and target value',
      'Progress bars on the home screen',
      'Edit or retire a goal at any time',
    ],
  ),
  SiteFeature(
    icon: Icons.forum_rounded,
    tint: Color(0x1A234E7D),
    ink: AppColors.navy,
    title: 'A coach on call',
    body:
        'Ask about nutrition, recovery or form. Coach Amara replies with an answer you can use today.',
    detailTitle: 'Ask a real specialist, get an answer for today.',
    detailBody:
        'Form, programming, recovery, macros — send a message and get a reply in the same thread. Trainer chat covers the training; Coach Amara handles sports nutrition.',
    bullets: [
      'Trainer chat for form, programmes and recovery',
      'Nutritionist chat for macros and meals',
      'Every thread stays with your account',
    ],
  ),
  SiteFeature(
    icon: Icons.play_circle_fill_rounded,
    tint: Color(0x1A234E7D),
    ink: AppColors.navy,
    title: 'Video library',
    body:
        'Guided sessions for the gym or the living room, sorted by goal and time you actually have.',
    detailTitle: "Follow along, whichever room you're in.",
    detailBody:
        'The library is sorted by focus and by the time you actually have — a 12-minute mobility reset or a full gym session. Premium members unlock the advanced sessions.',
    bullets: [
      'Gym and at-home sessions',
      'Filtered by focus, level and duration',
      'Locked sessions show exactly what Premium adds',
    ],
  ),
  SiteFeature(
    icon: Icons.restaurant_rounded,
    tint: Color(0x24F5A524),
    ink: Color(0xFFB9761E),
    title: 'Meal plans',
    body:
        'Seven days of meals built around your training load — no spreadsheets, no guesswork.',
    detailTitle: 'Seven days of eating that match the training.',
    detailBody:
        'Meal plans come with the daily calories, protein, carbs and fats already worked out, plus breakfast, lunch, snack and dinner for each day. No spreadsheet, no guesswork.',
    bullets: [
      'Plans with kcal and macro targets',
      'Every meal slot written out',
      'Swap plans as your training changes',
    ],
  ),
];

class SiteInfoCard {
  const SiteInfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

const siteFeatureDetails = <SiteInfoCard>[
  SiteInfoCard(
    icon: Icons.notifications_active_outlined,
    title: 'Reminders',
    body: 'Set the days and times you train. Your plan is waiting when the reminder lands.',
  ),
  SiteInfoCard(
    icon: Icons.place_outlined,
    title: 'Your gym',
    body:
        'Pick your gym from the directory or type its name — your account remembers it.',
  ),
  SiteInfoCard(
    icon: Icons.timer_outlined,
    title: 'Stopwatch sets',
    body:
        'Time a set and log the weight and reps. Every entry builds your training history.',
  ),
];

class SiteStep {
  const SiteStep({
    required this.number,
    required this.title,
    required this.body,
    required this.bullets,
  });

  final String number;
  final String title;
  final String body;
  final List<String> bullets;
}

const siteSteps = <SiteStep>[
  SiteStep(
    number: '01',
    title: 'Join your gym',
    body:
        "Create an account and pick your gym from the directory — or just type its name. That's what your profile and plan are built around; there's no code to chase down.",
    bullets: [
      'Email and password only',
      'Gym directory with free-text fallback',
      'Change gym later from your account',
    ],
  ),
  SiteStep(
    number: '02',
    title: "Get today's plan",
    body:
        "Open the app and today's workout is already there: warm-up, working sets, reps, weights and an estimate of how long it takes. No picking from a wall of videos before you've lifted anything.",
    bullets: [
      'Session ready on first sign-in',
      'Add exercises of your own',
      'Reminders on the days you train',
    ],
  ),
  SiteStep(
    number: '03',
    title: 'Track and level up',
    body:
        "Every checkmark updates today's progress, the week and your streak. Log sets with the stopwatch when you want the numbers. When you want more, Premium adds coaching, meal plans and the full video library.",
    bullets: [
      'Streaks, weekly view and session history',
      'Goal bars that move with your numbers',
      'Upgrade or cancel from Account → Subscription',
    ],
  ),
];

const siteSessionCards = <SiteInfoCard>[
  SiteInfoCard(
    icon: Icons.home_outlined,
    title: 'Open and go',
    body:
        "Home screen loads with today's workout, your streak and how much is left.",
  ),
  SiteInfoCard(
    icon: Icons.wb_twilight_rounded,
    title: 'Warm up',
    body:
        'Tick the warm-up off. The progress ring moves and the first win is on the board.',
  ),
  SiteInfoCard(
    icon: Icons.fitness_center_rounded,
    title: 'Working sets',
    body:
        'Follow the sets and reps. Use the stopwatch to log weight and reps where it matters.',
  ),
  SiteInfoCard(
    icon: Icons.check_circle_outline_rounded,
    title: 'Done for today',
    body:
        "Session complete, week updated, streak intact. Tomorrow's plan is already waiting.",
  ),
];

const siteRobustCards = <SiteInfoCard>[
  SiteInfoCard(
    icon: Icons.wifi_off_rounded,
    title: 'Keeps working offline',
    body:
        "Every screen renders from what's already on the device, then syncs when the connection comes back. You can keep ticking in a basement gym.",
  ),
  SiteInfoCard(
    icon: Icons.devices_rounded,
    title: 'One account, any screen',
    body:
        'Workouts, goals, plan and messages live on the server and follow you between phone and desktop.',
  ),
  SiteInfoCard(
    icon: Icons.storefront_outlined,
    title: 'Built around your gym',
    body:
        "Your gym is part of your profile, so the app doesn't pretend everyone trains in the same room.",
  ),
];

const siteBillingCards = <SiteInfoCard>[
  SiteInfoCard(
    icon: Icons.calendar_month_outlined,
    title: 'Monthly or annual',
    body:
        'Pay monthly or take the annual price: \$49 for General, \$149 for Premium. Annual plans run twelve months from the day you start.',
  ),
  SiteInfoCard(
    icon: Icons.swap_horiz_rounded,
    title: 'Change whenever',
    body:
        'Switch between General and Premium, or between monthly and annual, from Account → Subscription.',
  ),
  SiteInfoCard(
    icon: Icons.cancel_outlined,
    title: 'Cancel in two taps',
    body:
        'Cancelling moves you back to General straight away and keeps your workout history. Premium gates re-lock immediately.',
  ),
];

class SitePlan {
  const SitePlan({
    required this.name,
    required this.price,
    required this.note,
    required this.features,
    required this.cta,
    this.featured = false,
  });

  final String name;
  final String price;
  final String note;
  final List<String> features;
  final String cta;
  final bool featured;
}

const sitePlans = <SitePlan>[
  SitePlan(
    name: 'General',
    price: r'$4.99',
    note: r'or $49/year — cancel anytime',
    features: [
      'Daily workout tracking',
      'Goals and weekly streaks',
      'Standard video library',
      'Gym on your profile',
    ],
    cta: 'Start with General',
  ),
  SitePlan(
    name: 'Premium',
    price: r'$14.99',
    note: r'or $149/year — cancel anytime',
    features: [
      'Everything in General',
      'Coach and nutritionist chat',
      'Personalised meal plans',
      'Full premium video library',
      'Coaching sessions',
    ],
    cta: 'Go Premium',
    featured: true,
  ),
];

class SiteCompareRow {
  const SiteCompareRow({
    required this.label,
    required this.general,
    required this.premium,
  });

  final String label;
  final String general;
  final String premium;
}

/// Values are 'yes', 'no', or a short label shown as text.
const siteCompareRows = <SiteCompareRow>[
  SiteCompareRow(
    label: "Today's workout, sets, reps and weights",
    general: 'yes',
    premium: 'yes',
  ),
  SiteCompareRow(
    label: 'Stopwatch set log and session history',
    general: 'yes',
    premium: 'yes',
  ),
  SiteCompareRow(
    label: 'Streaks, weekly view and goals',
    general: 'yes',
    premium: 'yes',
  ),
  SiteCompareRow(
    label: 'Reminders and your gym',
    general: 'yes',
    premium: 'yes',
  ),
  SiteCompareRow(
    label: 'Video library',
    general: 'Standard sessions',
    premium: 'Full library',
  ),
  SiteCompareRow(label: 'Coach chat', general: 'no', premium: 'yes'),
  SiteCompareRow(label: 'Nutritionist chat', general: 'no', premium: 'yes'),
  SiteCompareRow(
    label: 'Personalised meal plans',
    general: 'no',
    premium: 'yes',
  ),
  SiteCompareRow(label: 'Coaching sessions', general: 'no', premium: 'yes'),
  SiteCompareRow(
    label: 'Cancel or switch plan',
    general: 'yes',
    premium: 'yes',
  ),
];

class SiteFaqItem {
  const SiteFaqItem(this.question, this.answer);

  final String question;
  final String answer;
}

class SiteFaqGroup {
  const SiteFaqGroup({required this.title, required this.items});

  final String title;
  final List<SiteFaqItem> items;
}

const siteFaqGroups = <SiteFaqGroup>[
  SiteFaqGroup(
    title: 'Getting started',
    items: [
      SiteFaqItem(
        'Do I need to install anything?',
        'No. MyFitWellness runs in your browser on phone and desktop, and keeps you signed in on the device you use.',
      ),
      SiteFaqItem(
        'Do I need a code from my gym?',
        'No. Pick your gym from the directory or type its name — your account remembers it, and you can change it later from Account.',
      ),
      SiteFaqItem(
        'Can I try it without creating an account?',
        'Yes — the demo signs in with a real seeded account: alex@myfitwellness.com and the password fitwellness. It is already filled in on the sign-in screen.',
      ),
      SiteFaqItem(
        'How long does setup take?',
        "About three minutes: create an account, choose your gym, and today's workout is already waiting. Nothing else to configure before your first checkmark.",
      ),
    ],
  ),
  SiteFaqGroup(
    title: 'Using the app',
    items: [
      SiteFaqItem(
        'How do streaks work?',
        "Every exercise you tick adds to today's progress, and every finished session fills in a day on the week view. The home screen shows the current streak — the demo starts with six days behind it.",
      ),
      SiteFaqItem(
        'What is the stopwatch for?',
        'It times a set and records the weight and reps with it. Those entries build your session history, so you can look back at what you actually lifted instead of estimating.',
      ),
      SiteFaqItem(
        "Can I add exercises that aren't in my plan?",
        'Yes. Add your own exercises to the daily list from the workout screen, then tick them off like the rest of the session.',
      ),
      SiteFaqItem(
        'What happens if I lose signal mid-workout?',
        "The app keeps working from what is already on your device. Checkmarks and entries sync back to your account when the connection returns, so a basement gym doesn't cost you the session.",
      ),
      SiteFaqItem(
        'Who answers in coach chat?',
        'Messages go to the trainer or nutritionist thread on your account. Trainers cover form, programming and recovery; Coach Amara covers sports nutrition. The reply lands in the same conversation.',
      ),
      SiteFaqItem(
        'Can I track goals other than weight?',
        'Yes — weight, distance, strength or anything else you can measure. Give a goal a start value and a target, then update the current number as you go.',
      ),
    ],
  ),
  SiteFaqGroup(
    title: 'Your account and data',
    items: [
      SiteFaqItem(
        'What happens to my data if I switch devices?',
        'Your account lives on the server, so workouts, goals, plan and messages follow you. Sign in on any browser to pick up where you left off.',
      ),
      SiteFaqItem(
        'Is the demo account private?',
        'No — the demo credentials are published on this site, so treat it as a shared sandbox. Create your own account if you want your workouts and messages to belong only to you.',
      ),
      SiteFaqItem(
        'How do I sign out?',
        "Use sign out in Account → Settings. The session token is revoked on the server, so the device can't keep using it.",
      ),
      SiteFaqItem(
        'Do I keep my history if I cancel Premium?',
        'Yes. Cancelling moves you back to General, re-locks Premium features right away, and leaves your workouts, goals and history intact.',
      ),
    ],
  ),
  SiteFaqGroup(
    title: 'Plans and billing',
    items: [
      SiteFaqItem(
        'How much do the plans cost?',
        'General is \$4.99/month or \$49/year. Premium is \$14.99/month or \$149/year. Both are cancel-anytime, and Premium includes everything in General.',
      ),
      SiteFaqItem(
        'What exactly does Premium unlock?',
        'Coach chat, nutritionist chat, personalised meal plans, the advanced video library and coaching sessions. General keeps the daily tracking, streaks, goals, history and standard videos.',
      ),
      SiteFaqItem(
        'Can I switch between plans or billing cadence?',
        'Yes — switch between General and Premium, or between monthly and annual, from Account → Subscription. Annual plans run twelve months from the day you start.',
      ),
      SiteFaqItem(
        'Is there a free trial?',
        "There isn't a countdown trial. The demo is free to use without paying, and General is the paid plan when you want your own account and history.",
      ),
    ],
  ),
];

const siteHomeFaqs = <SiteFaqItem>[
  SiteFaqItem(
    'Do I need to install anything?',
    'No. MyFitWellness runs in your browser on phone and desktop, and keeps you signed in on the device you use.',
  ),
  SiteFaqItem(
    'Can I try it without an account?',
    'Yes — the demo signs in with a real seeded account: alex@myfitwellness.com and the password fitwellness. It is already filled in on the sign-in screen.',
  ),
  SiteFaqItem(
    'What happens to my data if I switch devices?',
    'Your account lives on the server, so workouts, goals, plan and messages follow you. Sign in on any browser to pick up where you left off.',
  ),
  SiteFaqItem(
    'Can I cancel Premium?',
    'Any time, from Account → Subscription. Premium features lock again immediately and you keep your history.',
  ),
];