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
  final int weight;
  final int reps;
  final int sets;
}

class WorkoutLog {
  WorkoutLog({
    required this.exercise,
    required this.date,
    required this.setsCompleted,
  });

  final Exercise exercise;
  final DateTime date;
  final int setsCompleted;
}

class WorkoutAppState {
  WorkoutAppState() {
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

  late List<Exercise> exercises;
  late Exercise selectedExercise;

  final List<WorkoutLog> logs = [];

  int currentSetIndex = 0;
  final Set<int> completedSets = {};

  bool get workoutFinished {
    return completedSets.length >= selectedExercise.sets;
  }

  String get setProgressText {
    if (workoutFinished) {
      return 'Все подходы завершены';
    }

    return 'Подход ${currentSetIndex + 1} из ${selectedExercise.sets}';
  }

  int statusForSet(int index) {
    if (completedSets.contains(index)) return 2;
    if (!workoutFinished && index == currentSetIndex) return 1;
    return 0;
  }

  void selectExercise(Exercise exercise) {
    selectedExercise = exercise;
    resetWorkout();
  }

  void addExercise(Exercise exercise) {
    exercises.insert(0, exercise);
    selectExercise(exercise);
  }

  bool completeCurrentSet() {
    if (workoutFinished) return true;

    completedSets.add(currentSetIndex);

    if (completedSets.length >= selectedExercise.sets) {
      logs.insert(
        0,
        WorkoutLog(
          exercise: selectedExercise,
          date: DateTime.now(),
          setsCompleted: selectedExercise.sets,
        ),
      );
      return true;
    }

    currentSetIndex++;
    return false;
  }

  void resetWorkout() {
    currentSetIndex = 0;
    completedSets.clear();
  }
}