import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/todo_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TodoModels> todos = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  int _selectedPriority = 1;

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
        // Sort todos by priority and due date
        todos.sort((a, b) {
          int priorityComparison = b.priority.compareTo(a.priority);
          if (priorityComparison != 0) return priorityComparison;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      });
    }
  }

  Future<void> saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('todos', TodoModels.encode(todos));
    // After saving, sort todos by priority and due date again
    todos.sort((a, b) {
      int priorityComparison = b.priority.compareTo(a.priority);
      if (priorityComparison != 0) return priorityComparison;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    setState(() {}); // Trigger rebuild after sorting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Todo List'),
      ),
      backgroundColor: Colors.pink[50],
      body: todos.isEmpty
          ? Center(
              child: Text(
                'No todos yet. Add some tasks!',
                style: TextStyle(fontSize: 18.0),
              ),
            )
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: Colors.teal[50],
                    child: Dismissible(
                      key: Key(todo.title),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          todos.removeAt(index); // Remove item from the list
                          saveTodos(); // Save updated list to SharedPreferences
                        });
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (todo.desc.isNotEmpty) Text(todo.desc),
                            if (todo.dueDate != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  'Due Date: ${DateFormat('yyyy-MM-dd').format(todo.dueDate!)}',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            Text(
                              'Priority: ${todo.priority}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: _priorityColor(todo.priority),
                              ),
                            ),
                          ],
                        ),
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
                        leading: IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editTodoDialog(context, todo, index),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTodoDialog(context),
        tooltip: 'Add Tasks',
        child: Icon(Icons.add),
      ),
    );
  }

  Color _priorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Future<void> _addTodoDialog(BuildContext context) async {
    titleController.text = '';
    descController.text = '';
    _selectedPriority = 1;
    _selectedDate = null; // Reset selected date

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Todo'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    // Due date picker
                    InkWell(
                      onTap: () => _selectDate(context, setState),
                      child: IgnorePointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Due Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: _selectedDate != null
                                ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                                : '',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    // Priority selector
                    DropdownButtonFormField<int>(
                      value: _selectedPriority,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(5, (index) => index + 1)
                          .map((priority) => DropdownMenuItem(
                                value: priority,
                                child: Text('Priority $priority'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value!;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: Text('Add'),
              onPressed: () async {
                setState(() {
                  todos.add(TodoModels(
                    title: titleController.text,
                    desc: descController.text,
                    dueDate: _selectedDate,
                    priority: _selectedPriority,
                  ));
                  todos.sort((a, b) {
                    int priorityComparison = b.priority.compareTo(a.priority);
                    if (priorityComparison != 0) return priorityComparison;
                    return (a.dueDate ?? DateTime(0))
                        .compareTo(b.dueDate ?? DateTime(0));
                  });
                });

                await saveTodos();
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editTodoDialog(BuildContext context, TodoModels todo, int index) async {
    // Initialize controllers with current todo values
    titleController.text = todo.title;
    descController.text = todo.desc;
    _selectedDate = todo.dueDate;
    _selectedPriority = todo.priority;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    // Due date picker
                    InkWell(
                      onTap: () => _selectDate(context, setState),
                      child: IgnorePointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Due Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: _selectedDate != null
                                ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                                : '',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    // Priority selector
                    DropdownButtonFormField<int>(
                      value: _selectedPriority,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(5, (index) => index + 1)
                          .map((priority) => DropdownMenuItem(
                                value: priority,
                                child: Text('Priority $priority'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value!;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: Text('Save'),
              onPressed: () async {
                setState(() {
                  // Update the existing todo with edited values
                  todos[index].title = titleController.text;
                  todos[index].desc = descController.text;
                  todos[index].dueDate = _selectedDate;
                  todos[index].priority = _selectedPriority;
                  todos.sort((a, b) {
                    int priorityComparison = b.priority.compareTo(a.priority);
                    if (priorityComparison != 0) return priorityComparison;
                    return (a.dueDate ?? DateTime(0))
                        .compareTo(b.dueDate ?? DateTime(0));
                  });
                });

                await saveTodos();
                Navigator.of(context).pop(); // Dismiss dialog after editing todo
              },
            ),
          ],
        );
      },
    );
  }

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
