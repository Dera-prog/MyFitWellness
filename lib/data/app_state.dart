import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class Exercise {
  Exercise({
    required this.name,
    required this.detail,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.minutes,
    required this.icon,
    this.done = false,
  });

  final String name;
  final String detail;
  final int sets;
  final int reps;
  final double weight;
  final int minutes;
  final IconData icon;
  bool done;
}

class FitnessGoal {
  FitnessGoal({
    required this.title,
    required this.unit,
    required this.start,
    required this.target,
    required this.current,
    required this.icon,
    required this.color,
  });

  final String title;
  final String unit;
  final double start;
  final double target;
  double current;
  final IconData icon;
  final Color color;

  double get progress {
    final span = (target - start).abs();
    if (span == 0) return 0;
    return ((current - start) / (target - start)).clamp(0.0, 1.0);
  }

  String get currentLabel => '${current.toStringAsFixed(current % 1 == 0 ? 0 : 1)}$unit';
  String get targetLabel => '${target.toStringAsFixed(target % 1 == 0 ? 0 : 1)}$unit';
}

class WorkoutEntry {
  WorkoutEntry({
    required this.title,
    required this.date,
    required this.minutes,
    required this.exercises,
    required this.kcal,
    required this.intensity,
  });

  final String title;
  final DateTime date;
  final int minutes;
  final int exercises;
  final int kcal;
  final double intensity;
}

class Trainer {
  Trainer({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.sessions,
    required this.initials,
    required this.color,
  });

  final String name;
  final String specialty;
  final double rating;
  final int sessions;
  final String initials;
  final Color color;
}

class VideoItem {
  VideoItem({
    required this.title,
    required this.level,
    required this.minutes,
    required this.premium,
    required this.image,
    required this.focus,
  });

  final String title;
  final String level;
  final int minutes;
  final bool premium;
  final String image;
  final String focus;
}

class ChatMessage {
  ChatMessage({required this.text, required this.fromMe, required this.time});
  final String text;
  final bool fromMe;
  final String time;
}

enum PlanType { general, premium }

class AppState extends ChangeNotifier {
  String name = 'Alex';
  String email = 'alex@myfitwellness.com';
  String gym = 'Iron House Fitness';
  PlanType plan = PlanType.general;
  bool annualBilling = false;
  DateTime? planStartedAt;
  bool reminders = true;
  bool goalCheckIns = true;
  bool renewalAlerts = true;
  bool stopwatchPaired = false;

  int streak = 6;

  final List<Exercise> todayWorkout = [
    Exercise(
      name: 'Treadmill warm-up',
      detail: 'Incline 4 · steady pace',
      sets: 1,
      reps: 0,
      weight: 0,
      minutes: 8,
      icon: Icons.directions_run_rounded,
      done: true,
    ),
    Exercise(
      name: 'Barbell squats',
      detail: 'Back squat · full depth',
      sets: 4,
      reps: 8,
      weight: 60,
      minutes: 14,
      icon: Icons.fitness_center_rounded,
    ),
    Exercise(
      name: 'Dumbbell bench press',
      detail: 'Flat bench · controlled tempo',
      sets: 4,
      reps: 10,
      weight: 22.5,
      minutes: 12,
      icon: Icons.sports_gymnastics_rounded,
    ),
    Exercise(
      name: 'Cable rows',
      detail: 'Neutral grip · squeeze 2s',
      sets: 3,
      reps: 12,
      weight: 45,
      minutes: 10,
      icon: Icons.rowing_rounded,
    ),
    Exercise(
      name: 'Walking lunges',
      detail: 'Bodyweight · long stride',
      sets: 3,
      reps: 16,
      weight: 0,
      minutes: 9,
      icon: Icons.accessibility_new_rounded,
    ),
    Exercise(
      name: 'Core finisher',
      detail: 'Plank + hollow hold circuit',
      sets: 3,
      reps: 1,
      weight: 0,
      minutes: 7,
      icon: Icons.self_improvement_rounded,
    ),
  ];

  final List<WorkoutEntry> history = [
    WorkoutEntry(
      title: 'Push day',
      date: DateTime.now().subtract(const Duration(days: 1)),
      minutes: 52,
      exercises: 7,
      kcal: 430,
      intensity: 0.82,
    ),
    WorkoutEntry(
      title: 'Lower body strength',
      date: DateTime.now().subtract(const Duration(days: 2)),
      minutes: 61,
      exercises: 6,
      kcal: 505,
      intensity: 0.9,
    ),
    WorkoutEntry(
      title: 'HIIT + core',
      date: DateTime.now().subtract(const Duration(days: 3)),
      minutes: 34,
      exercises: 9,
      kcal: 380,
      intensity: 0.74,
    ),
    WorkoutEntry(
      title: 'Pull day',
      date: DateTime.now().subtract(const Duration(days: 4)),
      minutes: 48,
      exercises: 6,
      kcal: 395,
      intensity: 0.78,
    ),
    WorkoutEntry(
      title: 'Active recovery',
      date: DateTime.now().subtract(const Duration(days: 5)),
      minutes: 26,
      exercises: 4,
      kcal: 180,
      intensity: 0.4,
    ),
    WorkoutEntry(
      title: 'Full body circuit',
      date: DateTime.now().subtract(const Duration(days: 6)),
      minutes: 55,
      exercises: 8,
      kcal: 470,
      intensity: 0.85,
    ),
  ];

  final List<double> weeklyMinutes = [42, 61, 34, 48, 26, 55, 0];

