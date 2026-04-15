/// Data model and content manifest for the Project Registry.
class ProjectInfo {
  final String name;
  final String descriptionDe; // German description (informal "Du" form)
  final String descriptionEn; // English translation
  final String screenshotPath;
  final String? webUrl; // null → no "Play" button
  final String? apkUrl; // null → no "Download" button
  final String repoName; // GitHub repo name for share links

  const ProjectInfo({
    required this.name,
    required this.descriptionDe,
    required this.descriptionEn,
    required this.screenshotPath,
    this.webUrl,
    this.apkUrl,
    required this.repoName,
  });
}

/// Content Manifest (Section 8 of project guide).
abstract final class ProjectData {
  static const String githubOrg = '3llips3s';
  static const String baseDomain = 'studio10200.dev';

  static const List<ProjectInfo> projects = [
    ProjectInfo(
      name: 'Artikel Vogel',
      descriptionDe:
          'Fliege durch die richtigen Artikel, um deinen Vogel in der Luft zu halten.',
      descriptionEn:
          'Fly through the correct articles to keep your bird airborne.',
      screenshotPath: 'assets/screenshots/vogel.png',
      webUrl: 'https://studio10200.dev/artikel-vogel/',
      apkUrl:
          'https://github.com/3llips3s/artikel-vogel/releases/latest/download/app-release.apk',
      repoName: 'artikel-vogel',
    ),
    ProjectInfo(
      name: 'Hangmensch',
      descriptionDe:
          'Rette den Hangmensch vor dem Galgen, indem du die richtigen Artikel errätst.',
      descriptionEn:
          'Save the "Hangmensch" from the gallows by guessing the correct noun genders.',
      screenshotPath: 'assets/screenshots/hangmensch.png',
      webUrl: 'https://studio10200.dev/hangmensch/',
      apkUrl:
          'https://github.com/3llips3s/hangmensch/releases/latest/download/app-release.apk',
      repoName: 'hangmensch',
    ),
    ProjectInfo(
      name: 'Tic Tac Zwö',
      descriptionDe:
          'Setze dein X oder O mit dem richtigen Genus und schlage deine Gegner im Solo-, Pass-and-Play- oder Online-Modus mit Bestenliste.',
      descriptionEn:
          'Claim your X or O with the correct noun gender and beat your opponents in solo, pass-and-play, or online mode with a leaderboard.',
      screenshotPath: 'assets/screenshots/zwo.png',
      webUrl: null, // APK Only
      apkUrl:
          'https://github.com/3llips3s/tic-tac-zwo/releases/latest/download/app-release.apk',
      repoName: 'tic-tac-zwo',
    ),
    ProjectInfo(
      name: 'Wördle',
      descriptionDe:
          'Errate das gesuchte deutsche Nomen in nur sechs Versuchen.',
      descriptionEn: 'Guess the hidden German noun in six tries.',
      screenshotPath: 'assets/screenshots/wordle.png',
      webUrl: 'https://studio10200.dev/wordle/',
      apkUrl: null, // Web Only
      repoName: 'wordle',
    ),
  ];
}
