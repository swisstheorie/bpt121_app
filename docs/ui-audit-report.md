# BPT 121 Schweiz — Comprehensive UI, Color System & Text/Icon Audit

**Date:** 2026-10-18  
**Scope:** `lib/theme/app_colors.dart`, `lib/main.dart`, `lib/screens/exam_screen.dart`, and associated widgets.  
**Objective:** Resolve theme inconsistencies between Dark and Light modes, document all UI components, texts, and icons, and establish a unified semantic color architecture.

---

## 1. Color & Theme System Audit

### 1.1 Executive Summary of Theme Inconsistencies
When the user selects **"Hell" (Light mode)** in the Profile tab:
1. **The Scaffold background flips to light grey (`#F6F8FA`), but almost every card, container, and dialog remains dark navy/black (`#19202C`, `#232A37`).**
2. **The Hero Exam Card, Topic Cards, Focus Modules, and Profile Tiles appear as stark, heavy black boxes** floating over a light background.
3. **The Exam Screen (`ExamScreen`) completely ignores the active theme** because its `Scaffold` and `AppBar` have `backgroundColor: AppColors.primaryBackground` (`#0C131F`) hardcoded directly in `build()`. Tapping "Prüfung starten" from a light screen results in an abrupt full-screen flash to dark navy.
4. **Dialogs and Bottom Sheets (`_showExamRulesDialog`, `_showPaywallModal`, `_showQuestionNavigatorSheet`, `_showExitConfirmationDialog`) remain dark navy (`#19202C`)** even in Light mode.
5. **Text contrast vulnerabilities**: Several texts specify `AppColors.primaryText` (`#F1F5FA` frosty white) or `AppColors.secondaryText` (`#A9B7C9`), assuming a dark navy container background. If a container's background is partially adapted without updating its children, white text on light backgrounds or black text on dark cards occurs.
6. **Hardcoded Dark Hairline Borders**: Cards and containers use `Border.all(color: AppColors.mutedBorder)` (`#34465B`), which is designed for dark navy surfaces and looks harsh and unpolished on light surfaces.

---

### 1.2 Quantitative Audit of Hardcoded Color Tokens
A codebase scan of `lib/` reveals **976 direct color declarations**:
- **441** occurrences of static `AppColors.*` (e.g. `AppColors.cardBackground`, `AppColors.primaryText`, `AppColors.surfaceContainer`)
- **82** occurrences of raw `Color(0x...)` (e.g. `const Color(0xFF0C131F)`, `const Color(0xFF19202C)`)
- **453** occurrences of Flutter standard `Colors.*` (e.g. `Colors.transparent`, `Colors.white`, `Colors.black`)

#### Breakdown by File:
| File | `AppColors.*` | Raw `Color(0x...)` | `Colors.*` | Total Color Usages | Primary Theme Issues |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `lib/main.dart` | 323 | 39 | 331 | **693** | Cards, badges, dialogs, and text styles hardcoded to dark constants |
| `lib/screens/exam_screen.dart` | 152 | 9 | 157 | **318** | Scaffold, AppBar, cards, option tiles, and dialogs hardcoded to `#0C131F` / `#19202C` |
| `lib/theme/app_colors.dart` | 1 | 34 | 1 | **36** | Pure static constant palette; lacks semantic Light/Dark mode dynamic resolver |

---

### 1.3 Root Causes: Why Components Remain Dark in Light Theme

1. **Static Constant Binding instead of Dynamic Theme Context**:
   `AppColors` is defined as a class of static `const Color` values representing dark navy hues:
   ```dart
   static const Color primaryBackground = Color(0xFF0C131F); // Canvas Base
   static const Color cardBackground = Color(0xFF19202C);    // Surface Layer 1
   static const Color elevatedSurface = Color(0xFF232A37);   // Surface Container High
   static const Color surfaceContainer = Color(0xFF19202C);
   static const Color surfaceContainerHigh = Color(0xFF232A37);
   static const Color surfaceContainerLow = Color(0xFF151C28);
   static const Color surfaceContainerLowest = Color(0xFF070E1A);
   static const Color primaryText = Color(0xFFF1F5FA);       // Frosty white
   static const Color secondaryText = Color(0xFFA9B7C9);     // Blue-grey
   static const Color mutedBorder = Color(0xFF34465B);       // Cold steel
   ```
   In `lib/main.dart` and `lib/screens/exam_screen.dart`, widgets bind directly to `AppColors.surfaceContainer`, `AppColors.cardBackground`, and `AppColors.primaryText` rather than `Theme.of(context).colorScheme.surface` or `Theme.of(context).cardColor`.

