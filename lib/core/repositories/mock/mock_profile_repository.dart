import '../../models/progress_stats.dart';
import '../../models/user_profile.dart';
import '../profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  UserProfile _profile = const UserProfile(
    username: "mohammed_abukaff",
    email: "mohammedfort1@gmail.com",
    phone: "+962775306785",
    levelCode: "C1",
    levelLabel: "Advanced",
  );

  ProgressStats _stats = const ProgressStats(
    accuracy: 0.6957,
    totalCorrect: 64,
    levelScores: {
      "A1": 67,
      "A2": 0,
      "B1": 92,
      "B1+": 0,
      "B2": 0,
      "B2+": 0,
      "C1": 64,
    },
  );

  @override
  Future<UserProfile> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _profile;
  }

  @override
  Future<ProgressStats> fetchProgress() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _stats;
  }

  @override
  Future<void> updateProfile({required String email, required String phone}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _profile = _profile.copyWith(email: email, phone: phone);
  }

  @override
  Future<void> changePassword({required String newPassword}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
