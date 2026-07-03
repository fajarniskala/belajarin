import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart'; // Sesuaikan path ini dengan folder kamu

// ==========================================
// 1. MODEL
// ==========================================
class AchievementModel {
  final int id;
  final String title;
  final String description;
  final int point;
  final String icon;
  final bool unlocked;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.point,
    required this.icon,
    required this.unlocked,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    String dbIcon = json['icon']?.toString().toLowerCase() ?? '';
    String emojiIcon = "🏆"; 
    
    if (dbIcon.contains('book')) emojiIcon = "🏅";
    else if (dbIcon.contains('worm')) emojiIcon = "🐛";
    else if (dbIcon.contains('streak')) emojiIcon = "⭐";
    else if (dbIcon.contains('flash')) emojiIcon = "⚡";
    else if (dbIcon.contains('explore')) emojiIcon = "🗺️";
    else if (dbIcon.contains('star')) emojiIcon = "🌟";
    else if (dbIcon.contains('flame')) emojiIcon = "🔥";

    return AchievementModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? 'Pencapaian',
      description: json['description'] ?? '',
      point: int.tryParse(json['points_reward']?.toString() ?? '0') ?? 0,
      icon: emojiIcon,
      unlocked: json['unlocked'].toString() == '1' || json['unlocked'] == true,
    );
  }
}

// ==========================================
// 2. CONTROLLER (LOGIKA PERHITUNGAN)
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
// 3. CARD WIDGET
// ==========================================
class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback? onTap;

  const AchievementCard({super.key, required this.achievement, this.onTap}); // ✅ Sudah diperbaiki di sini

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
// 4. PAGE WIDGET (SCREEN)
// ==========================================
class AchievementScreen extends StatefulWidget {
  final int studentId;

  const AchievementScreen({super.key, required this.studentId});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  List<AchievementModel> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAchievements();
  }

  Future<void> _fetchAchievements() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl_siswa}/siswa/achievements/${widget.studentId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        if (mounted) {
          setState(() {
            _achievements = data.map((json) => AchievementModel.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Error fetching achievements: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalBadge = AchievementController.totalBadge(_achievements);
    final totalPoint = AchievementController.totalPoint(_achievements);

    return Scaffold(
      backgroundColor: const Color(0xffF6F1EB),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4D13D),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.brown),
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
                  _isLoading 
                    ? "Menghitung koleksimu..." 
                    : "$totalBadge badge diraih • $totalPoint total poin",
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          _isLoading
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xffFF9F1C)),
                  ),
                )
              : Expanded(
                  child: _achievements.isEmpty 
                    ? const Center(child: Text("Belum ada data badge", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _achievements.length,
                        itemBuilder: (_, index) {
                          return AchievementCard(
                            achievement: _achievements[index],
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Kamu meraih: ${_achievements[index].title}!"),
                                  backgroundColor: Colors.orange,
                                ),
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