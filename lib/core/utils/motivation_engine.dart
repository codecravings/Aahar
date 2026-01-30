import 'dart:math';
import '../constants/app_constants.dart';
import '../../features/dashboard/domain/entities/daily_stats.dart';
import '../../features/streaks/domain/entities/streak.dart';

/// Hinglish motivation message engine
class MotivationEngine {
  static final _random = Random();

  /// Evaluate daily stats and return appropriate motivation
  static MotivationMessage evaluateDay({
    required DailyStats stats,
    required UserStreak streak,
  }) {
    final states = _determineStates(stats, streak);

    if (states.isEmpty) {
      return _getRandomMessage(_neutralMessages);
    }

    // Priority order for messages
    if (states.contains(PerformanceState.perfectDay)) {
      return _getRandomMessage(_perfectDayMessages);
    }
    if (states.contains(PerformanceState.streakBroken)) {
      return _getRandomMessage(_streakBrokenMessages);
    }
    if (states.contains(PerformanceState.milestone)) {
      return _getMilestoneMessage(streak);
    }
    if (states.contains(PerformanceState.proteinLow)) {
      return _getRandomMessage(_proteinLowMessages);
    }
    if (states.contains(PerformanceState.caloriesHigh)) {
      return _getRandomMessage(_caloriesHighMessages);
    }
    if (states.contains(PerformanceState.caloriesLow)) {
      return _getRandomMessage(_caloriesLowMessages);
    }
    if (states.contains(PerformanceState.streakActive)) {
      return _getStreakMessage(streak);
    }

    return _getRandomMessage(_neutralMessages);
  }

  /// Determine all applicable performance states
  static List<PerformanceState> _determineStates(
    DailyStats stats,
    UserStreak streak,
  ) {
    final states = <PerformanceState>[];

    // Check perfect day
    if (stats.isPerfectDay && stats.hasLogs) {
      states.add(PerformanceState.perfectDay);
    }

    // Check protein
    if (stats.hasLogs && stats.protein < (stats.proteinTarget * 0.7)) {
      states.add(PerformanceState.proteinLow);
    } else if (stats.protein > stats.proteinTarget * 1.2) {
      states.add(PerformanceState.proteinHigh);
    }

    // Check calories
    if (stats.hasLogs && stats.calories > stats.calorieTarget * 1.15) {
      states.add(PerformanceState.caloriesHigh);
    } else if (stats.hasLogs && stats.calories < stats.calorieTarget * 0.6) {
      states.add(PerformanceState.caloriesLow);
    } else if (stats.hasLogs &&
        stats.calories >= stats.calorieTarget * 0.9 &&
        stats.calories <= stats.calorieTarget * 1.1) {
      states.add(PerformanceState.caloriesPerfect);
    }

    // Check streak
    if (!streak.isStreakActive && streak.longestStreak > 3) {
      states.add(PerformanceState.streakBroken);
    } else if (streak.currentStreak >= 3) {
      states.add(PerformanceState.streakActive);
    }

    // Check milestones
    if (streak.currentStreak == 7 ||
        streak.currentStreak == 30 ||
        streak.currentStreak == 100 ||
        streak.totalLogs == 50 ||
        streak.totalLogs == 100 ||
        streak.totalLogs == 500) {
      states.add(PerformanceState.milestone);
    }

    return states;
  }

  static MotivationMessage _getRandomMessage(List<MotivationMessage> messages) {
    return messages[_random.nextInt(messages.length)];
  }

  static MotivationMessage _getStreakMessage(UserStreak streak) {
    if (streak.currentStreak >= 30) {
      return MotivationMessage(
        text: '${streak.currentStreak} din ki streak! Tu legend hai bhai 👑',
        type: MessageType.celebration,
      );
    } else if (streak.currentStreak >= 7) {
      return MotivationMessage(
        text: '${streak.currentStreak} days straight! Discipline level: BEAST 🔥',
        type: MessageType.praise,
      );
    } else {
      return MotivationMessage(
        text: '${streak.currentStreak} din streak chal rahi hai, keep going! 💪',
        type: MessageType.encouragement,
      );
    }
  }

