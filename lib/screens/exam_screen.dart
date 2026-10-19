import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/exam_config.dart';
import '../models/exam_result.dart';
import '../models/question.dart';
import '../services/purchase_service.dart';
import '../services/question_service.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';

enum ExamMode {
  standard,
  topic,
  mistakes,
  favorites,
  simulation,
}

class ExamScreen extends StatefulWidget {
  final String language;
  final ExamMode mode;
  final String? topicId;
  final List<Question>? customQuestions;
  final String? customTitle;
  final int? timeLimitSeconds;

  const ExamScreen({
    super.key,
    this.language = 'de',
    this.mode = ExamMode.standard,
    this.topicId,
    this.customQuestions,
    this.customTitle,
    this.timeLimitSeconds,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late final List<Question> _questions;
  int _currentIndex = 0;

  // Practice mode state
  int? _selectedAnswerIndex;
  bool _isAnswerChecked = false;

  // Simulation mode state
  final Map<int, int?> _simulationAnswers = {};
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isTimerExpired = false;
  bool _isReviewMode = false;

  // Common exam state
  int _score = 0;
  int _incorrectCount = 0;
  int _unansweredCount = 0;
  bool _isExamFinished = false;
  bool _isCurrentFavorite = false;
  bool _isPremium = false;

  bool get _isSimulation => widget.mode == ExamMode.simulation;
  bool get _isSimulationActive => _isSimulation && !_isExamFinished;

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
    if (widget.customQuestions != null) {
      _questions = widget.customQuestions!;
    } else if (widget.topicId != null) {
      _questions = QuestionService.getQuestionsByTopic(
        widget.topicId!,
        language: widget.language,
      );
    } else if (widget.mode == ExamMode.simulation) {
      _questions = QuestionService.generateSimulationExam(language: widget.language);
    } else {
      _questions = QuestionService.getFreeQuestions(widget.language);
    }

    if (_isSimulation) {
      final defaultSeconds = _questions.length >= ExamConfig.fullExamQuestionCount
          ? ExamConfig.fullExamDurationSeconds
          : ExamConfig.shortExamDurationSeconds;
      _remainingSeconds = widget.timeLimitSeconds ?? defaultSeconds;
      _startTimer();
    }

    _checkCurrentFavorite();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPremiumStatus() async {
    final premium = await StorageService.isPremium();
    if (mounted) {
      setState(() {
        _isPremium = premium;
      });
    }
  }

  void _showPaywallModal() {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBg,
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
                    color: colors.borderSubtle,
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
                      color: colors.accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.workspace_premium_rounded, color: colors.accentGold, size: 26),
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
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'CHF 14.90 (Einmalig · Lebenslanger Zugriff)',
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
              const SizedBox(height: 20),
              _buildPaywallFeature(
                colors,
                Icons.all_inclusive_rounded,
                'Alle 500 ARV 2 Prüfungsfragen',
                'Kompletter Fragenpool nach Schweizer asa Standard (2026) ohne Sperren.',
              ),
              const SizedBox(height: 12),
              _buildPaywallFeature(
                colors,
                Icons.shuffle_rounded,
                'Dynamische Prüfungssimulation',
                'Unbegrenzte Zufallsprüfungen mit realem 45-Minuten-Timer.',
              ),
              const SizedBox(height: 12),
              _buildPaywallFeature(
                colors,
                Icons.wifi_off_rounded,
                '100% Offline & Werbefrei',
                'Einmaliger Kauf – kein Abo, keine Registrierung, keine Werbung.',
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accentGold,
                  foregroundColor: const Color(0xFF0C131F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await PurchaseService().buyFullAccess();
                  final premium = await StorageService.isPremium();
                  if (premium && mounted) {
                    setState(() {
                      _isPremium = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('✨ Vollversion erfolgreich freigeschaltet!'),
                        backgroundColor: colors.successJade,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: const Text(
                  'Jetzt freischalten (CHF 14.90)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await PurchaseService().restorePurchases();
                      final premium = await StorageService.isPremium();
                      if (premium && mounted) {
                        setState(() {
                          _isPremium = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('✨ Frühere Käufe erfolgreich wiederhergestellt!'),
                            backgroundColor: colors.successJade,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Keine früheren Käufe gefunden.'),
                            backgroundColor: colors.accentGold,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Käufe wiederherstellen',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(' • ', style: TextStyle(color: colors.borderSubtle)),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'Später',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colors.textSecondary,
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

  Widget _buildPaywallFeature(AppThemeColors colors, IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colors.accentGold),
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
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: colors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTimerExpired = true;
        });
        _finishExam(autoSubmitted: true);
      }
    });
  }

  Future<void> _checkCurrentFavorite() async {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return;
    final isFav = await StorageService.isFavorite(_questions[_currentIndex].id);
    if (mounted) {
      setState(() {
        _isCurrentFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return;
    HapticFeedback.selectionClick();
    final qId = _questions[_currentIndex].id;
    final newState = await StorageService.toggleFavorite(qId);
    if (mounted) {
      setState(() {
        _isCurrentFavorite = newState;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newState
                ? 'Frage zu Favoriten hinzugefügt'
                : 'Frage aus Favoriten entfernt',
            style: const TextStyle(color: AppColors.primaryText),
          ),
          backgroundColor: AppColors.surfaceContainer,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // ─── Practice Mode Selection ─────────────────────────────────
  void _selectOptionPractice(int index) {
    if (_isAnswerChecked || _questions.isEmpty) return;

    final q = _questions[_currentIndex];
    final isCorrect = (index == q.correctIndex);

    // Tactile haptic feedback: light for correct, medium for wrong
    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswerChecked = true;
      if (isCorrect) {
        _score++;
      }
    });

    StorageService.recordQuestionAnswer(q.id, isCorrect);
  }

  // ─── Simulation Mode Selection (No Live Feedback, Toggleable) ─
  void _selectOptionSimulation(int index) {
    if (_isExamFinished || _questions.isEmpty) return;

    // Tactile haptic feedback on selecting/deselecting options
    HapticFeedback.lightImpact();

    setState(() {
      if (_simulationAnswers[_currentIndex] == index) {
        // Toggle off: allow leaving blank
        _simulationAnswers[_currentIndex] = null;
      } else {
        _simulationAnswers[_currentIndex] = index;
      }
    });
  }

  // ─── Navigation ──────────────────────────────────────────────
  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        if (!_isSimulation) {
          _selectedAnswerIndex = null;
          _isAnswerChecked = false;
        }
      });
      _checkCurrentFavorite();
    }
  }

  void _nextQuestionPractice() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswerChecked = false;
      });
      _checkCurrentFavorite();
    } else {
      _finishPracticeExam();
    }
  }

  void _nextQuestionSimulation() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
      });
      _checkCurrentFavorite();
    } else {
      _showFinishConfirmationDialog();
    }
  }

  // ─── Finishing Exams ──────────────────────────────────────────
  void _finishPracticeExam() {
    final total = _questions.length;
    final correct = _score;
    final incorrect = total - _score;
    final percentage = total > 0 ? ((correct / total) * 100).round() : 0;
    final passed = (total == ExamConfig.fullExamQuestionCount)
        ? ExamConfig.isOfficialExamPassed(correct, total)
        : ExamConfig.isScorePassing(correct, total);

    final result = ExamResult(
      id: 'exam_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      language: widget.language,
      totalQuestions: total,
      correctCount: correct,
      incorrectCount: incorrect,
      unansweredCount: 0,
      percentage: percentage,
      isPassed: passed,
    );

    StorageService.saveExamResult(result);

    setState(() {
      _incorrectCount = incorrect;
      _unansweredCount = 0;
      _isExamFinished = true;
    });
  }

  Future<void> _showFinishConfirmationDialog() async {
    final colors = AppColors.of(context);
    final answered = _simulationAnswers.values.where((v) => v != null).length;
    final unanswered = _questions.length - answered;

    final shouldFinish = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.borderSubtle, width: 0.8),
        ),
        title: Row(
          children: [
            Icon(Icons.assignment_turned_in_rounded, color: colors.accentGold, size: 24),
            const SizedBox(width: 10),
            Text(
              'Prüfung abgeben?',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Beantwortete Fragen: $answered von ${_questions.length}',
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'Offene Fragen: $unanswered',
              style: TextStyle(
                color: unanswered > 0 ? colors.coralRed : colors.successJade,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unanswered > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Wichtig: Unbeantwortete Fragen erhalten 0 Punkte und gelten als falsch.',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Weiter prüfen', style: TextStyle(color: colors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.accentGold,
              foregroundColor: const Color(0xFF0C131F),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Jetzt abgeben', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldFinish == true) {
      _finishExam();
    }
  }

  Future<void> _finishExam({bool autoSubmitted = false}) async {
    _timer?.cancel();

    int correct = 0;
    int incorrect = 0;
    int unanswered = 0;

    final Map<int, bool> answersToRecord = {};

    for (int i = 0; i < _questions.length; i++) {
      final ans = _simulationAnswers[i];
      if (ans == null) {
        unanswered++;
        // Unanswered yields 0 points
      } else if (ans == _questions[i].correctIndex) {
        correct++;
        answersToRecord[_questions[i].id] = true;
      } else {
        incorrect++;
        answersToRecord[_questions[i].id] = false;
      }
    }

    // Atomically persist all answered questions to seen, correct, and wrong sets
    if (answersToRecord.isNotEmpty) {
      await StorageService.recordQuestionAnswers(answersToRecord);
    }

    final total = _questions.length;
    final percentage = total > 0 ? ((correct / total) * 100).round() : 0;

    // Passing criterion:
    // If 30 questions: strictly >= 27 correct
    // Otherwise: >= 90% ceil (for 15 questions, ceil(15 * 0.9) = 14)
    final passed = (total == ExamConfig.fullExamQuestionCount)
        ? ExamConfig.isOfficialExamPassed(correct, total)
        : ExamConfig.isScorePassing(correct, total);

    final result = ExamResult(
      id: 'sim_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      language: widget.language,
      totalQuestions: total,
      correctCount: correct,
      incorrectCount: incorrect,
      unansweredCount: unanswered,
      percentage: percentage,
      isPassed: passed,
    );

    await StorageService.saveExamResult(result);

    if (mounted) {
      setState(() {
        _score = correct;
        _incorrectCount = incorrect;
        _unansweredCount = unanswered;
        _isExamFinished = true;
      });

      if (autoSubmitted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zeit abgelaufen! Die Prüfung wurde automatisch abgegeben.'),
            backgroundColor: AppColors.coralRed,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<bool> _showExitConfirmationDialog() async {
    final colors = AppColors.of(context);
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.borderSubtle, width: 0.8),
        ),
        title: Text('Prüfung abbrechen?', style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(
          'Möchten Sie die laufende Prüfung wirklich verlassen? Bisher beantwortete Fragen werden in Ihrem Lernfortschritt gespeichert.',
          style: TextStyle(color: colors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Weiter prüfen', style: TextStyle(color: colors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.coralRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Prüfung beenden'),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      final Map<int, bool> answersToRecord = {};
      for (final entry in _simulationAnswers.entries) {
        if (entry.value != null && entry.key < _questions.length) {
          final q = _questions[entry.key];
          answersToRecord[q.id] = (entry.value == q.correctIndex);
        }
      }
      if (answersToRecord.isNotEmpty) {
        await StorageService.recordQuestionAnswers(answersToRecord);
      }
      return true;
    }
    return false;
  }

  void _restartExam() {
    _timer?.cancel();
    setState(() {
      _currentIndex = 0;
      _selectedAnswerIndex = null;
      _isAnswerChecked = false;
      _simulationAnswers.clear();
      _score = 0;
      _incorrectCount = 0;
      _unansweredCount = 0;
      _isExamFinished = false;
      _isTimerExpired = false;
      _isReviewMode = false;
    });

    if (_isSimulation) {
      final defaultSeconds = _questions.length >= ExamConfig.fullExamQuestionCount
          ? ExamConfig.fullExamDurationSeconds
          : ExamConfig.shortExamDurationSeconds;
      _remainingSeconds = widget.timeLimitSeconds ?? defaultSeconds;
      _startTimer();
    }

    _checkCurrentFavorite();
  }

  String get _appBarTitle {
    if (widget.customTitle != null) return widget.customTitle!;
    switch (widget.mode) {
      case ExamMode.simulation:
        return _questions.length >= ExamConfig.fullExamQuestionCount
            ? 'BPT 121 Vollprüfung'
            : 'BPT 121 Prüfungssimulation';
      case ExamMode.topic:
        return 'Thementraining';
      case ExamMode.mistakes:
        return 'Falsche Fragen wiederholen';
      case ExamMode.favorites:
        return 'Favoriten üben';
      case ExamMode.standard:
        return 'BPT 121 Probeprüfung';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return PopScope(
      canPop: _isExamFinished,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        final shouldLeave = await _showExitConfirmationDialog();
        if (shouldLeave && mounted) {
          nav.pop();
        }
      },
      child: Scaffold(
        backgroundColor: colors.scaffoldBg,
        appBar: AppBar(
          title: Text(_appBarTitle),
          centerTitle: true,
          backgroundColor: colors.scaffoldBg,
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
            onPressed: () async {
              if (!_isExamFinished) {
                final nav = Navigator.of(context);
                final leave = await _showExitConfirmationDialog();
                if (leave && mounted) nav.pop();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            // Simulation timer indicator
            if (_isSimulationActive)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(child: _buildTimerBadge(colors)),
              ),

            // Question overview button in simulation
            if (_isSimulationActive)
              IconButton(
                icon: Icon(Icons.grid_view_rounded, color: colors.primaryAccent, size: 22),
                tooltip: 'Fragenübersicht',
                onPressed: _showQuestionNavigatorSheet,
              ),

            // Favorite toggle
            if (_questions.isNotEmpty && !_isExamFinished)
              IconButton(
                icon: Icon(
                  _isCurrentFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: _isCurrentFavorite ? colors.accentGold : colors.textSecondary,
                  size: 24,
                ),
                tooltip: 'Favorit',
                onPressed: _toggleFavorite,
              ),
          ],
        ),
        body: SafeArea(
          child: _questions.isEmpty
              ? _buildEmptyView()
              : _isExamFinished
                  ? (_isReviewMode ? _buildReviewView(colors) : _buildResultView(colors))
                  : _buildQuestionView(colors),
        ),
      ),
    );
  }

  // ─── Countdown Timer Badge ────────────────────────────────────
  Widget _buildTimerBadge(AppThemeColors colors) {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final isWarning = _remainingSeconds <= 300; // <= 5 minutes

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isWarning ? colors.coralRed : colors.borderSubtle,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isWarning ? colors.coralRed : colors.successJade,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$minutes:$seconds',
            style: TextStyle(
              fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isWarning ? colors.coralRed : colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Question Navigator Bottom Sheet ──────────────────────────
  void _showQuestionNavigatorSheet() {
    final colors = AppColors.of(context);
    final answeredCount = _simulationAnswers.values.where((v) => v != null).length;
    final unansweredCount = _questions.length - answeredCount;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fragenübersicht',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$answeredCount von ${_questions.length} beantwortet · $unansweredCount offen',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: unansweredCount > 0 ? colors.accentGold : colors.successJade,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, size: 20, color: colors.textSecondary),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_questions.length, (idx) {
                        final isAnswered = _simulationAnswers[idx] != null;
                        final isCurrent = idx == _currentIndex;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _currentIndex = idx;
                            });
                            _checkCurrentFavorite();
                            Navigator.of(ctx).pop();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isAnswered
                                  ? colors.accentGold
                                  : colors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: isCurrent
                                  ? Border.all(color: colors.accentGold, width: 2.0)
                                  : Border.all(color: colors.borderSubtle, width: 0.8),
                            ),
                            child: Text(
                              '${idx + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isAnswered
                                    ? const Color(0xFF0C131F)
                                    : colors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyView() {
    final colors = AppColors.of(context);
    String title = 'Keine Fragen';
    String message = 'Keine Fragen in dieser Auswahl vorhanden.';
    IconData iconData = Icons.check_circle_outline_rounded;
    Color iconColor = colors.successJade;

    if (widget.mode == ExamMode.mistakes) {
      title = 'Keine offenen Fehler – Perfekt vorbereitet!';
      message =
          'Hervorragend! Aktuell sind keine falschen Fragen in Ihrer Fehler-Box gespeichert. Alle bisher geübten Fragen wurden fehlerfrei gelöst.';
      iconData = Icons.verified_rounded;
      iconColor = colors.successJade;
    } else if (widget.mode == ExamMode.favorites) {
      title = 'Keine Favoriten markiert';
      message =
          'Noch keine Fragen gemerkt. Tippen Sie während einer Übung oder Prüfung auf den Stern, um wichtige Fragen hier gezielt zu wiederholen.';
      iconData = Icons.star_outline_rounded;
      iconColor = colors.accentGold;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.mode == ExamMode.mistakes
                  ? colors.successJade.withValues(alpha: 0.4)
                  : colors.borderSubtle,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  size: 48,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: colors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primaryAccent,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Zurück zur Übersicht',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Question View ───────────────────────────────────────────
  Widget _buildQuestionView(AppThemeColors colors) {
    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Frage ${_currentIndex + 1} von ${_questions.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.borderSubtle, width: 0.8),
                  ),
                  child: Text(
                    question.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.primaryAccent,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(colors.successJade),
            ),
          ),
          const SizedBox(height: 16),

          // Question Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.borderSubtle, width: 0.8),
            ),
            child: Text(
              question.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Options List (A, B, C)
          ...List.generate(question.options.length, (index) {
            return _buildOptionTile(
              index: index,
              text: question.options[index],
              correctIndex: question.correctIndex,
              colors: colors,
            );
          }),

          // Practice Mode: Explanation Banner (Only when answered)
          if (!_isSimulation && _isAnswerChecked) ...[
            const SizedBox(height: 16),
            _buildExplanationBox(question, colors),
          ],

          const SizedBox(height: 24),

          // Action Buttons
          if (_isSimulation)
            _buildSimulationNavigationRow(colors)
          else
            _buildPracticeNextButton(colors),
        ],
      ),
    );
  }

  Widget _buildSimulationNavigationRow(AppThemeColors colors) {
    final isLast = (_currentIndex + 1 == _questions.length);

    return Row(
      children: [
        // Zurück Button
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.borderSubtle),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _currentIndex > 0 ? _previousQuestion : null,
              child: Text(
                'Zurück',
                style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Nächste / Prüfung beenden Button
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.accentGold,
                foregroundColor: const Color(0xFF0C131F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _nextQuestionSimulation,
              child: Text(
                isLast ? 'Prüfung beenden' : 'Nächste Frage',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeNextButton(AppThemeColors colors) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: _isAnswerChecked
              ? colors.accentGold
              : colors.surface,
          foregroundColor: _isAnswerChecked
              ? const Color(0xFF0C131F)
              : colors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: _isAnswerChecked ? _nextQuestionPractice : null,
        child: Text(
          _currentIndex + 1 < _questions.length
              ? 'Nächste Frage'
              : 'Ergebnis anzeigen',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationBox(Question question, AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.borderSubtle, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: colors.borderSubtle.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: colors.accentGold,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Erklärung & Rechtsgrundlage',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              if (question.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.successJade.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: colors.successJade.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 12, color: colors.successJade),
                      const SizedBox(width: 4),
                      Text(
                        'Verifiziert',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colors.successJade,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.explanation,
            style: TextStyle(
              fontSize: 13.5,
              color: colors.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Option Tile (Practice & Simulation) ──────────────────────
  Widget _buildOptionTile({
    required int index,
    required String text,
    required int correctIndex,
    required AppThemeColors colors,
  }) {
    final letters = ['A', 'B', 'C'];

    if (_isSimulation) {
      final isSelected = (_simulationAnswers[_currentIndex] == index);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _selectOptionSimulation(index),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? colors.surface : colors.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? colors.accentGold : colors.borderSubtle,
                width: isSelected ? 1.5 : 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? colors.accentGold : colors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    letters[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF0C131F) : colors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Practice mode option tile
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = index == correctIndex;

    Color backgroundColor = colors.cardBg;
    Color borderColor = isSelected ? colors.accentGold : colors.borderSubtle;
    Color letterBg = isSelected ? colors.accentGold : colors.surface;
    Color letterColor = isSelected ? const Color(0xFF0C131F) : colors.textSecondary;
    Color textColor = colors.textPrimary;
    Widget? trailingIcon;

    if (_isAnswerChecked) {
      if (isCorrect) {
        backgroundColor = colors.successJade.withValues(alpha: 0.15);
        borderColor = colors.successJade;
        letterBg = colors.successJade;
        letterColor = Colors.white;
        trailingIcon = Icon(Icons.check_circle_rounded, color: colors.successJade);
      } else if (isSelected) {
        backgroundColor = colors.coralRed.withValues(alpha: 0.15);
        borderColor = colors.coralRed;
        letterBg = colors.coralRed;
        letterColor = Colors.white;
        trailingIcon = Icon(Icons.cancel_rounded, color: colors.coralRed);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectOptionPractice(index),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: (isSelected || (_isAnswerChecked && isCorrect)) ? 1.5 : 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: letterBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  letters[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: letterColor,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 10),
                trailingIcon,
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Result View ─────────────────────────────────────────────
  Widget _buildResultView(AppThemeColors colors) {
    final total = _questions.length;
    final correctCount = _score;
    final incorrectCount = _isSimulation ? _incorrectCount : (total - _score);
    final unansweredCount = _isSimulation ? _unansweredCount : 0;
    final percentage = total > 0 ? ((correctCount / total) * 100).round() : 0;

    final isPassed = (total == ExamConfig.fullExamQuestionCount)
        ? ExamConfig.isOfficialExamPassed(correctCount, total)
        : ExamConfig.isScorePassing(correctCount, total);

    final requiredScore = ExamConfig.requiredPassingScore(total);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isPassed
                    ? colors.successJade.withValues(alpha: 0.15)
                    : colors.coralRed.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPassed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                size: 72,
                color: isPassed ? colors.successJade : colors.coralRed,
              ),
            ),
            const SizedBox(height: 24),

            // Status Headline
            Text(
              isPassed ? 'Bestanden!' : 'Nicht bestanden',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isPassed ? colors.successJade : colors.coralRed,
              ),
            ),
            const SizedBox(height: 8),

            if (_isTimerExpired) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.coralRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.coralRed, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_off_rounded, color: colors.coralRed, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Zeit abgelaufen – Automatisch abgegeben',
                        style: TextStyle(color: colors.coralRed, fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Passing condition description
            Text(
              isPassed
                  ? (total == ExamConfig.fullExamQuestionCount
                      ? 'Herzlichen Glückwunsch! Sie haben mit $correctCount von 30 Richtigen den offiziellen Schweizer Standard bestanden.'
                      : 'Herzlichen Glückwunsch! Sie haben $correctCount von $total Fragen (%90) richtig beantwortet.')
                  : (total == ExamConfig.fullExamQuestionCount
                      ? 'Für das offizielle Bestehen sind mindestens 27 von 30 richtigen Antworten (%90) erforderlich (maximal 3 Fehler).'
                      : 'Für das Bestehen sind mindestens $requiredScore von $total richtigen Antworten (%90) erforderlich.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // Score Card: Richtig, Falsch, Unbeantwortet, Quote
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              decoration: BoxDecoration(
                color: colors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.borderSubtle, width: 0.8),
              ),
              child: Row(
                children: [
                  // Richtig (Correct)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Richtig',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.successJade,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$correctCount',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 32, color: colors.borderSubtle),

                  // Falsch (Incorrect)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Falsch',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.coralRed,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$incorrectCount',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  if (_isSimulation) ...[
                    Container(width: 1, height: 32, color: colors.borderSubtle),

                    // Unbeantwortet (Unanswered)
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Offen',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$unansweredCount',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                  Container(width: 1, height: 32, color: colors.borderSubtle),

                  // Quote (Percentage)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Quote',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isPassed ? colors.successJade : colors.coralRed,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Upgrade CTA Action on Result View (when not premium)
            if (!_isPremium) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.accentGold.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accentGold.withValues(alpha: 0.1),
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.workspace_premium_rounded,
                            color: colors.accentGold,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prüfungsreife garantieren',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Alle 500 Originalfragen (2026) nach Schweizer ARV 2 freischalten.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.accentGold,
                        foregroundColor: const Color(0xFF0C131F),
                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _showPaywallModal,
                      icon: const Icon(Icons.lock_open_rounded, size: 18),
                      label: const Text(
                        'Alle 500 Prüfungsfragen (2026) freischalten 🔓 (CHF 14.90)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Review Answers Button (in simulation mode)
            if (_isSimulation) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.surface,
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.borderSubtle),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    setState(() {
                      _isReviewMode = true;
                      _currentIndex = 0;
                    });
                  },
                  icon: Icon(Icons.rate_review_rounded, color: colors.accentGold),
                  label: const Text(
                    'Antworten & Erklärungen prüfen',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Repeat Exam Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accentGold,
                  foregroundColor: const Color(0xFF0C131F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _restartExam,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Prüfung wiederholen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Back to main menu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.borderSubtle),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Zurück zum Hauptmenü',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Review View (Post-Simulation Answer Review) ──────────────
  Widget _buildReviewView(AppThemeColors colors) {
    final question = _questions[_currentIndex];
    final userAnswer = _simulationAnswers[_currentIndex];
    final letters = ['A', 'B', 'C'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Überprüfung: Frage ${_currentIndex + 1} von ${_questions.length}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _isReviewMode = false),
                child: Text('Zum Ergebnis', style: TextStyle(color: colors.accentGold, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.borderSubtle, width: 0.8),
            ),
            child: Text(
              question.text,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),

          // Answer options with review status
          ...List.generate(question.options.length, (idx) {
            final isCorrect = (idx == question.correctIndex);
            final wasChosen = (userAnswer == idx);

            Color bgColor = colors.cardBg;
            Color borderColor = colors.borderSubtle;
            Color letterBg = colors.surface;
            Color letterColor = colors.textSecondary;
            Widget? trailing;

            if (isCorrect) {
              bgColor = colors.successJade.withValues(alpha: 0.15);
              borderColor = colors.successJade;
              letterBg = colors.successJade;
              letterColor = Colors.white;
              trailing = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: colors.successJade, size: 18),
                  const SizedBox(width: 4),
                  Text('Richtig', style: TextStyle(color: colors.successJade, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              );
            } else if (wasChosen) {
              bgColor = colors.coralRed.withValues(alpha: 0.15);
              borderColor = colors.coralRed;
              letterBg = colors.coralRed;
              letterColor = Colors.white;
              trailing = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel_rounded, color: colors.coralRed, size: 18),
                  const SizedBox(width: 4),
                  Text('Ihre Wahl', style: TextStyle(color: colors.coralRed, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: (isCorrect || wasChosen) ? 1.5 : 0.8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: letterBg, borderRadius: BorderRadius.circular(6)),
                      child: Text(letters[idx], style: TextStyle(color: letterColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.options[idx],
                        style: TextStyle(fontSize: 13, color: colors.textPrimary, fontWeight: FontWeight.w500),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
              ),
            );
          }),

          if (userAnswer == null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.help_outline_rounded, size: 16, color: colors.textSecondary),
                  const SizedBox(width: 8),
                  Text('Diese Frage wurde nicht beantwortet (0 Punkte).', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                ],
              ),
            ),

          const SizedBox(height: 8),
          _buildExplanationBox(question, colors),
          const SizedBox(height: 20),

          // Review navigation row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.borderSubtle),
                  ),
                  onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null,
                  child: Text('Vorherige', style: TextStyle(color: colors.textPrimary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: colors.primaryAccent, foregroundColor: colors.onPrimary),
                  onPressed: _currentIndex + 1 < _questions.length
                      ? () => setState(() => _currentIndex++)
                      : () => setState(() => _isReviewMode = false),
                  child: Text(_currentIndex + 1 < _questions.length ? 'Nächste' : 'Fertig'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
