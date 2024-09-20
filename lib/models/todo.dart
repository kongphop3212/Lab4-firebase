import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String task;
  bool isDone;
  Timestamp createdOn;
  Timestamp updatedOn;

  Todo({
    required this.task,
    required this.isDone,
    required this.createdOn,
    required this.updatedOn,
  });

  Todo.fromJson(Map<String, Object?> json)
    : this(
        task: json['task'] as String? ?? 'No Task', // กำหนดค่าเริ่มต้น
        isDone: json['isDone'] as bool? ?? false,  // กำหนดค่าเริ่มต้น
        createdOn: json['createdOn'] as Timestamp? ?? Timestamp.now(), // กำหนดค่าเริ่มต้น
        updatedOn: json['updatedOn'] as Timestamp? ?? Timestamp.now(), // กำหนดค่าเริ่มต้น
      );

  Todo copyWith({
    String? task,
    bool? isDone,
    Timestamp? createdOn,
    Timestamp? updatedOn,
  }) {
    return Todo(
        task: task ?? this.task,
        isDone: isDone ?? this.isDone,
        createdOn: createdOn ?? this.createdOn,
        updatedOn: updatedOn ?? this.updatedOn);
  }

  Map<String, Object?> toJson() {
    return {
      'task': task,
      'isDone': isDone,
      'createdOn': createdOn,
      'updatedOn': updatedOn,
    };
  }
}
