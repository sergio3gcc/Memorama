import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'db/DatabaseHelper.dart'; // Importa DatabaseHelper
import 'splash_screen.dart'; // Asegúrate de importar la pantalla de presentación

class GameScreen extends StatefulWidget {
  final int pairs;

  GameScreen({required this.pairs});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late List<String> cardValues;
  late List<bool> cardFlipped;
  int? firstCardIndex;
  int? secondCardIndex;
  int score = 0;
  int moves = 0;
  int matches = 0;
  int seconds = 0;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    setState(() {
      List<String> emojis = [
        '❤', '👌', '😱', '👩‍🦰',
        '🎈', '🎗', '🎟', '🚕',
        '💨', '✝', '💢', '💦',
        '💫', '❌', '⭕', '❓',
      ];

      cardValues = List<String>.from(emojis.take(widget.pairs))
        ..addAll(List<String>.from(emojis.take(widget.pairs)));
      cardValues.shuffle(Random());

      cardFlipped = List<bool>.filled(cardValues.length, false);
      score = 0;
      moves = 0;
      matches = 0;
      seconds = 0;
      firstCardIndex = null;
      secondCardIndex = null;

      _timer?.cancel();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          seconds++;
        });
      });
    });
  }

  void _flipCard(int index) {
    if (cardFlipped[index] || (firstCardIndex != null && secondCardIndex != null)) return;

    setState(() {
      cardFlipped[index] = true;
      moves++;

      if (firstCardIndex == null) {
        firstCardIndex = index;
      } else {
        secondCardIndex = index;
        Future.delayed(Duration(milliseconds: 500), _checkForMatch);
      }
    });
  }

  void _checkForMatch() async {
    if (firstCardIndex != null && secondCardIndex != null) {
      if (cardValues[firstCardIndex!] == cardValues[secondCardIndex!]) {
        await _audioPlayer.play(AssetSource('sounds/matching_sound.mp3'));
        score++;
        matches++;
        firstCardIndex = null;
        secondCardIndex = null;

        if (matches == widget.pairs) {
          _timer?.cancel();
          _showWinDialog();
        }
      } else {
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            cardFlipped[firstCardIndex!] = false;
            cardFlipped[secondCardIndex!] = false;
            firstCardIndex = null;
            secondCardIndex = null;
          });
        });
      }
    }
  }

  void _showWinDialog() {
    final gameDuration = seconds;

    showDialog(
      context: context,
      builder: (context) {
        TextEditingController usernameController = TextEditingController();

        return AlertDialog(
          title: Text('¡Ganaste!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Has completado el juego en $seconds segundos.'),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Ingresa tu nombre'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final username = usernameController.text;
                if (username.isNotEmpty) {
                  await _databaseHelper.insertScore(username, widget.pairs, gameDuration);
                }
                if (mounted) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  _initializeGame();
                }
              },
              child: Text('Guardar y Reiniciar'),
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
        title: Text('Memorama'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => SplashScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aciertos: $score'),
                Text('Movimientos: $moves'),
                Text('Segundos: $seconds'),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount: cardValues.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _flipCard(index),
                  child: Card(
                    child: Center(
                      child: Text(
                        cardFlipped[index] ? cardValues[index] : '?',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _initializeGame,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
