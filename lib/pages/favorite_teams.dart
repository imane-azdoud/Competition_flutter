import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FavoriteTeamsPage extends StatelessWidget {
  final List<int> favoriteTeamIds = [541, 529, 85, 157, 40];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Équipes favorites')),
      body: ListView(
        children: favoriteTeamIds.map((id) {
          return FutureBuilder<Map<String, dynamic>?>(
            future: ApiService.getTeamDetails(id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(title: Text('Chargement équipe $id...'));
              }
              if (snapshot.hasError || snapshot.data == null) {
                return ListTile(title: Text('Erreur équipe $id'));
              }

              final team = snapshot.data!;
              return ListTile(
                leading: team['logo'] != null
                    ? Image.network(
                        team['logo'],
                        width: 40,
                        height: 40,
                        errorBuilder: (_, __, ___) => Icon(Icons.shield),
                      )
                    : Icon(Icons.shield),
                title: Text(team['name']),
                subtitle: Text(team['country']),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
