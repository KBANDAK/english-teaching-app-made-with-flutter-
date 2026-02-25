import '../models/credit_cost.dart';
import '../models/plan.dart';
import '../models/subscription.dart';

abstract class PlansRepository {
  Future<Subscription> fetchSubscription();
  Future<List<Plan>> fetchPlans();
  Future<List<CreditCost>> fetchCreditCosts();
  Future<void> startFreeTrial();
}
