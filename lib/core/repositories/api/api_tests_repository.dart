import '../../config/api_config.dart';
import '../../models/smart_test.dart';
import '../../../api_client.dart';
import '../tests_repository.dart';

class ApiTestsRepository implements TestsRepository {
  ApiTestsRepository({ApiClient? api})
      : _api = api ?? ApiClient(baseUrl: ApiConfig.apiBaseUrl);

  // ignore: unused_field
  final ApiClient _api;

  @override
  Future<List<SmartTest>> fetchSmartTests() async {
    // TODO: Replace with real API call + parsing.
    throw UnimplementedError("fetchSmartTests is not wired yet.");
  }
}