2. **Scaffold / Canvas Disconnect**:
   In `lib/main.dart`, `_lightTheme` sets:
   ```dart
   scaffoldBackgroundColor: const Color(0xFFF6F8FA),
   cardColor: const Color(0xFFFFFFFF),
   ```
   However, cards are built using `Container(decoration: BoxDecoration(color: AppColors.surfaceContainer))` instead of using `Card(color: Theme.of(context).cardColor)` or a dynamic surface token.

3. **Isolated Dark Theme in `ExamScreen`**:
   `lib/screens/exam_screen.dart` does not check `Theme.of(context).brightness`. Lines 530–545 explicitly set:
   ```dart
   Scaffold(
     backgroundColor: AppColors.primaryBackground, // Hardcoded #0C131F
     appBar: AppBar(
       backgroundColor: AppColors.primaryBackground, // Hardcoded #0C131F
   ```
   As a consequence, the entire exam experience is locked to Dark Mode.

4. **Popups, Bottom Sheets & Dialogs Hardcoded**:
   - `_showOfficialExamInfoDialog()` (line 942 of `lib/main.dart`): `backgroundColor: AppColors.surfaceContainer`
   - `_showPaywallModal()` (line 660 of `lib/main.dart`): `backgroundColor: AppColors.surfaceContainer`
   - `_showFinishConfirmationDialog()` (line 275 of `lib/screens/exam_screen.dart`): `backgroundColor: AppColors.surfaceContainer`
   - `_showExitConfirmationDialog()` (line 425 of `lib/screens/exam_screen.dart`): `backgroundColor: AppColors.surfaceContainer`
   - `_showQuestionNavigatorSheet()` (line 630 of `lib/screens/exam_screen.dart`): `backgroundColor: AppColors.surfaceContainer`

---

## 2. Comprehensive Screen, Tab, Text & Icon Inventory

### Tab 1: Home ("Prüfung") — Cockpit & Overview

