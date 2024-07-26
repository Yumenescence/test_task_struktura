import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:test_task_struktura/models/task.dart';
import 'package:test_task_struktura/models/task_status.dart';

class TaskProvider with ChangeNotifier {
  List<Task> tasks = [];
  bool allTasksComplete = false;
  final Map<int, Isolate> _isolates = {};
  final Map<int, SendPort> _sendPorts = {};

  void initializeTasks(int count) {
    final random = Random();
    for (int i = 0; i < count; i++) {
      final totalDuration = random.nextInt(5) + 3;
      Task task = Task(i, totalDuration);
      tasks.add(task);
      _startTask(task);
    }
  }

  Future<void> _startTask(Task task) async {
    task.startTime = DateTime.now();
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(_taskEntryPoint, receivePort.sendPort);
    _isolates[task.id] = isolate;

    final sendPort = await receivePort.first as SendPort;
    _sendPorts[task.id] = sendPort;
    final response = ReceivePort();
    sendPort.send([response.sendPort, task.id, task.elapsedSeconds, task.totalDuration]);

    response.listen((message) {
      if (message is int) {
        task.elapsedSeconds = message;
        notifyListeners();
      } else if (message == 'done') {
        _completeTask(task);
      }
    });

    task.status = TaskStatus.running;
    notifyListeners();
  }

  void _completeTask(Task task) {
    final endTime = DateTime.now();
    final duration = endTime.difference(task.startTime!).inSeconds + task.elapsedSeconds;
    task.status = TaskStatus.done;
    task.duration = duration;
    task.elapsedSeconds = task.totalDuration;
    notifyListeners();
    _isolates.remove(task.id);
    _checkAllTasksComplete();
  }

  void _checkAllTasksComplete() {
    if (tasks.every((task) => task.status == TaskStatus.done)) {
      allTasksComplete = true;
      notifyListeners();
    }
  }

  void addTask() {
    final random = Random();
    final totalDuration = random.nextInt(5) + 1;
    Task task = Task(tasks.length, totalDuration);
    tasks.add(task);
    _startTask(task);
    notifyListeners();
  }

  void pauseTask(Task task) {
    if (_isolates.containsKey(task.id)) {
      _isolates[task.id]?.kill(priority: Isolate.immediate);
      task.status = TaskStatus.paused;
      task.isPaused = true;
      task.elapsedSeconds += DateTime.now().difference(task.startTime!).inSeconds;
      task.startTime = null;
      notifyListeners();
    }
  }

  void resumeTask(Task task) {
    if (task.isPaused) {
      task.isPaused = false;
      task.startTime = DateTime.now();
      _startTask(task);
    }
  }

  static void _taskEntryPoint(SendPort sendPort) {
    final responsePort = ReceivePort();
    sendPort.send(responsePort.sendPort);

    responsePort.listen((message) async {
      final sendPort = message[0] as SendPort;
      final taskId = message[1] as int;
      final elapsedSeconds = message[2] as int;
      final totalDuration = message[3] as int;
      final remainingDuration = totalDuration - elapsedSeconds;

      for (int i = 0; i < remainingDuration; i++) {
        await Future.delayed(const Duration(seconds: 1));
        sendPort.send(elapsedSeconds + i + 1);
      }

      sendPort.send('done');
    });
  }
}
