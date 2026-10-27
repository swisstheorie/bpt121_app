import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/exam_config.dart';
import 'models/exam_result.dart';
import 'models/question.dart';
import 'screens/exam_screen.dart';
import 'services/purchase_service.dart';
import 'services/question_service.dart';
import 'services/storage_service.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const Bpt121App());
}

enum AppLanguage {
  de(
    code: 'de',
    name: 'Deutsch',
    flag: '🇨🇭 DE',
    title: 'BPT 121 Prüfungstrainer',
    subtitle: 'Schweizer Taxiprüfung (ARV 2)',
    description:
        'Bereiten Sie sich effizient auf die Schweizer BPT 121 Theorieprüfung vor (gewerbsmässiger Personentransport).',
    selectLanguage: 'Sprache wählen',
    startExam: 'Prüfung starten',
    featuresTitle: 'Prüfungsbereiche',
    feature1: 'ARV 2 Vorschriften',
    feature2: 'Signale & Verkehrsregeln',
    feature3: 'Fahrzeugtechnik & Sicherheit',
    comingSoonTitle: 'Bereit für die Vorbereitung!',
    comingSoonMessage:
        'Die Fragenbank wird geladen. Im nächsten Schritt fügen wir die ersten Übungsfragen hinzu.',
    close: 'Schliessen',
    lastExamTitle: 'Letztes Ergebnis',
  ),
  fr(
    code: 'fr',
    name: 'Français',
    flag: '🇨🇭 FR',
    title: 'Entraîneur BPT 121',
    subtitle: 'Examen de taxi suisse (OTR 2)',
    description:
        'Préparez-vous efficacement à l\'examen théorique suisse BPT 121 (transport professionnel de personnes).',
    selectLanguage: 'Choisir la langue',
    startExam: "Commencer l'examen",
    featuresTitle: "Thèmes d'examen",
    feature1: 'Règles OTR 2',
    feature2: 'Signaux et règles de circulation',
    feature3: 'Technique du véhicule et sécurité',
    comingSoonTitle: 'Prêt pour la préparation !',
    comingSoonMessage:
        'La banque de questions se prépare. Nous ajouterons les premières questions lors de la prochaine étape.',
    close: 'Fermer',
    lastExamTitle: 'Dernier résultat',
  ),
  it(
    code: 'it',
    name: 'Italiano',
    flag: '🇨🇭 IT',
    title: 'Allenatore BPT 121',
    subtitle: 'Esame di taxi svizzero (OLR 2)',
    description:
        'Preparati in modo efficiente all\'esame teorico svizzero BPT 121 (trasporto professionale di persone).',
    selectLanguage: 'Scegli la lingua',
    startExam: "Inizia l'esame",
    featuresTitle: "Argomenti d'esame",
    feature1: 'Norme OLR 2',
    feature2: 'Segnali e regole di circolazione',
    feature3: 'Tecnica del veicolo e sicurezza',
    comingSoonTitle: 'Pronto per la preparazione!',
    comingSoonMessage:
        'La banca dati delle domande è in arrivo. Al prossimo passo aggiungeremo le prime domande di prova.',
    close: 'Chiudi',
    lastExamTitle: 'Ultimo risultato',
  );

  const AppLanguage({
    required this.code,
    required this.name,
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.selectLanguage,
    required this.startExam,
    required this.featuresTitle,
    required this.feature1,
    required this.feature2,
    required this.feature3,
    required this.comingSoonTitle,
    required this.comingSoonMessage,
    required this.close,
    required this.lastExamTitle,
  });

  final String code;
  final String name;
  final String flag;
  final String title;
  final String subtitle;
  final String description;
  final String selectLanguage;
  final String startExam;
  final String featuresTitle;
  final String feature1;
  final String feature2;
  final String feature3;
  final String comingSoonTitle;
  final String comingSoonMessage;
  final String close;
  final String lastExamTitle;

  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.de;
    return AppLanguage.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLanguage.de,
    );
  }
}

class InitialLanguageScreen extends StatefulWidget {
  final ValueChanged<AppLanguage> onLanguageSelected;

  const InitialLanguageScreen({
    super.key,
    required this.onLanguageSelected,
  });

  @override
  State<InitialLanguageScreen> createState() => _InitialLanguageScreenState();
}

class _InitialLanguageScreenState extends State<InitialLanguageScreen> {
  AppThemeColors get colors => AppColors.of(context);
  AppLanguage _selected = AppLanguage.de;

  String get _buttonText {
    switch (_selected) {
      case AppLanguage.fr:
        return 'Continuer';
      case AppLanguage.it:
        return 'Continua';
      case AppLanguage.de:
        return 'Weiter';
    }
  }

  String get _titleText {
    switch (_selected) {
      case AppLanguage.fr:
        return 'Choisir la langue';
      case AppLanguage.it:
        return 'Scegli la lingua';
      case AppLanguage.de:
        return 'Sprache wählen';
    }
  }