| Component | UI Element Type | Current Text / Label | Icon / Graphic | Current Colors | Required Light Theme Token |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Top Bar** | Header Row | `BPT 121 Schweiz`<br>`OFFIZIELLE THEORIE` | `Icons.local_taxi_rounded` | Container: `surfaceContainerHigh`<br>Icon: `premiumBlue`<br>Text: `primaryText` / `gold` | Surface Container<br>Text Primary<br>Accent Gold |
| | Badge Pill | `🇨🇭 DE` (or FR/IT) | – | `surfaceContainerHigh`, border `mutedBorder` | Surface High, border `borderSubtle` |
| **Welcome Framing** | Super-title | `SCHWEIZER STANDARDS · BPT 121 VORBEREITUNG` | – | `secondaryText` (11sp, bold) | `textSecondary` |
| | Main Greeting | `Dein Weg zur Prüfungsreife` | – | `primaryText` (22sp, bold) | `textPrimary` |
| | Pro Badge | `BPT 121 PRO` / `START` | `Icons.shield_outlined` | Container: `alpineJade` 15%<br>Text: `alpineJade` | Success Surface, Success text |
| **Hero Exam Master Card** | Card Container | Cockpit Wrapper | – | `surfaceContainer` (`#19202C`), border `mutedBorder` | **`cardBackground` (`#FFFFFF`)**, border `borderSubtle` |
| | Header Badge | `SIMULATION`<br>`Offizielle Prüfung` | `Icons.verified_rounded`<br>`Icons.info_outline_rounded` | Icon: `gold`<br>Title: `primaryText`<br>Info: `secondaryText` | Icon: `goldDark`<br>Title: `textPrimary`<br>Info: `textSecondary` |
| | Readiness Pill | `BEREIT FÜR START` / `X% BEREIT` | Dot indicator | Pill: `surfaceContainerHighest`<br>Dot/Text: `alpineJade` / `secondaryText` | Pill: Light Grey (`#EAEFF5`)<br>Text: Jade / Grey |
| | Telemetry Row | `X/500 GEMEISTERT`<br>`X% QUOTE`<br>`X/30 LETZTER TEST` | Hairline dividers | Container: `surfaceContainerLow`<br>Values: `primaryText` / `gold` / `alpineJade`<br>Labels: `secondaryText` | Container: Sub-card Grey (`#F0F4F8`)<br>Values: `textPrimary`<br>Labels: `textSecondary` |
| | Progress Header | `Ausbildungsfortschritt`<br>`Ziel: 90% Schwellenwert` | – | Label: `secondaryText`<br>Goal: `gold` | Label: `textSecondary`<br>Goal: `goldDark` |
| | Progress Bar | 8px rounded track | – | Track: `surfaceContainerHighest`<br>Fill: `premiumBlue` / `alpineJade` | Track: Light Track (`#E1E4E8`)<br>Fill: Blue / Jade |
| | Parameter Badge 1 | `30 Fragen` | `Icons.format_list_numbered_rounded` | Container: `surfaceContainerLow`<br>Icon: `gold`, Text: `primaryText` | Container: `#F0F4F8`<br>Icon: `goldDark`, Text: `textPrimary` |
| | Parameter Badge 2 | `45 Minuten` | `Icons.timer_outlined` | Container: `surfaceContainerLow`<br>Icon: `gold`, Text: `primaryText` | Container: `#F0F4F8`<br>Icon: `goldDark`, Text: `textPrimary` |
| | Parameter Badge 3 | `Max. 3 Fehler` | `Icons.verified_user_outlined` | Container: `surfaceContainerLow`<br>Icon: `gold`, Text: `primaryText` | Container: `#F0F4F8`<br>Icon: `goldDark`, Text: `textPrimary` |
| | Primary Button | `Prüfung starten` | `Icons.play_arrow_rounded` | Button: `premiumBlue` (`#75B9F2`)<br>Foreground: `#0C131F` | Button: Accent Blue / Swiss Red<br>Foreground: White |
| | Mode Adjuster | `Prüfungsmodus anpassen` | `Icons.tune_rounded` | Outlined Button: border `mutedBorder`<br>Text/Icon: `secondaryText` | Outlined Button: border `borderSubtle`<br>Text: `textSecondary` |
| **Last Exam Card** | Container | Result Card | `Icons.history_rounded` | `surfaceContainer`, border `alpineJade` or `coralRed` | `cardBackground` (`#FFFFFF`), border Jade/Red |
| | Result Badge | `Bestanden` / `Nicht bestanden` | – | Jade / Red 15% pill | Jade / Red light pill |
| | Score & Meta | `X/30 (X%)`<br>`🇨🇭 DE · DD.MM.YYYY` | – | Score: `primaryText`<br>Meta: `secondaryText` | Score: `textPrimary`<br>Meta: `textSecondary` |
| **Catalog Section** | Section Header | `ARV 2 Themenkatalog`<br>`6 KATEGORIEN` | – | Title: `primaryText`<br>Badge: `gold` on `surfaceContainerHigh` | Title: `textPrimary`<br>Badge: `goldDark` on `#EAEFF5` |
| | Topic Card (x6) | Title, Article Subtitle, `X / Y gesehen` | `Icons.local_taxi_rounded`, `Icons.speed_rounded`, `Icons.coffee_rounded`, etc. | Card: `surfaceContainer`<br>Title: `primaryText`<br>Badges: `surfaceContainerHigh` | Card: `cardBackground` (`#FFFFFF`)<br>Title: `textPrimary`<br>Badges: `#F0F4F8` |
| **Lernrhythmus Card** | Container | `Empfohlener Lernrhythmus`<br>`3 Schritte zum Erfolg` | `Icons.schedule_rounded` | `surfaceContainer`, border `mutedBorder` | `cardBackground` (`#FFFFFF`), border `borderSubtle` |
| | 7-Day Pills | `Mo, Di, Mi, Do, Fr, Sa, So` | `Icons.check_rounded`, `★`, `·` | `surfaceContainerLowest` / `surfaceContainerHighest` | Light circles (`#EAEFF5` / `#F0F4F8`) |
| **Accreditation Card**| Container | `Offizielle Chauffeurzulassung (BPT 121)` | `Icons.verified_rounded` | `surfaceContainer`, icon `alpineJade` | `cardBackground` (`#FFFFFF`), icon `alpineJade` |

---

### Tab 2: "Lernen" — Topic Training & Focus Drills

