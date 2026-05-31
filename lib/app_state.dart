import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Exercise {
  Exercise({
    required this.id,
    required this.name,
    required this.weight,
    required this.reps,
    required this.sets,
  });

  final String id;
  final String name;
  final double weight;
  final int reps;
  final int sets;

  Exercise copyWith({
    String? id,
    String? name,
    double? weight,
    int? reps,
    int? sets,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      sets: sets ?? this.sets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'weight': weight,
      'reps': reps,
      'sets': sets,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Exercise.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return Exercise(
      id: doc.id,
      name: data['name']?.toString() ?? 'Упражнение',
      weight: _toDouble(data['weight'], 0),
      reps: _toInt(data['reps'], 8),
      sets: _toInt(data['sets'], 3),
    );
  }
}

class WorkoutLog {
  WorkoutLog({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.setsCompleted,
    required this.recommendedNextWeight,
    required this.date,
  });

  final String id;
  final String exerciseId;
  final String exerciseName;
  final double weight;
  final int reps;
  final int sets;
  final int setsCompleted;
  final double recommendedNextWeight;
  final DateTime date;

  bool get isFullyCompleted => setsCompleted >= sets;

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'weight': weight,
      'reps': reps,
      'sets': sets,
      'setsCompleted': setsCompleted,
      'recommendedNextWeight': recommendedNextWeight,
      'createdAt': Timestamp.fromDate(date),
    };
  }

  factory WorkoutLog.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAt = data['createdAt'];

    DateTime date = DateTime.now();

    if (createdAt is Timestamp) {
      date = createdAt.toDate();
    }

    return WorkoutLog(
      id: doc.id,
      exerciseId: data['exerciseId']?.toString() ?? '',
      exerciseName: data['exerciseName']?.toString() ?? 'Упражнение',
      weight: _toDouble(data['weight'], 0),
      reps: _toInt(data['reps'], 8),
      sets: _toInt(data['sets'], 3),
      setsCompleted: _toInt(data['setsCompleted'], 0),
      recommendedNextWeight: _toDouble(data['recommendedNextWeight'], 0),
      date: date,
    );
  }
}

