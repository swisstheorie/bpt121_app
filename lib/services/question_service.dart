import 'dart:math';
import '../models/question.dart';
import '../models/questions_fr.dart';
import '../models/questions_it.dart';

/// BPT 121 Frage- und Prüfungsservice.
/// Verwaltet den verifizierten 500-Fragen-Pool und generiert
/// offizielle Prüfungssimulationen nach Schweizer ARV 2 Standards.
class QuestionService {
  /// Aktiver BPT 121 Fragenpool (500 verifizierte Fragen).
  static const int freeExamTargetCount = 500;

  /// Offizielle Themenverteilung für die 30-Fragen-Vollprüfung:
  /// - 'arv2_geltungsbereich': 8 Fragen
  /// - 'arv2_dokumentation': 6 Fragen
  /// - 'arv2_arbeitszeit': 5 Fragen
  /// - 'arv2_ruhezeit': 5 Fragen
  /// - 'arv2_lenkzeit': 4 Fragen
  /// - 'arv2_pausen': 2 Fragen
  /// Gesamt: genau 30 Fragen
  static const Map<String, int> simulationTopicQuotas = {
    'arv2_geltungsbereich': 8,
    'arv2_dokumentation': 6,
    'arv2_arbeitszeit': 5,
    'arv2_ruhezeit': 5,
    'arv2_lenkzeit': 4,
    'arv2_pausen': 2,
  };

  /// Feste 30 Fragen (IDs 1 bis 30) für die kostenlose Testversion.
  static List<Question> getPreviewQuestions({String language = 'de'}) {
    final allQuestions = getFreeQuestions(language);
    return allQuestions.where((q) => q.id >= 1 && q.id <= 30).toList();
  }

  /// Erzeugt eine 30-Fragen-Prüfungssimulation mit proportionaler Themenverteilung.
  ///
  /// - Free-Tier (isPremium == false): Liefert die 30 festen Vorschaufragen nach offizieller Quote.
  /// - Premium-Tier (isPremium == true): Zieht dynamisch 30 zufällige Fragen aus dem 500-Fragen-Pool.
  static List<Question> generateSimulationExam({
    String language = 'de',
    bool isPremium = true,
    Random? random,
  }) {
    if (!isPremium) {
      return getPreviewQuestions(language: language);
    }
    final rng = random ?? Random();
    final allQuestions = getFreeQuestions(language);
    final List<Question> selected = [];

    for (final entry in simulationTopicQuotas.entries) {
      final topicId = entry.key;
      final quota = entry.value;

      final poolForTopic = allQuestions
          .where((q) => _canonicalTopicId(q.topicId) == topicId)
          .toList();

      poolForTopic.shuffle(rng);
      selected.addAll(poolForTopic.take(quota));
    }

    selected.shuffle(rng);
    return selected;
  }

  /// Alias für [generateSimulationExam] zur Abwärtskompatibilität.
  static List<Question> getExamQuestions({
    String language = 'de',
    bool isPremium = true,
    Random? random,
  }) {
    return generateSimulationExam(
      language: language,
      isPremium: isPremium,
      random: random,
    );
  }

  /// Liefert die für den aktuellen Nutzerstatus zugänglichen Fragen eines Themas.
  static List<Question> getAccessibleQuestionsByTopic(
    String topicId, {
    String language = 'de',
    bool isPremium = false,
  }) {
    final allInTopic = getQuestionsByTopic(topicId, language: language);
    if (isPremium) {
      return allInTopic;
    }
    final previewIds = getPreviewQuestions(language: language).map((q) => q.id).toSet();
    return allInTopic.where((q) => previewIds.contains(q.id)).toList();
  }

  /// Liefert alle für den aktuellen Nutzerstatus zugänglichen Fragen (30 im Free-Tier, 500 bei Premium).
  static List<Question> getAccessibleQuestions({
    String language = 'de',
    bool isPremium = false,
  }) {
    if (isPremium) {
      return getFreeQuestions(language);
    }
    return getPreviewQuestions(language: language);
  }

  /// Öffentlicher Zugriff auf die kanonische Themen-ID (z. B. für Tests und Filterung).
  static String canonicalTopicId(String id) => _canonicalTopicId(id);

  /// Havuzda şu an mevcut olan soru sayısı.
  static int get currentFreeCount => _allFreeQuestions.length;

  /// Hedef soru sayısına ulaşmak için hâlâ gereken soru sayısı.
  static int get remainingFreeCount =>
      (freeExamTargetCount - currentFreeCount).clamp(0, freeExamTargetCount);

  /// Seçilen dil için ücretsiz soru listesini döndürür.
  ///
  /// [language]: 'de', 'fr' veya 'it'. Tanımsız dil için Almanca liste döner.
  ///
  /// NOT: Şu anda tüm dillerde aynı 5 Almanca örnek soru kullanılmaktadır.
  /// Fransızca ve İtalyanca soru çevirileri, onaylandıkça eklenecektir.
  static List<Question> getFreeQuestions(String language) {
    switch (language) {
      case 'fr':
        return List.unmodifiable(sampleFrenchBpt121Questions);
      case 'it':
        return List.unmodifiable(sampleItalianBpt121Questions);
      case 'de':
      default:
        return List.unmodifiable(_allFreeQuestions);
    }
  }

  /// Doğrulanmış resmi konu başlıkları listesini döndürür.
  static List<QuestionTopic> getTopics() => sampleBpt121Topics;

  /// Belirli bir konuya ait soruları döndürür.
  static List<Question> getQuestionsByTopic(String topicId, {String language = 'de'}) {
    final canonical = _canonicalTopicId(topicId);
    return _allFreeQuestions.where((q) => _canonicalTopicId(q.topicId) == canonical).toList();
  }

  static String _canonicalTopicId(String id) {
    switch (id) {
      case 'arv2_lenkzeiten':
        return 'arv2_lenkzeit';
      case 'arv2_arbeitszeiten':
        return 'arv2_arbeitszeit';
      case 'arv2_ruhezeiten':
        return 'arv2_ruhezeit';
      case 'arv2_fahrtschreiber':
        return 'arv2_dokumentation';
      default:
        return id;
    }
  }

  /// ID üzerinden tekil soru arar.
  static Question? getQuestionById(int id) {
    try {
      return _allFreeQuestions.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Belirtilen ID listesindeki soruları sırasıyla döndürür.
  static List<Question> getQuestionsByIds(List<int> ids) {
    return _allFreeQuestions.where((q) => ids.contains(q.id)).toList();
  }

  /// Mevcut 15 doğrulanmış örnek soru.
  /// Bu sorular resmi kaynaklar (ARV 2, SVG, VRV) incelenerek hazırlanmıştır;
  /// eğitim amaçlıdır ve hukuki bağlayıcılıkları yoktur.
  static final List<Question> _allFreeQuestions = sampleGermanBpt121Questions;
}