| Component | UI Element Type | Current Text / Label | Icon / Graphic | Current Colors | Required Light Theme Token |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Header** | Title & Pill | `Lernbereich`<br>`6 THEMENGEBIETE` | – | Title: `primaryText`<br>Pill: `gold` on `surfaceContainerHigh` | Title: `textPrimary`<br>Pill: `goldDark` on `#EAEFF5` |
| | Subtitle | `Vertiefen Sie Ihr Wissen systematisch nach offiziellen Schweizer ARV 2 Richtlinien.` | – | `secondaryText` | `textSecondary` |
| **Freemium Banner** | Locked Banner | `30 / 500 Fragen freigeschaltet 🔒`<br>`Kostenlose Testversion mit Schweizer Quoten.` | `Icons.lock_rounded` | Background: `cardBackground`<br>Border: `accentGold` 50%<br>Icon: `accentGold` | Background: Amber/Gold tint (`#FFFBEB`)<br>Border: Gold 40%<br>Icon: Gold |
| | CTA Button | `Freischalten` | – | FilledButton: `gold`, foreground `#0C131F` | FilledButton: `goldDark`, foreground White |
| **Focus Training** | Section Header | `Gezieltes Training`<br>`SCHWERPUNKTE` | – | Header: `primaryText`<br>Sub: `gold` | Header: `textPrimary`<br>Sub: `goldDark` |
| | Focus Card 1 | `Fehlerkorrektur`<br>`X Fragen zum Wiederholen` | `Icons.replay_rounded` | Card: `cardBackground`, border `mutedBorder`<br>Icon: `gold`, Badge: `gold` 15% | Card: `#FFFFFF`, border `borderSubtle`<br>Icon: `goldDark` |
| | Focus Card 2 | `Favoriten`<br>`X Fragen markiert` | `Icons.star_rounded` | Card: `cardBackground`, border `mutedBorder`<br>Icon: `premiumBlue`, Badge: `premiumBlue` 15% | Card: `#FFFFFF`, border `borderSubtle`<br>Icon: Accent Blue |
| **Topics List** | Section Header | `Thementraining`<br>`6 Themengebiete · X frei` | – | Header: `primaryText`<br>Sub: `secondaryText` | Header: `textPrimary`<br>Sub: `textSecondary` |
| | Topic Tile | Topic Name, Article Reference | Category Icons | Tile: `surfaceContainer`<br>Border: `mutedBorder` | Tile: `cardBackground` (`#FFFFFF`)<br>Border: `borderSubtle` |
| | Seen Progress | `X / Y gesehen (Z%)` | – | `secondaryText` | `textSecondary` |
| | Status Badges | `X Richtig`<br>`Y Falsch` | – | Green 15% pill (`alpineJade`)<br>Red 15% pill (`coralRed`) | Green 15% pill<br>Red 15% pill |
| | Topic Mistakes CTA | `X Falsche Fragen üben` | `Icons.chevron_right_rounded` | Button: `coralRed` 15%<br>Border: `coralRed` 40%<br>Text: `coralRed` | Button: Soft Red (`#FEE2E2`)<br>Text: Crimson (`#DC2626`) |

---

### Tab 3: "Profil" — Settings & Information

| Component | UI Element Type | Current Text / Label | Icon / Graphic | Current Colors | Required Light Theme Token |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Header** | Page Title | `Profil & Einstellungen` | – | `primaryText` (18sp, bold) | `textPrimary` |
| **User Card** | Container | `BPT 121 Kandidat`<br>`Schweizer Taxiprüfung (ARV 2)` | `Icons.person_outline_rounded` | Card: `cardBackground`<br>Avatar Bg: `elevatedSurface`<br>Avatar Icon: `premiumBlue`<br>Text: `primaryText` / `secondaryText` | Card: `#FFFFFF`<br>Avatar Bg: `#F0F4F8`<br>Avatar Icon: Accent Blue<br>Text: `textPrimary` / `textSecondary` |
| | Version Pill | `PRO / Vollversion ✨` or `Kostenlos` | – | Jade 15% or `elevatedSurface` | Jade 15% or `#F0F4F8` |
| **Lernstand Section** | Header | `Lernstand & Wiederholung` | – | `primaryText` (15sp, bold) | `textPrimary` |
| | Drill Button 1 | `Falsche Fragen`<br>`X Fragen zum Wiederholen` | `Icons.replay_rounded`<br>`Üben` pill | Card: `cardBackground`, border `mutedBorder`<br>Title: `primaryText`, Sub: `secondaryText` | Card: `#FFFFFF`, border `borderSubtle`<br>Title: `textPrimary`, Sub: `textSecondary` |
| | Drill Button 2 | `Favoriten`<br>`X Fragen gespeichert` | `Icons.star_rounded`<br>`Üben` pill | Card: `cardBackground`, border `mutedBorder`<br>Title: `primaryText`, Sub: `secondaryText` | Card: `#FFFFFF`, border `borderSubtle`<br>Title: `textPrimary`, Sub: `textSecondary` |
| **Theme Selector** | Section Header | `Darstellung & Design` | – | `primaryText` (15sp, bold) | `textPrimary` |
| | Segment Container | 3-way toggle container | – | Container: `cardBackground` (`#19202C`), border `mutedBorder` | Container: `#FFFFFF`, border `borderSubtle` |
| | Option: Hell | `Hell` | `Icons.wb_sunny_rounded` | Selected: `elevatedSurface`, border `gold`<br>Unselected: Transparent | Selected: `#F0F4F8`, border `goldDark`<br>Unselected: Transparent |
| | Option: Dunkel | `Dunkel` | `Icons.nightlight_round` | Selected: `elevatedSurface`, border `gold` | Selected: `#F0F4F8`, border `goldDark` |
| | Option: System | `System` | `Icons.smartphone_rounded` | Selected: `elevatedSurface`, border `gold` | Selected: `#F0F4F8`, border `goldDark` |
| **Language Section** | Section Header | `Prüfungssprache` | – | `primaryText` (15sp, bold) | `textPrimary` |
| | Language Tiles | `Deutsch 🇨🇭`, `Français 🇫🇷`, `Italiano 🇮🇹` | `Icons.check_rounded` | Selected: `elevatedSurface`, border `premiumBlue`<br>Unselected: `cardBackground`, border `mutedBorder` | Selected: Blue tint (`#EBF5FF`), border Accent Blue<br>Unselected: `#FFFFFF`, border `borderSubtle` |
| | Disclaimer Note | Notice for French/Italian questions | – | `secondaryText` (italic, 12sp) | `textSecondary` |
| **Legal / Info** | Section Header | `Rechtliche Grundlagen & Info` | – | `primaryText` (15sp, bold) | `textPrimary` |
| | Info Tile 1 | `Offizielle Verordnung`<br>`ARV 2 (SR 822.222)` | `Icons.menu_book_rounded` | ListTile in `cardBackground`<br>Icon: `premiumBlue`, Title: `primaryText`, Sub: `secondaryText` | ListTile in `#FFFFFF`<br>Icon: Accent Blue, Title: `textPrimary`, Sub: `textSecondary` |
| | Info Tile 2 | `Datenspeicherung`<br>`Lokal auf diesem Gerät` | `Icons.lock_outline_rounded` | ListTile in `cardBackground` | ListTile in `#FFFFFF` |
| | Info Tile 3 | `App-Version`<br>`1.0.0 (Build 2026)` | `Icons.info_outline_rounded` | ListTile in `cardBackground` | ListTile in `#FFFFFF` |
| **Developer Toggle**| Header & Switch | `Entwickler-Optionen`<br>`Entwickler: Premium Freischalten` | `Icons.verified_rounded` / `Icons.lock_outline_rounded` | Material: `cardBackground`<br>Switch: `alpineJade`<br>Title: `primaryText`, Sub: `secondaryText` | Material: `#FFFFFF`<br>Switch: `alpineJade`<br>Title: `textPrimary`, Sub: `textSecondary` |
| **Restore Purchases**| Outlined Action | `Käufe wiederherstellen` | `Icons.restore_rounded` | OutlinedButton: border `mutedBorder`<br>Text/Icon: `secondaryText` | OutlinedButton: border `borderSubtle`<br>Text: `textSecondary` |

