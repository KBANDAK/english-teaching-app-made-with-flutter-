import 'config/api_config.dart';
import 'repositories/api/api_plans_repository.dart';
import 'repositories/api/api_profile_repository.dart';
import 'repositories/api/api_tests_repository.dart';
import 'repositories/mock/mock_plans_repository.dart';
import 'repositories/mock/mock_profile_repository.dart';
import 'repositories/mock/mock_tests_repository.dart';
import 'repositories/plans_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/tests_repository.dart';

class AppServices {
  static final ProfileRepository profile = ApiConfig.useMockApi
      ? MockProfileRepository()
      : ApiProfileRepository();

  static final PlansRepository plans = ApiConfig.useMockApi
      ? MockPlansRepository()
      : ApiPlansRepository();

  static final TestsRepository tests = ApiConfig.useMockApi
      ? MockTestsRepository()
      : ApiTestsRepository();
}
