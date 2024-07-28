import 'package:flutter/material.dart';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Mood {
  final int id;
  final double tiredness;
  final double tension;
  final String comment;

  const Mood({
    required this.id,
    required this.tiredness,
    required this.tension,
    required this.comment,
  });

  Map<String, Object?> toMap(newEntry) {
    Map<String, dynamic> map = {
      'tiredness': tiredness,
      'tension': tension,
      'comment': comment,
    };
    if (!newEntry) {
      map['id'] = id;
    }
    return map;
  }

  static Mood fromMap(item) {
    return Mood(
      id: item['id'],
      tiredness: item['tiredness'].toDouble(),
      tension: item['tension'].toDouble(),
      comment: item['comment'],
    );
  }

  @override
  String toString() {
    return 'Mood{id: $id, comment: $comment, tiredness: $tiredness, tension: $tension}';
  }
}

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  static String moodTable = 'mood';
  static String moodComment = 'comment';
  static String moodTiredness = 'tiredness';
  static String moodTension = 'tension';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'mood_database.db'),
      onCreate: _createTable,
      version: 1,
    );
  }

  void _createTable(Database db, int newVersion) async {
    if (_database == null) {
      await db.execute(
          'CREATE TABLE $moodTable (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $moodComment TEXT, $moodTiredness NUMERIC, $moodTension NUMERIC)');
    }
  }

  Future<void> insertMood(Mood mood) async {
    final Database db = await database;

    await db.insert(
      moodTable,
      mood.toMap(true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Mood>> getMood() async {
    Database db = await database;

    List result = await db.rawQuery("SELECT * FROM $moodTable;");

    return result.map((item) => Mood.fromMap(item)).toList();
  }
}

void main() async {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const StartPage(title: ''),
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key, required this.title});

  final String title;

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final TextEditingController _commentController = TextEditingController();
  double _tensionSliderValue = 50;
  double _tiredNessSliderValue = 50;

  DatabaseHelper helper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final helper = DatabaseHelper();
          final mood = Mood(
            id: 0,
            tension: _tensionSliderValue,
            tiredness: _tiredNessSliderValue,
            comment: _commentController.text,
          );
          helper.insertMood(mood);

          setState(() {
            _tensionSliderValue = 50;
            _tiredNessSliderValue = 50;
          });
          _commentController.text = '';
        },
        tooltip: 'Extended',
        icon: const Icon(Icons.add),
        label: const Text('save'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [getTensionSlider(), getTirednessSlider()],
              ),
              getComment(),
              getMoodList(),
            ],
          ),
        ),
      ),
    );
  }

  Padding getComment() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 42),
      child: TextField(
        controller: _commentController,
        minLines: 3,
        maxLines: 6,
        decoration: const InputDecoration(
          labelText: 'comment',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Column getTirednessSlider() {
    return Column(
      children: [
        const Text("Tiredness"),
        SizedBox(
          height: 450,
          child: RotatedBox(
            quarterTurns: -1,
            child: SliderTheme(
              data: const SliderThemeData(
                trackHeight: 15,
              ),
              child: Slider(
                min: 0,
                max: 100,
                divisions: 20,
                label: _tiredNessSliderValue.round().toString(),
                value: _tiredNessSliderValue,
                onChanged: (double value) {
                  setState(() {
                    _tiredNessSliderValue = value;
                  });
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Column getTensionSlider() {
    return Column(children: [
      const Text("Tension"),
      SizedBox(
        height: 450,
        child: RotatedBox(
          quarterTurns: -1,
          child: SliderTheme(
            data: const SliderThemeData(
              trackHeight: 15,
            ),
            child: Slider(
              min: 0,
              max: 100,
              divisions: 20,
              label: _tensionSliderValue.round().toString(),
              value: _tensionSliderValue,
              onChanged: (double value) {
                setState(() {
                  _tensionSliderValue = value;
                });
              },
            ),
          ),
        ),
      ),
    ]);
  }

  SizedBox getMoodList() {
    return SizedBox(
      height: 500,
      child: FutureBuilder<List<Mood>?>(
        future: DatabaseHelper().getMood(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Text(snapshot.data?[index].toString() ?? "got null");
              },
            );
          } else {
            return const Text("no result");
          }
        },
      ),
    );
  }
}
