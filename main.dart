import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

final Logger _logger = Logger();
void main() async {
  runApp(const MyApp());
}

class TaskData {
  List<String> todos;
  List<String> deletedTasks;

  TaskData({required this.todos, required this.deletedTasks});

  factory TaskData.fromJson(Map<String, dynamic> json) {
    return TaskData(
      todos: List<String>.from(json['todos']),
      deletedTasks: List<String>.from(json['deletedTasks']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todos': todos,
      'deletedTasks': deletedTasks,
    };
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List App',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: FutureBuilder(
        future: _loadTaskData(),
        builder: (context, AsyncSnapshot<TaskData> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return TodoList(taskData: snapshot.data!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      debugShowCheckedModeBanner: false, // removes debug banner
    );
  }

  Future<TaskData> _loadTaskData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/task_data.json';
      final file = File(filePath);

      if (file.existsSync()) {
        final jsonString = await file.readAsString();
        final jsonData = json.decode(jsonString);
        return TaskData.fromJson(jsonData);
      } else {
        return TaskData(todos: [], deletedTasks: []);
      }
    } catch (e) {
      _logger.e('Error loading task data: $e');
      return TaskData(todos: [], deletedTasks: []);
    }
  }
}

class TodoList extends StatefulWidget {
  final TaskData taskData;

  const TodoList({Key? key, required this.taskData}) : super(key: key);

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late List<String> todos;
  late List<String> deletedTasks; // Keep track of deleted tasks

  @override
  void initState() {
    super.initState();
    todos = widget.taskData.todos;
    deletedTasks = widget.taskData.deletedTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Navigate to the text page with deleted tasks
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TextPage(deletedTasks, onRestoreTask: _restoreTask,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever), // New delete all button
            onPressed: () {
              _showDeleteAllDialog(context);
            },
          ),
        ],
      ),
      body: todos.isEmpty
          ? const Center(
              child: Text('No tasks yet. Add some tasks! ,   swipe task to delete it.'),
            )
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return _buildTaskItem(index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
      drawer: _buildDrawer(), // Add drawer for navigation
    );
  }

  Widget _buildTaskItem(int index) {
  return Dismissible(
    key: Key(todos[index]),
    onDismissed: (direction) {
      setState(() {
        // Move the deleted task to the deletedTasks list
        deletedTasks.add(todos[index]);
        todos.removeAt(index);
        _saveTaskData();
      });
    },
    background: Container(
      color: Colors.red,
      child: const Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
    ),
    child: GestureDetector(
      onDoubleTap: () {
        _editTaskDialog(context, index);
      },
      child: ListTile(
        title: Text(todos[index]),
      ),
    ),
  );
}

void _restoreTask(String task) {
    setState(() {
      deletedTasks.remove(task);
      todos.insert(0, task); // Move the task to the top of the list
      _saveTaskData();
    });
  }

void _editTaskDialog(BuildContext context, int index) {
  String updatedTask = todos[index];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          onChanged: (value) {
            updatedTask = value;
          },
          controller: TextEditingController(text: updatedTask),
          decoration: const InputDecoration(
            hintText: 'Enter your updated task',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (updatedTask.isNotEmpty) {
                  todos[index] = updatedTask;
                  _saveTaskData();
                }
              });
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}


  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Todo App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          ListTile(
            title: const Text('App Usage'),
            onTap: () {
              _showAppUsageDialog(context);
            },
          ),
          // Add more ListTile items or sections as needed
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Tasks'),
          content: const Text('Are you sure you want to delete all tasks permanently?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  deletedTasks.addAll(todos);
                  todos.clear();
                  _saveTaskData();
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    String newTask = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            onChanged: (value) {
              newTask = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter your task',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (newTask.isNotEmpty) {
                    todos.add(newTask);
                    _saveTaskData();
                  }
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveTaskData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/task_data.json';
      final file = File(filePath);

      await file.writeAsString(json.encode(TaskData(todos: todos, deletedTasks: deletedTasks).toJson()));
    } catch (e) {
      _logger.e('Error saving task data: $e');
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About'),
          content: const Text('This app is made by the author Chandu.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAppUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('App Usage'),
          content: const Column(
            children: [
              Text('How to use the Todo App:'),
              SizedBox(height: 8),
              Text('1. Click on the "+" button to add a new task.'),
              Text('2. Swipe left on a task to delete it.'),
              Text('3. Click on the "Delete" icon in the app bar to view deleted tasks.'),
              // Add more usage instructions as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
  // Text page statrs here
class TextPage extends StatelessWidget {
  final List<String> deletedTasks;
  final Function(String) onRestoreTask;

  const TextPage(this.deletedTasks, {Key? key, required this.onRestoreTask}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deleted Tasks'),
         actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              _showDeleteAllDialog(context); // Call _showDeleteAllDialog here
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: deletedTasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(deletedTasks[index]),
            onTap: () {
              _showRestoreConfirmationDialog(context, deletedTasks[index]);
            },
          );
        },
      ),
    );
  }
  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Deleted Tasks'),
          content: const Text('Are you sure you want to delete all deleted tasks permanently?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteAllTasks(context);
              },
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }
  void _deleteAllTasks(BuildContext context) {
    deletedTasks.clear();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('All deleted tasks have been permanently deleted.'),
    ),
  );
  Navigator.of(context).pop();
 }

  void _showRestoreConfirmationDialog(BuildContext context, String task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restore Task'),
          content: const Text('Do you want to restore this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onRestoreTask(task); // Restore the task
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