  String get _subtitleText {
    switch (_selected) {
      case AppLanguage.fr:
        return 'Sélectionnez votre langue pour l\'entraînement. Vous pourrez la modifier à tout moment dans votre profil.';
      case AppLanguage.it:
        return 'Seleziona la tua lingua per la preparazione. Puoi modificarla in qualsiasi momento nel tuo profilo.';
      case AppLanguage.de:
        return 'Wählen Sie Ihre Sprache für die Prüfungsvorbereitung. Sie können diese jederzeit im Profil anpassen.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Header icon & branding
              Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.mutedBorder, width: 0.8),
                  ),
                  child: Icon(
                    Icons.local_taxi_rounded,
                    color: colors.premiumBlue,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'SWISS BPT 121',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _titleText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _subtitleText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // Language Cards
              ...AppLanguage.values.map((lang) {
                final isSelected = lang == _selected;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selected = lang;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.elevatedSurface : colors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? colors.premiumBlue : colors.mutedBorder,
                            width: isSelected ? 1.8 : 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              lang.flag,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.name,
                                    style: TextStyle(
                                      color: colors.primaryText,
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    lang.subtitle,
                                    style: TextStyle(
                                      color: colors.secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isSelected ? colors.premiumBlue : colors.mutedBorder,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Confirm button
              SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.premiumBlue,
                    foregroundColor: const Color(0xFF0D1420),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => widget.onLanguageSelected(_selected),
                  child: Text(
                    _buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class Bpt121App extends StatefulWidget {
  final String? initialLanguage;

  const Bpt121App({super.key, this.initialLanguage});

  @override
  State<Bpt121App> createState() => _Bpt121AppState();
}

class _Bpt121AppState extends State<Bpt121App> {
  bool _isLoading = true;
  String? _savedLanguageCode;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    final themeStr = await StorageService.getThemeMode();
    final mode = themeStr == 'light'
        ? ThemeMode.light
        : themeStr == 'dark'
            ? ThemeMode.dark
            : ThemeMode.system;

    if (Uri.base.queryParameters['screen'] != null) {
      await StorageService.markExamDisclaimerSeen();
      await StorageService.saveSelectedLanguage('de');
    }

    if (widget.initialLanguage != null) {
      setState(() {
        _savedLanguageCode = widget.initialLanguage;
        _themeMode = mode;
        _isLoading = false;
      });
      FlutterNativeSplash.remove();
      return;
    }
    final saved = await StorageService.getSavedLanguage();
    if (mounted) {
      setState(() {
        _savedLanguageCode = saved;
        _themeMode = mode;
        _isLoading = false;
      });
    }
    FlutterNativeSplash.remove();
  }

  void _onThemeModeChanged(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    final str = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await StorageService.setThemeMode(str);
  }



  static ThemeData get _darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0C131F),
      canvasColor: const Color(0xFF0C131F),
      cardColor: const Color(0xFF171F2B),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: const Color(0xFFF1F5FA),
          displayColor: const Color(0xFFF1F5FA),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFFB800),
        onPrimary: Color(0xFF0C131F),
        secondary: Color(0xFFFFB800),
        surface: Color(0xFF171F2B),
        onSurface: Color(0xFFF1F5FA),
        surfaceContainerHighest: Color(0xFF232A37),
        outline: Color(0xFF34465B),
        outlineVariant: Color(0xFF40474F),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0C131F),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFFF1F5FA),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Color(0xFFF1F5FA)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF171F2B),
        selectedItemColor: Color(0xFFFFB800),
        unselectedItemColor: Color(0xFF8B949E),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static ThemeData get _lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF6F8FA),
      canvasColor: const Color(0xFFF6F8FA),
      cardColor: const Color(0xFFFFFFFF),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.light().textTheme.apply(
          bodyColor: const Color(0xFF1F2328),
          displayColor: const Color(0xFF1F2328),
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFFB800),
        onPrimary: Color(0xFF0C131F),
        secondary: Color(0xFFFFB800),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF1F2328),
        surfaceContainerHighest: Color(0xFFF0F4F8),
        outline: Color(0xFFD0D7DE),
        outlineVariant: Color(0xFFE2E8F0),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFF1F2328),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Color(0xFF1F2328)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: Color(0xFFFFB800),
        unselectedItemColor: Color(0xFF656D76),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BPT 121 Taxi Theorie',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      builder: (context, child) {
        final screen = Uri.base.queryParameters['screen'];
        if (screen == null || child == null) return child!;

        final device = Uri.base.queryParameters['device'] ?? 'iphone';
        final isIpad = device == 'ipad';

        final double logicalWidth = isIpad ? 1032.0 : 440.0;
        final double logicalHeight = isIpad ? 1376.0 : 956.0;
        final double targetWidth = isIpad ? 2064.0 : 1320.0;
        final double targetHeight = isIpad ? 2752.0 : 2868.0;
        final double topPadding = isIpad ? 28.0 : 54.0;
        final double bottomPadding = isIpad ? 24.0 : 34.0;

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: Size(logicalWidth, logicalHeight),
            devicePixelRatio: targetWidth / logicalWidth,
            padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
            viewPadding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
          ),
          child: SizedBox(
            width: targetWidth,
            height: targetHeight,
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: logicalWidth,
                height: logicalHeight,
                child: child,
              ),
            ),
          ),
        );
      },
      home: _isLoading
          ? const Scaffold(
              backgroundColor: AppColors.primaryBackground,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.premiumBlue),
              ),
            )
          : Uri.base.queryParameters['screen'] == 'quiz'
              ? ExamScreen(
                  language: 'de',
                  mode: ExamMode.standard,
                  customQuestions: QuestionService.getPreviewQuestions(language: 'de'),
                  initialSelectedAnswerIndex: 1,
                  initialIsAnswerChecked: true,
                )
              : Uri.base.queryParameters['screen'] == 'home'
                  ? Bpt121HomeScreen(
                      initialLanguage: AppLanguage.fromCode(_savedLanguageCode ?? 'de'),
                      themeMode: _themeMode,
                      onThemeModeChanged: _onThemeModeChanged,
                    )
                  : Bpt121HomeScreen(initialLanguage: AppLanguage.fromCode(_savedLanguageCode ?? 'de'), themeMode: _themeMode, onThemeModeChanged: _onThemeModeChanged),
    );
  }
}

class Bpt121HomeScreen extends StatefulWidget {
  final AppLanguage? initialLanguage;
  final ThemeMode? themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  const Bpt121HomeScreen({
    super.key,
    this.initialLanguage,
    this.themeMode,
    this.onThemeModeChanged,
  });

  @override
  State<Bpt121HomeScreen> createState() => _Bpt121HomeScreenState();
}

