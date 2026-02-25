import '../../config/api_config.dart';
import '../../models/credit_cost.dart';
import '../../models/plan.dart';
import '../../models/subscription.dart';
import '../../../api_client.dart';
import '../plans_repository.dart';

class ApiPlansRepository implements PlansRepository {
  ApiPlansRepository({ApiClient? api})
      : _api = api ?? ApiClient(baseUrl: ApiConfig.apiBaseUrl);

  // ignore: unused_field
  final ApiClient _api;

  @override
  Future<Subscription> fetchSubscription() async {
    // TODO: Replace with real API call + parsing.
    throw UnimplementedError("fetchSubscription is not wired yet.");
  }

  @override
  Future<List<Plan>> fetchPlans() async {
    // TODO: Replace with real API call + parsing.
    throw UnimplementedError("fetchPlans is not wired yet.");
  }

  @override
  Future<List<CreditCost>> fetchCreditCosts() async {
    // TODO: Replace with real API call + parsing.
    throw UnimplementedError("fetchCreditCosts is not wired yet.");
  }

  @override
  Future<void> startFreeTrial() async {
    // TODO: Replace with real API call.
    throw UnimplementedError("startFreeTrial is not wired yet.");
  }
}
