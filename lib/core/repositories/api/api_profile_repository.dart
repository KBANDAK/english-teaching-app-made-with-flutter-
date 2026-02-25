import '../../config/api_config.dart';
import '../../models/progress_stats.dart';
import '../../models/user_profile.dart';
import '../../../api_client.dart';
import '../profile_repository.dart';

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository({ApiClient? api})
      : _api = api ?? ApiClient(baseUrl: ApiConfig.apiBaseUrl);

  // ignore: unused_field
  final ApiClient _api;

  @override
  Future<UserProfile> fetchProfile() async {
    // TODO: Replace with real API call + parsing.
    throw UnimplementedError("fetchProfile is not wired yet.");
  }

  @override
  Future<ProgressStats> fetchProgress() async {
    // TODO: Replace with real API call + parsing.
    throw UnimplementedError("fetchProgress is not wired yet.");
  }

  @override
  Future<void> updateProfile({required String email, required String phone}) async {
    // TODO: Replace with real API call.
    throw UnimplementedError("updateProfile is not wired yet.");
  }

  @override
  Future<void> changePassword({required String newPassword}) async {
    // TODO: Replace with real API call.
    throw UnimplementedError("changePassword is not wired yet.");
  }
}
