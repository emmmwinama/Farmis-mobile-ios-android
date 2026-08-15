import '../../core/api/api_client.dart';
import '../../models/team_member.dart';

class TeamRepository {
  Future<TeamData> getTeam() async {
    final response = await ApiClient.get('/mobile/team');
    return TeamData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> inviteMember({
    required String email,
    String? role,
    Map<String, dynamic>? permissions,
  }) async {
    await ApiClient.post('/mobile/team', {
      'email': email,
      if (role != null) 'role': role,
      if (permissions != null) 'permissions': permissions,
    });
  }
}