  static MotivationMessage _getMilestoneMessage(UserStreak streak) {
    if (streak.currentStreak == 100) {
      return const MotivationMessage(
        text: '💯 CENTURY! 100 din non-stop. Tu insaan nahi machine hai!',
        type: MessageType.celebration,
      );
    } else if (streak.currentStreak == 30) {
      return const MotivationMessage(
        text: '🏆 EK MAHINA! 30 days done. Ziddi banda confirmed.',
        type: MessageType.celebration,
      );
    } else if (streak.currentStreak == 7) {
      return const MotivationMessage(
        text: '📅 WEEK COMPLETE! 7 din streak. Ab toh habit ban gayi!',
        type: MessageType.celebration,
      );
    } else if (streak.totalLogs == 500) {
      return const MotivationMessage(
        text: '🎯 500 LOGS! Bhai tu serious hai nutrition ke baare mein!',
        type: MessageType.celebration,
      );
    } else if (streak.totalLogs == 100) {
      return const MotivationMessage(
        text: '💫 100 meals logged! Consistency king 👑',
        type: MessageType.celebration,
      );
    }

    return _getRandomMessage(_neutralMessages);
  }

  // Message collections
  static const List<MotivationMessage> _proteinLowMessages = [
    MotivationMessage(
      text: 'Protein kam hai bhai 😭 Ande ya paneer add kar!',
      type: MessageType.warning,
    ),
    MotivationMessage(
      text: 'Bro protein deficit mein hai tu. Gains nahi banenge aise!',
      type: MessageType.warning,
    ),
    MotivationMessage(
      text: 'Protein kahan hai? Chicken breast ka time ho gaya 🍗',
      type: MessageType.warning,
    ),
    MotivationMessage(
      text: 'Muscles tere se pooch rahe hain - "Protein kab milega?" 💪',
      type: MessageType.warning,
    ),
    MotivationMessage(
      text: 'Protein low hai boss. Aise toh sirf cardio bunny banega 🐰',
      type: MessageType.warning,
    ),
    MotivationMessage(
      text: 'Dal, eggs, chicken kuch toh khaa le bhai. Protein chahiye!',
      type: MessageType.warning,
    ),
  ];

  static const List<MotivationMessage> _caloriesHighMessages = [
    MotivationMessage(
      text: 'Bhai thoda zyada ho gaya aaj 😬 Kal adjust kar lena!',
      type: MessageType.warning,
    ),
    MotivationMessage(
      text: 'Calories overburst! Cheat day toh nahi tha na? 🤔',
      type: MessageType.warning,
    ),
    MotivationMessage(
      text: 'Surplus mode ON ho gaya. Bulking kar raha hai kya? 😅',
      type: MessageType.warning,
    ),
    MotivationMessage(
      text: 'Target cross ho gaya bhai. Portion control yaad rakh!',
      type: MessageType.warning,
    ),
    MotivationMessage(
      text: 'Calories zyada. Ab toh walk pe jaana padega 🚶',
      type: MessageType.warning,
    ),
  ];

  static const List<MotivationMessage> _caloriesLowMessages = [
    MotivationMessage(
      text: 'Bhai khana khaa le! Aise metabolism slow ho jayega 😰',
      type: MessageType.warning,
    ),
    MotivationMessage(
      text: 'Calories bahut kam. Body starvation mode mein mat daal!',
      type: MessageType.warning,
    ),
    MotivationMessage(
      text: 'Under-eating se bhi nahi hoga. Proper fuel de body ko 🔋',
      type: MessageType.warning,
    ),
    MotivationMessage(
      text: 'Kuch zyada hi diet mode ho gaya. Thoda khaa le yaar!',
      type: MessageType.warning,
    ),
  ];

