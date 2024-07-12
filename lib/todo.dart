import 'package:flutter/material.dart';

class Todo extends StatefulWidget {
  final String title;
  final String desc;
  bool done;
  final Function(String, String) onUpdate;
  final Function() onDelete;

  Todo({
    Key? key,
    required this.title,
    required this.desc,
    required this.done,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title;
    descController.text = widget.desc;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: widget.done ? Colors.blueAccent : Colors.purple,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 11, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
                onChanged: (value) {
                  widget.onUpdate(value, descController.text);
                },
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              TextFormField(
                controller: descController,
                onChanged: (value) {
                  widget.onUpdate(titleController.text, value);
                },
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: widget.onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