class UserProfileData {
  UserProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.goal,
    required this.currentWeight,
    required this.targetWeight,
    required this.bodyFat,
    required this.weeklyWorkoutsGoal,
    required this.workoutsDone,
  });

  final String name;
  final String email;
  final String phone;
  final String birthDate;
  final String goal;
  final double currentWeight;
  final double targetWeight;
  final double bodyFat;
  final int weeklyWorkoutsGoal;
  final int workoutsDone;

  UserProfileData copyWith({
    String? name,
    String? email,
    String? phone,
    String? birthDate,
    String? goal,
    double? currentWeight,
    double? targetWeight,
    double? bodyFat,
    int? weeklyWorkoutsGoal,
    int? workoutsDone,
  }) {
    return UserProfileData(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      goal: goal ?? this.goal,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      bodyFat: bodyFat ?? this.bodyFat,
      weeklyWorkoutsGoal: weeklyWorkoutsGoal ?? this.weeklyWorkoutsGoal,
      workoutsDone: workoutsDone ?? this.workoutsDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
      'goal': goal,
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
      'bodyFat': bodyFat,
      'weeklyWorkoutsGoal': weeklyWorkoutsGoal,
      'workoutsDone': workoutsDone,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserProfileData.fromMap(
    Map<String, dynamic> data, {
    required String fallbackEmail,
    required String fallbackName,
  }) {
    return UserProfileData(
      name: _readString(data['name'], fallbackName),
      email: _readString(data['email'], fallbackEmail),
      phone: _readString(data['phone'], ''),
      birthDate: _readString(data['birthDate'], ''),
      goal: _readString(data['goal'], 'Набор мышечной массы'),
      currentWeight: _toDouble(data['currentWeight'], 0),
      targetWeight: _toDouble(data['targetWeight'], 0),
      bodyFat: _toDouble(data['bodyFat'], 0),
      weeklyWorkoutsGoal: _toInt(data['weeklyWorkoutsGoal'], 4),
      workoutsDone: _toInt(data['workoutsDone'], 0),
    );
  }
}

class WorkoutAppState {
  WorkoutAppState() {
    _setDefaults();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late List<Exercise> exercises;
  late Exercise selectedExercise;

  List<WorkoutLog> logs = [];

  UserProfileData profile = UserProfileData(
    name: '',
    email: '',
    phone: '',
    birthDate: '',
    goal: 'Набор мышечной массы',
    currentWeight: 0,
    targetWeight: 0,
    bodyFat: 0,
    weeklyWorkoutsGoal: 4,
    workoutsDone: 0,
  );

  int currentSetIndex = 0;
  bool setInProgress = false;
  bool workoutEnded = false;
  bool workoutFailed = false;

  final Set<int> completedSets = {};

  double progressionStep = 2.5;

  bool get workoutFinished {
    return workoutEnded || completedSets.length >= selectedExercise.sets;
  }

  String get setProgressText {
    if (workoutFailed) {
      return 'Тренировка остановлена';
    }

    if (completedSets.length >= selectedExercise.sets) {
      return 'Все подходы завершены';
    }

    return 'Подход ${currentSetIndex + 1} из ${selectedExercise.sets}';
  }

  String get workoutStatusText {
    if (workoutFailed) {
      return 'Подход\nне выполнен';
    }

    if (completedSets.length >= selectedExercise.sets) {
      return 'Тренировка\nзавершена!';
    }

    if (setInProgress) {
      return 'Выполняется\nподход...';
    }

    return 'Готов к\nподходу';
  }

  void _setDefaults() {
    final defaultExercise = Exercise(
      id: 'bench_press',
      name: 'Жим лежа',
      weight: 80,
      reps: 8,
      sets: 3,
    );

    exercises = [
      defaultExercise,
      Exercise(
        id: 'squats',
        name: 'Приседания',
        weight: 70,
        reps: 10,
        sets: 3,
      ),
      Exercise(
        id: 'deadlift',
        name: 'Становая тяга',
        weight: 100,
        reps: 6,
        sets: 3,
      ),
    ];

    selectedExercise = defaultExercise;
  }

  String? get _uid {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  DocumentReference<Map<String, dynamic>>? get _userRef {
    final uid = _uid;
    if (uid == null) return null;

    return _db.collection('users').doc(uid);
  }

  Future<void> loadFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload();
    }

    final freshUser = FirebaseAuth.instance.currentUser;

    final fallbackEmail = freshUser?.email ?? '';
    final fallbackName = freshUser?.displayName?.trim().isNotEmpty == true
        ? freshUser!.displayName!.trim()
        : 'Пользователь';

    profile = profile.copyWith(
      email: fallbackEmail,
      name: fallbackName,
    );

    final userRef = _userRef;
    if (userRef == null) return;

    try {
      final userSnap = await userRef.get();

      if (userSnap.exists) {
        profile = UserProfileData.fromMap(
          userSnap.data() ?? {},
          fallbackEmail: fallbackEmail,
          fallbackName: fallbackName,
        );
      } else {
        profile = UserProfileData(
          name: fallbackName,
          email: fallbackEmail,
          phone: '',
          birthDate: '',
          goal: 'Набор мышечной массы',
          currentWeight: 0,
          targetWeight: 0,
          bodyFat: 0,
          weeklyWorkoutsGoal: 4,
          workoutsDone: 0,
        );

        await userRef.set(profile.toMap(), SetOptions(merge: true));
      }

      final exercisesSnap = await userRef.collection('exercises').get();

      if (exercisesSnap.docs.isNotEmpty) {
        exercises = exercisesSnap.docs.map(Exercise.fromDoc).toList();
        selectedExercise = exercises.first;
      } else {
        for (final exercise in exercises) {
          await userRef.collection('exercises').doc(exercise.id).set(
                {
                  ...exercise.toMap(),
                  'createdAt': FieldValue.serverTimestamp(),
                },
                SetOptions(merge: true),
              );
        }
      }

      final logsSnap = await userRef
          .collection('workout_logs')
          .orderBy('createdAt', descending: true)
          .limit(80)
          .get();

      logs = logsSnap.docs.map(WorkoutLog.fromDoc).toList();

      profile = profile.copyWith(workoutsDone: logs.length);
      resetWorkout();
    } catch (e) {
      debugPrint('Firestore load error: $e');
    }
  }

  int statusForSet(int index) {
    if (completedSets.contains(index)) return 2;
    if (setInProgress && !workoutFinished && index == currentSetIndex) return 1;
    return 0;
  }

  void startCurrentSet() {
    if (workoutFinished) return;
    setInProgress = true;
  }

  void selectExercise(Exercise exercise) {
    selectedExercise = exercise;
    resetWorkout();
  }

  Future<void> addExercise(Exercise exercise) async {
    exercises.insert(0, exercise);
    selectExercise(exercise);

    final userRef = _userRef;
    if (userRef == null) return;

    try {
      await userRef.collection('exercises').doc(exercise.id).set(
        {
          ...exercise.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Add exercise error: $e');
    }
  }

  Future<void> updateSelectedExercise(Exercise updatedExercise) async {
    selectedExercise = updatedExercise;

    final index = exercises.indexWhere((item) => item.id == updatedExercise.id);
    if (index != -1) {
      exercises[index] = updatedExercise;
    }

    final userRef = _userRef;
    if (userRef == null) return;

    try {
      await userRef
          .collection('exercises')
          .doc(updatedExercise.id)
          .set(updatedExercise.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Update exercise error: $e');
    }
  }

  Future<bool> completeCurrentSet() async {
    if (workoutFinished) return true;

    if (!setInProgress) {
      return false;
    }

    completedSets.add(currentSetIndex);
    setInProgress = false;

    if (completedSets.length >= selectedExercise.sets) {
      workoutEnded = true;
      workoutFailed = false;

      final nextWeight = selectedExercise.weight + progressionStep;

      final log = WorkoutLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        exerciseId: selectedExercise.id,
        exerciseName: selectedExercise.name,
        weight: selectedExercise.weight,
        reps: selectedExercise.reps,
        sets: selectedExercise.sets,
        setsCompleted: selectedExercise.sets,
        recommendedNextWeight: nextWeight,
        date: DateTime.now(),
      );

      logs.insert(0, log);
      profile = profile.copyWith(workoutsDone: logs.length);

      await _saveWorkoutLog(log);
      await saveProfile(profile);

      return true;
    }

    currentSetIndex++;
    return false;
  }

  Future<void> failCurrentSet() async {
    if (workoutFinished) return;

    setInProgress = false;
    workoutEnded = true;
    workoutFailed = true;

    final log = WorkoutLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exerciseId: selectedExercise.id,
      exerciseName: selectedExercise.name,
      weight: selectedExercise.weight,
      reps: selectedExercise.reps,
      sets: selectedExercise.sets,
      setsCompleted: completedSets.length,
      recommendedNextWeight: selectedExercise.weight,
      date: DateTime.now(),
    );

    logs.insert(0, log);
    profile = profile.copyWith(workoutsDone: logs.length);

    await _saveWorkoutLog(log);
    await saveProfile(profile);
  }

  Future<void> startNextWorkoutWithRecommendedWeight() async {
    final nextWeight = recommendedWeightFor(selectedExercise);

    final updated = selectedExercise.copyWith(weight: nextWeight);
    await updateSelectedExercise(updated);

    resetWorkout();
  }

  WorkoutLog? lastLogForExercise(Exercise exercise) {
    for (final log in logs) {
      if (log.exerciseId == exercise.id || log.exerciseName == exercise.name) {
        return log;
      }
    }

    return null;
  }

  double recommendedWeightFor(Exercise exercise) {
    final lastLog = lastLogForExercise(exercise);

    if (lastLog == null) {
      return exercise.weight;
    }

    if (lastLog.isFullyCompleted) {
      return lastLog.weight + progressionStep;
    }

    return lastLog.weight;
  }

  List<WorkoutLog> progressLogsForSelectedExercise() {
    final result = logs.where((log) {
      return log.exerciseId == selectedExercise.id ||
          log.exerciseName == selectedExercise.name;
    }).toList();

    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  int completedThisWeek() {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    return logs.where((log) => log.date.isAfter(startOfWeek)).length;
  }

  Future<void> saveProfile(UserProfileData updatedProfile) async {
    profile = updatedProfile.copyWith(
      workoutsDone: logs.length,
    );

    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null && profile.name.trim().isNotEmpty) {
        await user.updateDisplayName(profile.name.trim());
      }

      final userRef = _userRef;
      if (userRef != null) {
        await userRef.set(profile.toMap(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Save profile error: $e');
    }
  }

  Future<void> _saveWorkoutLog(WorkoutLog log) async {
    final userRef = _userRef;
    if (userRef == null) return;

    try {
      await userRef
          .collection('workout_logs')
          .doc(log.id)
          .set(log.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Save workout log error: $e');
    }
  }

  void resetWorkout() {
    currentSetIndex = 0;
    setInProgress = false;
    workoutEnded = false;
    workoutFailed = false;
    completedSets.clear();
  }
}

String _readString(dynamic value, String fallback) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

int _toInt(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;

  return fallback;
}

double _toDouble(dynamic value, double fallback) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) {
    return double.tryParse(value.replaceAll(',', '.')) ?? fallback;
  }

  return fallback;
}

String formatWeight(double value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(1);
}