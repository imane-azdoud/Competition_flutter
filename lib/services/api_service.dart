import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/player.dart';
import '../models/team.dart';

class ApiService {
  static const String _baseUrl = 'https://sofascore.p.rapidapi.com';
  static const String _apiKey =
      'deb58bcb41mshfef47822891cddfp1ece37jsn56b0573d58ac';
  static const String _apiHost = 'sofascore.p.rapidapi.com';

  static Map<String, String> get _headers => {
        'x-rapidapi-key': _apiKey,
        'x-rapidapi-host': _apiHost,
      };

  // Get tournaments list
  static Future<List<Tournament>> getTournamentsList() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/tournaments/list',
        ).replace(queryParameters: {'categoryId': '1'}),
        headers: _headers,
      );

      print('Tournaments API status: \\${response.statusCode}');
      print('Tournaments API body: \\${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null || data['groups'] == null) {
          print('No groups found in tournaments response');
          return [];
        }
        final groups = data['groups'] as List?;
        final tournaments = <Tournament>[];
        if (groups != null) {
          for (var group in groups) {
            final uniqueTournaments = group['uniqueTournaments'] as List?;
            if (uniqueTournaments != null) {
              for (var tournament in uniqueTournaments) {
                tournaments.add(Tournament.fromJson(tournament));
              }
            }
          }
        }
        // Return first 10 tournaments
        return tournaments.take(10).toList();
      } else {
        throw Exception(
          'Failed to get tournaments list: \\${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getTournamentsList: $e');
      throw Exception('Error getting tournaments list: $e');
    }
  }

  // Get the current seasonId for a tournament using /tournaments/get-seasons
  static Future<int?> getTournamentCurrentSeasonId(int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/tournaments/get-seasons',
        ).replace(queryParameters: {'tournamentId': tournamentId.toString()}),
        headers: _headers,
      );

      print(
        'Get-seasons API status for tournamentId=$tournamentId: \\${response.statusCode}',
      );
      print(
        'Get-seasons API body for tournamentId=$tournamentId: \\${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final seasons = data['seasons'] as List?;
        if (seasons != null && seasons.isNotEmpty) {
          final seasonId = seasons.first['id'];
          print(
            '  Found season id=\\${seasonId} for tournamentId=\\${tournamentId}',
          );
          return seasonId;
        } else {
          print('  No seasons found for tournamentId=\\${tournamentId}');
        }
      }
      return null;
    } catch (e) {
      print('Error getting tournament seasons: $e');
      return null;
    }
  }

  // Get tournament top teams
  static Future<List<TournamentTopTeam>> getTournamentTopTeams(
    int tournamentId,
    int seasonId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tournaments/get-top-teams').replace(
          queryParameters: {
            'tournamentId': tournamentId.toString(),
            'seasonId': seasonId.toString(),
            'type': 'total',
          },
        ),
        headers: _headers,
      );

      print(
        'Top teams API status for tournamentId=$tournamentId, seasonId=$seasonId: \\${response.statusCode}',
      );
      print(
        'Top teams API body for tournamentId=$tournamentId, seasonId=$seasonId: \\${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if data is null
        if (data == null) {
          print(
            '  Top teams API returned null data for tournamentId=$tournamentId',
          );
          return [];
        }

        // Check if topTeams field exists and is not null
        if (data['topTeams'] == null) {
          print(
            '  No topTeams field found in response for tournamentId=$tournamentId',
          );
          return [];
        }

        final topTeams = data['topTeams'] as Map<String, dynamic>?;
        if (topTeams == null) {
          print('  topTeams is null for tournamentId=$tournamentId');
          return [];
        }

        // Check if avgRating field exists and is not null
        if (topTeams['avgRating'] == null) {
          print(
            '  No avgRating field found in topTeams for tournamentId=$tournamentId',
          );
          return [];
        }

        final avgRatingTeams = topTeams['avgRating'] as List?;
        if (avgRatingTeams == null) {
          print('  avgRating is null for tournamentId=$tournamentId');
          return [];
        }

        print(
          '  Found \\${avgRatingTeams.length} teams in avgRating for tournamentId=$tournamentId',
        );

        return avgRatingTeams.map((teamData) {
          return TournamentTopTeam.fromJson(teamData);
        }).toList();
      } else {
        print('  Top teams API failed with status: \\${response.statusCode}');
        throw Exception(
          'Failed to get tournament top teams: \\${response.statusCode}',
        );
      }
    } catch (e) {
      print('  Error in getTournamentTopTeams: $e');
      throw Exception('Error getting tournament top teams: $e');
    }
  }

  // Search players
  static Future<List<Player>> searchPlayers(String name) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/players/search',
        ).replace(queryParameters: {'name': name}),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final players = data['players'] as List;
        return players.map((player) => Player.fromJson(player)).toList();
      } else {
        throw Exception('Failed to search players: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching players: $e');
    }
  }

  // Get player details
  static Future<Player> getPlayerDetails(int playerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/players/$playerId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Player.fromJson(data['player']);
      } else {
        throw Exception('Failed to get player details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting player details: $e');
    }
  }

  // Search teams
  static Future<List<TeamModel>> searchTeams(String name) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/teams/search',
        ).replace(queryParameters: {'name': name}),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final teams = data['teams'] as List;
        return teams.map((team) => TeamModel.fromJson(team)).toList();
      } else {
        throw Exception('Failed to search teams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching teams: $e');
    }
  }

  // Get team details (with stadium/venue coordinates)
  static Future<TeamModel> getTeamDetails(int teamId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/teams/detail',
        ).replace(queryParameters: {'teamId': teamId.toString()}),
        headers: _headers,
      );

      print(
        'Team detail API status for teamId=$teamId: \\${response.statusCode}',
      );
      print('Team detail API body for teamId=$teamId: \\${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if data is null
        if (data == null) {
          print('  Team detail API returned null data for teamId=$teamId');
          throw Exception('Team detail API returned null data');
        }

        // Check if team field exists
        if (data['team'] == null) {
          print('  No team field found in response for teamId=$teamId');
          throw Exception('No team field found in response');
        }

        return TeamModel.fromJson(data['team']);
      } else {
        print('  Team detail API failed with status: \\${response.statusCode}');
        throw Exception('Failed to get team details: \\${response.statusCode}');
      }
    } catch (e) {
      print('  Error in getTeamDetails: $e');
      throw Exception('Error getting team details: $e');
    }
  }

  // Search tournaments
  static Future<List<Tournament>> searchTournaments(String name) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/tournaments/search',
        ).replace(queryParameters: {'name': name}),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tournaments = data['uniqueTournaments'] as List;
        return tournaments
            .map((tournament) => Tournament.fromJson(tournament))
            .toList();
      } else {
        throw Exception('Failed to search tournaments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching tournaments: $e');
    }
  }

  // Get tournament details
  static Future<Tournament> getTournamentDetails(int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tournaments/$tournamentId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Tournament.fromJson(data['tournament']);
      } else {
        throw Exception(
          'Failed to get tournament details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting tournament details: $e');
    }
  }

  // Get team squad
  static Future<List<Player>> getTeamSquad(int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/teams/$teamId/players'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final players = data['players'] as List;
        return players.map((player) => Player.fromJson(player)).toList();
      } else {
        throw Exception('Failed to get team squad: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting team squad: $e');
    }
  }
}
