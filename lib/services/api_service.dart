import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://v3.football.api-sports.io';
  static const Map<String, String> _headers = {
    'X-RapidAPI-Key': '8fb1ad15c6541eca62d7925e38da6a4d',
    'X-RapidAPI-Host': 'v3.football.api-sports.io',
  };

  static Future<Map<String, dynamic>?> getPlayerDetails(int playerId) async {
    final url = Uri.parse('$_baseUrl/players?id=$playerId&season=2023');
    final resp = await http.get(url, headers: _headers);
    print('Player URL: $url => ${resp.statusCode}');
    print('Body: ${resp.body}');
    final data = json.decode(resp.body);
    if (data['results'] == 0) return null;
    return data['response'][0];
  }

  static Future<Map<String, dynamic>?> getTeamDetails(int teamId) async {
    final url = Uri.parse('$_baseUrl/teams?id=$teamId');
    final resp = await http.get(url, headers: _headers);
    final data = json.decode(resp.body);
    if (data['results'] == 0) return null;

    final team = data['response'][0]['team'];
    final country = team['country'];

    final Map<String, String> countryFlagMap = {
      'France': 'https://media.api-sports.io/flags/fr.svg',
      'Spain': 'https://media.api-sports.io/flags/es.svg',
      'Germany': 'https://media.api-sports.io/flags/de.svg',
      'England': 'https://media.api-sports.io/flags/gb.svg',
      'Portugal': 'https://media.api-sports.io/flags/pt.svg',
      'USA': 'https://media.api-sports.io/flags/us.svg',
      'Argentina': 'https://media.api-sports.io/flags/ar.svg',
      'Saudi-Arabia': 'https://media.api-sports.io/flags/sa.svg',
    };

    return {
      'name': team['name'],
      'country': country,
      'countryFlag': countryFlagMap[country],
    };
  }
}
