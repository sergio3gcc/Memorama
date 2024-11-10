import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido a Memorama',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => GameScreen(pairs: 8),
                  ),
                );
              },
              child: Text('Fácil (8 pares)'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => GameScreen(pairs: 10),
                  ),
                );
              },
              child: Text('Intermedio (10 pares)'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => GameScreen(pairs: 12),
                  ),
                );
              },
              child: Text('Difícil (12 pares)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LeaderboardScreen(),
                  ),
                );
              },
              child: Text('Mejores Tiempos'),
            ),
          ],
        ),
      ),
    );
  }
}
