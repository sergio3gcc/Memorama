import 'package:flutter/material.dart';
import 'db/DatabaseHelper.dart'; // Asegúrate de importar tu DatabaseHelper

class LeaderboardScreen extends StatelessWidget {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> _fetchScores() async {
    return await _dbHelper.getAllScores(); // Método que definiremos en DatabaseHelper
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mejores Tiempos'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchScores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay puntajes guardados.'));
          }

          final scores = snapshot.data!;
          return ListView.builder(
            itemCount: scores.length,
            itemBuilder: (context, index) {
              final score = scores[index];
              return ListTile(
                title: Text(score['username']),
                subtitle: Text('Nivel: ${score['level']} - Tiempo: ${score['time']} segundos'),
              );
            },
          );
        },
      ),
    );
  }
}
