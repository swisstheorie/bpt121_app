import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bpt121_app/config/exam_config.dart';
import 'package:bpt121_app/main.dart';
import 'package:bpt121_app/models/exam_result.dart';
import 'package:bpt121_app/models/question.dart';
import 'package:bpt121_app/screens/exam_screen.dart';
import 'package:bpt121_app/services/question_service.dart';
import 'package:bpt121_app/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ExamResult model serialization and deserialization', () {
    final now = DateTime(2026, 10, 17, 14, 30);
    final result = ExamResult(
      id: 'exam_test_1',
      date: now,
      language: 'de',
      totalQuestions: 5,
      correctCount: 5,
      incorrectCount: 0,
      percentage: 100,
      isPassed: true,
    );

    final json = result.toJson();
    expect(json['id'], 'exam_test_1');
    expect(json['language'], 'de');
    expect(json['totalQuestions'], 5);
    expect(json['correctCount'], 5);
    expect(json['incorrectCount'], 0);
    expect(json['percentage'], 100);
    expect(json['isPassed'], true);

    final fromJson = ExamResult.fromJson(json);
    expect(fromJson.id, result.id);
    expect(fromJson.date, result.date);
    expect(fromJson.language, result.language);
    expect(fromJson.totalQuestions, result.totalQuestions);
    expect(fromJson.correctCount, result.correctCount);
    expect(fromJson.incorrectCount, result.incorrectCount);
    expect(fromJson.percentage, result.percentage);
    expect(fromJson.isPassed, result.isPassed);
  });

  test('StorageService saves and retrieves exam results locally', () async {
    final now = DateTime(2026, 10, 17, 14, 30);
    final result = ExamResult(
      id: 'exam_1',
      date: now,
      language: 'de',
      totalQuestions: 30,
      correctCount: 28,
      incorrectCount: 2,
      percentage: 93,
      isPassed: true,
    );

    await StorageService.saveExamResult(result);

    final savedList = await StorageService.getExamResults();
    expect(savedList.length, 1);
    expect(savedList.first.id, 'exam_1');
    expect(savedList.first.correctCount, 28);
    expect(savedList.first.isPassed, true);

    final latest = await StorageService.getLatestResult();
    expect(latest, isNotNull);
    expect(latest!.percentage, 93);
  });

  test('StorageService saves and loads selected language preference', () async {
    expect(await StorageService.getSavedLanguage(), isNull);

    await StorageService.saveSelectedLanguage('fr');
    expect(await StorageService.getSavedLanguage(), 'fr');

    await StorageService.saveSelectedLanguage('it');
    expect(await StorageService.getSavedLanguage(), 'it');
  });

  test('Pass calculation rules for 30-question exam and 5-question dev test', () {
    // 30 questions requires 27 (90%)
    expect(calculateRequiredPassingScore(30), 27);
    expect(isExamPassed(27, 30), true);
    expect(isExamPassed(26, 30), false);

    // 5 questions dev mode requires ceil(5 * 0.9) = 5 correct
    expect(calculateRequiredPassingScore(5), 5);
    expect(isExamPassed(5, 5), true);
    expect(isExamPassed(4, 5), false);

    // 15 soruluk hedef için %90 = ceil(15*0.9) = ceil(13.5) = 14 doğru gerekir
    expect(calculateRequiredPassingScore(15), 14);
    expect(isExamPassed(14, 15), true);
    expect(isExamPassed(13, 15), false);
  });

  test('QuestionService - free question pool is complete at 500 questions', () {
    // Hedef ve gerçek sayı eşit: 500
    expect(QuestionService.freeExamTargetCount, 500);
    expect(QuestionService.currentFreeCount, 500);
    expect(QuestionService.remainingFreeCount, 0);

    // DE dilinde tam 500 soru dönüyor
    final deQuestions = QuestionService.getFreeQuestions('de');
    expect(deQuestions.length, 500);
    expect(deQuestions, isA<List<Question>>());

    // Her soruda tam 3 şık var
    for (final q in deQuestions) {
      expect(q.options.length, 3,
          reason: 'Soru ${q.id} tam olarak 3 şık içermeli');
    }

    // Her sorunun correctIndex değeri 0, 1 veya 2 aralığında
    for (final q in deQuestions) {
      expect(q.correctIndex >= 0 && q.correctIndex < 3, true,
          reason:
              'Soru ${q.id} için correctIndex (${q.correctIndex}) 0-2 aralığında olmalı');
    }

    // Her sorunun id değeri benzersiz (1'den 500'e)
    final ids = deQuestions.map((q) => q.id).toSet();
    expect(ids.length, 500, reason: 'Tüm soru id değerleri benzersiz olmalı');
    expect(ids, Set.from(List.generate(500, (i) => i + 1)));

    // Cevap anahtarı kontrolü: Verilen 500 sorunun cevap anahtarları korunmuş mu
    const expectedKey = {
      1: 1, 2: 0, 3: 2, 4: 0, 5: 2, 6: 2, 7: 1, 8: 1, 9: 1, 10: 0,
      11: 1, 12: 2, 13: 1, 14: 2, 15: 1, 16: 0, 17: 2, 18: 2, 19: 1, 20: 1,
      21: 1, 22: 0, 23: 2, 24: 0, 25: 2, 26: 2, 27: 2, 28: 2, 29: 0, 30: 1,
      31: 2, 32: 1, 33: 2, 34: 0, 35: 2, 36: 1, 37: 2, 38: 0, 39: 2, 40: 2,
      41: 0, 42: 2, 43: 1, 44: 2, 45: 0, 46: 1, 47: 1, 48: 1, 49: 2, 50: 2,
      51: 2, 52: 2, 53: 1, 54: 1, 55: 1, 56: 2, 57: 0, 58: 2, 59: 0, 60: 2,
      61: 1, 62: 2, 63: 2, 64: 1, 65: 1, 66: 2, 67: 0, 68: 1, 69: 2, 70: 1,
      71: 1, 72: 1, 73: 1, 74: 0, 75: 2, 76: 0, 77: 2, 78: 1, 79: 1, 80: 2,
      81: 1, 82: 0, 83: 0, 84: 0, 85: 0, 86: 0, 87: 1, 88: 0, 89: 2, 90: 1,
      91: 2, 92: 2, 93: 1, 94: 0, 95: 2, 96: 1, 97: 0, 98: 1, 99: 0, 100: 1,
      101: 0, 102: 0, 103: 2, 104: 0, 105: 1, 106: 1, 107: 0, 108: 2, 109: 2, 110: 2,
      111: 1, 112: 1, 113: 2, 114: 1, 115: 1, 116: 1, 117: 1, 118: 2, 119: 2, 120: 1,
      121: 2, 122: 0, 123: 0, 124: 2, 125: 0, 126: 1, 127: 0, 128: 2, 129: 1, 130: 0,
      131: 1, 132: 0, 133: 2, 134: 1, 135: 1, 136: 1, 137: 1, 138: 1, 139: 1, 140: 0,
      141: 2, 142: 1, 143: 1, 144: 0, 145: 1, 146: 1, 147: 1, 148: 1, 149: 1, 150: 2,
      151: 1, 152: 1, 153: 1, 154: 2, 155: 2, 156: 1, 157: 2, 158: 1, 159: 0, 160: 2,
      161: 1, 162: 1, 163: 0, 164: 1, 165: 1, 166: 1, 167: 1, 168: 1, 169: 0, 170: 0,
      171: 1, 172: 0, 173: 1, 174: 0, 175: 2, 176: 0, 177: 0, 178: 0, 179: 0, 180: 1,
      181: 1, 182: 0, 183: 0, 184: 1, 185: 1, 186: 0, 187: 0, 188: 0, 189: 0, 190: 1,
      191: 1, 192: 1, 193: 1, 194: 1, 195: 1, 196: 0, 197: 1, 198: 0, 199: 0, 200: 1,
      201: 0, 202: 1, 203: 1, 204: 0, 205: 0, 206: 0, 207: 1, 208: 0, 209: 1, 210: 0,
      211: 0, 212: 1, 213: 1, 214: 0, 215: 1, 216: 0, 217: 0, 218: 1, 219: 0, 220: 0,
      221: 1, 222: 0, 223: 1, 224: 0, 225: 0, 226: 1, 227: 0, 228: 0, 229: 2, 230: 1,
      231: 1, 232: 1, 233: 2, 234: 1, 235: 1, 236: 1, 237: 1, 238: 1, 239: 1, 240: 0,
      241: 2, 242: 1, 243: 1, 244: 0, 245: 2, 246: 0, 247: 1, 248: 1, 249: 1, 250: 1,
      251: 2, 252: 1, 253: 1, 254: 2, 255: 2, 256: 1, 257: 2, 258: 1, 259: 0, 260: 1,
      261: 1, 262: 1, 263: 1, 264: 1, 265: 1, 266: 1, 267: 1, 268: 1, 269: 0, 270: 0,
      271: 1, 272: 1, 273: 0, 274: 0, 275: 1, 276: 0, 277: 1, 278: 0, 279: 1, 280: 1,
      281: 1, 282: 1, 283: 1, 284: 1, 285: 0, 286: 1, 287: 0, 288: 1, 289: 1, 290: 0,
      291: 0, 292: 1, 293: 1, 294: 0, 295: 1, 296: 0, 297: 1, 298: 0, 299: 1, 300: 1,
      301: 0, 302: 1, 303: 1, 304: 2, 305: 1, 306: 0, 307: 0, 308: 0, 309: 1, 310: 1,
      311: 1, 312: 1, 313: 0, 314: 0, 315: 0, 316: 1, 317: 0, 318: 0, 319: 1, 320: 0,
      321: 1, 322: 0, 323: 0, 324: 1, 325: 1, 326: 1, 327: 0, 328: 0,
      329: 0, 330: 0, 331: 0, 332: 0, 333: 0, 334: 0, 335: 0, 336: 0, 337: 0, 338: 0,
      339: 0, 340: 0, 341: 0, 342: 0, 343: 0, 344: 0, 345: 0, 346: 0, 347: 0, 348: 0,
      349: 0, 350: 0, 351: 0, 352: 0, 353: 0, 354: 0, 355: 0, 356: 0, 357: 0, 358: 0,
      359: 0, 360: 0, 361: 0, 362: 0, 363: 0, 364: 0, 365: 0, 366: 0, 367: 0, 368: 0,
      369: 0, 370: 0, 371: 0, 372: 0, 373: 0, 374: 0, 375: 0, 376: 0, 377: 0, 378: 0,
      379: 0, 380: 0, 381: 0, 382: 0, 383: 0, 384: 0, 385: 0, 386: 0, 387: 0, 388: 0,
      389: 0, 390: 0, 391: 0, 392: 0, 393: 0, 394: 0, 395: 0, 396: 0, 397: 0, 398: 0,
      399: 0, 400: 0, 401: 0, 402: 0, 403: 0, 404: 0, 405: 0, 406: 0, 407: 0, 408: 0,
      409: 0, 410: 0, 411: 0, 412: 0, 413: 0, 414: 0, 415: 0, 416: 0, 417: 0, 418: 0,
      419: 0, 420: 0, 421: 0, 422: 0, 423: 0, 424: 0, 425: 0, 426: 0, 427: 0, 428: 0,
      429: 0, 430: 0, 431: 0, 432: 0, 433: 0, 434: 0, 435: 0, 436: 0, 437: 0, 438: 0,
      439: 0, 440: 0, 441: 0, 442: 0, 443: 0, 444: 0, 445: 0, 446: 0, 447: 0, 448: 0,
      449: 0, 450: 0, 451: 0, 452: 0, 453: 0, 454: 0, 455: 0, 456: 0, 457: 0, 458: 0,
      459: 0, 460: 0, 461: 0, 462: 0, 463: 0, 464: 0, 465: 0, 466: 0, 467: 0, 468: 0,
      469: 0, 470: 0, 471: 0, 472: 0, 473: 0, 474: 0, 475: 0, 476: 0, 477: 0, 478: 0,
      479: 0, 480: 0, 481: 0, 482: 0, 483: 0, 484: 0, 485: 0, 486: 0, 487: 0, 488: 0,
      489: 0, 490: 0, 491: 0, 492: 0, 493: 0, 494: 0, 495: 0, 496: 0, 497: 0, 498: 0,
      499: 0, 500: 0,
    };
    for (final q in deQuestions) {
      expect(q.correctIndex, expectedKey[q.id],
          reason: 'Soru ${q.id} için cevap anahtarı doğru korunmalı');
      expect(q.isVerified, true,
          reason: 'Soru ${q.id} resmi kaynaklardan doğrulanmış olmalı');
    }

    // FR ve IT dilleri boş liste dönmüyor
    expect(QuestionService.getFreeQuestions('fr').isEmpty, false);
    expect(QuestionService.getFreeQuestions('it').isEmpty, false);
    expect(QuestionService.getFreeQuestions('xx').isEmpty, false);

    // Döndürülen liste değiştirilemez (unmodifiable)
    expect(
      () => QuestionService.getFreeQuestions('de').add(
        const Question(
          id: 999,
          category: 'Test',
          text: 'Test?',
          options: ['A', 'B', 'C'],
          correctIndex: 0,
          explanation: '',
        ),
      ),
      throwsUnsupportedError,
    );
  });

  test('QuestionService - generateSimulationExam returns 30 questions with exact topic distribution', () {
    final exam = QuestionService.generateSimulationExam(language: 'de');

    // 1. Exactly 30 questions
    expect(exam.length, 30);

    // 2. All 30 questions are distinct
    final distinctIds = exam.map((q) => q.id).toSet();
    expect(distinctIds.length, 30);

    // 3. All questions exist in the 500-question pool
    final allIds = sampleGermanBpt121Questions.map((q) => q.id).toSet();
    for (final q in exam) {
      expect(allIds.contains(q.id), true,
          reason: 'Frage ${q.id} muss im 500-Fragen-Pool existieren');
    }

    // 4. Proportional topic distribution quota:
    // * 'arv2_geltungsbereich': 8 questions
    // * 'arv2_dokumentation': 6 questions
    // * 'arv2_arbeitszeit': 5 questions
    // * 'arv2_ruhezeit': 5 questions
    // * 'arv2_lenkzeit': 4 questions
    // * 'arv2_pausen': 2 questions
    final counts = <String, int>{};
    for (final q in exam) {
      final canon = QuestionService.canonicalTopicId(q.topicId);
      counts[canon] = (counts[canon] ?? 0) + 1;
    }

    expect(counts['arv2_geltungsbereich'], 8);
    expect(counts['arv2_dokumentation'], 6);
    expect(counts['arv2_arbeitszeit'], 5);
    expect(counts['arv2_ruhezeit'], 5);
    expect(counts['arv2_lenkzeit'], 4);
    expect(counts['arv2_pausen'], 2);

    // 5. getExamQuestions alias works identically
    final aliasExam = QuestionService.getExamQuestions();
    expect(aliasExam.length, 30);
  });

  testWidgets(
      'First launch flow: shows language selection screen, persists choice, and navigates to Home',
      (WidgetTester tester) async {
    // Clean mock storage: no language saved
    SharedPreferences.setMockInitialValues({'bpt121_disclaimer_seen': true});

    await tester.pumpWidget(const Bpt121App());
    await tester.pumpAndSettle();

    // Verify InitialLanguageScreen is shown
    expect(find.text('Sprache wählen'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);
    expect(find.text('Italiano'), findsOneWidget);
    expect(find.text('Weiter'), findsOneWidget);

    // Select Français
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    // Title and button text update reactively
    expect(find.text('Choisir la langue'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);

    // Tap continue button
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    // Verify we transitioned to HomeScreen in French
    expect(find.text('BPT 121 Taxi Theorie'), findsWidgets);
    expect(find.text("Commencer l'examen"), findsOneWidget);

    // Home screen MUST NOT have the old language selection component
    expect(find.text('Choisir la langue'), findsNothing);

    // Verify choice was saved permanently in storage
    final savedLang = await StorageService.getSavedLanguage();
    expect(savedLang, 'fr');
  });

  testWidgets(
      'Subsequent launch flow: directly loads saved language without showing initial language screen',
      (WidgetTester tester) async {
    // Pre-saved language preference: Italian
    SharedPreferences.setMockInitialValues({'bpt121_selected_language': 'it', 'bpt121_disclaimer_seen': true});

    await tester.pumpWidget(const Bpt121App());
    await tester.pumpAndSettle();

    // Initial language screen is skipped
    expect(find.text('Scegli la lingua'), findsNothing);
    expect(find.text('Continua'), findsNothing);

    // Directly in Home screen in Italian
    expect(find.text('BPT 121 Taxi Theorie'), findsWidgets);
    expect(find.text("Inizia l'esame"), findsOneWidget);
  });

  testWidgets(
      'Profile tab language gating: keeps Deutsch active and gates French and Italian',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true});

    await tester.pumpWidget(const Bpt121App());
    await tester.pumpAndSettle();

    // Switch to Profil tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Profil & Einstellungen'), findsOneWidget);
    expect(find.text('Prüfungssprache'), findsOneWidget);

    // Verify upgrade card in Profile tab when not premium
    expect(find.text('BPT 121 Vollversion freischalten 🔓'), findsOneWidget);
    expect(find.text('500 aktuelle Fragen (2026) · CHF 14.90 (Einmalig)'), findsOneWidget);

    // Verify "Bald verfügbar (Update)" tags for French and Italian
    expect(find.text('Bald verfügbar (Update)'), findsNWidgets(2));

    // Tap on Français (interaction is disabled)
    await tester.ensureVisible(find.text('Français'));
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    // Switch back to Home tab to confirm language remained Deutsch
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('BPT 121 Taxi Theorie'), findsWidgets);

    // Confirm persisted language remains 'de'
    expect(await StorageService.getSavedLanguage(), 'de');
  });

  testWidgets(
      'BPT 121 app smoke test on home screen (language selection removed from home)',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true});

    await tester.pumpWidget(const Bpt121App());
    await tester.pumpAndSettle();

    expect(find.text('BPT 121 Taxi Theorie'), findsWidgets);
    // Language selection must NOT be present on Home tab
    expect(find.text('Sprache wählen'), findsNothing);
    expect(find.text('Prüfung starten'), findsOneWidget);
    // Disclaimer card was removed from Home tab body
    expect(find.text('Offizieller Prüfungsstandard ASA / ARV 2'), findsNothing);
    expect(find.text('Aktueller Fragenkatalog 2026: 30 / 500 Fragen verfügbar'), findsOneWidget);
    expect(find.text('2026 · NEU: Offizieller ASA-Fragenkatalog'), findsOneWidget);
    expect(find.text('STAND: 2026 · NEUE PRÜFUNGSFRAGEN'), findsOneWidget);
  });

  testWidgets('Exam screen displays exactly 3 options (A, B, C)',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true});

    await tester.pumpWidget(const Bpt121App());
    await tester.pumpAndSettle();

    final startButton = find.text('Prüfung starten');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pumpAndSettle();

    expect(find.text('BPT 121 Vollprüfung'), findsOneWidget);
    expect(find.text('Frage 1 von 30'), findsOneWidget);

    // Options A, B, and C must be present, but D must not exist
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('D'), findsNothing);
  });

  testWidgets(
      'Exam flow with custom 5 questions - completes and displays result',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true});

    final testQuestions = sampleGermanBpt121Questions.take(5).toList();

    await tester.pumpWidget(
      MaterialApp(
        home: ExamScreen(
          language: 'de',
          mode: ExamMode.standard,
          customQuestions: testQuestions,
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (int i = 0; i < testQuestions.length; i++) {
      final q = testQuestions[i];
      final correctText = q.options[q.correctIndex];

      final optionFinder = find.text(correctText);
      await tester.ensureVisible(optionFinder);
      await tester.tap(optionFinder);
      await tester.pumpAndSettle();

      final actionButtonFinder = find.text(
        i + 1 < testQuestions.length
            ? 'Nächste Frage'
            : 'Ergebnis anzeigen',
      );
      await tester.ensureVisible(actionButtonFinder);
      await tester.tap(actionButtonFinder);
      await tester.pumpAndSettle();
    }

    // Verify Result Screen: 5/5, 100%, Bestanden
    expect(find.text('Bestanden!'), findsOneWidget);
    expect(find.text('Richtig'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Falsch'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Prüfung wiederholen'), findsOneWidget);
    expect(find.text('Zurück zum Hauptmenü'), findsOneWidget);
  });

  testWidgets(
      '4-tab navigation allows smooth switching between Home, Lernen, Statistik, and Profil',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true});

    await tester.pumpWidget(const Bpt121App());
    await tester.pumpAndSettle();

    // Verify all 4 bottom navigation tabs are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Lernen'), findsOneWidget);
    expect(find.text('Statistik'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    // Switch to Tab 1: Lernen
    await tester.tap(find.byIcon(Icons.school_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Lernbereich'), findsOneWidget);
    expect(find.text('Thementraining'), findsOneWidget);
    expect(find.text('Gezieltes Training'), findsOneWidget);

    // Switch to Tab 2: Statistik (initially empty)
    await tester.tap(find.text('Statistik'));
    await tester.pumpAndSettle();
    expect(find.text('Lernstatistik'), findsOneWidget);
    expect(find.text('Noch keine Prüfungen absolviert'), findsOneWidget);

    // Switch to Tab 3: Profil
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Profil & Einstellungen'), findsOneWidget);
    expect(find.text('BPT 121 Kandidat'), findsOneWidget);
    expect(find.text('ARV 2 (SR 822.222)'), findsOneWidget);
    expect(find.text('Käufe wiederherstellen'), findsWidgets);

    // Switch back to Tab 0: Home
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('BPT 121 Taxi Theorie'), findsWidgets);
    // Home tab does NOT have language selection
    expect(find.text('Sprache wählen'), findsNothing);
  });

  test('Questions are categorized into official legal topics with explanations', () {
    final questions = QuestionService.getFreeQuestions('de');
    expect(questions.length, 500);

    final topics = QuestionService.getTopics();
    expect(topics.length, 6);
    final topicIds = topics.map((t) => t.id).toSet();
    expect(
      topicIds,
      containsAll([
        'arv2_lenkzeit',
        'arv2_arbeitszeit',
        'arv2_pausen',
        'arv2_ruhezeit',
        'arv2_dokumentation',
        'arv2_geltungsbereich',
      ]),
    );

    for (final q in questions) {
      expect(q.topicId, isNotEmpty, reason: 'Question ${q.id} must have a topicId');
      expect(topicIds.contains(q.topicId), isTrue,
          reason: 'Question ${q.id} topicId "${q.topicId}" must exist in topics list');
      expect(q.explanation, isNotEmpty, reason: 'Question ${q.id} must have an explanation');
    }

    final lenkQuestions = QuestionService.getQuestionsByTopic('arv2_lenkzeit');
    final arbeitQuestions = QuestionService.getQuestionsByTopic('arv2_arbeitszeit');
    final pausenQuestions = QuestionService.getQuestionsByTopic('arv2_pausen');
    final ruheQuestions = QuestionService.getQuestionsByTopic('arv2_ruhezeit');
    final dokQuestions = QuestionService.getQuestionsByTopic('arv2_dokumentation');
    final geltQuestions = QuestionService.getQuestionsByTopic('arv2_geltungsbereich');

    expect(lenkQuestions.length, 65);
    expect(arbeitQuestions.length, 87);
    expect(pausenQuestions.length, 36);
    expect(ruheQuestions.length, 85);
    expect(dokQuestions.length, 90);
    expect(geltQuestions.length, 137);
    expect(
      lenkQuestions.length +
          arbeitQuestions.length +
          pausenQuestions.length +
          ruheQuestions.length +
          dokQuestions.length +
          geltQuestions.length,
      500,
    );
  });

  test('StorageService wrong questions tracking and removal on correct answer', () async {
    // Initially empty
    expect(await StorageService.getWrongQuestionIds(), isEmpty);

    // Record wrong answer for Q1
    await StorageService.recordQuestionAnswer(1, false);
    var wrong = await StorageService.getWrongQuestionIds();
    expect(wrong, [1]);

    // Record wrong answer for Q2
    await StorageService.recordQuestionAnswer(2, false);
    wrong = await StorageService.getWrongQuestionIds();
    expect(wrong, [1, 2]);

    // Answering Q1 correctly removes it from the wrong questions list
    await StorageService.recordQuestionAnswer(1, true);
    wrong = await StorageService.getWrongQuestionIds();
    expect(wrong, [2]);

    // Clear wrong questions
    await StorageService.clearWrongQuestions();
    expect(await StorageService.getWrongQuestionIds(), isEmpty);
  });

  test('StorageService favorites bookmarking and persistence', () async {
    expect(await StorageService.getFavoriteQuestionIds(), isEmpty);
    expect(await StorageService.isFavorite(3), false);

    // Toggle favorite on
    final added = await StorageService.toggleFavorite(3);
    expect(added, true);
    expect(await StorageService.isFavorite(3), true);
    expect(await StorageService.getFavoriteQuestionIds(), [3]);

    // Add another favorite
    await StorageService.setFavorite(7, true);
    expect(await StorageService.getFavoriteQuestionIds(), containsAll([3, 7]));

    // Toggle off
    final removed = await StorageService.toggleFavorite(3);
    expect(removed, false);
    expect(await StorageService.isFavorite(3), false);
    expect(await StorageService.getFavoriteQuestionIds(), [7]);

    // Clear
    await StorageService.clearFavorites();
    expect(await StorageService.getFavoriteQuestionIds(), isEmpty);
  });

  testWidgets('Lernen tab displays Thementraining and Gezieltes Training',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true});
    await StorageService.recordQuestionAnswer(1, false);
    await StorageService.recordQuestionAnswer(4, false);
    await StorageService.setFavorite(3, true);

    await tester.pumpWidget(const Bpt121App());
    await tester.pumpAndSettle();

    // Navigate to Lernen tab
    await tester.tap(find.byIcon(Icons.school_rounded));
    await tester.pumpAndSettle();

    // Verify Gezieltes Training cards with persisted counts
    expect(find.text('Gezieltes Training'), findsOneWidget);
    expect(find.text('Falsche Fragen'), findsOneWidget);
    expect(find.text('2 Fehler'), findsOneWidget);
    expect(find.text('Favoriten'), findsOneWidget);
    expect(find.text('1 gemerkt'), findsOneWidget);

    // Verify Thementraining section
    expect(find.text('Thementraining'), findsOneWidget);
    expect(find.text('6 Themengebiete'), findsOneWidget);
    expect(find.text('ARV 2 • Lenkzeiten'), findsOneWidget);
    expect(find.text('ARV 2 • Arbeitszeiten'), findsOneWidget);
    expect(find.text('ARV 2 • Pausen'), findsOneWidget);
  });

  testWidgets('ExamScreen allows toggling favorites and shows verified explanation',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true});

    await tester.pumpWidget(
      const MaterialApp(
        home: ExamScreen(language: 'de', mode: ExamMode.standard),
      ),
    );
    await tester.pumpAndSettle();

    // Star icon is present in app bar
    final starIconFinder = find.byIcon(Icons.star_outline_rounded);
    expect(starIconFinder, findsOneWidget);

    // Tap star icon to bookmark
    await tester.tap(starIconFinder);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(find.text('Frage zu Favoriten hinzugefügt'), findsOneWidget);

    // Pick correct option with ensureVisible
    final q = sampleGermanBpt121Questions.first;
    final optionFinder = find.text(q.options[q.correctIndex]);
    await tester.ensureVisible(optionFinder);
    await tester.tap(optionFinder);
    await tester.pumpAndSettle();

    // Explanation card is displayed
    expect(find.text('Erklärung & Rechtsgrundlage'), findsOneWidget);

    final nextBtnFinder = find.text('Nächste Frage');
    expect(nextBtnFinder, findsOneWidget);

    // Tap "Nächste Frage" to proceed to question 2
    await tester.ensureVisible(nextBtnFinder);
    await tester.tap(nextBtnFinder);
    await tester.pumpAndSettle();
    expect(find.text('Frage 2 von 500'), findsOneWidget);
  });

  testWidgets('Profile tab shows Lernstand & Wiederholung with counts',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true});
    await StorageService.recordQuestionAnswer(5, false);
    await StorageService.recordQuestionAnswer(8, false);
    await StorageService.setFavorite(2, true);
    await StorageService.setFavorite(9, true);

    await tester.pumpWidget(const Bpt121App());
    await tester.pumpAndSettle();

    // Navigate to Profil tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Lernstand & Wiederholung'), findsOneWidget);
    expect(find.text('2 Fragen zum Wiederholen'), findsOneWidget);
    expect(find.text('2 Fragen gespeichert'), findsOneWidget);
  });

  test('ExamConfig 30-question official exam pass/fail and launch eligibility rules', () {
    // 30 questions pass threshold: strictly >= 27 is pass, <= 26 is fail
    expect(ExamConfig.isOfficialExamPassed(30, 30), true);
    expect(ExamConfig.isOfficialExamPassed(27, 30), true);
    expect(ExamConfig.isOfficialExamPassed(26, 30), false);
    expect(ExamConfig.isOfficialExamPassed(0, 30), false);

    // Minimum passing score calculation
    expect(ExamConfig.requiredPassingScore(30), 27);
    expect(ExamConfig.requiredPassingScore(15), 14);

    // Rule: Do not start 30-question exam if distinct pool < 30
    expect(ExamConfig.canLaunchFullSimulation(0), false);
    expect(ExamConfig.canLaunchFullSimulation(15), false);
    expect(ExamConfig.canLaunchFullSimulation(29), false);
    expect(ExamConfig.canLaunchFullSimulation(30), true);
    expect(ExamConfig.canLaunchFullSimulation(45), true);
  });

  test('ExamResult serialization with unansweredCount for simulation mode', () {
    final now = DateTime(2026, 10, 17, 15, 0);
    final result = ExamResult(
      id: 'sim_1',
      date: now,
      language: 'de',
      totalQuestions: 30,
      correctCount: 20,
      incorrectCount: 5,
      unansweredCount: 5,
      percentage: 67,
      isPassed: false,
    );

    final json = result.toJson();
    expect(json['unansweredCount'], 5);

    final fromJson = ExamResult.fromJson(json);
    expect(fromJson.unansweredCount, 5);
    expect(fromJson.correctCount, 20);
    expect(fromJson.incorrectCount, 5);
    expect(fromJson.totalQuestions, 30);
  });

  testWidgets('Official 30-question full exam launches simulation when pool >= 30',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true});
    await tester.pumpWidget(const Bpt121App());
    await tester.pumpAndSettle();

    // Tap "Prüfung starten" button on Home tab hero card
    final startBtn = find.text('Prüfung starten');
    await tester.ensureVisible(startBtn);
    await tester.tap(startBtn);
    await tester.pumpAndSettle();

    // Sınav simülasyonu doğrudan başlar (30 soru ile)
    expect(find.text('Frage 1 von 30'), findsOneWidget);
    expect(find.text('BPT 121 Vollprüfung'), findsOneWidget);
  });

  testWidgets(
      'Clicking simulation parameter badge opens official rules dialog without starting exam',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true});
    await tester.pumpWidget(const Bpt121App());
    await tester.pumpAndSettle();

    // Tap "30 Fragen" badge
    final badge = find.text('30 Fragen');
    expect(badge, findsOneWidget);
    await tester.ensureVisible(badge);
    await tester.tap(badge);
    await tester.pumpAndSettle();

    // Dialog appears
    expect(find.text('Offizielle Prüfungsregeln'), findsOneWidget);
    expect(find.text('30 Fragen (A, B, C)'), findsOneWidget);
    expect(find.text('45 Minuten Prüfungszeit'), findsOneWidget);
    expect(find.text('Max. 3 Fehler erlaubt'), findsOneWidget);

    // Tap "Verstanden" to close dialog
    final closeBtn = find.text('Verstanden');
    await tester.tap(closeBtn);
    await tester.pumpAndSettle();

    // Dialog is closed and user is still on Home, no exam started
    expect(find.text('Offizielle Prüfungsregeln'), findsNothing);
    expect(find.text('Prüfung starten'), findsOneWidget);
    expect(find.text('Frage 1 von 30'), findsNothing);
  });

  testWidgets('Simulation mode: navigation, blank questions, confirmation dialog, and scoring',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true});

    final testQuestions = sampleGermanBpt121Questions.take(3).toList();

    await tester.pumpWidget(
      MaterialApp(
        home: ExamScreen(
          language: 'de',
          mode: ExamMode.simulation,
          customQuestions: testQuestions,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // In simulation mode, no explanation or instant feedback is shown
    expect(find.text('Erklärung & Rechtsgrundlage'), findsNothing);

    // Answer Question 1 correctly
    final q1 = testQuestions[0];
    final correctOpt1 = find.text(q1.options[q1.correctIndex]);
    await tester.ensureVisible(correctOpt1);
    await tester.tap(correctOpt1);
    await tester.pumpAndSettle();

    // Navigate to Question 2 using "Nächste Frage"
    final nextBtn = find.text('Nächste Frage');
    await tester.ensureVisible(nextBtn);
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    expect(find.text('Frage 2 von 3'), findsOneWidget);

    // Leave Question 2 blank! Navigate to Question 3
    await tester.ensureVisible(nextBtn);
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    expect(find.text('Frage 3 von 3'), findsOneWidget);

    // Test back navigation to Question 2
    final backBtn = find.text('Zurück');
    await tester.ensureVisible(backBtn);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    expect(find.text('Frage 2 von 3'), findsOneWidget);

    // Select and then unselect an option on Question 2 to verify toggle / blank capability
    final opt2 = find.text(testQuestions[1].options[0]);
    await tester.ensureVisible(opt2);
    await tester.tap(opt2); // select
    await tester.pumpAndSettle();
    await tester.tap(opt2); // deselect / leave blank
    await tester.pumpAndSettle();

    // Advance back to Question 3
    await tester.ensureVisible(nextBtn);
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    expect(find.text('Frage 3 von 3'), findsOneWidget);

    // Tap "Prüfung beenden" (on last question)
    final finishBtn = find.text('Prüfung beenden');
    await tester.ensureVisible(finishBtn);
    await tester.tap(finishBtn);
    await tester.pumpAndSettle();

    // Confirmation dialog appears
    expect(find.text('Prüfung abgeben?'), findsOneWidget);
    expect(find.text('Offene Fragen: 2'), findsOneWidget);
    expect(
      find.text('Wichtig: Unbeantwortete Fragen erhalten 0 Punkte und gelten als falsch.'),
      findsOneWidget,
    );

    // Tap "Jetzt abgeben"
    await tester.tap(find.text('Jetzt abgeben'));
    await tester.pumpAndSettle();

    // Results screen: 1 Correct, 0 Incorrect, 2 Unanswered
    // Blanks scored as 0 points
    expect(find.text('Richtig'), findsOneWidget);
    expect(find.text('Falsch'), findsOneWidget);
    expect(find.text('Offen'), findsOneWidget);
    expect(find.text('1'), findsWidgets); // 1 correct
    expect(find.text('2'), findsWidgets); // 2 unanswered

    // Verify unified progress tracking: Question 1 recorded to seen and correct
    final seen = await StorageService.getSeenQuestionIds();
    final correct = await StorageService.getCorrectQuestionIds();
    expect(seen, contains(testQuestions[0].id));
    expect(correct, contains(testQuestions[0].id));
  });

  testWidgets('Simulation mode auto-submits when countdown timer expires',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true});

    final testQuestions = sampleGermanBpt121Questions.take(2).toList();

    await tester.pumpWidget(
      MaterialApp(
        home: ExamScreen(
          language: 'de',
          mode: ExamMode.simulation,
          customQuestions: testQuestions,
          timeLimitSeconds: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Fast forward timer by 2 seconds
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verifies auto-submission banner on result screen
    expect(find.text('Zeit abgelaufen – Automatisch abgegeben'), findsOneWidget);
    expect(find.text('Offen'), findsOneWidget);
  });

  test('StorageService.recordQuestionAnswers atomically records batch answers', () async {
    SharedPreferences.setMockInitialValues({});

    await StorageService.recordQuestionAnswers({
      10: true,
      11: false,
      12: true,
    });

    expect(await StorageService.getSeenQuestionIds(), [10, 11, 12]);
    expect(await StorageService.getCorrectQuestionIds(), [10, 12]);
    expect(await StorageService.getWrongQuestionIds(), [11]);

    // Answering 11 correctly should remove from wrong and add to correct
    await StorageService.recordQuestionAnswers({11: true});
    expect(await StorageService.getSeenQuestionIds(), [10, 11, 12]);
    expect(await StorageService.getCorrectQuestionIds(), [10, 12, 11]);
    expect(await StorageService.getWrongQuestionIds(), isEmpty);
  });

  testWidgets(
      'Exam simulation updates topic seen, correct, and wrong counts on Lernen tab',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true});

    // Questions 1 and 2 belong to 'arv2_geltungsbereich'
    final q1 = sampleGermanBpt121Questions[0]; // id 1
    final q2 = sampleGermanBpt121Questions[1]; // id 2

    await tester.pumpWidget(const Bpt121App());
    await tester.pumpAndSettle();

    // Answer Q1 correctly, Q2 incorrectly in simulation
    await StorageService.recordQuestionAnswers({
      q1.id: true,
      q2.id: false,
    });

    // Navigate to Lernen tab
    await tester.tap(find.byIcon(Icons.school_rounded));
    await tester.pumpAndSettle();

    // Verify Falsche Fragen card shows 1 Fehler
    expect(find.text('1 Fehler'), findsOneWidget);

    // Verify Lernen tab shows seen counter and mistake drill button for topic
    expect(find.textContaining('gesehen'), findsWidgets);
    expect(find.text('1 falsche Frage üben'), findsOneWidget);
  });

  test('StorageService.resetLearningProgress clears questions and exams but preserves settings',
      () async {
    SharedPreferences.setMockInitialValues({});

    await StorageService.saveSelectedLanguage('de');
    await StorageService.setPremium(true);
    await StorageService.setThemeMode('dark');
    await StorageService.setFavorite(42, true);

    await StorageService.recordQuestionAnswers({
      1: true,
      2: false,
    });
    await StorageService.saveExamResult(ExamResult(
      id: 'test_exam',
      date: DateTime.now(),
      language: 'de',
      totalQuestions: 30,
      correctCount: 28,
      incorrectCount: 2,
      percentage: 93,
      isPassed: true,
    ));

    expect(await StorageService.getSeenQuestionIds(), [1, 2]);
    expect(await StorageService.getCorrectQuestionIds(), [1]);
    expect(await StorageService.getWrongQuestionIds(), [2]);
    expect((await StorageService.getExamResults()).length, 1);

    // Reset learning progress
    await StorageService.resetLearningProgress();

    // Learning data is cleared
    expect(await StorageService.getSeenQuestionIds(), isEmpty);
    expect(await StorageService.getCorrectQuestionIds(), isEmpty);
    expect(await StorageService.getWrongQuestionIds(), isEmpty);
    expect(await StorageService.getExamResults(), isEmpty);

    // Settings & favorites are preserved
    expect(await StorageService.getSavedLanguage(), 'de');
    expect(await StorageService.isPremium(), isTrue);
    expect(await StorageService.getThemeMode(), 'dark');
    expect(await StorageService.getFavoriteQuestionIds(), [42]);
  });

  testWidgets(
      'Profile tab Lernstand zurücksetzen shows confirmation dialog and executes reset',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true,
      'bpt121_seen_question_ids': '[1, 2, 3]',
      'bpt121_correct_question_ids': '[1, 2]',
      'bpt121_wrong_question_ids': '[3]',
    });

    await tester.pumpWidget(const Bpt121App());
    await tester.pumpAndSettle();

    // Switch to Profile Tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Scroll down to find "Lernstand zurücksetzen"
    final resetBtn = find.text('Lernstand zurücksetzen');
    expect(resetBtn, findsOneWidget);
    await tester.ensureVisible(resetBtn);
    await tester.tap(resetBtn);
    await tester.pumpAndSettle();

    // Confirmation dialog is shown
    expect(find.text('Lernstand wirklich zurücksetzen?'), findsOneWidget);
    expect(find.text('Alle bisher gelösten Fragen und Statistiken werden unwiderruflich gelöscht.'), findsOneWidget);

    // Tap "Zurücksetzen"
    final confirmAction = find.text('Zurücksetzen');
    expect(confirmAction, findsOneWidget);
    await tester.tap(confirmAction);
    await tester.pumpAndSettle();

    // SnackBar is displayed
    expect(find.text('Lernstand und Statistiken wurden zurückgesetzt.'), findsOneWidget);

    // Storage is cleared
    expect(await StorageService.getSeenQuestionIds(), isEmpty);
    expect(await StorageService.getCorrectQuestionIds(), isEmpty);
    expect(await StorageService.getWrongQuestionIds(), isEmpty);
  });

  testWidgets('First launch presents official exam disclaimer modal when hasSeen is false',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': false,
    });

    await tester.pumpWidget(const Bpt121App());
    await tester.pumpAndSettle();

    // Modal dialog is shown on first launch
    expect(find.text('Offizieller Prüfungshinweis (BPT 121)'), findsOneWidget);
    expect(find.text('Verstanden & Fortfahren'), findsOneWidget);

    // Tap "Verstanden & Fortfahren" to dismiss
    await tester.tap(find.text('Verstanden & Fortfahren'));
    await tester.pumpAndSettle();

    // Dialog is dismissed
    expect(find.text('Offizieller Prüfungshinweis (BPT 121)'), findsNothing);
    expect(await StorageService.hasSeenExamDisclaimer(), isTrue);
  });

  testWidgets('Profile tab opens official exam disclaimer dialog when tapping legal tile',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true,
    });

    await tester.pumpWidget(const Bpt121App());
    await tester.pumpAndSettle();

    // Switch to Profile Tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Find and tap the legal tile
    final tile = find.text('Offizieller Prüfungshinweis');
    expect(tile, findsOneWidget);
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await tester.pumpAndSettle();

    // Disclaimer dialog opens
    expect(find.text('Offizieller Prüfungshinweis (BPT 121)'), findsOneWidget);
    expect(find.text('Schliessen'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Schliessen'));
    await tester.pumpAndSettle();
    expect(find.text('Offizieller Prüfungshinweis (BPT 121)'), findsNothing);
  });

  testWidgets('Exam result view displays prominent upgrade CTA when free tier',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'bpt121_selected_language': 'de',
      'bpt121_disclaimer_seen': true,
      'bpt121_is_premium': false,
    });

    final testQuestions = sampleGermanBpt121Questions.take(1).toList();

    await tester.pumpWidget(
      MaterialApp(
        home: ExamScreen(
          language: 'de',
          mode: ExamMode.standard,
          customQuestions: testQuestions,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Answer the 1 question
    final q = testQuestions[0];
    final correctText = q.options[q.correctIndex];
    final optionFinder = find.text(correctText);
    await tester.ensureVisible(optionFinder);
    await tester.tap(optionFinder);
    await tester.pumpAndSettle();

    final actionButtonFinder = find.text('Ergebnis anzeigen');
    await tester.ensureVisible(actionButtonFinder);
    await tester.tap(actionButtonFinder);
    await tester.pumpAndSettle();

    // Result view displays upgrade CTA
    expect(find.text('Prüfungsreife garantieren'), findsOneWidget);
    final upgradeBtnFinder = find.text('Alle 500 Prüfungsfragen (2026) freischalten 🔓 (CHF 14.90)');
    expect(upgradeBtnFinder, findsOneWidget);

    // Tap upgrade CTA opens paywall bottom sheet
    await tester.ensureVisible(upgradeBtnFinder);
    await tester.tap(upgradeBtnFinder);
    await tester.pumpAndSettle();

    expect(find.text('BPT 121 Vollversion freischalten'), findsOneWidget);
    expect(find.text('Jetzt freischalten (CHF 14.90)'), findsOneWidget);
  });

}
