class ExamResult {
  final String id;
  final DateTime date;
  final String language;
  final int totalQuestions;
  final int correctCount;
  final int incorrectCount;
  final int unansweredCount;
  final int percentage;
  final bool isPassed;

  const ExamResult({
    required this.id,
    required this.date,
    required this.language,
    required this.totalQuestions,
    required this.correctCount,
    required this.incorrectCount,
    this.unansweredCount = 0,
    required this.percentage,
    required this.isPassed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'language': language,
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'unansweredCount': unansweredCount,
      'percentage': percentage,
      'isPassed': isPassed,
    };
  }

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    final total = json['totalQuestions'] as int;
    final correct = json['correctCount'] as int;
    final incorrect = json['incorrectCount'] as int;
    final unanswered = json['unansweredCount'] as int? ??
        (total - correct - incorrect).clamp(0, total);

    return ExamResult(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      language: json['language'] as String,
      totalQuestions: total,
      correctCount: correct,
      incorrectCount: incorrect,
      unansweredCount: unanswered,
      percentage: json['percentage'] as int,
      isPassed: json['isPassed'] as bool,
    );
  }
}

