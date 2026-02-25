import '../models/progress_stats.dart';
import '../models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> fetchProfile();
  Future<ProgressStats> fetchProgress();
  Future<void> updateProfile({required String email, required String phone});
  Future<void> changePassword({required String newPassword});
}