---

### Exam Screen (`ExamScreen`) — Live Simulation & Practice

| Component | UI Element Type | Current Text / Label | Icon / Graphic | Current Colors | Required Light Theme Token |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Screen Root** | Scaffold & AppBar | Screen Base | – | `backgroundColor: AppColors.primaryBackground` (`#0C131F`) | `backgroundColor: Theme.of(context).scaffoldBackgroundColor` (`#F6F8FA`) |
| **App Bar** | Title | Dynamic (e.g. `Prüfungssimulation`, `Thementraining`) | – | `primaryText` | `textPrimary` |
| | Back Action | Navigation pop | `Icons.arrow_back_rounded` | `primaryText` | `textPrimary` |
| | Timer Badge | `MM:SS` (45 min countdown) | `Icons.timer_outlined` | Pill: `surfaceContainerHigh`<br>Icon/Text: `gold` (or `coralRed` when < 5m) | Pill: `#F0F4F8`<br>Icon/Text: `goldDark` (or Red) |
| | Navigator Action | Question grid trigger | `Icons.grid_view_rounded` | `premiumBlue` | Accent Blue |
| | Favorite Action | Toggle bookmark | `Icons.star_rounded` / `Icons.star_outline_rounded` | `accentGold` / `secondaryText` | `accentGold` / `secondaryText` |
| **Progress Header** | Counter & Topic | `Frage X von Y`<br>`Topic Category Name` | – | Counter: `secondaryText`<br>Topic Pill: `surfaceContainerHigh`, text `premiumBlue` | Counter: `textSecondary`<br>Topic Pill: `#F0F4F8`, text Accent Blue |
| | Progress Bar | LinearProgressIndicator | – | Track: `surfaceContainerHigh`<br>Fill: `premiumGreen` (`#5CC7A0`) | Track: `#E1E4E8`<br>Fill: `premiumGreen` |
| **Question Card** | Container | Official ARV 2 Question Text | – | Container: `surfaceContainer` (`#19202C`), border `mutedBorder`<br>Text: `primaryText` (16sp, w600) | Container: **`#FFFFFF`**, border `borderSubtle`<br>Text: **`textPrimary` (`#1F2328`)** |
| **Option Tile (A, B, C)** | Interactive Card | Option Letter ('A', 'B', 'C') & Answer Text | Check / Error icons | Neutral: `surfaceContainer`, border `mutedBorder`<br>Selected Sim: `surfaceContainerHigh`, border `premiumBlue`<br>Practice Correct: Green 15%<br>Practice Wrong: Red 15% | Neutral: **`#FFFFFF`**, border `borderSubtle`<br>Selected Sim: Blue tint (`#EBF5FF`), border Accent Blue<br>Practice Correct: Soft Jade tint<br>Practice Wrong: Soft Red tint |
| **Explanation Box** | Container | `Erklärung & Rechtsgrundlage`<br>`Verifiziert`<br>Legal citation text | `Icons.menu_book_rounded`<br>`Icons.verified_rounded` | Container: `surfaceContainerLow`<br>Header: `gold`<br>Citation: `secondaryText` | Container: `#F0F4F8`<br>Header: `goldDark`<br>Citation: `textSecondary` |
| **Navigation Row** | Buttons | `Zurück`<br>`Nächste Frage` / `Jetzt abgeben` | `Icons.arrow_back_rounded`<br>`Icons.arrow_forward_rounded` | Zurück: OutlinedButton `mutedBorder`<br>Nächste: FilledButton `premiumBlue` (fg `#0C131F`) | Zurück: OutlinedButton `borderSubtle`<br>Nächste: FilledButton Accent Blue (fg White) |
| **Result View** | Status Graphic | Trophy / Replay circle | `Icons.emoji_events_rounded` / `Icons.replay_rounded` | Jade 15% or Red 15% | Jade 15% or Red 15% |
| | Status Headline | `Bestanden!` or `Nicht bestanden` | – | `successGreen` or `errorRed` (24sp, bold) | `successGreen` or `errorRed` |
| | Score Breakdown Card| Columns: `Richtig`, `Falsch`, `Offen`, `Quote` | – | Card: `surfaceContainer` (`#19202C`), border `mutedBorder`<br>Values: `primaryText`<br>Labels: Green, Red, Grey, Blue | Card: **`#FFFFFF`**, border `borderSubtle`<br>Values: `textPrimary`<br>Labels: Green, Red, Grey, Blue |
| | Result Actions | `Antworten prüfen`<br>`Neue Prüfung starten` | `Icons.rate_review_rounded`<br>`Icons.refresh_rounded` | OutlinedButton border `mutedBorder`<br>FilledButton `premiumBlue` (fg `#0C131F`) | OutlinedButton border `borderSubtle`<br>FilledButton Accent Blue (fg White) |
| **Review View** | Header & Tile | `Überprüfung: Frage X von Y`<br>`Zum Ergebnis` | Question Card & Options with 'Richtig'/'Falsch' indicators | `surfaceContainer`, `surfaceContainerHigh` | **`#FFFFFF`**, `#F0F4F8` |

