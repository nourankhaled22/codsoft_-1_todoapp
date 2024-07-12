import 'dart:convert';

class TodoModels {
  String title;
  String desc;
  bool done;
  int priority;
  DateTime? dueDate;

  TodoModels({
    required this.title,
    required this.desc,
    this.done = false,
    this.priority = 1,
    this.dueDate,
  });

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

  static String encode(List<TodoModels> todos) =>
      json.encode(todos.map<Map<String, dynamic>>((todo) => todo.toJson()).toList());

  static List<TodoModels> decode(String todos) =>
      (json.decode(todos) as List<dynamic>)
          .map<TodoModels>((item) => TodoModels.fromJson(item))
          .toList();
}