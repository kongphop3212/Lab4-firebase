import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          onPrimary: Colors.white, // ใช้สีขาวสำหรับข้อความที่อยู่บนพื้นหลังสีหลัก
          primary: Colors.teal, // สีหลัก
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          titleMedium: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black), // สีของหัวข้อ
          bodyMedium: TextStyle(fontSize: 18, color: Colors.black), // สีของตัวหนังสือหลัก
          bodySmall: TextStyle(fontSize: 16, color: Colors.black), // สีของตัวหนังสือขนาดเล็ก
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          labelStyle: TextStyle(fontSize: 16, color: Colors.black), // สีของข้อความใน TextField
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
  final List<Map<String, String>> _myList = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _detailController = TextEditingController();
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
              onPressed: () {
                setState(() {
                  _myList.add({
                    'หัวข้อ': _titleController.text,
                    'รายละเอียด': _detailController.text
                  });
                });
                _titleController.clear();
                _detailController.clear();
                Navigator.pop(context);
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

  void editTodoHandle(BuildContext context, int index) {
    _titleController.text = _myList[index]['หัวข้อ']!;
    _detailController.text = _myList[index]['รายละเอียด']!;

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
              onPressed: () {
                setState(() {
                  _myList[index] = {
                    'หัวข้อ': _titleController.text,
                    'รายละเอียด': _detailController.text
                  };
                });
                _titleController.clear();
                _detailController.clear();
                Navigator.pop(context);
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

  void deleteTodoHandle(int index) {
    setState(() {
      _myList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "รายการ",
          style: TextStyle(fontSize: 24, color: Colors.black), // สีของหัวข้อ AppBar
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary), // สีของตัวหนังสือใน AppBar
      ),
      body: _myList.isEmpty
          ? const Center(child: Text('ยังไม่มีรายการ', style: TextStyle(color: Colors.black))) // สีดำ
          : ListView.builder(
              itemCount: _myList.length,
              itemBuilder: (context, index) {
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
                      _myList[index]['หัวข้อ']!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // สีของตัวหนังสือใน ListTile
                      ),
                    ),
                    subtitle: Text(
                      _myList[index]['รายละเอียด']!,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    tileColor: Colors.teal,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            editTodoHandle(context, index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () {
                            deleteTodoHandle(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addTodoHandle(context);
        },
        backgroundColor: Colors.white, // สีพื้นหลังของปุ่มบวก
        child: const Icon(Icons.add, color: Colors.teal), // สีของไอคอนปุ่มบวก
      ),
    );
  }
}
