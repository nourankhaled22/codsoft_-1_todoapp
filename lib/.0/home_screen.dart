import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TodoModels> todos = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  Future<void> loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedTodos = prefs.getString('todos');
    if (storedTodos != null) {
      setState(() {
        todos = TodoModels.decode(storedTodos);
      });
    }
  }

  Future<void> saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('todos', TodoModels.encode(todos));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Todo List'),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Dismissible(
            key: Key(todo.title),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                todos.removeAt(index);
                saveTodos();
              });
            },
            child: ListTile(
              title: Text(todo.title),
              subtitle: Text(todo.desc),
              trailing: Checkbox(
                value: todo.done,
                onChanged: (value) {
                  setState(() {
                    todo.done = value!;
                    saveTodos();
                  });
                },
              ),
              onTap: () => _editTodoDialog(context, todo, index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTodoDialog(context),
        tooltip: 'Add Todo',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addTodoDialog(BuildContext context) async {
    titleController.text = '';
    descController.text = '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                setState(() {
                  todos.add(TodoModels(
                    title: titleController.text,
                    desc: descController.text,
                  ));
                  saveTodos();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editTodoDialog(BuildContext context, TodoModels todo, int index) async {
    titleController.text = todo.title;
    descController.text = todo.desc;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  todos[index].title = titleController.text;
                  todos[index].desc = descController.text;
                  saveTodos();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  factory TodoModels.fromJson(Map<String, dynamic> json) => TodoModels(
    title: json['title'],
    desc: json['desc'],
    done: json['done'],
    priority: json['priority'],
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'desc': desc,
    'done': done,
    'priority': priority,
    'dueDate': dueDate?.toIso8601String(),
  };

  static String encode(List<TodoModels> todos) => json.encode(
    todos.map<Map<String, dynamic>>((todo) => todo.toJson()).toList(),
  );

  static List<TodoModels> decode(String todos) =>
      (json.decode(todos) as List<dynamic>)
          .map<TodoModels>((item) => TodoModels.fromJson(item))
          .toList();
}



