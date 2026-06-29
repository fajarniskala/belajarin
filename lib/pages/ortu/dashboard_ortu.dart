import 'package:flutter/material.dart';
import 'halaman_riwayat.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardOrtuScreen(),
    ),
  );
}

class DashboardOrtuScreen extends StatefulWidget {
  const DashboardOrtuScreen({super.key});

  @override
  State<DashboardOrtuScreen> createState() => _DashboardOrtuScreenState();
}

class _DashboardOrtuScreenState extends State<DashboardOrtuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[50], // Latar belakang halaman krem/putih lembut
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== KARTU UTAMA UTK DASHBOARD (KODEMU) ====================
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  // height statis dihapus agar konten GridView di dalamnya fleksibel & tidak overflow
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade300,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Halo, Bu Sari 👋",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight
                                        .w800, // Diperbaiki dari FontWeight(800)
                                  ),
                                ),
                                Text(
                                  "Pantau aktivitas belajar Andi",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(
                                      0.8,
                                    ), // Diperbaiki agar lebih terbaca
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Colors.white,
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                  style: BorderStyle.solid,
                                  width: 3,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "S",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisExtent: 80,
                          children: const [
                            CardContainer(
                              icons: Icons.book,
                              jumlah: "5",
                              judul: "Buku Selesai",
                            ),
                            CardContainer(
                              icons: Icons.menu_book,
                              jumlah: "2",
                              judul: "Sedang Dibaca",
                            ),
                            CardContainer(
                              icons: Icons.access_time,
                              jumlah: "3 jam",
                              judul: "Total Durasi",
                            ),
                            CardContainer(
                              icons: Icons.star,
                              jumlah: "12",
                              judul: "Poin Anak",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==================== HALAMAN RIWAYAT MEMBACA (DARI GAMBAR) ====================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Bagian: Sedang Dibaca ---
                    const SectionHeader(
                      icon: Icons.menu_book_rounded,
                      title: "Sedang Dibaca Andi",
                      iconColor: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    const ReadingBookCard(),

                    const SizedBox(height: 25),

                    // --- Bagian: Sudah Selesai ---
                    const SectionHeader(
                      icon: Icons.check_circle,
                      title: "Sudah Selesai",
                      iconColor: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    const CompletedBookCard(),

                    const SizedBox(height: 25),

                    // --- Bagian: Tombol Aksi ---
                    Row(
                      children: [
                        Expanded(
                          child: ActionButton(
                            color: Colors.blue[400]!,
                            icon: Icons.cloud_upload_rounded,
                            text: "Upload Buku",
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ActionButton(
                            color: const Color(0xFFBC8FFD),
                            icon: Icons.bar_chart_rounded,
                            text: "Lihat Riwayat",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HalamanRiwayat(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== WIDGET PENDUKUNG ====================

// Widget Grid milikmu yang sudah diperbaiki
class CardContainer extends StatelessWidget {
  final IconData icons;
  final String jumlah;
  final String judul;
  const CardContainer({
    super.key,
    required this.icons,
    required this.jumlah,
    required this.judul,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              jumlah,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icons, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  judul,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Judul Section (Sedang Dibaca / Sudah Selesai)
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }
}

// Widget Kartu Buku Sedang Dibaca
class ReadingBookCard extends StatelessWidget {
  const ReadingBookCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107), // Warna Oranye Singa
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text("🦁", style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Si Kancil dan Buaya",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Terakhir baca: Hari ini, 14:30",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.3,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Hal. 24 dari 80 • 30% • 45 menit baca",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Kartu Buku Sudah Selesai
class CompletedBookCard extends StatelessWidget {
  const CompletedBookCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4), // Warna Biru Ikan
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text("🐟", style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dunia Bawah Laut",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Selesai: Kemarin, 16:00",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 1.0,
              minHeight: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.check_box, color: Colors.green, size: 18),
              SizedBox(width: 6),
              Text(
                "Selesai • 1 jam 50 menit baca",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget Tombol Aksi di bagian bawah (Upload & Riwayat)
class ActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.color,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