class _Bpt121HomeScreenState extends State<Bpt121HomeScreen> {
  AppThemeColors get colors => AppColors.of(context);
  int _currentTabIndex = 0;
  late AppLanguage _selectedLanguage;
  ExamResult? _lastResult;
  List<ExamResult> _allResults = [];
  bool _isLoadingResults = false;
  List<int> _wrongQuestionIds = [];
  List<int> _favoriteQuestionIds = [];
  List<int> _seenQuestionIds = [];
  List<int> _correctQuestionIds = [];
  bool _isPremium = false;
  ThemeMode _currentThemeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _currentThemeMode = widget.themeMode ?? ThemeMode.system;
    _selectedLanguage = widget.initialLanguage ?? AppLanguage.de;
    _syncSavedLanguage();
    _loadResults();
    PurchaseService().initialize(
      onPurchaseSuccess: () {
        if (mounted) {
          setState(() {
            _isPremium = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✨ Vollversion erfolgreich freigeschaltet!'),
              backgroundColor: colors.alpineJade,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      onPurchaseError: (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kauf nicht abgeschlossen: $err'),
              backgroundColor: colors.coralRed,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowExamDisclaimer();
    });
  }

  @override
  void dispose() {
    PurchaseService().dispose();
    super.dispose();
  }

  Future<void> _syncSavedLanguage() async {
    final saved = await StorageService.getSavedLanguage();
    if (saved != null && mounted) {
      setState(() {
        _selectedLanguage = AppLanguage.fromCode(saved);
      });
    }
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoadingResults = true;
    });
    final last = await StorageService.getLatestResult();
    final all = await StorageService.getExamResults();
    final wrong = await StorageService.getWrongQuestionIds();
    final favs = await StorageService.getFavoriteQuestionIds();
    final seen = await StorageService.getSeenQuestionIds();
    final correct = await StorageService.getCorrectQuestionIds();
    final premium = await StorageService.isPremium();
    final themeStr = await StorageService.getThemeMode();
    final mode = themeStr == 'light'
        ? ThemeMode.light
        : themeStr == 'dark'
            ? ThemeMode.dark
            : ThemeMode.system;

    if (mounted) {
      setState(() {
        _lastResult = last;
        _allResults = all;
        _wrongQuestionIds = wrong;
        _favoriteQuestionIds = favs;
        _seenQuestionIds = seen;
        _correctQuestionIds = correct;
        _isPremium = premium;
        _currentThemeMode = mode;
        _isLoadingResults = false;
      });
    }
  }

  void _onLanguageSelected(AppLanguage language) async {
    setState(() {
      _selectedLanguage = language;
    });
    await StorageService.saveSelectedLanguage(language.code);
  }

  void _updateThemeMode(ThemeMode mode) async {
    setState(() {
      _currentThemeMode = mode;
    });
    final str = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await StorageService.setThemeMode(str);
    widget.onThemeModeChanged?.call(mode);
  }

  void _showPaywallModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceContainer,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.mutedBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.workspace_premium_rounded, color: colors.gold, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BPT 121 Vollversion freischalten',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'CHF 15.00 (Einmalig · Lebenslanger Zugriff)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildPaywallFeature(
                Icons.all_inclusive_rounded,
                'Alle 500 ARV 2 Prüfungsfragen',
                'Kompletter Fragenpool nach Schweizer asa Standard ohne Sperren.',
              ),
              const SizedBox(height: 12),
              _buildPaywallFeature(
                Icons.shuffle_rounded,
                'Dynamische Prüfungssimulation',
                'Unbegrenzte Zufallsprüfungen mit realem 45-Minuten-Timer.',
              ),
              const SizedBox(height: 12),
              _buildPaywallFeature(
                Icons.wifi_off_rounded,
                '100% Offline & Werbefrei',
                'Einmaliger Kauf – kein Abo, keine Registrierung, keine Werbung.',
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.gold,
                  foregroundColor: const Color(0xFF0C131F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  await PurchaseService().buyFullAccess();
                },
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: const Text(
                  'Jetzt freischalten (CHF 15.00)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _showRestorePurchasesDialog();
                    },
                    child: Text(
                      'Käufe wiederherstellen',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(' • ', style: TextStyle(color: colors.mutedBorder)),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'Später',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaywallFeature(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colors.gold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: colors.secondaryText,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Future<void> _handleStartTopicMistakesExam(
      QuestionTopic topic, List<Question> wrongQuestions) async {
    if (!_isPremium) {
      _showPaywallModal();
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExamScreen(
          language: _selectedLanguage.code,
          mode: ExamMode.mistakes,
          customQuestions: wrongQuestions,
          customTitle: '${topic.getTitle(_selectedLanguage.code)} – Fehler üben',
        ),
      ),
    );
    _loadResults();
  }

  Future<void> _handleStartSimulationExam() async {
    final questions = QuestionService.generateSimulationExam(
      language: _selectedLanguage.code,
      isPremium: _isPremium,
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExamScreen(
          language: _selectedLanguage.code,
          mode: ExamMode.simulation,
          customQuestions: questions,
        ),
      ),
    );
    _loadResults();
  }

  Future<void> _handleStartOfficialFullExam() async {
    final available = QuestionService.currentFreeCount;
    if (!ExamConfig.canLaunchFullSimulation(available)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: colors.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.mutedBorder, width: 0.8),
          ),
          title: Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: colors.gold, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Offizielle Vollprüfung',
                  style: TextStyle(color: colors.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Für die offizielle 30-Fragen Prüfungssimulation (45 Minuten, Bestehensgrenze mind. 27 Richtige nach Schweizer ARV 2 / ASA Standard) sind mindestens 30 unterschiedliche Fragen erforderlich.\n\nAktuell sind $available verifizierte Fragen im Übungspool hinterlegt. Fragen werden nicht künstlich dupliziert, um die Ausbildungsqualität zu wahren.',
                style: TextStyle(color: colors.secondaryText, fontSize: 13, height: 1.45),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Schliessen', style: TextStyle(color: colors.secondaryText)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.premiumBlue,
                foregroundColor: const Color(0xFF0C131F),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _handleStartSimulationExam();
              },
              child: const Text('Kompaktes Training starten', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    final questions = QuestionService.generateSimulationExam(
      language: _selectedLanguage.code,
      isPremium: _isPremium,
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExamScreen(
          language: _selectedLanguage.code,
          mode: ExamMode.simulation,
          customQuestions: questions,
        ),
      ),
    );
    _loadResults();
  }

  void _showOfficialExamInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.mutedBorder, width: 0.8),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.info_outline_rounded, color: colors.gold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Offizielle Prüfungsregeln',
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded, color: colors.secondaryText, size: 20),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theorieprüfung für den gewerbsmässigen Personentransport nach Schweizer ARV 2 / asa Standard:',
              style: TextStyle(color: colors.secondaryText, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            _buildDialogRuleRow(
              Icons.format_list_numbered_rounded,
              '30 Fragen (A, B, C)',
              'Proportionale Verteilung über alle 6 gesetzlichen ARV 2 Themengebiete.',
            ),
            const SizedBox(height: 10),
            _buildDialogRuleRow(
              Icons.timer_outlined,
              '45 Minuten Prüfungszeit',
              'Echtes Zeitlimit mit Countdown. Automatische Abgabe nach Ablauf.',
            ),
            const SizedBox(height: 10),
            _buildDialogRuleRow(
              Icons.verified_user_outlined,
              'Max. 3 Fehler erlaubt',
              'Mindestens 27 von 30 Fragen müssen für das offizielle Bestehen richtig sein (90%).',
            ),
            const SizedBox(height: 10),
            _buildDialogRuleRow(
              Icons.shield_outlined,
              'Simulation ohne Soforthilfe',
              'Keine Anzeige von Lösungen während des Tests. Fragen können vor Abgabe überprüft werden.',
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.gold,
                foregroundColor: const Color(0xFF0C131F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Verstanden', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRuleRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: colors.gold),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExamParamBadge({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colors.mutedBorder.withValues(alpha: 0.7),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: colors.gold),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _handleStartTopicExam(QuestionTopic topic, {List<Question>? customQuestions}) async {
    final questions = customQuestions ??
        QuestionService.getAccessibleQuestionsByTopic(
          topic.id,
          language: _selectedLanguage.code,
          isPremium: _isPremium,
        );

    if (questions.isEmpty && !_isPremium) {
      _showPaywallModal();
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExamScreen(
          language: _selectedLanguage.code,
          mode: ExamMode.topic,
          topicId: topic.id,
          customQuestions: questions,
          customTitle: _isPremium
              ? topic.getTitle(_selectedLanguage.code)
              : '${topic.getTitle(_selectedLanguage.code)} (Testversion)',
        ),
      ),
    );
    _loadResults();
  }

  Future<void> _handleStartMistakesExam() async {
    if (!_isPremium) {
      _showPaywallModal();
      return;
    }
    if (_wrongQuestionIds.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: colors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.verified_rounded, color: colors.successGreen, size: 26),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Keine offenen Fehler',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'Keine offenen Fehler – Perfekt vorbereitet!\n\nAktuell sind alle geübten Fragen fehlerfrei beantwortet. Wiederholen Sie Prüfungen oder trainieren Sie Themengebiete, um Ihr Wissen weiter zu festigen.',
            style: TextStyle(fontSize: 13.5, color: colors.secondaryText, height: 1.45),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.gold,
                foregroundColor: const Color(0xFF0C131F),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Super!'),
            ),
          ],
        ),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExamScreen(
          language: _selectedLanguage.code,
          mode: ExamMode.mistakes,
        ),
      ),
    );
    _loadResults();
  }

  Future<void> _handleStartFavoritesExam() async {
    if (_favoriteQuestionIds.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: colors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.star_rounded, color: colors.accentGold, size: 26),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Keine Favoriten markiert',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'Noch keine Favoriten gespeichert. Tippen Sie während einer Übung oder Probeprüfung auf das Stern-Symbol, um anspruchsvolle Fragen hier für gezieltes Wiederholen abzulegen.',
            style: TextStyle(fontSize: 13.5, color: colors.secondaryText, height: 1.45),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.gold,
                foregroundColor: const Color(0xFF0C131F),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Verstanden'),
            ),
          ],
        ),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExamScreen(
          language: _selectedLanguage.code,
          mode: ExamMode.favorites,
        ),
      ),
    );
    _loadResults();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildCurrentTab(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          border: Border(
            top: BorderSide(
              color: colors.mutedBorder,
              width: 0.8,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });
            _loadResults();
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_rounded),
              label: 'Lernen',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Statistik',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentTabIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildLernenTab();
      case 2:
        return _buildStatistikTab();
      case 3:
        return _buildProfilTab();
      default:
        return _buildHomeTab();
    }
  }

  // ==========================================
  // TAB 0: HOME (STITCH HELVETIC PRECISION)
  // ==========================================
  Widget _buildHomeTab() {
    final lang = _selectedLanguage;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Bar & Branding
          _buildTopBar(lang),
          const SizedBox(height: 10),

          // 2. Welcome & Assurance Framing
          _buildWelcomeFraming(lang),
          const SizedBox(height: 10),

          // Top Freemium Status Banner (only shown if not premium)
          if (!_isPremium) ...[
            _buildTopFreemiumBanner(),
            const SizedBox(height: 12),
          ],

          // 3. Hero Exam Preparation Master Card (Cockpit)
          _buildHeroExamMasterCard(lang),
          const SizedBox(height: 12),

          // 4. Last Exam Result Card (if any)
          if (_lastResult != null) ...[
            _buildLastResultCard(lang),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }


  // ─── Top Freemium Status Banner ───────────────────────────────
  Widget _buildTopFreemiumBanner() {
    if (_isPremium) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.accentGold.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colors.accentGold.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 2026 Gold/Red Official ASA Pill Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colors.accentGold.withValues(alpha: 0.5), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDA291C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '2026 · NEU: Offizieller ASA-Fragenkatalog',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                        color: colors.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.lock_clock_rounded, color: colors.accentGold, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Aktueller Fragenkatalog 2026: 30 / 500 Fragen verfügbar',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Lernen Sie nach den neuesten Schweizer ARV 2-Richtlinien 2026. Schalten Sie alle 500 Originalfragen für nur CHF 15.00 frei.',
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF141923),
              foregroundColor: colors.accentGold,
              side: BorderSide(color: colors.accentGold, width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: const Size.fromHeight(44),
            ),
            onPressed: _showPaywallModal,
            icon: Icon(Icons.lock_open_rounded, size: 16, color: colors.accentGold),
            label: Text(
              'Alle 500 Fragen freischalten (CHF 15.00) 🔓',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colors.accentGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Legal Exam Disclaimer Dialog & Onboarding ─────────────────
  Future<void> _checkAndShowExamDisclaimer() async {
    final hasSeen = await StorageService.hasSeenExamDisclaimer();
    if (!hasSeen && mounted) {
      _showOfficialExamDisclaimerDialog(isFirstLaunch: true);
    }
  }

  void _showOfficialExamDisclaimerDialog({bool isFirstLaunch = false}) {
    showDialog(
      context: context,
      barrierDismissible: !isFirstLaunch,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.borderSubtle, width: 0.8),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.verified_user_rounded, color: colors.primaryAccent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Offizieller Prüfungshinweis (BPT 121)',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (!isFirstLaunch)
              IconButton(
                icon: Icon(Icons.close_rounded, color: colors.textSecondary, size: 20),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ASA / ARV 2 RICHTLINIEN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: colors.gold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Die Schweizer Theorieprüfung BPT 121 (ARV 2) wird an den kantonalen Strassenverkehrsämtern digital am PC absolviert.',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Hinweis zur Fragenauthentizität:\nDie Vereinigung der Strassenverkehrsämter (asa) sowie die kantonalen Behörden veröffentlichen die amtlichen Original-Prüfungsfragen grundsätzlich nicht.',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Unser Fragenkatalog (500 Fragen) wurde präzise auf Basis der gesetzlichen Verordnung (ARV 2, SR 822.222) und der offiziellen asa-Prüfungsrichtlinien verfasst. Er deckt alle prüfungsrelevanten Themenbereiche und Fragetypen vollständig und realitätsgetreu ab.',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.gold,
                foregroundColor: const Color(0xFF0C131F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                if (isFirstLaunch) {
                  await StorageService.markExamDisclaimerSeen();
                }
              },
              child: Text(
                isFirstLaunch ? 'Verstanden & Fortfahren' : 'Schliessen',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ─── 1. Top Bar ───────────────────────────────────────────────
  Widget _buildTopBar(AppLanguage lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.gold,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: colors.gold.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icons/splash_logo.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.local_taxi_rounded,
                      color: Color(0xFF0C131F),
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'BPT 121 Taxi Theorie',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                        color: colors.primaryText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFFFB800).withValues(alpha: 0.6),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            'ARV 2 • ASA 2026',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              color: Color(0xFFFFB800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: colors.gold.withValues(alpha: 0.6), width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🇨🇭', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
              Text(
                lang.code.toUpperCase(),
                style: TextStyle(
                  color: colors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── 2. Welcome & Assurance Framing ───────────────────────────
  Widget _buildWelcomeFraming(AppLanguage lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: colors.gold.withValues(alpha: 0.6), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFDA291C),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'STAND: 2026 · NEUE PRÜFUNGSFRAGEN',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: colors.gold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Dein Weg zur Prüfungsreife',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            color: colors.primaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          lang.description,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.35,
            color: colors.secondaryText,
          ),
        ),
      ],
    );
  }

  // ─── 3. Hero Master Preparation Card (Cockpit) ────────────────
  Widget _buildHeroExamMasterCard(AppLanguage lang) {
    final totalQuestions = QuestionService.currentFreeCount;
    final hasResults = _allResults.isNotEmpty;

    // Real Data Calculations:
    final masteredCount = hasResults
        ? (totalQuestions - _wrongQuestionIds.length).clamp(0, totalQuestions)
        : 0;

    final avgPercentage = hasResults
        ? (_allResults.map((r) => r.percentage).reduce((a, b) => a + b) / _allResults.length).round()
        : null;

    final lastScore = _lastResult != null
        ? '${_lastResult!.correctCount}/${_lastResult!.totalQuestions}'
        : null;

    final readinessPercentage = _lastResult?.percentage ?? (hasResults ? avgPercentage : 0);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.mutedBorder, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Simulation badge + Readiness status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        color: colors.gold,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SIMULATION',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: colors.secondaryText,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Offizielle Prüfung',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primaryText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: _showOfficialExamInfoDialog,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    size: 15,
                                    color: colors.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: hasResults ? colors.alpineJade : colors.secondaryText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      hasResults
                          ? '$readinessPercentage% BEREIT'
                          : 'BEREIT FÜR START',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                        color: hasResults ? colors.alpineJade : colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3-Column Telemetry Row (Derived from REAL DATA)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.mutedBorder.withValues(alpha: 0.5), width: 0.8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$masteredCount/$totalQuestions',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'GEMEISTERT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 28,
                  width: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        avgPercentage != null ? '$avgPercentage%' : '–',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: avgPercentage != null ? colors.gold : colors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'QUOTE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 28,
                  width: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        lastScore ?? '–',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: lastScore != null ? colors.alpineJade : colors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'LETZTER TEST',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ausbildungsfortschritt Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ausbildungsfortschritt',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colors.secondaryText,
                ),
              ),
              Text(
                'Ziel: 90% Schwellenwert',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              color: colors.surfaceContainerHighest,
              child: Stack(
                children: [
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: hasResults
                        ? ((readinessPercentage ?? 0) / 100).clamp(0.0, 1.0)
                        : 0.0,
                    child: Container(
                      color: ((readinessPercentage ?? 0) >= 90)
                          ? colors.alpineJade
                          : colors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3 Parameter Badges ("30 Fragen", "45 Minuten", "Max. 3 Fehler")
          Row(
            children: [
              Expanded(
                child: _buildExamParamBadge(
                  icon: Icons.format_list_numbered_rounded,
                  label: '30 Fragen',
                  onTap: _showOfficialExamInfoDialog,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildExamParamBadge(
                  icon: Icons.timer_outlined,
                  label: '45 Minuten',
                  onTap: _showOfficialExamInfoDialog,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildExamParamBadge(
                  icon: Icons.verified_user_outlined,
                  label: 'Max. 3 Fehler',
                  onTap: _showOfficialExamInfoDialog,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Primary Launch Button
          SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.gold,
                foregroundColor: const Color(0xFF0C131F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: _handleStartOfficialFullExam,
              child: Row(
                children: [
                  const Icon(Icons.play_arrow_rounded, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.startExam,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Offizielle Simulation (30 Fragen · 45 Min)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 4. Last Exam Result Card ─────────────────────────────────
  Widget _buildLastResultCard(AppLanguage lang) {
    if (_lastResult == null) return const SizedBox.shrink();

    final result = _lastResult!;
    final dateFormatted =
        '${result.date.day.toString().padLeft(2, '0')}.${result.date.month.toString().padLeft(2, '0')}.${result.date.year}';
    final isPassed = result.isPassed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPassed
              ? colors.alpineJade.withValues(alpha: 0.6)
              : colors.coralRed.withValues(alpha: 0.6),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 18,
                    color: isPassed ? colors.alpineJade : colors.coralRed,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    lang.lastExamTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colors.primaryText,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPassed
                      ? colors.alpineJade.withValues(alpha: 0.15)
                      : colors.coralRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isPassed ? 'Bestanden' : 'Nicht bestanden',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? colors.alpineJade : colors.coralRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${result.correctCount}/${result.totalQuestions} (${result.percentage}%)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
              Text(
                '🇨🇭 ${result.language.toUpperCase()} • $dateFormatted',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  // ==========================================
  // TAB 1: LERNEN (LEARNING & DRILLS)
  // ==========================================
  Widget _buildLernenTab() {
    final topics = QuestionService.getTopics();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lernbereich',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.mutedBorder, width: 0.8),
                ),
                child: Text(
                  '6 THEMENGEBIETE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: colors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Vertiefen Sie Ihr Wissen systematisch nach offiziellen Schweizer ARV 2 Richtlinien.',
            style: TextStyle(
              fontSize: 13,
              color: colors.secondaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Freemium Status Banner (when not premium)
          if (!_isPremium) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.accentGold.withValues(alpha: 0.5), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.lock_rounded, color: colors.accentGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '30 / 500 Fragen freigeschaltet 🔒',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colors.primaryText,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Kostenlose Testversion mit Schweizer Quoten.',
                          style: TextStyle(fontSize: 11, color: colors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.gold,
                      foregroundColor: const Color(0xFF0C131F),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: _showPaywallModal,
                    child: const Text('Freischalten', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Gezieltes Training (Quick-Access Cards for Falsche Fragen & Favoriten)
          Text(
            'Gezieltes Training',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFocusTrainingCard(
                  title: 'Falsche Fragen',
                  count: _wrongQuestionIds.length,
                  icon: _wrongQuestionIds.isNotEmpty
                      ? Icons.replay_rounded
                      : Icons.verified_rounded,
                  accentColor: _wrongQuestionIds.isNotEmpty
                      ? colors.errorRed
                      : colors.successGreen,
                  badgeText: _wrongQuestionIds.isNotEmpty
                      ? '${_wrongQuestionIds.length} Fehler'
                      : '0 Fehler ✨',
                  onTap: _handleStartMistakesExam,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFocusTrainingCard(
                  title: 'Favoriten',
                  count: _favoriteQuestionIds.length,
                  icon: Icons.star_rounded,
                  accentColor: _favoriteQuestionIds.isNotEmpty
                      ? colors.accentGold
                      : colors.secondaryText,
                  badgeText: '${_favoriteQuestionIds.length} gemerkt',
                  onTap: _handleStartFavoritesExam,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Thementraining Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thementraining',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
              Text(
                '${topics.length} Themengebiete',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 6 Rebuilt Topic Cards with interactive stats and mistake drill action
          ...topics.map((topic) {
            final topicQuestions = QuestionService.getQuestionsByTopic(topic.id);
            final total = topicQuestions.length;
            final accessibleQuestions = QuestionService.getAccessibleQuestionsByTopic(
              topic.id,
              language: _selectedLanguage.code,
              isPremium: _isPremium,
            );
            final seenInTopic = topicQuestions.where((q) => _seenQuestionIds.contains(q.id)).length;
            final correctInTopic = topicQuestions.where((q) => _correctQuestionIds.contains(q.id)).length;
            final wrongInTopic = topicQuestions.where((q) => _wrongQuestionIds.contains(q.id)).toList();

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.mutedBorder, width: 0.8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleStartTopicExam(topic, customQuestions: accessibleQuestions),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Icon + Title + Seen Counter / Lock Pill
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: colors.elevatedSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.mutedBorder, width: 0.8),
                              ),
                              child: Icon(
                                _getTopicIcon(topic.id),
                                color: colors.gold,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                topic.getTitle(_selectedLanguage.code),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primaryText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Seen counter pill & locked indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colors.mutedBorder, width: 0.6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!_isPremium) ...[
                                    Icon(Icons.lock_outline_rounded, size: 12, color: colors.gold),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${accessibleQuestions.length} frei',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: colors.gold,
                                      ),
                                    ),
                                    Text(' · ', style: TextStyle(color: colors.secondaryText, fontSize: 11)),
                                  ],
                                  Text(
                                    '$seenInTopic / $total gesehen',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: colors.gold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Row 2: Full-width descriptive explanation text (flows into 2-3 readable lines)
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            topic.getDescription(_selectedLanguage.code),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: colors.secondaryText,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Badges Row: Green (Richtig) & Red (Falsch)
                        Row(
                          children: [
                            // Green Badge (Richtig)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.alpineJade.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colors.alpineJade.withValues(alpha: 0.35),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 14, color: colors.alpineJade),
                                  const SizedBox(width: 5),
                                  Text(
                                    '$correctInTopic Richtig',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: colors.alpineJade,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Red Badge (Falsch)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: wrongInTopic.isNotEmpty
                                    ? colors.errorRed.withValues(alpha: 0.12)
                                    : colors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: wrongInTopic.isNotEmpty
                                      ? colors.errorRed.withValues(alpha: 0.35)
                                      : colors.mutedBorder.withValues(alpha: 0.5),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.cancel_rounded,
                                    size: 14,
                                    color: wrongInTopic.isNotEmpty
                                        ? colors.errorRed
                                        : colors.secondaryText,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${wrongInTopic.length} Falsch',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: wrongInTopic.isNotEmpty
                                          ? colors.errorRed
                                          : colors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),
                            Icon(Icons.chevron_right_rounded, color: colors.secondaryText, size: 18),
                          ],
                        ),

                        // Card Footer Action: If user made mistakes in this topic
                        if (wrongInTopic.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: colors.errorRed.withValues(alpha: 0.6),
                                  width: 0.8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                backgroundColor: colors.errorRed.withValues(alpha: 0.08),
                              ),
                              icon: Icon(Icons.replay_rounded, size: 15, color: colors.errorRed),
                              label: Text(
                                '${wrongInTopic.length} ${wrongInTopic.length == 1 ? "falsche Frage" : "falsche Fragen"} üben',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colors.errorRed,
                                ),
                              ),
                              onPressed: () => _handleStartTopicMistakesExam(topic, wrongInTopic),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _getTopicIcon(String topicId) {
    switch (topicId) {
      case 'arv2_lenkzeit':
        return Icons.speed_rounded;
      case 'arv2_arbeitszeit':
        return Icons.work_history_rounded;
      case 'arv2_pausen':
        return Icons.coffee_rounded;
      case 'arv2_ruhezeit':
        return Icons.bed_rounded;
      case 'arv2_dokumentation':
        return Icons.assignment_outlined;
      case 'arv2_geltungsbereich':
        return Icons.gavel_rounded;
      default:
        return Icons.folder_open_rounded;
    }
  }

  Widget _buildFocusTrainingCard({
    required String title,
    required int count,
    required IconData icon,
    required Color accentColor,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.mutedBorder, width: 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.elevatedSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.mutedBorder, width: 0.8),
                      ),
                      child: Icon(icon, color: accentColor, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count == 0
                      ? (title == 'Falsche Fragen' ? 'Perfekt vorbereitet!' : 'Keine Fragen')
                      : 'Jetzt wiederholen',
                  style: TextStyle(
                    fontSize: 11,
                    color: count == 0 && title == 'Falsche Fragen'
                        ? colors.successGreen
                        : colors.secondaryText,
                    fontWeight: count == 0 && title == 'Falsche Fragen'
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: STATISTIK (STATISTICS TAB)
  // ==========================================
  Widget _buildStatistikTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Lernstatistik',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 16),

          if (_isLoadingResults)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: colors.premiumBlue),
              ),
            )
          else if (_allResults.isEmpty)
            // Clean empty state (no fake statistics)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.mutedBorder, width: 0.8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 48,
                    color: colors.secondaryText,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Noch keine Prüfungen absolviert',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.primaryText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sobald Sie eine Probeprüfung abschliessen, werden Ihre Ergebnisse und Ihre Erfolgsquote hier angezeigt.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.secondaryText,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            )
          else
            // Real statistics derived directly from local storage
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRealStatisticsSummary(),
                const SizedBox(height: 24),
                Text(
                  'Prüfungshistorie',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 12),
                ..._allResults.map((res) => _buildHistoryItem(res)),
              ],
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRealStatisticsSummary() {
    final total = _allResults.length;
    final passedCount = _allResults.where((r) => r.isPassed).length;
    final passRate = total > 0 ? ((passedCount / total) * 100).round() : 0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricTile('Prüfungen', '$total', colors.primaryText),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile('Bestanden', '$passedCount', colors.successGreen),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile('Erfolgsquote', '$passRate%', colors.gold),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.mutedBorder, width: 0.8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ExamResult result) {
    final dateFormatted =
        '${result.date.day.toString().padLeft(2, '0')}.${result.date.month.toString().padLeft(2, '0')}.${result.date.year} ${result.date.hour.toString().padLeft(2, '0')}:${result.date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.isPassed
              ? colors.successGreen.withValues(alpha: 0.3)
              : colors.errorRed.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                result.isPassed
                    ? Icons.check_circle_outline_rounded
                    : Icons.highlight_off_rounded,
                color: result.isPassed
                    ? colors.successGreen
                    : colors.errorRed,
                size: 20,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${result.correctCount}/${result.totalQuestions} richtig (${result.percentage}%)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateFormatted,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: result.isPassed
                  ? colors.successGreen.withValues(alpha: 0.15)
                  : colors.errorRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              result.isPassed ? 'Bestanden' : 'Nicht bestanden',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: result.isPassed
                    ? colors.successGreen
                    : colors.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetLearningProgressDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.borderSubtle, width: 0.8),
        ),
        title: Text(
          'Lernstand wirklich zurücksetzen?',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Alle bisher gelösten Fragen und Statistiken werden unwiderruflich gelöscht.',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Abbrechen',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.coralRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await StorageService.resetLearningProgress();
      await _loadResults();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lernstand und Statistiken wurden zurückgesetzt.'),
            backgroundColor: colors.coralRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showRestorePurchasesDialog() async {
    if (!_isPremium) {
      await PurchaseService().restorePurchases();
      final premium = await StorageService.isPremium();
      if (premium && mounted) {
        setState(() {
          _isPremium = true;
        });
      }
    }
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.mutedBorder, width: 0.8),
        ),
        title: Row(
          children: [
            Icon(
              _isPremium ? Icons.verified_rounded : Icons.restore_rounded,
              color: _isPremium ? colors.alpineJade : colors.accentGold,
              size: 26,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Käufe wiederherstellen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          _isPremium
              ? 'Ihre BPT 121 Vollversion (CHF 15.00) ist aktiv. Alle 500 Originalfragen und Funktionen stehen unbegrenzt zur Verfügung.'
              : 'Es wurden keine früheren Einkäufe für Ihr Konto gefunden. Sie können alle 500 Fragen jederzeit für CHF 15.00 (Einmalkauf) freischalten.',
          style: TextStyle(
            fontSize: 13.5,
            color: colors.secondaryText,
            height: 1.45,
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.gold,
              foregroundColor: const Color(0xFF0C131F),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.mutedBorder, width: 0.8),
        ),
        title: Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: colors.gold, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Datenschutzerklärung',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ihre Privatsphäre hat bei uns oberste Priorität.\n\n'
                '• Offline & Lokal: Alle Ihre Prüfungsergebnisse, Lernfortschritte, Fehler-Listen und Favoriten werden ausschliesslich lokal auf Ihrem Gerät gespeichert.\n\n'
                '• Kein Tracking: Wir erheben keine personenbezogenen Tracking-Daten, erstellen keine Nutzerprofile und teilen keine Daten mit Werbenetzwerken.\n\n'
                '• Transaktionen: In-App-Käufe werden ausschliesslich über die sicheren Zahlungsdienste des jeweiligen App Stores (Google Play / Apple App Store) abgewickelt.\n\n'
                'Stand: 2026 • Schweiz',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.secondaryText,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.gold,
              foregroundColor: const Color(0xFF0C131F),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Schliessen', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.mutedBorder, width: 0.8),
        ),
        title: Row(
          children: [
            Icon(Icons.gavel_rounded, color: colors.gold, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Nutzungsbedingungen (AGB)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BPT 121 Taxi Theorie ist eine unabhängige Schweizer Lernsoftware zur Vorbereitung auf die Theorieprüfung für den gewerbsmässigen Personentransport (BPT / Code 121 gemäss ARV 2).\n\n'
                '• Offizieller Lehrplan: Die Fragen und Antworten orientieren sich am offiziellen Anforderungskatalog der Vereinigung der Strassenverkehrsämter (asa) und der Chauffeurzulassungsverordnung (CZV / ARV 2).\n\n'
                '• Haftungsausschluss: Die Nutzung der App ersetzt nicht die offizielle Anmeldung und Prüfung beim zuständigen kantonalen Strassenverkehrsamt. Für das Prüfungsergebnis wird keine rechtliche Gewähr übernommen.\n\n'
                '• Lizenz: Der Einmalkauf (CHF 15.00) gewährt eine unbegrenzte, nicht-übertragbare Einzelnutzerlizenz inklusive aller Aktualisierungen für 2026.\n\n'
                'Stand: 2026 • Schweiz',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.secondaryText,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.gold,
              foregroundColor: const Color(0xFF0C131F),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Schliessen', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: PROFIL (PROFILE TAB)
  // ==========================================
  Widget _buildProfilTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Profil & Einstellungen',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 16),

          // User Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.mutedBorder, width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.elevatedSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.mutedBorder, width: 0.8),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: colors.gold,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BPT 121 Kandidat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.primaryText,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Schweizer Taxiprüfung (ARV 2)',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isPremium
                        ? colors.alpineJade.withValues(alpha: 0.15)
                        : colors.elevatedSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isPremium ? colors.alpineJade : colors.mutedBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    _isPremium ? 'PRO / Vollversion ✨' : 'Kostenlos',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _isPremium ? colors.alpineJade : colors.accentGold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Upgrade / Purchase Card in Profile Tab (when not premium)
          if (!_isPremium) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.accentGold.withValues(alpha: 0.8),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.accentGold.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: colors.accentGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BPT 121 Vollversion freischalten 🔓',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: colors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '500 aktuelle Fragen (2026) · CHF 15.00 (Einmalig)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.accentGold,
                      foregroundColor: const Color(0xFF0C131F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _showPaywallModal,
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text(
                      'Jetzt freischalten (CHF 15.00)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.successJade.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.successJade.withValues(alpha: 0.4), width: 1.0),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.successJade.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.verified_rounded, size: 20, color: colors.successJade),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vollversion aktiv · Alle 500 Fragen freigeschaltet ✨',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colors.successJade,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lebenslanger Zugriff auf den offiziellen Fragenkatalog 2026.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Learning Status / Mistakes & Favorites Section in Profile
          Text(
            'Lernstand & Wiederholung',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.mutedBorder, width: 0.8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.elevatedSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.replay_rounded,
                        color: colors.errorRed,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Falsche Fragen',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colors.primaryText,
                            ),
                          ),
                          Text(
                            _wrongQuestionIds.isEmpty
                                ? 'Keine Fehler erfasst'
                                : '${_wrongQuestionIds.length} Fragen zum Wiederholen',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _wrongQuestionIds.isEmpty ? null : _handleStartMistakesExam,
                      child: const Text('Üben'),
                    ),
                  ],
                ),
                Divider(color: colors.elevatedSurface, height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.elevatedSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: colors.accentGold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Favoriten',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colors.primaryText,
                            ),
                          ),
                          Text(
                            _favoriteQuestionIds.isEmpty
                                ? 'Keine Fragen markiert'
                                : '${_favoriteQuestionIds.length} Fragen gespeichert',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _favoriteQuestionIds.isEmpty ? null : _handleStartFavoritesExam,
                      child: const Text('Üben'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Appearance / Theme Section
          Text(
            'Erscheinungsbild',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.mutedBorder, width: 0.8),
            ),
            child: Row(
              children: [
                _buildThemeOptionTile(
                  icon: Icons.wb_sunny_rounded,
                  label: 'Hell',
                  mode: ThemeMode.light,
                  isSelected: _currentThemeMode == ThemeMode.light,
                ),
                _buildThemeOptionTile(
                  icon: Icons.nightlight_round,
                  label: 'Dunkel',
                  mode: ThemeMode.dark,
                  isSelected: _currentThemeMode == ThemeMode.dark,
                ),
                _buildThemeOptionTile(
                  icon: Icons.smartphone_rounded,
                  label: 'System',
                  mode: ThemeMode.system,
                  isSelected: _currentThemeMode == ThemeMode.system,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Language Setting Header
          Text(
            'Prüfungssprache',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 10),

          // Language Tiles
          ...AppLanguage.values.map((lang) {
            final isSelected = lang == _selectedLanguage;
            final String? availableTag = null;

            return Opacity(
              opacity: 1.0,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.elevatedSurface
                      : colors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? colors.premiumBlue : colors.mutedBorder,
                    width: isSelected ? 1.5 : 0.8,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    dense: true,
                    onTap: () => _onLanguageSelected(lang),
                    leading: Text(
                      lang.flag,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    title: Row(
                      children: [
                        Text(
                          lang.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? colors.primaryText : colors.secondaryText,
                          ),
                        ),
                        if (availableTag != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.elevatedSurface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: colors.mutedBorder, width: 0.6),
                            ),
                            child: Text(
                              availableTag,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colors.secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded, color: colors.premiumBlue)
                        : null,
                  ),
                ),
              ),
            );
          }),



          const SizedBox(height: 24),

          // Legal & Official Info
          Text(
            'Rechtliche Grundlagen & Info',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 10),

          Material(
            color: colors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: colors.mutedBorder, width: 0.8),
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  Icons.restore_rounded,
                  'Käufe wiederherstellen',
                  'StoreKit / Google Play',
                  onTap: _showRestorePurchasesDialog,
                ),
                Divider(color: colors.elevatedSurface, height: 1),
                _buildInfoTile(
                  Icons.privacy_tip_outlined,
                  'Datenschutzerklärung',
                  'Offline & DSGVO-konform',
                  onTap: _showPrivacyPolicyDialog,
                ),
                Divider(color: colors.elevatedSurface, height: 1),
                _buildInfoTile(
                  Icons.gavel_rounded,
                  'Nutzungsbedingungen',
                  'AGB & Richtlinien',
                  onTap: _showTermsDialog,
                ),
                Divider(color: colors.elevatedSurface, height: 1),
                _buildInfoTile(
                  Icons.verified_outlined,
                  'Offizieller Prüfungshinweis',
                  'ASA-Richtlinien',
                  onTap: () => _showOfficialExamDisclaimerDialog(isFirstLaunch: false),
                ),
                Divider(color: colors.elevatedSurface, height: 1),
                _buildInfoTile(
                  Icons.menu_book_rounded,
                  'Offizielle Verordnung',
                  'ARV 2 (SR 822.222)',
                ),
                Divider(color: colors.elevatedSurface, height: 1),
                _buildInfoTile(
                  Icons.lock_outline_rounded,
                  'Datenspeicherung',
                  'Lokal auf diesem Gerät',
                ),
                Divider(color: colors.elevatedSurface, height: 1),
                _buildInfoTile(
                  Icons.info_outline_rounded,
                  'App-Version',
                  '1.0.0 (Build 2026.1)',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Restore Purchases action button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.mutedBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _showRestorePurchasesDialog,
            icon: Icon(Icons.restore_rounded, color: colors.secondaryText, size: 20),
            label: Text(
              'Käufe wiederherstellen',
              style: TextStyle(
                color: colors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Reset learning progress action
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.coralRed.withValues(alpha: 0.6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _showResetLearningProgressDialog,
            icon: Icon(Icons.delete_sweep_rounded, color: colors.coralRed, size: 20),
            label: Text(
              'Lernstand zurücksetzen',
              style: TextStyle(
                color: colors.coralRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Subtle elegant footer
          Center(
            child: Text(
              'Version 1.0.0 (Build 2026.1) • Made for Switzerland 🇨🇭',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.secondaryText.withValues(alpha: 0.7),
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildThemeOptionTile({
    required IconData icon,
    required String label,
    required ThemeMode mode,
    required bool isSelected,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => _updateThemeMode(mode),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colors.elevatedSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: colors.gold, width: 1.2)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? colors.gold : colors.secondaryText,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? colors.primaryText : colors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      dense: true,
      onTap: onTap,
      leading: Icon(icon, color: colors.gold, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.primaryText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11.5,
          color: colors.secondaryText,
        ),
      ),
      trailing: onTap != null
          ? Icon(Icons.chevron_right_rounded, size: 20, color: colors.secondaryText)
          : null,
    );
  }
}
