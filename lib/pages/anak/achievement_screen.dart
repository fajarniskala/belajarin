import 'package:flutter/material.dart';

// ==========================================
// 1. MODEL
// ==========================================
class AchievementModel {
  final String title;
  final String description;
  final int point;
  final String icon;
  final bool unlocked;

  AchievementModel({
    required this.title,
    required this.description,
    required this.point,
    required this.icon,
    required this.unlocked,
  });
}

// ==========================================
// 2. RULES
// ==========================================
class AchievementRule {
  static const int firstReaderPoint = 100;
  static const int diligentReaderPoint = 150;
  static const int bookWormPoint = 300;
  static const int speedReaderPoint = 120;
  static const int explorerPoint = 80;

  static int calculateTotalPoint(List<int> points) {
    return points.fold(0, (sum, item) => sum + item);
  }
}

// ==========================================
// 3. CONTROLLER
// ==========================================
class AchievementController {
  static int totalPoint(List<AchievementModel> achievements) {
    return achievements
        .where((a) => a.unlocked)
        .fold(0, (sum, a) => sum + a.point);
  }

  static int totalBadge(List<AchievementModel> achievements) {
    return achievements.where((a) => a.unlocked).length;
  }
}

// ==========================================
// 4. CARD WIDGET
// ==========================================
class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback? onTap;

  const AchievementCard({super.key, required this.achievement, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool unlocked = achievement.unlocked;

    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: unlocked ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: unlocked ? Colors.amber.shade50 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 42),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: unlocked ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 18,
                      color: unlocked ? Colors.black54 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    unlocked
                        ? "+${achievement.point} poin ✅ Diraih!"
                        : "+${achievement.point} poin 🔒 Terkunci",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: unlocked ? Colors.orange : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. PAGE WIDGET (SCREEN)
// ==========================================
class AchievementScreen extends StatelessWidget {
  AchievementScreen({super.key});

  final List<AchievementModel> achievements = [
    AchievementModel(
      title: "Calon Ilmuwan",
      description: "Selesaikan 1 e-book pertama kali",
      point: 100,
      icon: "🏅",
      unlocked: true,
    ),
    AchievementModel(
      title: "Rajin Membaca",
      description: "Baca e-book 7 hari berturut-turut",
      point: 150,
      icon: "⭐",
      unlocked: true,
    ),
    AchievementModel(
      title: "Seperti Detektif",
      description: "Selesaikan 5 e-book",
      point: 300,
      icon: "🐛",
      unlocked: false,
    ),
    AchievementModel(
      title: "Blitzkrieg",
      description: "Selesaikan 1 buku dalam 1 hari",
      point: 120,
      icon: "⚡",
      unlocked: false,
    ),
    AchievementModel(
      title: "Jendela Dunia",
      description: "Buka lebih dari 50 halaman berbeda",
      point: 80,
      icon: "🗺️",
      unlocked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalBadge = AchievementController.totalBadge(achievements);
    final totalPoint = AchievementController.totalPoint(achievements);

    return Scaffold(
      backgroundColor: const Color(0xffF6F1EB),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4D13D),
        centerTitle: true,
        title: const Text(
          "BADGE & ACHIEVEMENT",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffFF9F1C), Color(0xffFF6B6B)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "🏆 Koleksi Badgeku",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$totalBadge badge diraih • $totalPoint total poin",
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: achievements.length,
              itemBuilder: (_, index) {
                return AchievementCard(
                  achievement: achievements[index],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(achievements[index].title)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
