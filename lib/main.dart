import 'package:flutter/material.dart';
import 'pages/favorite_players.dart';
import 'pages/favorite_teams.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> pages = [
    {'title': 'Favorite Players', 'widget': FavoritePlayersPage()},
    {'title': 'Favorite Teams', 'widget': FavoriteTeamsPage()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Football App')),
      body: ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(pages[index]['title']),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => pages[index]['widget']),
          ),
        ),
      ),
    );
  }
}
