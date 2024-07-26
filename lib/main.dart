import 'package:flutter/material.dart';

void main() {
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
  double _tensionSliderValue = 50;
  double _tiredNessSliderValue = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        tooltip: 'Extended',
        icon: const Icon(Icons.add),
        label: const Text('save'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [getTensionSlider(), getTirednessSlider()],
              ),
              getComment()
            ],
          ),
        ),
      ),
    );
  }

  Padding getComment() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 42),
      child: TextField(
        keyboardType: TextInputType.multiline,
        minLines: 3, // Set this
        maxLines: 6,
        decoration: InputDecoration(
          labelText: 'comment',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Column getTirednessSlider() {
    return Column(
      children: [
        Text("Tiredness"),
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
}
