import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FavoritePlayersPage extends StatelessWidget {
  final List<int> favoritePlayerIds = [874, 154, 278];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Joueurs favoris')),
      body: ListView(
        children: favoritePlayerIds.map((id) {
          return FutureBuilder<Map<String, dynamic>?>(
            future: ApiService.getPlayerDetails(id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(title: Text('Chargement joueur $id...'));
              }
              if (snapshot.hasError || snapshot.data == null) {
                return ListTile(
                  title: Text('Erreur joueur $id'),
                  subtitle: Text('Impossible de charger les données'),
                  tileColor: Colors.red[100],
                );
              }

              final player = snapshot.data!['player'];
              final stats = snapshot.data!['statistics'];

              final firstStatWithPosition = stats.firstWhere(
                (s) => s['games']?['position'] != null,
                orElse: () => null,
              );

              final position = firstStatWithPosition != null
                  ? firstStatWithPosition['games']['position']
                  : 'Inconnu';

              final teamName = firstStatWithPosition != null
                  ? firstStatWithPosition['team']['name']
                  : 'Équipe inconnue';

              final goals = firstStatWithPosition?['goals']?['total'] ?? 0;
              final assists = firstStatWithPosition?['goals']?['assists'] ?? 0;

              return ListTile(
                leading: Image.network(
                  player['photo'],
                  width: 50,
                  errorBuilder: (_, __, ___) => Icon(Icons.person),
                ),
                title: Text(player['name']),
                subtitle: Text(
                    '$teamName • $position\nButs: $goals • Passes: $assists'),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
