import 'package:flutter/material.dart';
import '../core/achievement_system.dart';

const _gold = Color(0xFFC7AD79);
const _ivory = Color(0xFFF0E9DC);
const _muted = Color(0xFFABA99F);
const _ink = Color(0xFF090D0E);

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = AchievementSystem.achievements;
    final unlocked = AchievementSystem.unlockedCount;

    return Scaffold(
      backgroundColor: _ink,
      appBar: AppBar(
        backgroundColor: _ink,
        foregroundColor: _ivory,
        elevation: 0,
        title: const Text(
          'LOGROS',
          style: TextStyle(
            fontFamily: 'Cinzel',
            letterSpacing: 2,
            color: _gold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF191D1C),
                border: Border.all(color: _gold.withValues(alpha: .4)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium, color: _gold, size: 42),
                  const SizedBox(height: 12),
                  const Text(
                    'TU LEGADO',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 13,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$unlocked de ${achievements.length} logros desbloqueados',
                    style: const TextStyle(color: _ivory, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: achievements.isEmpty
                        ? 0
                        : unlocked / achievements.length,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'DESAFÍOS DEL REINO',
              style: TextStyle(
                color: _gold,
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...achievements.map(_achievementCard),
          ],
        ),
      ),
    );
  }

  Widget _achievementCard(Achievement achievement) {
    final unlocked = achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191D1C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: unlocked ? _gold.withValues(alpha: .65) : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: unlocked
                  ? _gold.withValues(alpha: .15)
                  : Colors.white.withValues(alpha: .05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              achievement.icon,
              style: TextStyle(
                fontSize: 27,
                color: unlocked ? null : Colors.white38,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: TextStyle(
                          color: unlocked ? _gold : _ivory,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (unlocked)
                      const Icon(Icons.check_circle, color: _gold, size: 19)
                    else
                      const Icon(Icons.lock_outline, color: _muted, size: 17),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  achievement.description,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: achievement.progressPercentage,
                  minHeight: 5,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    unlocked ? _gold : Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${achievement.progress.clamp(0, achievement.target)} / ${achievement.target}',
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
