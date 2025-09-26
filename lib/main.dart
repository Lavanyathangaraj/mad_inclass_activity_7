import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MoodModel()),
        ChangeNotifierProvider(create: (context) => ThemeModel()),
      ],
      child: MyApp(),
    ),
  );
}

// Mood Model - The "Brain" of our app
class MoodModel with ChangeNotifier {
  String _currentMood = 'assets/happy_emoji.jpeg';

  final Map<String, int> _moodCounts = {
    'Happy': 0,
    'Sad': 0,
    'Excited': 0,
  };

  final List<String> _moodHistory = [];

  String get currentMood => _currentMood;
  Map<String, int> get moodCounts => _moodCounts;
  List<String> get moodHistory => _moodHistory;

  void _updateMood(String mood, String asset, Color bgColor, BuildContext context) {
    _currentMood = asset;
    Provider.of<ThemeModel>(context, listen: false).setMoodColor(bgColor);

    _moodCounts[mood] = (_moodCounts[mood] ?? 0) + 1;

    _moodHistory.insert(0, mood);
    if (_moodHistory.length > 3) {
      _moodHistory.removeLast();
    }

    notifyListeners();
  }

  void setHappy(BuildContext context) {
    _updateMood('Happy', 'assets/happy_emoji.jpeg',
        Provider.of<ThemeModel>(context, listen: false).getColor('Happy'), context);
  }

  void setSad(BuildContext context) {
    _updateMood('Sad', 'assets/sad_emoji.jpeg',
        Provider.of<ThemeModel>(context, listen: false).getColor('Sad'), context);
  }

  void setExcited(BuildContext context) {
    _updateMood('Excited', 'assets/excited_emoji.jpeg',
        Provider.of<ThemeModel>(context, listen: false).getColor('Excited'), context);
  }

  void setRandomMood(BuildContext context) {
    final random = Random();
    int choice = random.nextInt(3);

    switch (choice) {
      case 0:
        setHappy(context);
        break;
      case 1:
        setSad(context);
        break;
      case 2:
        setExcited(context);
        break;
    }
  }
}

class ThemeModel with ChangeNotifier {
  String _mode = 'Default';
  Color _currentColor = Colors.yellow;

  final Map<String, Map<String, Color>> _modeColors = {
    'Default': {
      'Happy': Colors.yellow,
      'Sad': Colors.blue,
      'Excited': Colors.orange,
    },
    'Dark': {
      'Happy': Colors.amber.shade700,
      'Sad': Colors.blue.shade900,
      'Excited': Colors.deepOrange.shade700,
    },
    'Pastel': {
      'Happy': Colors.yellow.shade100,
      'Sad': Colors.blue.shade100,
      'Excited': Colors.orange.shade100,
    },
  };

  String get mode => _mode;
  Color get currentColor => _currentColor;

  void setMode(String mode) {
    _mode = mode;
    notifyListeners();
  }

  void setMoodColor(Color color) {
    _currentColor = color;
    notifyListeners();
  }

  Color getColor(String mood) {
    return _modeColors[_mode]?[mood] ?? Colors.grey;
  }
}

// Main App Widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Toggle Challenge',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

// Home Page
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<MoodModel, ThemeModel>(
      builder: (context, moodModel, themeModel, child) {
        return Scaffold(
          appBar: AppBar(title: Text('Mood Toggle Challenge')),
          backgroundColor: themeModel.currentColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('How are you feeling?', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                MoodDisplay(),
                SizedBox(height: 30),
                MoodButtons(),
                SizedBox(height: 20),
                ThemeSelector(),
                SizedBox(height: 30),
                MoodCounter(),
                SizedBox(height: 30),
                MoodHistory(),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Mood Display Widget
class MoodDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodModel>(
      builder: (context, moodModel, child) {
        return Image.asset(
          moodModel.currentMood,
          width: 180,
          height: 180,
          fit: BoxFit.cover,
        );
      },
    );
  }
}

// Mood Buttons
class MoodButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Provider.of<MoodModel>(context, listen: false).setHappy(context);
              },
              child: Text('Happy'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<MoodModel>(context, listen: false).setSad(context);
              },
              child: Text('Sad'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<MoodModel>(context, listen: false).setExcited(context);
              },
              child: Text('Excited'),
            ),
          ],
        ),
        SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          onPressed: () {
            Provider.of<MoodModel>(context, listen: false).setRandomMood(context);
          },
          child: Text('Random Mood', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ],
    );
  }
}

class ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Select Mode: ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(width: 10),
            DropdownButton<String>(
              value: themeModel.mode,
              items: ['Default', 'Dark', 'Pastel']
                  .map((mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(mode),
                      ))
                  .toList(),
              onChanged: (mode) {
                if (mode != null) {
                  themeModel.setMode(mode);
                }
              },
            ),
          ],
        );
      },
    );
  }
}

// Mood Counter Widget
class MoodCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodModel>(
      builder: (context, moodModel, child) {
        return Column(
          children: [
            Text("Mood Counts:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CounterCard(label: 'Happy', count: moodModel.moodCounts['Happy'] ?? 0),
                CounterCard(label: 'Sad', count: moodModel.moodCounts['Sad'] ?? 0),
                CounterCard(label: 'Excited', count: moodModel.moodCounts['Excited'] ?? 0),
              ],
            ),
          ],
        );
      },
    );
  }
}

class CounterCard extends StatelessWidget {
  final String label;
  final int count;

  const CounterCard({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Mood History Widget
class MoodHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodModel>(
      builder: (context, moodModel, child) {
        final history = moodModel.moodHistory;
        if (history.isEmpty) {
          return Text("No history yet", style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic));
        }

        return Column(
          children: [
            Text("Last three Mood History:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: history
                  .map((mood) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          mood,
                          style: TextStyle(fontSize: 18),
                        ),
                      ))
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}