  static const List<MotivationMessage> _perfectDayMessages = [
    MotivationMessage(
      text: 'PERFECT DAY! All macros hit. Beast mode activated 🔥',
      type: MessageType.celebration,
    ),
    MotivationMessage(
      text: 'Bhai mast! Sab macros perfect. Aaj toh champion hai tu! 🏆',
      type: MessageType.celebration,
    ),
    MotivationMessage(
      text: 'Nutrition game STRONG today! Body building ho rahi hai 💪',
      type: MessageType.celebration,
    ),
    MotivationMessage(
      text: 'Calories ✓ Protein ✓ Discipline ✓ Legend ✓ 👑',
      type: MessageType.celebration,
    ),
    MotivationMessage(
      text: 'Perfect balance aaj! Tera body thanking you right now 🙏',
      type: MessageType.celebration,
    ),
    MotivationMessage(
      text: 'LETHAL precision bhai! All targets SMASHED 💥',
      type: MessageType.celebration,
    ),
  ];

  static const List<MotivationMessage> _streakBrokenMessages = [
    MotivationMessage(
      text: 'Streak toot gayi 😢 But comeback arc shuru!',
      type: MessageType.encouragement,
    ),
    MotivationMessage(
      text: 'Koi nahi bhai, restart karte hain. Aaj se naya streak!',
      type: MessageType.encouragement,
    ),
    MotivationMessage(
      text: 'Streak gone. But tu gira nahi, sirf ruka tha. Chal uth! 💪',
      type: MessageType.encouragement,
    ),
    MotivationMessage(
      text: 'Miss ho gaya ek din. Ab dobara prove kar - tu champion hai!',
      type: MessageType.encouragement,
    ),
    MotivationMessage(
      text: 'Streak break happens. Legends wapas aate hain stronger! 🦁',
      type: MessageType.encouragement,
    ),
  ];

  static const List<MotivationMessage> _neutralMessages = [
    MotivationMessage(
      text: 'Tracking chal rahi hai! Keep logging bro 📝',
      type: MessageType.neutral,
    ),
    MotivationMessage(
      text: 'Data hai toh power hai. Knowledge is gains! 🧠',
      type: MessageType.neutral,
    ),
    MotivationMessage(
      text: 'Consistency > Perfection. Chal raha hai tu achha!',
      type: MessageType.neutral,
    ),
    MotivationMessage(
      text: 'Log kar, track kar, improve kar. Yahi formula hai! 📊',
      type: MessageType.neutral,
    ),
    MotivationMessage(
      text: 'Aaj bhi tracking kar raha hai. Dedication 👊',
      type: MessageType.neutral,
    ),
  ];

  /// Get a greeting based on time of day
  static String getGreeting(String? userName) {
    final hour = DateTime.now().hour;
    final name = userName ?? 'Bhai';

    if (hour < 12) {
      return 'Good morning $name! ☀️';
    } else if (hour < 17) {
      return 'Good afternoon $name! 💪';
    } else if (hour < 21) {
      return 'Good evening $name! 🌙';
    } else {
      return 'Late night grind $name? 🦉';
    }
  }

  /// Get a random motivational tip
  static String getRandomTip() {
    const tips = [
      'Protein har meal mein hona chahiye 🍳',
      'Water intake mat bhoolna! 💧',
      '1g protein per pound bodyweight - golden rule',
      'Sleep bhi important hai gains ke liye 😴',
      'Pre-workout meal 2 hours pehle optimal hai',
      'Fiber intake dekh, digestion important hai',
      'Post-workout anabolic window - 30 mins mein khaa le!',
      'Veggies micronutrients ke liye zaroori hain 🥗',
      'Healthy fats brain ke liye chahiye 🥑',
      'Meal timing matters - consistent rakh!',
    ];

    return tips[_random.nextInt(tips.length)];
  }
}

/// Motivation message with type
class MotivationMessage {
  final String text;
  final MessageType type;

  const MotivationMessage({
    required this.text,
    required this.type,
  });
}

/// Type of motivation message
enum MessageType {
  celebration,
  praise,
  encouragement,
  warning,
  neutral,
}