---

### Paywall, Sheets & Dialogs

| Dialog / Sheet | UI Element Type | Texts & Descriptions | Icons | Current Colors | Required Light Theme Token |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Paywall Modal** | Bottom Sheet | `BPT 121 Vollversion freischalten`<br>`Uneingeschränkte ARV 2 Theorieausbildung` | `Icons.workspace_premium_rounded` | Sheet: `surfaceContainer` (`#19202C`)<br>Drag Handle: `mutedBorder`<br>Title: `primaryText` | Sheet: **`#FFFFFF`**<br>Drag Handle: `#D0D7DE`<br>Title: `textPrimary` |
| | Feature Row 1 | `Alle 500 ARV 2 Prüfungsfragen`<br>`Kompletter Fragenpool nach Schweizer asa Standard.` | `Icons.all_inclusive_rounded` | Icon: `gold` on `surfaceContainerHigh` | Icon: `goldDark` on `#F0F4F8` |
| | Feature Row 2 | `Dynamische Prüfungssimulation`<br>`Unbegrenzte Zufallsprüfungen mit realem 45-Minuten-Timer.` | `Icons.shuffle_rounded` | Icon: `gold` on `surfaceContainerHigh` | Icon: `goldDark` on `#F0F4F8` |
| | Feature Row 3 | `100% Offline & Werbefrei`<br>`Einmaliger Kauf – kein Abo, keine Registrierung.` | `Icons.wifi_off_rounded` | Icon: `gold` on `surfaceContainerHigh` | Icon: `goldDark` on `#F0F4F8` |
| | Unlock Button | `Jetzt freischalten (Einmalig CHF 19.–)` | `Icons.check_circle_rounded` | FilledButton: `gold`, fg `#0C131F` | FilledButton: `gold`, fg `#0C131F` |
| | Dismiss Button | `Später` | – | TextButton: `secondaryText` | TextButton: `textSecondary` |
| **Exam Rules Dialog** | AlertDialog | `Offizielle Prüfungsregeln`<br>`Theorieprüfung für den Personentransport...` | `Icons.info_outline_rounded`<br>`Icons.close_rounded` | Dialog: `surfaceContainer` (`#19202C`), border `mutedBorder`<br>Title: `primaryText` | Dialog: **`#FFFFFF`**, border `borderSubtle`<br>Title: `textPrimary` |
| | Rule 1 | `30 Fragen (A, B, C)`<br>`Proportionale Verteilung über alle 6 Themen.` | `Icons.format_list_numbered_rounded` | Icon: `gold`, Title: `primaryText`, Sub: `secondaryText` | Icon: `goldDark`, Title: `textPrimary`, Sub: `textSecondary` |
| | Rule 2 | `45 Minuten Prüfungszeit`<br>`Echtes Zeitlimit mit Countdown.` | `Icons.timer_outlined` | Icon: `gold`, Title: `primaryText`, Sub: `secondaryText` | Icon: `goldDark`, Title: `textPrimary`, Sub: `textSecondary` |
| | Rule 3 | `Maximal 3 Fehler erlaubt`<br>`Mindestens 27/30 Punkte (90%) zum Bestehen.` | `Icons.verified_user_outlined` | Icon: `gold`, Title: `primaryText`, Sub: `secondaryText` | Icon: `goldDark`, Title: `textPrimary`, Sub: `textSecondary` |
| | Confirm Action | `Verstanden` | – | FilledButton: `premiumBlue`, fg `#0C131F` | FilledButton: Accent Blue, fg White |
| **Exit Confirm Dialog** | AlertDialog | `Prüfung abbrechen?`<br>`Möchten Sie die laufende Prüfung wirklich verlassen?` | – | Dialog: `surfaceContainer`<br>Actions: `coralRed` button | Dialog: **`#FFFFFF`**<br>Actions: Crimson button |
| **Submit Confirm Dialog**| AlertDialog | `Prüfung abgeben?`<br>`Beantwortete Fragen: X von Y`<br>`Offene Fragen: Z` | `Icons.assignment_turned_in_rounded` | Dialog: `surfaceContainer`<br>Actions: `alpineJade` button | Dialog: **`#FFFFFF`**<br>Actions: Jade button |
| **Question Navigator** | Bottom Sheet | `Fragenübersicht`<br>Grid of numbers 1..30 | `Icons.close_rounded` | Sheet: `surfaceContainer`<br>Unanswered Tile: `surfaceContainerHigh`<br>Answered Tile: `premiumBlue` | Sheet: **`#FFFFFF`**<br>Unanswered Tile: `#F0F4F8`<br>Answered Tile: Accent Blue |

