import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/strings.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import '../providers/task_provider.dart';

class TaskManagerScreen extends StatelessWidget {
  const TaskManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.taskManager),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: taskProvider.allTasksComplete ? 60.0 : 0.0,
                child: taskProvider.allTasksComplete
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          Strings.allTasksComplete,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskProvider.tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: SizedBox(
                          width: 24,
                          child: task.status == TaskStatus.done
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                        ),
                        title: Text(
                          _getTaskStatusText(task),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.duration != null) Text('Duration: ${task.duration} seconds'),
                            if (task.status != TaskStatus.done)
                              SizedBox(
                                height: 4,
                                child: LinearProgressIndicator(
                                  value: task.progress / 100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    task.status == TaskStatus.running ? Colors.blue : Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (task.status == TaskStatus.running)
                              IconButton(
                                icon: const Icon(Icons.pause),
                                onPressed: () {
                                  taskProvider.pauseTask(task);
                                },
                              ),
                            if (task.status == TaskStatus.paused)
                              IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () {
                                  taskProvider.resumeTask(task);
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Provider.of<TaskProvider>(context, listen: false).addTask();
        },
        icon: const Icon(Icons.add),
        label: const Text(Strings.addTask),
        backgroundColor: Colors.white,
      ),
    );
  }

  String _getTaskStatusText(Task task) {
    switch (task.status) {
      case TaskStatus.pending:
        return '${Strings.task} ${task.id} ${Strings.taskPending}';
      case TaskStatus.running:
        return '${Strings.task} ${task.id} ${Strings.taskRunning}';
      case TaskStatus.paused:
        return '${Strings.task} ${task.id} ${Strings.taskPaused}';
      case TaskStatus.done:
        return '${Strings.task} ${task.id} ${Strings.taskDone}';
      default:
        return '';
    }
  }
}
