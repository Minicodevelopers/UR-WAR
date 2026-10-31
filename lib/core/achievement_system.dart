import 'save_system.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int progress;
  final int target;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    required this.target,
  });

  bool get isUnlocked => progress >= target;

  double get progressPercentage {
    if (target <= 0) return 1;
    return (progress / target).clamp(0.0, 1.0);
  }
}

class AchievementSystem {
  AchievementSystem._();

  static List<Achievement> get achievements {
    final data = SaveSystem.data;

    const campaignMaps = [
      'level_1_forest',
      'level_2_orcs',
      'level_3_snow',
      'level_4_necro',
      'level_5_titan',
    ];

    final completedMaps = campaignMaps.where((mapId) {
      return (data.levelStars[mapId] ?? 0) > 0;
    }).length;

    return [
      Achievement(
        id: 'first_blood',
        title: 'Primera sangre',
        description: 'Derrota a 100 enemigos.',
        icon: '⚔️',
        progress: data.totalKills,
        target: 100,
      ),
      Achievement(
        id: 'treasure_hunter',
        title: 'Cazador de tesoros',
        description: 'Consigue 1.000 monedas de oro.',
        icon: '💰',
        progress: data.totalGoldGathered,
        target: 1000,
      ),
      Achievement(
        id: 'legendary_score',
        title: 'Puntuación legendaria',
        description: 'Alcanza una puntuación de 5.000 puntos.',
        icon: '🏆',
        progress: data.highScore,
        target: 5000,
      ),
      Achievement(
        id: 'adventurer',
        title: 'Aventurero',
        description: 'Completa los cinco niveles de campaña.',
        icon: '🗺️',
        progress: completedMaps,
        target: campaignMaps.length,
      ),
      Achievement(
        id: 'dragon_slayer',
        title: 'Matadragones',
        description: 'Derrota al dragón Varyx.',
        icon: '🐉',
        progress: data.dragonKills,
        target: 1,
      ),
    ];
  }

  static int get unlockedCount =>
      achievements.where((achievement) => achievement.isUnlocked).length;

  static int get totalCount => achievements.length;
}
