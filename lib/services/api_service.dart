import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api-football-v1.p.rapidapi.com/v3';
  static const Map<String, String> _headers = {
    'x-rapidapi-key': '841a931021mshb8e199294a1a42cp15c4bbjsn9ed0c52ef22e',
    'x-rapidapi-host': 'api-football-v1.p.rapidapi.com',
  };

  static Future<Map<String, dynamic>?> getPlayerDetails(int playerId) async {
    final url = Uri.parse('$_baseUrl/players?id=$playerId&season=2023');
    final resp = await http.get(url, headers: _headers);
    print('Player URL: $url => ${resp.statusCode}');
    final data = json.decode(resp.body);
    if (data['results'] == 0 || data['response'].isEmpty) return null;
    return data['response'][0];
  }

  static Future<Map<String, dynamic>?> getTeamDetails(int teamId) async {
    final url = Uri.parse('$_baseUrl/teams?id=$teamId');
    final resp = await http.get(url, headers: _headers);
    if (resp.statusCode != 200) return null;

    final data = json.decode(resp.body);
    if (data['results'] == 0 || data['response'].isEmpty) return null;

    final team = data['response'][0]['team'];
    final country = team['country'];

    return {
      'name': team['name'],
      'country': country,
      'logo': team['logo'],
    };
  }

  static Future<List<Map<String, dynamic>>?> getTeamsInLeague(
      int leagueId, int season) async {
    final url = Uri.parse('$_baseUrl/teams?league=$leagueId&season=$season');
    final resp = await http.get(url, headers: _headers);
    if (resp.statusCode != 200) return null;

    final data = json.decode(resp.body);
    if (data['results'] == 0 || data['response'].isEmpty) return null;

    return List<Map<String, dynamic>>.from(data['response']);
  }
}
