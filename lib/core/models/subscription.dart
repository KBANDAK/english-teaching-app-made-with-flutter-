class Subscription {
  const Subscription({
    required this.hasActiveSubscription,
    required this.message,
    required this.planName,
  });

  final bool hasActiveSubscription;
  final String? message;
  final String? planName;

  static const empty = Subscription(
    hasActiveSubscription: false,
    message: null,
    planName: null,
  );
}
