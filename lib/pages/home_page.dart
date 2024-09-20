import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/todo.dart';
import '../services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  String? _editingTodoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayTextInputDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: const Text(
        "Todo",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Column(
        children: [
          _messagesListView(),
        ],
      ),
    );
  }

  Widget _messagesListView() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.80,
      width: MediaQuery.sizeOf(context).width,
      child: StreamBuilder<QuerySnapshot<Todo>>(
        stream: _databaseService.getTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error loading todos: ${snapshot.error}"),
            );
          }
          final todos = snapshot.data?.docs ?? [];
          if (todos.isEmpty) {
            return const Center(
              child: Text("Add a todo!"),
            );
          }
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index].data();
              final todoId = todos[index].id;

              if (todo == null) {
                return const ListTile(
                  title: Text("Todo data is not available"),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: ListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer,
                  title: Text(todo.task),
                  subtitle: Text(
                    DateFormat("dd-MM-yyyy h:mm a").format(
                      todo.updatedOn.toDate(),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editingTodoId = todoId;
                          _textEditingController.text = todo.task;
                          _displayTextInputDialog(isEditing: true);
                        },
                      ),
                      Checkbox(
                        value: todo.isDone,
                        onChanged: (value) {
                          final updatedTodo = todo.copyWith(
                            isDone: value ?? false,
                            updatedOn: Timestamp.now(),
                          );
                          _databaseService.updateTodo(todoId, updatedTodo);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _databaseService.deleteTodo(todoId);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _displayTextInputDialog({bool isEditing = false}) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit todo' : 'Add a todo'),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(hintText: "Todo...."),
          ),
          actions: <Widget>[
            MaterialButton(
              color: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              child: const Text('Ok'),
              onPressed: () async {
                if (_textEditingController.text.trim().isNotEmpty) {
                  if (isEditing && _editingTodoId != null) {
                    final updatedTodo = Todo(
                      task: _textEditingController.text.trim(),
                      isDone: false,
                      createdOn: Timestamp.now(), // ใช้เวลาที่สร้างใหม่
                      updatedOn: Timestamp.now(),
                    );
                    await _databaseService.updateTodo(
                      _editingTodoId!,
                      updatedTodo,
                    );
                  } else {
                    final newTodo = Todo(
                      task: _textEditingController.text.trim(),
                      isDone: false,
                      createdOn: Timestamp.now(),
                      updatedOn: Timestamp.now(),
                    );
                    await _databaseService.addTodo(newTodo);
                  }
                  setState(() {});
                  Navigator.pop(context);
                  _textEditingController.clear();
                  _editingTodoId = null; // รีเซ็ต ID
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a todo")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
