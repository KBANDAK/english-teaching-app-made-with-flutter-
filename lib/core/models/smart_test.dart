class SmartTest {
  const SmartTest({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationMin,
    required this.progress,
  });

  final int id;
  final String title;
  final String subtitle;
  final int durationMin;
  final int progress; // 0..100
}
