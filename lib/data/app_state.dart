import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'api_client.dart';

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
    this.id,
    this.iconKey = 'fitness_center',
  });

  final String name;
  final String detail;
  final int sets;
  final int reps;
  final double weight;
  final int minutes;
  final IconData icon;
  final String iconKey;
  String? id;
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
    this.id,
    this.colorKey = 'green',
  });

  final String title;
  final String unit;
  final double start;
  final double target;
  double current;
  final IconData icon;
  final Color color;
  final String colorKey;
  String? id;

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
    this.key,
  });

  final String name;
  final String specialty;
  final double rating;
  final int sessions;
  final String initials;
  final Color color;
  final String? key;
}

class VideoItem {
  VideoItem({
    required this.title,
    required this.level,
    required this.minutes,
    required this.premium,
    required this.image,
    required this.focus,
    this.id,
  });

  final String title;
  final String level;
  final int minutes;
  final bool premium;
  final String image;
  final String focus;
  final String? id;
}

class ChatMessage {
  ChatMessage({required this.text, required this.fromMe, required this.time});
  final String text;
  final bool fromMe;
  final String time;
}

enum PlanType { general, premium }

class AppState extends ChangeNotifier {
  final ApiClient api = ApiClient();
  bool offline = false;
  String? phone;
  String name = 'Alex';
  String email = 'alex@myfitwellness.com';
  String gym = 'Iron House Fitness';
  PlanType plan = PlanType.general;
  bool annualBilling = false;
  DateTime? planStartedAt;
  DateTime? planRenewsAt;
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
    if (index < 0 || index >= todayWorkout.length) return;
    final exercise = todayWorkout[index];
    exercise.done = !exercise.done;
    notifyListeners();
    final id = exercise.id;
    if (id != null) {
      _sync(() async {
        await api.patchWorkoutItem(id, exercise.done);
      });
    }
  }

  void addExercise(Exercise exercise) {
    todayWorkout.add(exercise);
    notifyListeners();
    _sync(() async {
      final data = await api.addWorkoutItem(
        name: exercise.name,
        detail: exercise.detail,
        sets: exercise.sets,
        reps: exercise.reps,
        weight: exercise.weight,
        minutes: exercise.minutes,
        icon: exercise.iconKey,
      );
      final item = data['item'];
      if (item is Map<String, dynamic>) exercise.id = item['id'] as String?;
    });
  }

  void removeExercise(int index) {
    if (index < 0 || index >= todayWorkout.length) return;
    final exercise = todayWorkout.removeAt(index);
    notifyListeners();
    final id = exercise.id;
    if (id != null) {
      _sync(() async {
        await api.deleteWorkoutItem(id);
      });
    }
  }

  void addGoal(FitnessGoal goal) {
    goals.add(goal);
    notifyListeners();
    _sync(() async {
      final data = await api.addGoal(
        title: goal.title,
        unit: goal.unit,
        start: goal.start,
        target: goal.target,
        current: goal.current,
        icon: AppState.iconKeyFor(goal.icon),
        color: goal.colorKey,
      );
      final row = data['goal'];
      if (row is Map<String, dynamic>) goal.id = row['id'] as String?;
    });
  }

  void nudgeGoal(FitnessGoal goal, double delta) {
    goal.current = (goal.current + delta).clamp(0, 1000);
    notifyListeners();
    final id = goal.id;
    if (id != null) {
      _sync(() async {
        await api.patchGoal(id, current: goal.current);
      });
    }
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
    _sync(() async {
      await api.patchMe({
        if (reminders != null) 'reminders': reminders,
        if (goalCheckIns != null) 'goalCheckIns': goalCheckIns,
        if (renewalAlerts != null) 'renewalAlerts': renewalAlerts,
      });
    });
  }

  void updateProfile({String? name, String? email, String? gym, String? phone}) {
    if (name != null) this.name = name;
    if (email != null) this.email = email;
    if (gym != null) this.gym = gym;
    if (phone != null) this.phone = phone;
    notifyListeners();
    _sync(() async {
      final data = await api.patchMe({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      });
      final user = data['user'];
      if (user is Map<String, dynamic>) _applyUser(user);
    });
  }

  void pairStopwatch() {
    stopwatchPaired = true;
    notifyListeners();
    _sync(() async {
      await api.patchMe({'stopwatchPaired': true});
    });
  }

  Future<String?> sendMessage(String text) async {
    final now = DateTime.now();
    chat.add(ChatMessage(
      text: text,
      fromMe: true,
      time:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    ));
    notifyListeners();
    if (!api.hasToken) return null;
    try {
      final data = await api.sendMessage('amara', text);
      final reply = data['reply'];
      if (reply is Map<String, dynamic>) return reply['body'] as String?;
      return null;
    } on ApiException catch (error) {
      if (error.status == 401) await api.saveToken(null);
      offline = true;
      notifyListeners();
      return null;
    }
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

  // ---------------------------------------------------------------- backend

  bool get signedIn => api.hasToken;

  Future<void> init() async {
    await api.loadToken();
    if (!api.hasToken) return;
    await refresh();
  }

  Future<void> refresh() async {
    if (!api.hasToken) return;
    try {
      final data = await api.me();
      _applyBootstrap(data);
      offline = false;
    } on ApiException catch (error) {
      offline = true;
      if (error.status == 401) await api.saveToken(null);
    } catch (_) {
      offline = true;
    }
    notifyListeners();
  }

  void _applyBootstrap(Map<String, dynamic> data) {
    final user = data['user'];
    if (user is Map<String, dynamic>) _applyUser(user);

    final workout = data['workout'];
    if (workout is List) {
      todayWorkout
        ..clear()
        ..addAll(workout.whereType<Map<String, dynamic>>().map((row) => Exercise(
              id: row['id'] as String?,
              name: (row['name'] as String?) ?? 'Exercise',
              detail: (row['detail'] as String?) ?? '',
              sets: _intOf(row['sets']),
              reps: _intOf(row['reps']),
              weight: _doubleOf(row['weight']),
              minutes: _intOf(row['minutes']),
              icon: iconForKey(row['icon'] as String?),
              iconKey: (row['icon'] as String?) ?? 'fitness_center',
              done: row['done'] == true,
            )));
    }

    final history = data['history'];
    if (history is List) {
      this.history
        ..clear()
        ..addAll(history.whereType<Map<String, dynamic>>().map((row) {
          final date = DateTime.tryParse('${row['date']}T12:00:00') ?? DateTime.now();
          return WorkoutEntry(
            title: (row['title'] as String?) ?? 'Session',
            date: date,
            minutes: _intOf(row['minutes']),
            exercises: _intOf(row['exercises']),
            kcal: _intOf(row['kcal']),
            intensity: _doubleOf(row['intensity']),
          );
        }));
    }

    final goals = data['goals'];
    if (goals is List) {
      this.goals
        ..clear()
        ..addAll(goals.whereType<Map<String, dynamic>>().map((row) {
          final iconKey = row['icon'] as String?;
          final colorKey = (row['color'] as String?) ?? 'green';
          return FitnessGoal(
            id: row['id'] as String?,
            title: (row['title'] as String?) ?? 'Goal',
            unit: (row['unit'] as String?) ?? '',
            start: _doubleOf(row['start']),
            target: _doubleOf(row['target']),
            current: _doubleOf(row['current']),
            icon: iconForKey(iconKey),
            color: colorForKey(colorKey),
            colorKey: colorKey,
          );
        }));
    }

    final videos = data['videos'];
    if (videos is List) {
      this.videos
        ..clear()
        ..addAll(videos.whereType<Map<String, dynamic>>().map((row) => VideoItem(
              id: row['id'] as String?,
              title: (row['title'] as String?) ?? 'Session',
              level: (row['level'] as String?) ?? 'Beginner',
              minutes: _intOf(row['minutes']),
              premium: row['premium'] == true,
              image: (row['image'] as String?) ?? 'assets/images/onboard_train.jpg',
              focus: (row['focus'] as String?) ?? '',
            )));
    }

    final coaches = data['coaches'];
    if (coaches is List) {
      trainers
        ..clear()
        ..addAll(coaches
            .whereType<Map<String, dynamic>>()
            .where((row) => (row['role'] ?? 'trainer') == 'trainer')
            .map((row) => Trainer(
                  key: row['key'] as String?,
                  name: (row['name'] as String?) ?? 'Coach',
                  specialty: (row['specialty'] as String?) ?? '',
                  rating: _doubleOf(row['rating']),
                  sessions: _intOf(row['sessions']),
                  initials: (row['initials'] as String?) ?? '',
                  color: colorFromHex(row['color'] as String?),
                )));
    }

    final messages = data['messages'];
    if (messages is List) {
      chat
        ..clear()
        ..addAll(messages
            .whereType<Map<String, dynamic>>()
            .where((row) => row['coach_key'] == 'amara')
            .map((row) => ChatMessage(
                  text: (row['body'] as String?) ?? '',
                  fromMe: row['from_me'] == true,
                  time: _timeOf(row['created_at']),
                )));
    }

    final stats = data['stats'];
    if (stats is Map<String, dynamic>) {
      streak = _intOf(stats['streak']);
    }
  }

  void _applyUser(Map<String, dynamic> user) {
    name = (user['name'] as String?) ?? name;
    email = (user['email'] as String?) ?? email;
    phone = user['phone'] as String?;
    plan = user['plan'] == 'premium' ? PlanType.premium : PlanType.general;
    annualBilling = user['annualBilling'] == true;
    planStartedAt = _dateOf(user['planStartedAt']);
    planRenewsAt = _dateOf(user['planRenewsAt']);
    gym = (user['gym'] as String?) ?? gym;
    reminders = user['reminders'] != false;
    goalCheckIns = user['goalCheckIns'] != false;
    renewalAlerts = user['renewalAlerts'] != false;
    stopwatchPaired = user['stopwatchPaired'] == true;
    streak = _intOf(user['streak']);
    notifyListeners();
  }

  Future<ApiException?> signIn({required String email, required String password}) async {
    try {
      final data = await api.login(email: email.trim().toLowerCase(), password: password);
      await api.saveToken(data['token'] as String?);
      await refresh();
      return null;
    } on ApiException catch (error) {
      if (error.isNetwork) {
        offline = true;
        notifyListeners();
        return null;
      }
      return error;
    }
  }

  Future<ApiException?> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final first = name.trim().split(RegExp(r'\s+')).first;
    this.name = first.isEmpty ? this.name : first;
    this.email = email.trim();
    try {
      final data = await api.register(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
        phone: phone,
      );
      await api.saveToken(data['token'] as String?);
      await refresh();
      return null;
    } on ApiException catch (error) {
      if (error.isNetwork) {
        offline = true;
        notifyListeners();
        return null;
      }
      return error;
    }
  }

  Future<void> signOut() async {
    try {
      await api.logout();
    } catch (_) {
      // Signing out locally is enough when the server is unreachable.
    }
    await api.saveToken(null);
    offline = false;
    notifyListeners();
  }

  void _sync(Future<void> Function() action) {
    action().then((_) {
      if (offline) {
        offline = false;
        notifyListeners();
      }
    }).catchError((Object error) {
      if (error is ApiException && error.status == 401) {
        api.saveToken(null);
      }
      offline = true;
      notifyListeners();
    });
  }

  void purchasePlan(PlanType value, {required bool annual}) {
    setPlan(value);
    setBilling(annual: annual);
    _sync(() async {
      final data = await api.purchasePlan(value.name, annual: annual);
      final user = data['user'];
      if (user is Map<String, dynamic>) _applyUser(user);
    });
  }

  void switchPlan(PlanType value, {required bool annual}) {
    setPlan(value);
    if (value == PlanType.premium) setBilling(annual: annual);
    _sync(() async {
      final data = await api.switchPlan(value.name, annual: annual);
      final user = data['user'];
      if (user is Map<String, dynamic>) _applyUser(user);
    });
  }

  void cancelPlan() {
    setPlan(PlanType.general);
    _sync(() async {
      final data = await api.cancelPlan();
      final user = data['user'];
      if (user is Map<String, dynamic>) _applyUser(user);
    });
  }

  void logSet(String exercise, int setNumber, int seconds) {
    _sync(() async {
      await api.logSet(exercise: exercise, setNumber: setNumber, seconds: seconds);
    });
  }

  void playVideo(VideoItem video) {
    final id = video.id;
    if (id == null) return;
    _sync(() async {
      await api.playVideo(id);
    });
  }

  void setGym(String label, {String? gymId}) {
    gym = label;
    notifyListeners();
    _sync(() async {
      final data = await api.setGym(gymId: gymId, label: label);
      final user = data['user'];
      if (user is Map<String, dynamic>) _applyUser(user);
    });
  }

  static int _intOf(dynamic value) => value is num ? value.toInt() : 0;

  static double _doubleOf(dynamic value) => value is num ? value.toDouble() : 0;

  static DateTime? _dateOf(dynamic value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;

  static String _timeOf(dynamic value) {
    final date = _dateOf(value);
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static IconData iconForKey(String? key) {
    switch (key) {
      case 'directions_run':
        return Icons.directions_run_rounded;
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'sports_gymnastics':
        return Icons.sports_gymnastics_rounded;
      case 'rowing':
        return Icons.rowing_rounded;
      case 'accessibility_new':
        return Icons.accessibility_new_rounded;
      case 'self_improvement':
        return Icons.self_improvement_rounded;
      case 'monitor_weight':
        return Icons.monitor_weight_outlined;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'flag':
        return Icons.flag_rounded;
      case 'play_circle':
        return Icons.play_circle_fill_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }

  static String iconKeyFor(IconData icon) {
    if (icon == Icons.directions_run_rounded) return 'directions_run';
    if (icon == Icons.sports_gymnastics_rounded) return 'sports_gymnastics';
    if (icon == Icons.rowing_rounded) return 'rowing';
    if (icon == Icons.accessibility_new_rounded) return 'accessibility_new';
    if (icon == Icons.self_improvement_rounded) return 'self_improvement';
    if (icon == Icons.monitor_weight_outlined) return 'monitor_weight';
    if (icon == Icons.bolt_rounded) return 'bolt';
    if (icon == Icons.flag_rounded) return 'flag';
    if (icon == Icons.play_circle_fill_rounded) return 'play_circle';
    return 'fitness_center';
  }

  static Color colorForKey(String? key) {
    switch (key) {
      case 'navy':
        return AppColors.navy;
      case 'amber':
        return AppColors.amber;
      case 'green_deep':
        return AppColors.greenDeep;
      default:
        return AppColors.green;
    }
  }

  static String colorKeyFor(Color color) {
    if (color == AppColors.navy) return 'navy';
    if (color == AppColors.amber) return 'amber';
    if (color == AppColors.greenDeep) return 'green_deep';
    return 'green';
  }

  static Color colorFromHex(String? hex) {
    if (hex == null) return const Color(0xFF1F5D4A);
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return const Color(0xFF1F5D4A);
    return Color(cleaned.length == 6 ? 0xFF000000 | value : value);
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
