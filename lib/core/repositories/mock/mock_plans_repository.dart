import '../../models/credit_cost.dart';
import '../../models/plan.dart';
import '../../models/subscription.dart';
import '../plans_repository.dart';

class MockPlansRepository implements PlansRepository {
  Subscription _subscription = const Subscription(
    hasActiveSubscription: false,
    message: "You don't have an active plan",
    planName: null,
  );

  final List<Plan> _plans = const [
    Plan(
      name: "Starter",
      credits: 60,
      isUnlimited: false,
      details: [
        "AI Writing feedback",
        "AI Speaking feedback",
        "Basic analytics",
      ],
    ),
    Plan(
      name: "Pro",
      credits: 200,
      isUnlimited: false,
      details: [
        "Everything in Starter",
        "Smart Tests access",
        "Advanced analytics",
      ],
    ),
    Plan(
      name: "Elite",
      credits: 0,
      isUnlimited: true,
      details: [
        "Unlimited credits",
        "Priority AI feedback",
        "Full dashboard",
      ],
    ),
    Plan(
      name: "Team",
      credits: 0,
      isUnlimited: true,
      details: [
        "Team seats",
        "Admin controls",
        "Priority support",
      ],
    ),
  ];

  final List<CreditCost> _creditCosts = const [
    CreditCost(feature: "Writing Feedback", creditsRequired: 3),
    CreditCost(feature: "Speaking Feedback", creditsRequired: 2),
    CreditCost(feature: "Smart Test (Full)", creditsRequired: 5),
    CreditCost(feature: "Reading Check", creditsRequired: 1),
    CreditCost(feature: "Listening Check", creditsRequired: 1),
  ];

  @override
  Future<Subscription> fetchSubscription() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _subscription;
  }

  @override
  Future<List<Plan>> fetchPlans() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _plans;
  }

  @override
  Future<List<CreditCost>> fetchCreditCosts() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _creditCosts;
  }

  @override
  Future<void> startFreeTrial() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _subscription = const Subscription(
      hasActiveSubscription: true,
      message: "Free Trial Activated",
      planName: "Trial",
    );
  }
}
