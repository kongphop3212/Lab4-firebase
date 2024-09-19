import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; // เพิ่มการนำเข้าแพ็กเกจ logger

final Logger logger = Logger(); // สร้างอินสแตนซ์ของ Logger

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDXKep4EG0xrFJUPM4U-d0Zbqm-3KdUSmU",
        authDomain: "lab4-2220e.firebaseapp.com",
        projectId: "lab4-2220e",
        storageBucket: "lab4-2220e.appspot.com",
        messagingSenderId: "741088714435",
        appId: "1:741088714435:web:ba914430013c62646e8c76",
        measurementId: "G-C7Z1KQGXDL",
      ),
    );
  } catch (e) {
    logger.e('Error initializing Firebase: $e'); // ใช้ logger แทน print
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          onPrimary: Colors.white,
          primary: Colors.teal,
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          titleMedium: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 18, color: Colors.black),
          bodySmall: TextStyle(fontSize: 16, color: Colors.black),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          labelStyle: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
      home: const TodaApp(),
    );
  }
}

class TodaApp extends StatefulWidget {
  const TodaApp({super.key});

  @override
  State<TodaApp> createState() => _TodaAppState();
}

class _TodaAppState extends State<TodaApp> {
  late TextEditingController _titleController;
  late TextEditingController _detailController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _detailController = TextEditingController();
  }

  Future<void> _addTodoToFirestore(String title, String detail) async {
    try {
      await FirebaseFirestore.instance.collection('todos').add({
        'หัวข้อ': title,
        'รายละเอียด': detail,
      });
    } catch (e) {
      logger.e('Error adding todo: $e'); // ใช้ logger แทน print
    }
  }

  Future<void> _updateTodoInFirestore(String docId, String title, String detail) async {
    try {
      await FirebaseFirestore.instance.collection('todos').doc(docId).update({
        'หัวข้อ': title,
        'รายละเอียด': detail,
      });
    } catch (e) {
      logger.e('Error updating todo: $e'); // ใช้ logger แทน print
    }
  }

  Future<void> _deleteTodoFromFirestore(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('todos').doc(docId).delete();
    } catch (e) {
      logger.e('Error deleting todo: $e'); // ใช้ logger แทน print
    }
  }

  void addTodoHandle(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("เพิ่มรายการใหม่"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "ชื่อหัวข้อ"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _detailController,
                decoration: const InputDecoration(labelText: "รายละเอียด"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final title = _titleController.text;
                final detail = _detailController.text;
                _titleController.clear();
                _detailController.clear();

                if (mounted) {
                  Navigator.pop(context);
                }

                // บันทึกข้อมูลลง Firestore
                await _addTodoToFirestore(title, detail);
              },
              child: const Text("บันทึก"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("ยกเลิก"),
            ),
          ],
        );
      },
    );
  }

  void editTodoHandle(BuildContext context, String docId, String currentTitle, String currentDetail) {
    _titleController.text = currentTitle;
    _detailController.text = currentDetail;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("แก้ไขรายการ"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "ชื่อหัวข้อ"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _detailController,
                decoration: const InputDecoration(labelText: "รายละเอียด"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final title = _titleController.text;
                final detail = _detailController.text;
                _titleController.clear();
                _detailController.clear();

                if (mounted) {
                  Navigator.pop(context);
                }

                // อัปเดตข้อมูลใน Firestore
                await _updateTodoInFirestore(docId, title, detail);
              },
              child: const Text("บันทึก"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("ยกเลิก"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "List of Todo",
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('todos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('ยังไม่มีรายการ', style: TextStyle(color: Colors.black)));
          }

          final todos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              final docId = todo.id;
              final title = todo['หัวข้อ'];
              final detail = todo['รายละเอียด'];

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  border: Border.all(color: Colors.teal, width: 1),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    detail,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  tileColor: Colors.teal,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          editTodoHandle(context, docId, title, detail);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          _deleteTodoFromFirestore(docId);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addTodoHandle(context);
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.teal),
      ),
    );
  }
}
