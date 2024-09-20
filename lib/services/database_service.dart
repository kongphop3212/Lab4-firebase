import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lab4_todo/models/todo.dart';

const String todoCollectionRef = "todos";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference<Todo> _todosRef;

  DatabaseService() {
    _todosRef = _firestore.collection(todoCollectionRef).withConverter<Todo>(
      fromFirestore: (snapshots, _) {
        final data = snapshots.data();
        if (data != null) {
          return Todo.fromJson(data);
        }
        throw Exception("Error in fetching data");
      },
      toFirestore: (todo, _) => todo.toJson(),
    );
  }

  Stream<QuerySnapshot<Todo>> getTodos() {
    return _todosRef.snapshots();
  }

  Future<void> addTodo(Todo todo) async {
    try {
      await _todosRef.add(todo);
    } catch (e) {
      print("Error adding todo: $e");
    }
  }

  Future<void> updateTodo(String todoId, Todo todo) async {
    try {
      await _todosRef.doc(todoId).update(todo.toJson());
    } catch (e) {
      print("Error updating todo: $e");
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await _todosRef.doc(todoId).delete();
    } catch (e) {
      print("Error deleting todo: $e");
    }
  }
}
