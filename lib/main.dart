import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MoodModel(),
      child: MyApp(),
    ),
  );
}

// Mood Model - The "Brain" of our app
class MoodModel with ChangeNotifier {
  String _currentMood = 'assets/happy_emoji.jpeg';
  Color _backgroundColor = Colors.yellow;

  final Map<String, int> _moodCounts = {
    'Happy': 0,
    'Sad': 0,
    'Excited': 0,
  };

  final List<String> _moodHistory = [];

  String get currentMood => _currentMood;
  Color get backgroundColor => _backgroundColor;
  Map<String, int> get moodCounts => _moodCounts;
  List<String> get moodHistory => _moodHistory;

  void _updateMood(String mood, String asset, Color bgColor) {
    _currentMood = asset;
    _backgroundColor = bgColor;

    _moodCounts[mood] = (_moodCounts[mood] ?? 0) + 1;

    _moodHistory.insert(0, mood);
    if (_moodHistory.length > 3) {
      _moodHistory.removeLast();
    }

    notifyListeners();
  }

  void setHappy() {
    _updateMood('Happy', 'assets/happy_emoji.jpeg', Colors.yellow);
  }

  void setSad() {
    _updateMood('Sad', 'assets/sad_emoji.jpeg', Colors.blue);
  }

  void setExcited() {
    _updateMood('Excited', 'assets/excited_emoji.jpeg', Colors.orange);
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
    return Consumer<MoodModel>(
      builder: (context, moodModel, child) {
        return Scaffold(
          appBar: AppBar(title: Text('Mood Toggle Challenge')),
          backgroundColor: moodModel.backgroundColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('How are you feeling?', style: TextStyle(fontSize: 24)),
                SizedBox(height: 30),
                MoodDisplay(),
                SizedBox(height: 50),
                MoodButtons(),
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

// Widget that displays the current mood
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

// Widget with buttons to change the mood
class MoodButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            Provider.of<MoodModel>(context, listen: false).setHappy();
          },
          child: Text('Happy'),
        ),
        ElevatedButton(
          onPressed: () {
            Provider.of<MoodModel>(context, listen: false).setSad();
          },
          child: Text('Sad'),
        ),
        ElevatedButton(
          onPressed: () {
            Provider.of<MoodModel>(context, listen: false).setExcited();
          },
          child: Text('Excited'),
        ),
      ],
    );
  }
}

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

class MoodHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodModel>(
      builder: (context, moodModel, child) {
        final history = moodModel.moodHistory;
        if (history.isEmpty) {
          return Text("No history", style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic));
        }

        return Column(
          children: [
            Text("Last Three Mood History:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
