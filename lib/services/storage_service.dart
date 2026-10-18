import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exam_result.dart';

class StorageService {
  static const String _examHistoryKey = 'bpt121_exam_history';
  static const String _languageKey = 'bpt121_selected_language';

  /// Kullanıcının seçtiği dili ('de', 'fr', 'it') yerel olarak kaydeder.
  static Future<void> saveSelectedLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  /// Cihazda kayıtlı dil tercihini döndürür. Henüz seçim yapılmamışsa null döner (ilk açılış tespiti için).
  static Future<String?> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  /// Tamamlanan bir sınav sonucunu SharedPreferences içine JSON formatında kaydeder.
  static Future<void> saveExamResult(ExamResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final existingResults = await getExamResults();
    final updatedList = [result, ...existingResults];
    final jsonList = updatedList.map((item) => item.toJson()).toList();
    await prefs.setString(_examHistoryKey, jsonEncode(jsonList));
  }

  /// Cihazda yerel olarak saklanan tüm sınav sonuçlarını okur.
  static Future<List<ExamResult>> getExamResults() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_examHistoryKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => ExamResult.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// En son çözülen sınav sonucunu döndürür. Henüz sınav çözülmemişse null döner.
  static Future<ExamResult?> getLatestResult() async {
    final results = await getExamResults();
    if (results.isEmpty) return null;
    return results.first;
  }

