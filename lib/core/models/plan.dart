class Plan {
  const Plan({
    required this.name,
    required this.credits,
    required this.isUnlimited,
    required this.details,
  });

  final String name;
  final int credits;
  final bool isUnlimited;
  final List<String> details;
}
