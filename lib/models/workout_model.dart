class WorkoutModel {
  final String workoutId;
  final String type;
  final int duration;
  final double calories;
  final String timestamp;

  WorkoutModel({
    required this.workoutId,
    required this.type,
    required this.duration,
    required this.calories,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'workoutId': workoutId,
      'type': type,
      'duration': duration,
      'calories': calories,
      'timestamp': timestamp,
    };
  }

  factory WorkoutModel.fromMap(String workoutId, Map<String, dynamic> map) {
    return WorkoutModel(
      workoutId: workoutId,
      type: map['type'] as String,
      duration: map['duration'] as int,
      calories: map['calories'] as double,
      timestamp: map['timestamp'] as String,
    );
  }
}