  /// Tüm kayıtlı sonuçları temizler (testler ve sıfırlama için kullanılır).
  static Future<void> clearExamResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_examHistoryKey);
  }

  // ==========================================
  // LERNFORTSCHRITT & FRAGEN-STATUS
  // ==========================================
  static const String _wrongQuestionsKey = 'bpt121_wrong_question_ids';
  static const String _seenQuestionsKey = 'bpt121_seen_question_ids';
  static const String _correctQuestionsKey = 'bpt121_correct_question_ids';

  /// Gibt die IDs aller bisher mindestens einmal beantworteten Fragen zurück.
  static Future<List<int>> getSeenQuestionIds() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_seenQuestionsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => e as int).toList();
    } catch (_) {
      return [];
    }
  }

  /// Gibt die IDs aller aktuell als richtig beantwortet geltenden Fragen zurück.
  static Future<List<int>> getCorrectQuestionIds() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_correctQuestionsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => e as int).toList();
    } catch (_) {
      return [];
    }
  }

  /// Yanlış cevaplanan soru ID'lerini döndürür.
  static Future<List<int>> getWrongQuestionIds() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_wrongQuestionsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => e as int).toList();
    } catch (_) {
      return [];
    }
  }

  /// Bir soruyu yanlış sorular listesine ekler.
  static Future<void> addWrongQuestionId(int id) async {
    final list = await getWrongQuestionIds();
    if (!list.contains(id)) {
      list.add(id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_wrongQuestionsKey, jsonEncode(list));
    }
  }

  /// Bir soruyu yanlış sorular listesinden çıkarır.
  static Future<void> removeWrongQuestionId(int id) async {
    final list = await getWrongQuestionIds();
    if (list.contains(id)) {
      list.remove(id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_wrongQuestionsKey, jsonEncode(list));
    }
  }

  /// Erfasst mehrere Antworten auf einmal und aktualisiert Gesehen-, Richtig- und Falsch-Sets atomar:
  static Future<void> recordQuestionAnswers(Map<int, bool> answers) async {
    if (answers.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();

    final seen = await getSeenQuestionIds();
    final correct = await getCorrectQuestionIds();
    final wrong = await getWrongQuestionIds();

    bool seenChanged = false;
    bool correctChanged = false;
    bool wrongChanged = false;

    for (final entry in answers.entries) {
      final id = entry.key;
      final isCorrect = entry.value;

      if (!seen.contains(id)) {
        seen.add(id);
        seenChanged = true;
      }

      if (isCorrect) {
        if (!correct.contains(id)) {
          correct.add(id);
          correctChanged = true;
        }
        if (wrong.contains(id)) {
          wrong.remove(id);
          wrongChanged = true;
        }
      } else {
        if (correct.contains(id)) {
          correct.remove(id);
          correctChanged = true;
        }
        if (!wrong.contains(id)) {
          wrong.add(id);
          wrongChanged = true;
        }
      }
    }

    if (seenChanged) {
      await prefs.setString(_seenQuestionsKey, jsonEncode(seen));
    }
    if (correctChanged) {
      await prefs.setString(_correctQuestionsKey, jsonEncode(correct));
    }
    if (wrongChanged) {
      await prefs.setString(_wrongQuestionsKey, jsonEncode(wrong));
    }
  }

  /// Erfasst eine Antwort und aktualisiert sofort Gesehen-, Richtig- und Falsch-Sets:
  /// - Gesehen: Soru her halükarda görüldü olarak kaydedilir.
  /// - Richtig: Soru doğruysa doğru kümesine eklenir, yanlış kümesinden çıkarılır.
  /// - Falsch: Soru yanlışsa doğru kümesinden çıkarılır, yanlış kümesine eklenir.
  static Future<void> recordQuestionAnswer(int id, bool isCorrect) async {
    await recordQuestionAnswers({id: isCorrect});
  }

  /// Yanlış sorular listesini sıfırlar.
  static Future<void> clearWrongQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_wrongQuestionsKey);
  }

  /// Setzt den gesamten Fragen-Lernfortschritt (gesehen, richtig, falsch) zurück.
  static Future<void> clearLearningProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_seenQuestionsKey);
    await prefs.remove(_correctQuestionsKey);
    await prefs.remove(_wrongQuestionsKey);
  }

  // ==========================================
  // FAVORİLER (BOOKMARKS / FAVORITES)
  // ==========================================
  static const String _favoriteQuestionsKey = 'bpt121_favorite_question_ids';

  /// Favorilere eklenen soru ID'lerini döndürür.
  static Future<List<int>> getFavoriteQuestionIds() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_favoriteQuestionsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => e as int).toList();
    } catch (_) {
      return [];
    }
  }

  /// Sorunun favorilerde olup olmadığını kontrol eder.
  static Future<bool> isFavorite(int id) async {
    final list = await getFavoriteQuestionIds();
    return list.contains(id);
  }

  /// Sorunun favori durumunu tersine çevirir (varsa çıkarır, yoksa ekler).
  static Future<bool> toggleFavorite(int id) async {
    final list = await getFavoriteQuestionIds();
    final prefs = await SharedPreferences.getInstance();
    bool isNowFav;
    if (list.contains(id)) {
      list.remove(id);
      isNowFav = false;
    } else {
      list.add(id);
      isNowFav = true;
    }
    await prefs.setString(_favoriteQuestionsKey, jsonEncode(list));
    return isNowFav;
  }

  /// Favori durumunu doğrudan ayarlar.
  static Future<void> setFavorite(int id, bool isFav) async {
    final list = await getFavoriteQuestionIds();
    final prefs = await SharedPreferences.getInstance();
    if (isFav && !list.contains(id)) {
      list.add(id);
      await prefs.setString(_favoriteQuestionsKey, jsonEncode(list));
    } else if (!isFav && list.contains(id)) {
      list.remove(id);
      await prefs.setString(_favoriteQuestionsKey, jsonEncode(list));
    }
  }

  /// Tüm favorileri temizler.
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoriteQuestionsKey);
  }

  /// Setzt den gesamten Lernfortschritt zurück (gesehene, richtige und falsche Fragen sowie Prüfungshistorie).
  /// Behält Premium-Status, Sprache und Theme-Einstellungen bei.
  static Future<void> resetLearningProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_seenQuestionsKey);
    await prefs.remove(_correctQuestionsKey);
    await prefs.remove(_wrongQuestionsKey);
    await prefs.remove(_examHistoryKey);
  }

  // ==========================================
  // FREEMIUM / PRO STATUS
  // ==========================================
  static const String _premiumKey = 'bpt121_is_premium';

  /// Gibt zurück, ob der Nutzer die Vollversion (Premium) freigeschaltet hat (Standard: false).
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumKey) ?? false;
  }

  /// Setzt den Premium-Status (Freischaltung / Entwickler-Test).
  static Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
  }

  // ==========================================
  // ERSCHEINUNGSBILD / THEME MODE
  // ==========================================
  static const String _themeModeKey = 'bpt121_theme_mode';

  /// Gibt den gespeicherten Theme-Modus zurück ('system', 'light', 'dark').
  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey) ?? 'system';
  }

  /// Speichert den gewünschten Theme-Modus.
  static Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }

  // ==========================================
  // ONBOARDING & PRÜFUNGSHINWEIS
  // ==========================================
  static const String _disclaimerSeenKey = 'bpt121_disclaimer_seen';

  /// Gibt zurück, ob der offizielle Prüfungshinweis bereits bestätigt wurde.
  static Future<bool> hasSeenExamDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_disclaimerSeenKey) ?? false;
  }

  /// Markiert den offiziellen Prüfungshinweis als bestätigt.
  static Future<void> markExamDisclaimerSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_disclaimerSeenKey, true);
  }
}
