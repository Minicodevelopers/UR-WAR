import 'package:flutter_test/flutter_test.dart';
import 'package:ur_war/core/save_system.dart';

void main() {
  group('SaveData.fromJson', () {
    test('uses safe defaults when the profile is empty', () {
      final data = SaveData.fromJson({});

      expect(data.highScore, 0);
      expect(data.dragonKills, 0);
      expect(data.unlockedCampaignLevel, 1);
      expect(data.soundEnabled, isTrue);
      expect(data.musicEnabled, isTrue);
      expect(data.soundVolume, 0.7);
      expect(data.musicVolume, 0.3);
      expect(data.controlScale, 1.0);
    });

    test('clamps invalid configuration values to allowed ranges', () {
      final data = SaveData.fromJson({
        'highScore': -10,
        'unlockedCampaignLevel': 99,
        'soundVolume': 5.0,
        'musicVolume': -2.0,
        'controlScale': 10.0,
      });

      expect(data.highScore, 0);
      expect(data.unlockedCampaignLevel, 5);
      expect(data.soundVolume, 1.0);
      expect(data.musicVolume, 0.0);
      expect(data.controlScale, 1.3);
    });

    test('ignores values with the wrong type', () {
      final data = SaveData.fromJson({
        'highScore': 'muchos puntos',
        'soundEnabled': 'sí',
        'levelStars': 'no es un mapa',
        'tutorialHintsSeen': 'no es una lista',
      });

      expect(data.highScore, 0);
      expect(data.soundEnabled, isTrue);
      expect(data.levelStars, isEmpty);
      expect(data.tutorialHintsSeen, isEmpty);
    });

    test('loads the dragon defeat counter from the profile', () {
      final data = SaveData.fromJson({'dragonKills': 3});

      expect(data.dragonKills, 3);
    });

    test('saves and restores the dragon defeat counter', () {
      final original = SaveData(dragonKills: 5);

      final restored = SaveData.fromJson(original.toJson());

      expect(restored.dragonKills, 5);
    });
  });
}
