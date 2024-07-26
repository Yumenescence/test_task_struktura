import 'task_status.dart';

class Task {
  final int id;
  TaskStatus status;
  int? duration;
  bool isPaused;
  int elapsedSeconds;
  DateTime? startTime;
  int totalDuration;

  Task(this.id, this.totalDuration)
      : status = TaskStatus.pending,
        isPaused = false,
        elapsedSeconds = 0;

  int get progress {
    if (totalDuration > 0) {
      return ((elapsedSeconds / totalDuration) * 100).toInt();
    }
    return 0;
  }
}