---

## 3. Architectural Clean-Up Plan

### 3.1 Design Principles for Unified Dynamic Theming
To cleanly adapt 100% of widgets between Dark and Light mode without breaking any existing features or test suites:
1. **Never use static compile-time color constants for surfaces, cards, text, or borders.**
2. **Introduce a context-aware helper `AppColors.of(context)`** that inspects `Theme.of(context).brightness`.
3. **Preserve brand accents (Swiss Gold, Alpine Jade, Coral Red) while calibrating their luminance** for readability against white vs dark navy backgrounds.

---

### 3.2 Semantic Color Token Matrix

| Semantic Token | Dark Mode (`Brightness.dark`) | Light Mode (`Brightness.light`) | Intended Usage |
| :--- | :--- | :--- | :--- |
| **`scaffoldBg`** | `Color(0xFF0F141C)` (Deep Canvas) | `Color(0xFFF6F8FA)` (Subtle Cool Grey) | Screen background / Scaffold canvas |
| **`cardBg`** | `Color(0xFF171F2B)` (Surface Layer 1) | `Color(0xFFFFFFFF)` (Pure White Card) | Primary card containers, question cards, dialogs |
| **`surfaceHigh`** | `Color(0xFF232A37)` (Elevated Layer) | `Color(0xFFF0F4F8)` (Light Soft Grey) | Nested sub-containers, badges, telemetry containers |
| **`surfaceHighest`**| `Color(0xFF2E3542)` (Pill Layer) | `Color(0xFFE2E8F0)` (Divider/Pill Grey) | Inactive tracks, status pills, progress bar background |
| **`textPrimary`** | `Color(0xFFF1F5FA)` (Frosty White) | `Color(0xFF1F2328)` (Material 3 Dark Charcoal)| Headings, question text, primary values |
| **`textSecondary`** | `Color(0xFFA9B7C9)` (Muted Slate) | `Color(0xFF59636E)` (Neutral Grey) | Subtitles, legal notes, labels, timestamps |
| **`textTertiary`** | `Color(0xFF5A6E85)` (Disabled) | `Color(0xFF8C959F)` (Light Disabled) | Placeholders, inactive items |
| **`borderSubtle`** | `Color(0xFF34465B)` (Cold Steel Hairline) | `Color(0xFFD0D7DE)` (Hairline Border) | Card borders, dividers, list tile borders |
| **`borderStrong`** | `Color(0xFF4B6079)` | `Color(0xFFAFB8C1)` | Active/focused element outlines |
| **`primaryAccent`** | `Color(0xFF75B9F2)` (Ice Blue) | `Color(0xFF0969DA)` (Swiss Navy/Blue) | Primary buttons, active tabs, selected states |
| **`onPrimary`** | `Color(0xFF0C131F)` (Dark contrast) | `Color(0xFFFFFFFF)` (White contrast) | Text/icons inside primary buttons |
| **`accentGold`** | `Color(0xFFD6AD55)` (Swiss Gold) | `Color(0xFFB45309)` (Warm Amber Gold) | Badges, warnings, milestones, streaks |
| **`successJade`** | `Color(0xFF5CC7A0)` (Alpine Jade) | `Color(0xFF16A34A)` (Emerald Jade) | Passed exams, correct answers, verification |
| **`coralRed`** | `Color(0xFFF87171)` (Controlled Coral) | `Color(0xFFDC2626)` (Clean Crimson) | Failed exams, wrong answers, timer alert |