  final List<FitnessGoal> goals = [
    FitnessGoal(
      title: 'Lose 6 kg',
      unit: 'kg',
      start: 82,
      target: 76,
      current: 78.7,
      icon: Icons.monitor_weight_outlined,
      color: AppColors.green,
    ),
    FitnessGoal(
      title: 'Build strength',
      unit: 'kg',
      start: 40,
      target: 80,
      current: 60,
      icon: Icons.fitness_center_rounded,
      color: AppColors.navy,
    ),
    FitnessGoal(
      title: 'Endurance',
      unit: 'min',
      start: 10,
      target: 45,
      current: 31,
      icon: Icons.bolt_rounded,
      color: AppColors.amber,
    ),
  ];

  final List<Trainer> trainers = [
    Trainer(
      name: 'Daniel Okoro',
      specialty: 'Strength & conditioning',
      rating: 4.9,
      sessions: 412,
      initials: 'DO',
      color: const Color(0xFF1F5D4A),
    ),
    Trainer(
      name: 'Maya Bennett',
      specialty: 'Mobility & recovery',
      rating: 4.8,
      sessions: 287,
      initials: 'MB',
      color: const Color(0xFF7A4E2D),
    ),
    Trainer(
      name: 'Tunde Balogun',
      specialty: 'Hypertrophy coaching',
      rating: 4.7,
      sessions: 350,
      initials: 'TB',
      color: const Color(0xFF2C4A7A),
    ),
  ];

  final List<VideoItem> videos = [
    VideoItem(
      title: 'Perfect squat form',
      level: 'Beginner',
      minutes: 8,
      premium: false,
      image: 'assets/images/onboard_train.jpg',
      focus: 'Legs',
    ),
    VideoItem(
      title: 'Full-body dumbbell flow',
      level: 'Intermediate',
      minutes: 22,
      premium: false,
      image: 'assets/images/onboard_track.jpg',
      focus: 'Full body',
    ),
    VideoItem(
      title: 'Fuel your training',
      level: 'Beginner',
      minutes: 6,
      premium: false,
      image: 'assets/images/onboard_food.jpg',
      focus: 'Nutrition',
    ),
    VideoItem(
      title: 'Push-day mastery',
      level: 'Advanced',
      minutes: 34,
      premium: true,
      image: 'assets/images/athlete_portrait.jpg',
      focus: 'Chest',
    ),
    VideoItem(
      title: 'Deadlift power block',
      level: 'Advanced',
      minutes: 28,
      premium: true,
      image: 'assets/images/onboard_train.jpg',
      focus: 'Back',
    ),
    VideoItem(
      title: 'Macro-balanced meals',
      level: 'Intermediate',
      minutes: 12,
      premium: true,
      image: 'assets/images/onboard_food.jpg',
      focus: 'Nutrition',
    ),
  ];

  final List<ChatMessage> chat = [
    ChatMessage(
      text: 'Hi Alex! I reviewed your week — solid consistency on push days.',
      fromMe: false,
      time: '09:12',
    ),
    ChatMessage(
      text: 'Thanks! I am struggling with post-workout meals though.',
      fromMe: true,
      time: '09:14',
    ),
    ChatMessage(
      text: 'Let us fix that. Aim for 35g protein within an hour — Greek yogurt, eggs or a shake all work. I will add options to your plan.',
      fromMe: false,
      time: '09:15',
    ),
  ];

  int get completedToday => todayWorkout.where((e) => e.done).length;

  double get todayProgress =>
      todayWorkout.isEmpty ? 0 : completedToday / todayWorkout.length;

  int get todayMinutes => todayWorkout.fold(0, (a, e) => a + e.minutes);

  bool get isPremium => plan == PlanType.premium;

  void toggleExercise(int index) {
    todayWorkout[index].done = !todayWorkout[index].done;
    notifyListeners();
  }

  void addExercise(Exercise exercise) {
    todayWorkout.add(exercise);
    notifyListeners();
  }

  void removeExercise(int index) {
    if (index < 0 || index >= todayWorkout.length) return;
    todayWorkout.removeAt(index);
    notifyListeners();
  }

  void addGoal(FitnessGoal goal) {
    goals.add(goal);
    notifyListeners();
  }

  void nudgeGoal(FitnessGoal goal, double delta) {
    goal.current = (goal.current + delta).clamp(0, 1000);
    notifyListeners();
  }

  void setPlan(PlanType value) {
    if (value == PlanType.general) {
      planStartedAt = null;
    } else {
      planStartedAt ??= DateTime.now();
    }
    plan = value;
    notifyListeners();
  }

  void setBilling({required bool annual}) {
    annualBilling = annual;
    notifyListeners();
  }

  void setAlerts({bool? reminders, bool? goalCheckIns, bool? renewalAlerts}) {
    if (reminders != null) this.reminders = reminders;
    if (goalCheckIns != null) this.goalCheckIns = goalCheckIns;
    if (renewalAlerts != null) this.renewalAlerts = renewalAlerts;
    notifyListeners();
  }

  void updateProfile({String? name, String? email, String? gym}) {
    if (name != null) this.name = name;
    if (email != null) this.email = email;
    if (gym != null) this.gym = gym;
    notifyListeners();
  }

  void pairStopwatch() {
    stopwatchPaired = true;
    notifyListeners();
  }

  void sendMessage(String text) {
    final now = DateTime.now();
    chat.add(ChatMessage(
      text: text,
      fromMe: true,
      time:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    ));
    notifyListeners();
  }

  void receiveCoachMessage(String text) {
    final now = DateTime.now();
    chat.add(ChatMessage(
      text: text,
      fromMe: false,
      time:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    ));
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing from widget tree');
    return scope!.notifier!;
  }
}
