import 'package:flutter/material.dart';

/// Represents metadata for a single project in the registry.
class ProjectInfo {
  /// The display name of the project.
  final String name;

  /// The primary description of the project.
  final String description;

  /// Optional secondary text, such as a translation or technical subtitle.
  final String? secondaryText;

  /// Path to the primary screenshot asset.
  final String screenshotPath;

  /// Optional additional screenshot assets for the gallery view.
  final List<String>? galleryImages;

  /// The URL for the web version of the project, if available.
  final String? webUrl;

  /// The URL for the APK download, if available.
  final String? apkUrl;

  /// The GitHub repository name used for links and sharing.
  final String repoName;

  /// Optional label override for the primary action button (defaults to "Open").
  final String? primaryActionLabel;

  /// Optional icon override for the primary action button (defaults to [Icons.open_in_new_rounded]).
  final IconData? primaryActionIcon;

  const ProjectInfo({
    required this.name,
    required this.description,
    this.secondaryText,
    required this.screenshotPath,
    this.galleryImages,
    this.webUrl,
    this.apkUrl,
    required this.repoName,
    this.primaryActionLabel,
    this.primaryActionIcon,
  });
}

/// Central registry containing all project metadata and global constants.
abstract final class ProjectData {
  /// The GitHub organization or username owning the repositories.
  static const String githubOrg = '3llips3s';

  /// The base domain for hosted projects.
  static const String baseDomain = 'studio10200.dev';

  static const List<ProjectInfo> projects = [
    ProjectInfo(
      name: 'Artikel Vogel',
      description:
          'Fliege durch die richtigen Artikel, um deinen Vogel in der Luft zu halten.',
      secondaryText:
          'Fly through the correct articles to keep your bird airborne.',
      screenshotPath: 'assets/screenshots/vogel.png',
      webUrl: 'https://studio10200.dev/artikel-vogel/',
      apkUrl:
          'https://github.com/3llips3s/artikel-vogel/releases/latest/download/artikel_vogel.apk',
      repoName: 'artikel-vogel',
      primaryActionLabel: 'Play',
      primaryActionIcon: Icons.play_arrow_rounded,
    ),
    ProjectInfo(
      name: 'Hangmensch',
      description:
          'Entkomme dem Galgen, indem du die richtigen Artikel errätst.',
      secondaryText: 'Escape the gallows by guessing the correct noun genders.',
      screenshotPath: 'assets/screenshots/hangmensch.png',
      webUrl: 'https://studio10200.dev/hangmensch/',
      apkUrl:
          'https://github.com/3llips3s/hangmensch/releases/latest/download/hangmensch.apk',
      repoName: 'hangmensch',
      primaryActionLabel: 'Play',
      primaryActionIcon: Icons.play_arrow_rounded,
    ),
    ProjectInfo(
      name: 'Tic Tac Zwö',
      description:
          'Setze dein X oder Ö mit dem richtigen Genus und schlage deine Gegner im Solo-, Pass-und-Play- oder Online-Modus mit Leaderboard.',
      secondaryText:
          'Claim your X or Ö with the correct noun gender and beat your opponents in solo, pass-and-play, or online mode with a leaderboard.',
      screenshotPath: 'assets/screenshots/zwo.png',
      galleryImages: [
        'assets/screenshots/zwo_2.png',
        'assets/screenshots/zwo_3.png',
      ],
      webUrl: null, // APK Only
      apkUrl:
          'https://github.com/3llips3s/tic-tac-zwo/releases/latest/download/tic_tac_zwo.apk',
      repoName: 'tic-tac-zwo',
      primaryActionLabel: 'Play',
      primaryActionIcon: Icons.play_arrow_rounded,
    ),
    ProjectInfo(
      name: 'Wördle',
      description: 'Errate das gesuchte deutsche Nomen in nur sechs Versuchen.',
      secondaryText: 'Guess the hidden German noun in six tries.',
      screenshotPath: 'assets/screenshots/wordle.png',
      webUrl: 'https://studio10200.dev/wordle/',
      apkUrl: null, // Web Only
      repoName: 'wordle',
      primaryActionLabel: 'Play',
      primaryActionIcon: Icons.play_arrow_rounded,
    ),
  ];
}
