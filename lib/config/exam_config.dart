/// Schweizerische BPT 121 Prüfungs-Konfiguration & Parameter.
///
/// RECHTS- UND AUSBILDUNGSQUELLEN:
/// - asa (Vereinigung der Strassenverkehrsämter): Richtlinien zur theoretischen
///   Führerprüfung für den berufsmässigen Personentransport (BPT 121 / Taxi).
/// - ARV 2 (SR 822.222): Verordnung über die Arbeits- und Ruhezeit der berufsmässigen
///   Führer von leichten Personentransportfahrzeugen und schweren Personenwagen.
/// - SVG (SR 741.01): Strassenverkehrsgesetz der Schweizerischen Eidgenossenschaft.
/// - VRV (SR 741.11): Verkehrsregelverordnung.
///
/// OFFIZIELLER SCHWEIZER STANDARD:
/// - 30 Fragen (Multiple-Choice mit je 3 Antwortoptionen A, B, C)
/// - 45 Minuten Zeitdauer
/// - Bestehensgrenze: Mindestens 27 richtige Antworten (maximal 3 Fehler bzw. 90%)
///
/// KURZSIMULATION (Kompakttraining für den aktuellen 15-Fragen-Pool):
/// - 15 Fragen
/// - 22 Minuten Zeitdauer
/// - Realistische Bedingungen: Countdown-Timer, Vor/Zurück-Navigation,
///   keine Live-Auflösung während der Prüfung, Erfassung von unbeantworteten Fragen.
/// - Das Ergebnis der Kurzsimulation gilt als Trainingsstand und stellt
///   kein offizielles Bestehensurteil dar.
class ExamConfig {
  // ==========================================
  // Offizielle Vollprüfung (asa / ARV 2 Standard)
  // ==========================================
  static const int fullExamQuestionCount = 30;
  static const int fullExamDurationMinutes = 45;
  static const int fullExamDurationSeconds = fullExamDurationMinutes * 60; // 2700 s
  static const int fullExamMinCorrect = 27;
  static const int fullExamMaxMistakes = 3;
  static const double passingPercentage = 90.0;

  // ==========================================
  // Kurzsimulation (Kompakttraining)
  // ==========================================
  static const int shortExamQuestionCount = 15;
  static const int shortExamDurationMinutes = 22;
  static const int shortExamDurationSeconds = shortExamDurationMinutes * 60; // 1320 s

  /// Vollprüfung ist nur startbar, wenn mindestens 30 unterschiedliche Fragen verfügbar sind.
  static bool canLaunchFullSimulation(int availableDistinctQuestions) {
    return availableDistinctQuestions >= fullExamQuestionCount;
  }

  /// Berechnet das Bestehenskriterium für eine Prüfung.
  /// Bei 30 Fragen gilt zwingend der offizielle Schweizer Standard (mind. 27 richtig).
  /// Bei anderen Längen wird 90% aufgerundet herangezogen.
  static int requiredPassingScore(int totalQuestions) {
    if (totalQuestions == fullExamQuestionCount) {
      return fullExamMinCorrect;
    }
    return (totalQuestions * 0.9).ceil();
  }

  /// Prüft, ob ein Ergebnis den offiziellen Bestehensstandard erfüllt.
  /// Offizielles Bestehen gilt ausschliesslich bei einer 30-Fragen-Vollprüfung mit mind. 27 Richtigen.
  static bool isOfficialExamPassed(int correctCount, int totalQuestions) {
    if (totalQuestions == fullExamQuestionCount) {
      return correctCount >= fullExamMinCorrect;
    }
    return false;
  }

  /// Allgemeine Bestehensberechnung für Test-/Lernzwecke.
  static bool isScorePassing(int correctCount, int totalQuestions) {
    return correctCount >= requiredPassingScore(totalQuestions);
  }
}