---

### 3.3 Implementation Blueprint: `AppThemeColors`

```dart
class AppThemeColors {
  final Brightness brightness;
  final Color scaffoldBg;
  final Color cardBg;
  final Color surfaceHigh;
  final Color surfaceHighest;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color borderSubtle;
  final Color borderStrong;
  final Color primaryAccent;
  final Color onPrimary;
  final Color accentGold;
  final Color successJade;
  final Color coralRed;

  const AppThemeColors._({
    required this.brightness,
    required this.scaffoldBg,
    required this.cardBg,
    required this.surfaceHigh,
    required this.surfaceHighest,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.borderSubtle,
    required this.borderStrong,
    required this.primaryAccent,
    required this.onPrimary,
    required this.accentGold,
    required this.successJade,
    required this.coralRed,
  });

  static const dark = AppThemeColors._(
    brightness: Brightness.dark,
    scaffoldBg: Color(0xFF0F141C),
    cardBg: Color(0xFF171F2B),
    surfaceHigh: Color(0xFF232A37),
    surfaceHighest: Color(0xFF2E3542),
    textPrimary: Color(0xFFF1F5FA),
    textSecondary: Color(0xFFA9B7C9),
    textTertiary: Color(0xFF5A6E85),
    borderSubtle: Color(0xFF34465B),
    borderStrong: Color(0xFF4B6079),
    primaryAccent: Color(0xFF75B9F2),
    onPrimary: Color(0xFF0C131F),
    accentGold: Color(0xFFD6AD55),
    successJade: Color(0xFF5CC7A0),
    coralRed: Color(0xFFF87171),
  );

  static const light = AppThemeColors._(
    brightness: Brightness.light,
    scaffoldBg: Color(0xFFF6F8FA),
    cardBg: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFF0F4F8),
    surfaceHighest: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF1F2328),
    textSecondary: Color(0xFF59636E),
    textTertiary: Color(0xFF8C959F),
    borderSubtle: Color(0xFFD0D7DE),
    borderStrong: Color(0xFFAFB8C1),
    primaryAccent: Color(0xFF0969DA),
    onPrimary: Color(0xFFFFFFFF),
    accentGold: Color(0xFFB45309),
    successJade: Color(0xFF16A34A),
    coralRed: Color(0xFFDC2626),
  );

  static AppThemeColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}
```

---

### 3.4 5-Step Execution Plan

1. **Step 1: Extend `lib/theme/app_colors.dart`**
   - Retain existing `AppColors` constants for backward compatibility so no existing code or tests break prematurely.
   - Add `AppThemeColors` and the `AppColors.of(context)` resolver.
2. **Step 2: Update `lib/main.dart` ThemeData definitions**
   - Ensure `_lightTheme` and `_darkTheme` properly map `colorScheme`, `cardColor`, `scaffoldBackgroundColor`, and `appBarTheme`.
3. **Step 3: Refactor `lib/main.dart` UI Build Methods**
   - In `_buildHomeTab`, `_buildLernenTab`, `_buildStatistikTab`, `_buildProfilTab`, and all sub-builders, obtain `final colors = AppColors.of(context);`.
   - Replace hardcoded `AppColors.surfaceContainer` with `colors.cardBg`, `AppColors.primaryText` with `colors.textPrimary`, `AppColors.mutedBorder` with `colors.borderSubtle`, etc.
   - Update `_showPaywallModal` and `_showOfficialExamInfoDialog` to use `colors.cardBg`.
4. **Step 4: Refactor `lib/screens/exam_screen.dart`**
   - Remove hardcoded `backgroundColor: AppColors.primaryBackground` from `Scaffold` and `AppBar`. Let it inherit from the active `Theme`.
   - Obtain `final colors = AppColors.of(context);` inside `build()`, `_buildQuestionView()`, `_buildOptionTile()`, `_buildResultView()`, etc.
   - Refactor dialogs and sheets to use `colors.cardBg`.
5. **Step 5: Rigorous Verification**
   - Run `flutter analyze` to ensure 0 errors/warnings.
   - Run `flutter test` across the entire 27-test suite.
   - Build debug APK and install on the connected Android device to visually verify seamless switching between Light, Dark, and System modes.
