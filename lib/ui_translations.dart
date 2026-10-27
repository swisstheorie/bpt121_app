class UiTranslations {
  final String navHome;
  final String navLearn;
  final String navStats;
  final String navProfile;

  // Home
  final String standHeader;
  final String welcomeTitle;
  final String freemiumPill;
  final String freemiumTitle;
  final String freemiumSub;
  final String freemiumBtn;
  final String simulationTag;
  final String officialExam;
  final String readyForStart;
  final String readyPercent;
  final String mastered;
  final String quote;
  final String lastTest;
  final String progressTitle;
  final String targetThreshold;
  final String paramQuestions;
  final String paramMinutes;
  final String paramMistakes;
  final String officialSimulationSub;
  final String passed;
  final String failed;

  // Learn
  final String learnTitle;
  final String sixTopics;
  final String learnSub;
  final String learnBannerTitle;
  final String learnBannerSub;
  final String unlockBtn;
  final String targetedTraining;
  final String wrongQuestions;
  final String favorites;
  final String zeroMistakes;
  final String countMistakes;
  final String countFavorites;
  final String noQuestions;
  final String perfectPrepared;
  final String repeatNow;
  final String topicTraining;
  final String topicsCountLabel;
  final String seenLabel;
  final String freeBadgeLabel;
  final String correctBadge;
  final String wrongBadge;
  final String practiceMistakes;

  // Stats
  final String statsTitle;
  final String noExamsTitle;
  final String noExamsSub;
  final String statExams;
  final String statPassed;
  final String statSuccessRate;
  final String examHistory;

  // Profile
  final String profileTitle;
  final String candidateTitle;
  final String candidateSubtitle;
  final String proVersion;
  final String freeVersion;
  final String unlockFullTitle;
  final String unlockFullSub;
  final String unlockFullBtn;
  final String learningStatusSection;
  final String noMistakesRecorded;
  final String noFavoritesMarked;
  final String practiceBtn;
  final String appearanceSection;
  final String themeLight;
  final String themeDark;
  final String themeSystem;
  final String examLanguageSection;
  final String legalSection;
  final String restorePurchases;
  final String storeKitSub;
  final String privacyPolicy;
  final String privacySub;
  final String termsOfUse;
  final String termsSub;
  final String officialDisclaimer;
  final String disclaimerSub;
  final String officialRegulation;
  final String regulationSub;
  final String dataStorage;
  final String dataStorageSub;
  final String appVersion;
  final String resetProgress;

  // Paywall Modal
  final String paywallPriceSub;
  final String paywallFeature1Title;
  final String paywallFeature1Sub;
  final String paywallFeature2Title;
  final String paywallFeature2Sub;
  final String paywallFeature3Title;
  final String paywallFeature3Sub;
  final String paywallLater;

  // Exam / Quiz Navigation & Dialogs
  final String examScreenTitle;
  final String questionWord;
  final String ofWord;
  final String btnBack;
  final String btnNext;
  final String exitDialogTitle;
  final String exitDialogMessage;
  final String btnContinueExam;
  final String btnFinishExam;
  final String submitDialogTitle;
  final String answeredQuestions;
  final String openQuestions;
  final String unansweredWarning;
  final String btnSubmitNow;

  // Disclaimer Modal
  final String disclaimerModalTitle;
  final String disclaimerBadge;
  final String disclaimerP1;
  final String disclaimerNoticeHeader;
  final String disclaimerP2;
  final String disclaimerP3;
  final String btnUnderstandContinue;

  // Result / Auswertung Screen
  final String resultPassSub;
  final String resultFailSub;
  final String statOpen;
  final String guaranteeTitle;
  final String guaranteeSub;
  final String guaranteeBtn;
  final String btnReviewAnswers;
  final String btnRepeatExam;
  final String btnBackToMenu;

  // Dynamic plural helper fields
  final String practiceOneMistake;
  final String practiceMultipleMistakes;

  const UiTranslations({
    required this.navHome,
    required this.navLearn,
    required this.navStats,
    required this.navProfile,
    required this.standHeader,
    required this.welcomeTitle,
    required this.freemiumPill,
    required this.freemiumTitle,
    required this.freemiumSub,
    required this.freemiumBtn,
    required this.simulationTag,
    required this.officialExam,
    required this.readyForStart,
    required this.readyPercent,
    required this.mastered,
    required this.quote,
    required this.lastTest,
    required this.progressTitle,
    required this.targetThreshold,
    required this.paramQuestions,
    required this.paramMinutes,
    required this.paramMistakes,
    required this.officialSimulationSub,
    required this.passed,
    required this.failed,
    required this.learnTitle,
    required this.sixTopics,
    required this.learnSub,
    required this.learnBannerTitle,
    required this.learnBannerSub,
    required this.unlockBtn,
    required this.targetedTraining,
    required this.wrongQuestions,
    required this.favorites,
    required this.zeroMistakes,
    required this.countMistakes,
    required this.countFavorites,
    required this.noQuestions,
    required this.perfectPrepared,
    required this.repeatNow,
    required this.topicTraining,
    required this.topicsCountLabel,
    required this.seenLabel,
    required this.freeBadgeLabel,
    required this.correctBadge,
    required this.wrongBadge,
    required this.practiceMistakes,
    required this.statsTitle,
    required this.noExamsTitle,
    required this.noExamsSub,
    required this.statExams,
    required this.statPassed,
    required this.statSuccessRate,
    required this.examHistory,
    required this.profileTitle,
    required this.candidateTitle,
    required this.candidateSubtitle,
    required this.proVersion,
    required this.freeVersion,
    required this.unlockFullTitle,
    required this.unlockFullSub,
    required this.unlockFullBtn,
    required this.learningStatusSection,
    required this.noMistakesRecorded,
    required this.noFavoritesMarked,
    required this.practiceBtn,
    required this.appearanceSection,
    required this.themeLight,
    required this.themeDark,
    required this.themeSystem,
    required this.examLanguageSection,
    required this.legalSection,
    required this.restorePurchases,
    required this.storeKitSub,
    required this.privacyPolicy,
    required this.privacySub,
    required this.termsOfUse,
    required this.termsSub,
    required this.officialDisclaimer,
    required this.disclaimerSub,
    required this.officialRegulation,
    required this.regulationSub,
    required this.dataStorage,
    required this.dataStorageSub,
    required this.appVersion,
    required this.resetProgress,
    required this.paywallPriceSub,
    required this.paywallFeature1Title,
    required this.paywallFeature1Sub,
    required this.paywallFeature2Title,
    required this.paywallFeature2Sub,
    required this.paywallFeature3Title,
    required this.paywallFeature3Sub,
    required this.paywallLater,
    required this.examScreenTitle,
    required this.questionWord,
    required this.ofWord,
    required this.btnBack,
    required this.btnNext,
    required this.exitDialogTitle,
    required this.exitDialogMessage,
    required this.btnContinueExam,
    required this.btnFinishExam,
    required this.submitDialogTitle,
    required this.answeredQuestions,
    required this.openQuestions,
    required this.unansweredWarning,
    required this.btnSubmitNow,
    required this.disclaimerModalTitle,
    required this.disclaimerBadge,
    required this.disclaimerP1,
    required this.disclaimerNoticeHeader,
    required this.disclaimerP2,
    required this.disclaimerP3,
    required this.btnUnderstandContinue,
    required this.resultPassSub,
    required this.resultFailSub,
    required this.statOpen,
    required this.guaranteeTitle,
    required this.guaranteeSub,
    required this.guaranteeBtn,
    required this.btnReviewAnswers,
    required this.btnRepeatExam,
    required this.btnBackToMenu,
    required this.practiceOneMistake,
    required this.practiceMultipleMistakes,
  });

  String practiceMistakesLabel(int count) {
    if (count == 1) {
      return '1 $practiceOneMistake';
    }
    return '$count $practiceMultipleMistakes';
  }

  static const UiTranslations de = UiTranslations(
    navHome: 'Home',
    navLearn: 'Lernen',
    navStats: 'Statistik',
    navProfile: 'Profil',
    standHeader: 'STAND: 2026 · NEUE PRÜFUNGSFRAGEN',
    welcomeTitle: 'Dein Weg zur Prüfungsreife',
    freemiumPill: '2026 · NEU: Offizieller ASA-Fragenkatalog',
    freemiumTitle: 'Aktueller Fragenkatalog 2026: 30 / 500 Fragen verfügbar',
    freemiumSub: 'Lernen Sie nach den neuesten Schweizer ARV 2-Richtlinien 2026. Schalten Sie alle 500 Originalfragen für nur CHF 15.00 frei.',
    freemiumBtn: 'Alle 500 Fragen freischalten (CHF 15.00) 🔓',
    simulationTag: 'SIMULATION',
    officialExam: 'Offizielle Prüfung',
    readyForStart: 'BEREIT FÜR START',
    readyPercent: 'BEREIT',
    mastered: 'GEMEISTERT',
    quote: 'QUOTE',
    lastTest: 'LETZTER TEST',
    progressTitle: 'Ausbildungsfortschritt',
    targetThreshold: 'Ziel: 90% Schwellenwert',
    paramQuestions: '30 Fragen',
    paramMinutes: '45 Minuten',
    paramMistakes: 'Max. 3 Fehler',
    officialSimulationSub: 'Offizielle Simulation (30 Fragen · 45 Min)',
    passed: 'Bestanden',
    failed: 'Nicht bestanden',
    learnTitle: 'Lernbereich',
    sixTopics: '6 THEMENGEBIETE',
    learnSub: 'Vertiefen Sie Ihr Wissen systematisch nach offiziellen Schweizer ARV 2 Richtlinien.',
    learnBannerTitle: '30 / 500 Fragen freigeschaltet 🔒',
    learnBannerSub: 'Kostenlose Testversion mit Schweizer Quoten.',
    unlockBtn: 'Freischalten',
    targetedTraining: 'Gezieltes Training',
    wrongQuestions: 'Falsche Fragen',
    favorites: 'Favoriten',
    zeroMistakes: '0 Fehler ✨',
    countMistakes: 'Fehler',
    countFavorites: 'gemerkt',
    noQuestions: 'Keine Fragen',
    perfectPrepared: 'Perfekt vorbereitet!',
    repeatNow: 'Jetzt wiederholen',
    topicTraining: 'Thementraining',
    topicsCountLabel: 'Themengebiete',
    seenLabel: 'gesehen',
    freeBadgeLabel: 'frei',
    correctBadge: 'Richtig',
    wrongBadge: 'Falsch',
    practiceMistakes: 'Fehler üben',
    statsTitle: 'Lernstatistik',
    noExamsTitle: 'Noch keine Prüfungen absolviert',
    noExamsSub: 'Sobald Sie eine Probeprüfung abschliessen, werden Ihre Ergebnisse und Ihre Erfolgsquote hier angezeigt.',
    statExams: 'Prüfungen',
    statPassed: 'Bestanden',
    statSuccessRate: 'Erfolgsquote',
    examHistory: 'Prüfungshistorie',
    profileTitle: 'Profil & Einstellungen',
    candidateTitle: 'BPT 121 Kandidat',
    candidateSubtitle: 'Schweizer Taxiprüfung (ARV 2)',
    proVersion: 'PRO / Vollversion ✨',
    freeVersion: 'Kostenlos',
    unlockFullTitle: 'BPT 121 Vollversion freischalten 🔓',
    unlockFullSub: '500 aktuelle Fragen (2026) · CHF 15.00 (Einmalig)',
    unlockFullBtn: 'Jetzt freischalten (CHF 15.00)',
    learningStatusSection: 'Lernstand & Wiederholung',
    noMistakesRecorded: 'Keine Fehler erfasst',
    noFavoritesMarked: 'Keine Fragen markiert',
    practiceBtn: 'Üben',
    appearanceSection: 'Erscheinungsbild',
    themeLight: 'Hell',
    themeDark: 'Dunkel',
    themeSystem: 'System',
    examLanguageSection: 'Prüfungssprache',
    legalSection: 'Rechtliche Grundlagen & Info',
    restorePurchases: 'Käufe wiederherstellen',
    storeKitSub: 'StoreKit / Google Play',
    privacyPolicy: 'Datenschutzerklärung',
    privacySub: 'Offline & DSGVO-konform',
    termsOfUse: 'Nutzungsbedingungen (AGB)',
    termsSub: 'AGB & Richtlinien',
    officialDisclaimer: 'Offizieller Prüfungshinweis',
    disclaimerSub: 'ASA-Richtlinien',
    officialRegulation: 'Offizielle Verordnung (ARV 2)',
    regulationSub: 'ARV 2 (SR 822.222)',
    dataStorage: 'Datenspeicherung',
    dataStorageSub: 'Lokal auf diesem Gerät',
    appVersion: 'App-Version',
    resetProgress: 'Lernstand zurücksetzen',
    paywallPriceSub: 'CHF 15.00 (Einmalig · Lebenslanger Zugriff)',
    paywallFeature1Title: 'Alle 500 ARV 2 Prüfungsfragen',
    paywallFeature1Sub: 'Kompletter Fragenpool nach Schweizer asa Standard ohne Sperren.',
    paywallFeature2Title: 'Dynamische Prüfungssimulation',
    paywallFeature2Sub: 'Unbegrenzte Zufallsprüfungen mit realem 45–Minuten-Timer.',
    paywallFeature3Title: '100% Offline & Werbefrei',
    paywallFeature3Sub: 'Einmaliger Kauf – kein Abo, keine Registrierung, keine Werbung.',
    paywallLater: 'Später',
    examScreenTitle: 'BPT 121 Vollprüfung',
    questionWord: 'Frage',
    ofWord: 'von',
    btnBack: 'Zurück',
    btnNext: 'Nächste Frage',
    exitDialogTitle: 'Prüfung abbrechen?',
    exitDialogMessage: 'Möchten Sie die laufende Prüfung wirklich verlassen? Bisher beantwortete Fragen werden in Ihrem Lernfortschritt gespeichert.',
    btnContinueExam: 'Weiter prüfen',
    btnFinishExam: 'Prüfung beenden',
    submitDialogTitle: 'Prüfung abgeben?',
    answeredQuestions: 'Beantwortete Fragen',
    openQuestions: 'Offene Fragen',
    unansweredWarning: 'Wichtig: Unbeantwortete Fragen erhalten 0 Punkte und gelten als falsch.',
    btnSubmitNow: 'Jetzt abgeben',
    disclaimerModalTitle: 'Offizieller Prüfungshinweis (BPT 121)',
    disclaimerBadge: 'ASA / ARV 2 RICHTLINIEN',
    disclaimerP1: 'Die Schweizer Theorieprüfung BPT 121 (ARV 2) wird an den kantonalen Strassenverkehrsämtern digital am PC absolviert.',
    disclaimerNoticeHeader: 'Hinweis zur Fragenauthentizität:',
    disclaimerP2: 'Die Vereinigung der Strassenverkehrsämter (asa) sowie die kantonalen Behörden veröffentlichen die amtlichen Original-Prüfungsfragen grundsätzlich nicht.',
    disclaimerP3: 'Unser Fragenkatalog (500 Fragen) wurde präzise auf Basis der gesetzlichen Verordnung (ARV 2, SR 822.222) und der offiziellen asa-Prüfungsrichtlinien verfasst. Er deckt alle prüfungsrelevanten Themenbereiche und Fragetypen vollständig und realitätsgetreu ab.',
    btnUnderstandContinue: 'Verstanden & Fortfahren',
    resultPassSub: 'Herzlichen Glückwunsch! Sie haben die Bestehensgrenze erreicht.',
    resultFailSub: 'Für das offizielle Bestehen sind mindestens 27 von 30 richtigen Antworten (%90) erforderlich (maximal 3 Fehler).',
    statOpen: 'Offen',
    guaranteeTitle: 'Prüfungsreife garantieren',
    guaranteeSub: 'Alle 500 Originalfragen (2026) nach Schweizer ARV 2 freischalten.',
    guaranteeBtn: 'Alle 500 Prüfungsfragen (2026) freischalten 🔓 (CHF 15.00)',
    btnReviewAnswers: 'Antworten & Erklärungen prüfen',
    btnRepeatExam: 'Prüfung wiederholen',
    btnBackToMenu: 'Zurück zum Hauptmenü',
    practiceOneMistake: 'falsche Frage üben',
    practiceMultipleMistakes: 'falsche Fragen üben',
  );

  static const UiTranslations fr = UiTranslations(
    navHome: 'Accueil',
    navLearn: 'Apprendre',
    navStats: 'Statistiques',
    navProfile: 'Profil',
    standHeader: 'ÉTAT : 2026 · NOUVELLES QUESTIONS D\'EXAMEN',
    welcomeTitle: 'Votre chemin vers la réussite à l\'examen',
    freemiumPill: '2026 · NOUVEAU : Catalogue officiel ASA',
    freemiumTitle: 'Catalogue de questions 2026 : 30 / 500 questions disponibles',
    freemiumSub: 'Apprenez selon les directives suisses OTR 2 (2026). Débloquez les 500 questions originales pour seulement CHF 15.00.',
    freemiumBtn: 'Débloquer les 500 questions (CHF 15.00) 🔓',
    simulationTag: 'SIMULATION',
    officialExam: 'Examen officiel',
    readyForStart: 'PRÊT AU DÉPART',
    readyPercent: 'PRÊT',
    mastered: 'MAÎTRISÉ',
    quote: 'TAUX',
    lastTest: 'DERNIER TEST',
    progressTitle: 'Progression de la formation',
    targetThreshold: 'Objectif : seuil de 90%',
    paramQuestions: '30 Questions',
    paramMinutes: '45 Minutes',
    paramMistakes: 'Max. 3 Fautes',
    officialSimulationSub: 'Simulation officielle (30 questions · 45 min)',
    passed: 'Réussi',
    failed: 'Échoué',
    learnTitle: 'Zone d\'apprentissage',
    sixTopics: '6 DOMAINES',
    learnSub: 'Approfondissez vos connaissances selon les directives officielles suisses de l\'OTR 2.',
    learnBannerTitle: '30 / 500 questions débloquées 🔒',
    learnBannerSub: 'Version d\'essai gratuite avec quotas suisses.',
    unlockBtn: 'Débloquer',
    targetedTraining: 'Entraînement ciblé',
    wrongQuestions: 'Questions incorrectes',
    favorites: 'Favoris',
    zeroMistakes: '0 Faute ✨',
    countMistakes: 'fautes',
    countFavorites: 'enregistrés',
    noQuestions: 'Aucune question',
    perfectPrepared: 'Parfaitement préparé !',
    repeatNow: 'Répéter maintenant',
    topicTraining: 'Entraînement par thème',
    topicsCountLabel: 'domaines',
    seenLabel: 'vus',
    freeBadgeLabel: 'gratuit',
    correctBadge: 'Correct',
    wrongBadge: 'Faux',
    practiceMistakes: 'Réviser les erreurs',
    statsTitle: 'Statistiques d\'apprentissage',
    noExamsTitle: 'Aucun examen passé pour le moment',
    noExamsSub: 'Dès que vous terminez un examen blanc, vos résultats et votre taux de réussite s\'afficheront ici.',
    statExams: 'Examens',
    statPassed: 'Réussis',
    statSuccessRate: 'Taux de réussite',
    examHistory: 'Historique des examens',
    profileTitle: 'Profil & Paramètres',
    candidateTitle: 'Candidat BPT 121',
    candidateSubtitle: 'Examen de taxi suisse (OTR 2)',
    proVersion: 'PRO / Version complète ✨',
    freeVersion: 'Gratuit',
    unlockFullTitle: 'Débloquer la version complète BPT 121 🔓',
    unlockFullSub: '500 questions actuelles (2026) · CHF 15.00 (Unique)',
    unlockFullBtn: 'Débloquer maintenant (CHF 15.00)',
    learningStatusSection: 'Progression & Répétition',
    noMistakesRecorded: 'Aucune erreur enregistrée',
    noFavoritesMarked: 'Aucune question enregistrée',
    practiceBtn: 'S\'exercer',
    appearanceSection: 'Apparence',
    themeLight: 'Clair',
    themeDark: 'Sombre',
    themeSystem: 'Système',
    examLanguageSection: 'Langue de l\'examen',
    legalSection: 'Bases légales & Infos',
    restorePurchases: 'Restaurer les achats',
    storeKitSub: 'StoreKit / Google Play',
    privacyPolicy: 'Protection des données',
    privacySub: 'Hors ligne et conforme RGPD',
    termsOfUse: 'Conditions d\'utilisation (CGU)',
    termsSub: 'CGU & Directives',
    officialDisclaimer: 'Avis officiel d\'examen',
    disclaimerSub: 'Directives ASA',
    officialRegulation: 'Ordonnance officielle (OTR 2)',
    regulationSub: 'OTR 2 (RS 822.222)',
    dataStorage: 'Stockage des données',
    dataStorageSub: 'Localement sur cet appareil',
    appVersion: 'Version de l\'application',
    resetProgress: 'Réinitialiser la progression',
    paywallPriceSub: 'CHF 15.00 (Unique · Accès à vie)',
    paywallFeature1Title: 'Toutes les 500 questions OTR 2',
    paywallFeature1Sub: 'Ensemble complet des questions selon les normes suisses asa, sans restriction.',
    paywallFeature2Title: 'Simulation d\'examen dynamique',
    paywallFeature2Sub: 'Examens aléatoires illimités avec un chronomètre réel de 45 minutes.',
    paywallFeature3Title: '100% Hors ligne et sans publicité',
    paywallFeature3Sub: 'Achat unique – pas d\'abonnement, pas d\'inscription, pas de publicité.',
    paywallLater: 'Plus tard',
    examScreenTitle: 'Examen complet BPT 121',
    questionWord: 'Question',
    ofWord: 'sur',
    btnBack: 'Précédent',
    btnNext: 'Question suivante',
    exitDialogTitle: 'Quitter l\'examen ?',
    exitDialogMessage: 'Voulez-vous vraiment quitter l\'examen en cours ? Les réponses données seront enregistrées dans votre progression.',
    btnContinueExam: 'Poursuivre l\'examen',
    btnFinishExam: 'Terminer l\'examen',
    submitDialogTitle: 'Rendre l\'examen ?',
    answeredQuestions: 'Questions répondues',
    openQuestions: 'Questions restantes',
    unansweredWarning: 'Important : Les questions sans réponse obtiennent 0 point et comptent comme fausses.',
    btnSubmitNow: 'Rendre maintenant',
    disclaimerModalTitle: 'Avis officiel d\'examen (BPT 121)',
    disclaimerBadge: 'DIRECTIVES ASA / OTR 2',
    disclaimerP1: 'L\'examen théorique suisse BPT 121 (OTR 2) se déroule sur ordinateur auprès des services cantonaux des automobiles.',
    disclaimerNoticeHeader: 'Remarque sur l\'authenticité des questions :',
    disclaimerP2: 'L\'association des services des automobiles (asa) et les autorités cantonales ne publient en principe pas les questions officielles d\'origine.',
    disclaimerP3: 'Notre catalogue de 500 questions a été rédigé avec précision sur la base de l\'ordonnance officielle (OTR 2, RS 822.222) et des directives de l\'asa. Il couvre l\'ensemble des thèmes et types de questions de manière réaliste.',
    btnUnderstandContinue: 'Compris et continuer',
    resultPassSub: 'Félicitations ! Vous avez atteint le seuil de réussite.',
    resultFailSub: 'Pour réussir l\'examen officiel, au moins 27 réponses correctes sur 30 (90%) sont requises (3 fautes au maximum).',
    statOpen: 'Restantes',
    guaranteeTitle: 'Garantir la réussite',
    guaranteeSub: 'Débloquez les 500 questions officielles (2026) selon l\'OTR 2 suisse.',
    guaranteeBtn: 'Débloquer les 500 questions (2026) 🔓 (CHF 15.00)',
    btnReviewAnswers: 'Revoir les réponses & explications',
    btnRepeatExam: 'Recommencer l\'examen',
    btnBackToMenu: 'Retour au menu principal',
    practiceOneMistake: 'réviser l\'erreur',
    practiceMultipleMistakes: 'réviser les erreurs',
  );

  static const UiTranslations it = UiTranslations(
    navHome: 'Home',
    navLearn: 'Studio',
    navStats: 'Statistiche',
    navProfile: 'Profilo',
    standHeader: 'STATO: 2026 · NUOVE DOMANDE D\'ESAME',
    welcomeTitle: 'Il tuo percorso verso la preparazione all\'esame',
    freemiumPill: '2026 · NOVITÀ: Catalogo ufficiale ASA',
    freemiumTitle: 'Catalogo domande 2026: 30 / 500 domande disponibili',
    freemiumSub: 'Studia secondo le direttive svizzere OLR 2 (2026). Sblocca tutte le 500 domande originali per soli CHF 15.00.',
    freemiumBtn: 'Sblocca tutte le 500 domande (CHF 15.00) 🔓',
    simulationTag: 'SIMULAZIONE',
    officialExam: 'Esame ufficiale',
    readyForStart: 'PRONTO AL VIA',
    readyPercent: 'PRONTO',
    mastered: 'SUPERATO',
    quote: 'QUOTA',
    lastTest: 'ULTIMO TEST',
    progressTitle: 'Avanzamento della formazione',
    targetThreshold: 'Obiettivo: soglia del 90%',
    paramQuestions: '30 Domande',
    paramMinutes: '45 Minuti',
    paramMistakes: 'Max. 3 Errori',
    officialSimulationSub: 'Simulazione ufficiale (30 domande · 45 min)',
    passed: 'Superato',
    failed: 'Non superato',
    learnTitle: 'Area di studio',
    sixTopics: '6 MATERIE',
    learnSub: 'Approfondisci le tue conoscenze secondo le direttive ufficiali svizzere OLR 2.',
    learnBannerTitle: '30 / 500 domande sbloccate 🔒',
    learnBannerSub: 'Versione di prova gratuita con quote svizzere.',
    unlockBtn: 'Sblocca',
    targetedTraining: 'Allenamento mirato',
    wrongQuestions: 'Domande errate',
    favorites: 'Preferiti',
    zeroMistakes: '0 Errori ✨',
    countMistakes: 'errori',
    countFavorites: 'salvati',
    noQuestions: 'Nessuna domanda',
    perfectPrepared: 'Perfettamente preparato!',
    repeatNow: 'Ripeti ora',
    topicTraining: 'Allenamento per argomento',
    topicsCountLabel: 'materie',
    seenLabel: 'visti',
    freeBadgeLabel: 'gratuito',
    correctBadge: 'Corretto',
    wrongBadge: 'Errato',
    practiceMistakes: 'Esercita errori',
    statsTitle: 'Statistiche di studio',
    noExamsTitle: 'Nessun esame svolto finora',
    noExamsSub: 'Non appena completerai una simulazione d\'esame, i tuoi risultati e la percentuale di successo appariranno qui.',
    statExams: 'Esami',
    statPassed: 'Superati',
    statSuccessRate: 'Percentuale di successo',
    examHistory: 'Cronologia esami',
    profileTitle: 'Profilo & Impostazioni',
    candidateTitle: 'Candidato BPT 121',
    candidateSubtitle: 'Esame di taxi svizzero (OLR 2)',
    proVersion: 'PRO / Versione completa ✨',
    freeVersion: 'Gratuito',
    unlockFullTitle: 'Sblocca la versione completa BPT 121 🔓',
    unlockFullSub: '500 domande attuali (2026) · CHF 15.00 (Una tantum)',
    unlockFullBtn: 'Sblocca ora (CHF 15.00)',
    learningStatusSection: 'Progresso & Ripasso',
    noMistakesRecorded: 'Nessun errore registrato',
    noFavoritesMarked: 'Nessuna domanda salvata',
    practiceBtn: 'Esercitati',
    appearanceSection: 'Aspetto',
    themeLight: 'Chiaro',
    themeDark: 'Scuro',
    themeSystem: 'Sistema',
    examLanguageSection: 'Lingua d\'esame',
    legalSection: 'Basi legali & Info',
    restorePurchases: 'Ripristina acquisti',
    storeKitSub: 'StoreKit / Google Play',
    privacyPolicy: 'Informativa sulla privacy',
    privacySub: 'Offline e conforme GDPR',
    termsOfUse: 'Condizioni di utilizzo (CGU)',
    termsSub: 'Termini e direttive',
    officialDisclaimer: 'Avviso ufficiale d\'esame',
    disclaimerSub: 'Direttive ASA',
    officialRegulation: 'Ordinanza ufficiale (OLR 2)',
    regulationSub: 'OLR 2 (RS 822.222)',
    dataStorage: 'Memorizzazione dati',
    dataStorageSub: 'Localmente su questo dispositivo',
    appVersion: 'Versione dell\'app',
    resetProgress: 'Reimposta progresso',
    paywallPriceSub: 'CHF 15.00 (Una tantum · Accesso a vita)',
    paywallFeature1Title: 'Tutte le 500 domande OLR 2',
    paywallFeature1Sub: 'Raccolta completa di domande secondo gli standard svizzeri asa senza limitazioni.',
    paywallFeature2Title: 'Simulazione dinamica dell\'esame',
    paywallFeature2Sub: 'Esami casuali illimitati con timer reale di 45 minuti.',
    paywallFeature3Title: '100% Offline e senza pubblicità',
    paywallFeature3Sub: 'Acquisto una tantum – nessun abbonamento, nessuna registrazione, nessuna pubblicità.',
    paywallLater: 'Più tardi',
    examScreenTitle: 'Esame completo BPT 121',
    questionWord: 'Domanda',
    ofWord: 'di',
    btnBack: 'Indietro',
    btnNext: 'Domanda successiva',
    exitDialogTitle: 'Interrompere l\'esame?',
    exitDialogMessage: 'Vuoi davvero uscire dall\'esame in corso? Le risposte date finora verranno salvate nei tuoi progressi.',
    btnContinueExam: 'Continua l\'esame',
    btnFinishExam: 'Termina l\'esame',
    submitDialogTitle: 'Consegnare l\'esame?',
    answeredQuestions: 'Domande risposte',
    openQuestions: 'Domande aperte',
    unansweredWarning: 'Importante: Le domande senza risposta ottengono 0 punti e contano come errate.',
    btnSubmitNow: 'Consegna ora',
    disclaimerModalTitle: 'Avviso ufficiale d\'esame (BPT 121)',
    disclaimerBadge: 'DIRETTIVE ASA / OLR 2',
    disclaimerP1: 'L\'esame teorico svizzero BPT 121 (OLR 2) si svolge al computer presso gli uffici cantonali della circolazione.',
    disclaimerNoticeHeader: 'Nota sull\'autenticità delle domande:',
    disclaimerP2: 'L\'associazione dei servizi della circolazione (asa) e le autorità cantonali non pubblicano le domande ufficiali originali.',
    disclaimerP3: 'Il nostro catalogo di 500 domande è stato redatto accuratamente in base all\'ordinanza ufficiale (OLR 2, RS 822.222) e alle direttive asa. Copre tutti gli argomenti e tipi di domande in modo realistico.',
    btnUnderstandContinue: 'Ho capito e continua',
    resultPassSub: 'Congratulazioni! Hai raggiunto la soglia per superare l\'esame.',
    resultFailSub: 'Per superare l\'esame ufficiale sono necessarie almeno 27 risposte corrette su 30 (90%) (massimo 3 errori).',
    statOpen: 'Aperte',
    guaranteeTitle: 'Garantisci il successo all\'esame',
    guaranteeSub: 'Sblocca tutte le 500 domande originali (2026) secondo l\'OLR 2 svizzero.',
    guaranteeBtn: 'Sblocca tutte le 500 domande (2026) 🔓 (CHF 15.00)',
    btnReviewAnswers: 'Rivedi risposte & spiegazioni',
    btnRepeatExam: 'Ripeti l\'esame',
    btnBackToMenu: 'Torna al menu principal',
    practiceOneMistake: 'esercita errore',
    practiceMultipleMistakes: 'esercita errori',
  );

  static UiTranslations of(String code) {
    switch (code) {
      case 'fr':
        return fr;
      case 'it':
        return it;
      case 'de':
      default:
        return de;
    }
  }
}
