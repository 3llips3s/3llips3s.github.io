/// Data model and content manifest for the Project Registry.
class ProjectInfo {
  final String name;
  final String?
  descriptionDe; // Optional German description (informal "Du" form)
  final String? descriptionEn; // Optional English translation
  final String screenshotPath;
  final List<String>?
  galleryImages; // Optional additional screenshots for Lightbox View
  final String? webUrl; // null → no "Play" button
  final String? apkUrl; // null → no "Download" button
  final String repoName; // GitHub repo name for share links

  const ProjectInfo({
    required this.name,
    this.descriptionDe,
    this.descriptionEn,
    required this.screenshotPath,
    this.galleryImages,
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
          'https://github.com/3llips3s/artikel-vogel/releases/latest/download/artikel_vogel.apk',
      repoName: 'artikel-vogel',
    ),
    ProjectInfo(
      name: 'Hangmensch',
      descriptionDe:
          'Entkomme dem Galgen, indem du die richtigen Artikel errätst.',
      descriptionEn: 'Escape the gallows by guessing the correct noun genders.',
      screenshotPath: 'assets/screenshots/hangmensch.png',
      webUrl: 'https://studio10200.dev/hangmensch/',
      apkUrl:
          'https://github.com/3llips3s/hangmensch/releases/latest/download/hangmensch.apk',
      repoName: 'hangmensch',
    ),
    ProjectInfo(
      name: 'Tic Tac Zwö',
      descriptionDe:
          'Setze dein X oder Ö mit dem richtigen Genus und schlage deine Gegner im Solo-, Pass-und-Play- oder Online-Modus mit Leaderboard.',
      descriptionEn:
          'Claim your X or O with the correct noun gender and beat your opponents in solo, pass-and-play, or online mode with a leaderboard.',
      screenshotPath: 'assets/screenshots/zwo.png',
      galleryImages: [
        'assets/screenshots/zwo_2.png',
        'assets/screenshots/zwo_3.png',
      ],
      webUrl: null, // APK Only
      apkUrl:
          'https://github.com/3llips3s/tic-tac-zwo/releases/latest/download/tic_tac_zwo.apk',
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
