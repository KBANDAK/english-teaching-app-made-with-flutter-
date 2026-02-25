class ProgressStats {
  const ProgressStats({
    required this.accuracy,
    required this.totalCorrect,
    required this.levelScores,
  });

  final double accuracy; // 0..1
  final int totalCorrect;
  final Map<String, double> levelScores;

  static const empty = ProgressStats(
    accuracy: 0,
    totalCorrect: 0,
    levelScores: {},
  );

  ProgressStats copyWith({
    double? accuracy,
    int? totalCorrect,
    Map<String, double>? levelScores,
  }) {
    return ProgressStats(
      accuracy: accuracy ?? this.accuracy,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      levelScores: levelScores ?? this.levelScores,
    );
  }
}
