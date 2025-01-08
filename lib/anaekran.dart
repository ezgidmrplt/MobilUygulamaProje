import 'package:flutter/material.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final List<Map<String, dynamic>> groups = [
    {
      'title': 'Grup 1',
      'tasks': [
        {'task': 'Görev 1', 'dueDate': '12/01/2025', 'isCompleted': false},
        {'task': 'Görev 2', 'dueDate': '15/01/2025', 'isCompleted': false},
      ],
    },
    {
      'title': 'Grup 2',
      'tasks': [
        {'task': 'Görev 1', 'dueDate': '13/01/2025', 'isCompleted': false},
        {'task': 'Görev 2', 'dueDate': '18/01/2025', 'isCompleted': false},
      ],
    },
  ];

  void _updateTaskCompletion(int groupIndex, int taskIndex, bool value) {
    setState(() {
      groups[groupIndex]['tasks'][taskIndex]['isCompleted'] = value;
    });
  }

  double _calculateProgress(int groupIndex) {
    final tasks = groups[groupIndex]['tasks'];
    final completedTasks = tasks.where((task) => task['isCompleted'] == true).length;
    return completedTasks / tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panolarınız'),
        backgroundColor: const Color(0xFFAE445A), // Same as login screen
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, groupIndex) {
            final group = groups[groupIndex];
            final progress = _calculateProgress(groupIndex);

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Color(0xFFFFCDD2), // Light pink background
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group['title'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    // İlerleme barı
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      color: Color(0xFFAE445A), // Same as app bar color
                    ),
                    SizedBox(height: 10),
                    ...group['tasks'].map<Widget>((task) {
                      final taskIndex = group['tasks'].indexOf(task);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['task'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Bitiş Tarihi: ${task['dueDate']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Checkbox(
                                value: task['isCompleted'] ?? false, // Handling null values
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    _updateTaskCompletion(groupIndex, taskIndex, value);
                                  }
                                },
                                activeColor: Color(0xFFAE445A), // Same as app bar color
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
