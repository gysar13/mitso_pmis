import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'appointments/appointments.dart';
import 'contacts/contacts.dart';
import 'notes/notes.dart';
import 'tasks/tasks.dart';
import 'appointments/appointmentsModel.dart';
import 'contacts/contactsModel.dart';
import 'notes/notesModel.dart';
import 'tasks/tasksModel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    databaseFactory = databaseFactoryFfi;
  }

  await _initializeDatabase();

  runApp(MyApp());
}

Future<void> _initializeDatabase() async {
  await openDatabase('appointments.db', version: 1, onCreate: (db, version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        date TEXT
      )''');
  });

  await openDatabase('contacts.db', version: 1, onCreate: (db, version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        email TEXT
      )''');
  });

  await openDatabase('notes.db', version: 1, onCreate: (db, version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT
      )''');
  });

  await openDatabase('tasks.db', version: 1, onCreate: (db, version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        due_date TEXT
      )''');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Information Manager',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[200],
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppointmentsModel>(
      model: AppointmentsModel(),
      child: ScopedModel<ContactsModel>(
        model: ContactsModel(),
        child: ScopedModel<NotesModel>(
          model: NotesModel(),
          child: ScopedModel<TasksModel>(
            model: TasksModel(),
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Personal Organizer'),
                centerTitle: true,
                backgroundColor: Colors.indigo,
              ),
              body: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(context, 'Appointments', Icons.calendar_today, Appointments()),
                  _buildFeatureCard(context, 'Contacts', Icons.contacts, Contacts()),
                  _buildFeatureCard(context, 'Notes', Icons.note, Notes()),
                  _buildFeatureCard(context, 'Tasks', Icons.task, Tasks()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.indigo),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
