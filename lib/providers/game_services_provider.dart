import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:games_services/games_services.dart';

class GameServicesManager {
  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;

  Future<void> signIn() async {
    try {
      final result = await GamesServices.signIn();
      _isSignedIn = result != null;
    } catch (e) {
      _isSignedIn = false;
    }
  }

  Future<void> submitScore(String leaderboardId, int score) async {
    if (!_isSignedIn) return;
    await GamesServices.submitScore(
      score: Score(
        androidLeaderboardID: leaderboardId,
        iOSLeaderboardID: leaderboardId,
        value: score,
      ),
    );
  }

  Future<void> unlockAchievement(String achievementId) async {
    if (!_isSignedIn) return;
    await GamesServices.unlock(
      achievement: Achievement(
        androidID: achievementId,
        iOSID: achievementId,
      ),
    );
  }
}

final gameServicesProvider = Provider<GameServicesManager>((ref) {
  return GameServicesManager();
});